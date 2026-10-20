#' `packageCellar()` saves files from a renv.lock file into the 'cellar' folder in `renv`
#'
#' @param path Character string giving the cellar path. This must be supplied explicitly.
#' @param project Character string giving the project path. If omitted, defaults to `usethis::proj_get()`.
#' @param lockfile Character string giving the lockfile path. If omitted, defaults to `renv.lock` at the project base level provided by `usethis::proj_get()`.
#' @param type Character string specifying whether to download all packages (`"complete"`) or only packages from GitHub (`"github"`).
#' @returns Invisible
#'
#' @importFrom checkmate assertFileExists assertDirectoryExists assertChoice assertList
#' @importFrom renv lockfile_validate retrieve lockfile_read 
#' @importFrom usethis proj_get
#' @export
#' 
#' @examples
#' 
#' \dontrun{
#' # It will download the tar files for every package in the renv.lock
#' packageCellar(path = file.path(tempdir(), "cellar"))
#' }
packageCellar <- function(
  path,
  project,
  lockfile,
  type = "complete"
) {
  if (missing(project)) {
    project <- usethis::proj_get()
  }
  if (missing(lockfile)) {
    lockfile <- file.path(
      project,
      "renv.lock"
    )
  }
  if (missing(path)) {
    cli::cli_abort("{.arg path} must be supplied explicitly.")
  }
  if (!dir.exists(path)) {
    dir.create(
      path,
      recursive = TRUE
    )
  }
  checkmate::assertFileExists(lockfile)
  renv::lockfile_validate(lockfile = lockfile)
  checkmate::assertDirectoryExists(path)
  checkmate::assertChoice(type, c("complete", "github"))
  requireInstall("purrr")
  switch(
    type,
    complete = renv::retrieve(
      lockfile = lockfile,
      destdir = path
    ),
    github = retrieveGithub(
      lockfile = lockfile,
      path = path
    )
  )
  return(invisible())
}

retrieveGithub <- function(
  lockfile,
  path
) {
  checkmate::assertDirectoryExists(path)
  checkmate::assertFileExists(lockfile)
  packageList(
    lockfile = lockfile,
    type = "github"
  ) |> 
    downloadGithub(
      path
  )
}

packageList <- function(
  lockfile,
  type = "github"
) {
  requireInstall("jsonvalidate")
  is_lockfile <- renv::lockfile_validate(
    lockfile = lockfile
  )
  if (isTRUE(is_lockfile)) {
    lockfile_data <- renv::lockfile_read(
      file = lockfile
    )
    cli::cli_alert_success(
      "{lockfile} read successfully"
    )
  } else {
    cli::cli_abort(
      "{lockfile} is not a valid renv.lock file"
    )
  }
  checkmate::assertChoice(
    type,
    c("github", "complete")
  )
  if (type == "github") {
    return(extractGithubList(lockfile_data$Packages))
  }
}

extractGithubList <- function(lockfile_data) {
  lockfile_data |> 
    lapply(
      FUN = function(x) {
        if (x$Source == "GitHub") {
          if (x$RemoteType == "github") {
            download_data <- list(
              Version = x$Version,
              RemoteRepo = x$RemoteRepo,
              RemoteUsername = x$RemoteUsername,
              RemoteHost = x$RemoteHost,
              Hash = x$Hash,
              Requirements = x$Requirements
            )
            return(download_data)
          }
        }
      }
    ) |> 
  Filter(
    Negate(is.null),
    x = _
  )
}

downloadGithub <- function(
  packageData,
  path
) {
  checkmate::assertList(packageData)
  checkmate::assertDirectoryExists(path)
  purrr::walk(
    packageData,
    function(
      package,
      path
    ) {
      packages <- paste(
        package$RemoteUsername,
        package$RemoteRepo,
        sep = "/"
      )
      renv::retrieve(
        packages = packages,
        destdir = path
      )
    },
    path
  )
}

#' `installCellar()` installs files already saved in a cellar
#'
#' @param path Character string giving the cellar path. This must be supplied explicitly.
#' @param project Character string giving the project path. This must be supplied explicitly.
#' @param library Character string giving the library path. This must be supplied explicitly.
#' @param lockfile Character string giving the lockfile path. If omitted, defaults to `renv.lock` at the base level of `project`.
#'
#' @returns Invisible
#'
#' @importFrom checkmate assertFileExists assertDirectoryExists
#' @export
#'
#' @examples
#'
#' \dontrun{
#' # It will install all packages in the cellar
#' installCellar(
#'   path = file.path(tempdir(), "cellar"),
#'   project = file.path(tempdir(), "project"),
#'   library = file.path(tempdir(), "library")
#' )
#' }
installCellar <- function(
  path,
  project,
  library,
  lockfile
) {
  if (missing(project)) {
    cli::cli_abort("{.arg project} must be supplied explicitly.")
  }
  checkmate::assertDirectoryExists(project)
  if (missing(path)) {
    cli::cli_abort("{.arg path} must be supplied explicitly.")
  }
  checkmate::assertDirectoryExists(path)
  if (missing(library)) {
    cli::cli_abort("{.arg library} must be supplied explicitly.")
  }
  if (!dir.exists(library)) {
    dir.create(library, recursive = TRUE)
  }
  library <- normalizePath(library)
  checkmate::assertDirectoryExists(library)
  if (missing(lockfile)) {
    lockfile <- file.path(
      project,
      "renv.lock"
    ) 
  }
  checkmate::assertFileExists(lockfile)
  packages <- path |> 
    list.files()
  if (length(packages) == 0) {
    cli::cli_abort(
      glue::glue(
        "No packages found in cellar {path}"
      )
    )
  }
  cli::cli_alert_warning(
    "renv cache disabled during installation"
  )
  withr::local_envvar(
    c(
      RENV_CONFIG_CACHE_ENABLED = "FALSE",
      RENV_PATHS_ROOT = library,
      RENV_PATHS_LIBRARY = library,
      RENV_PATHS_LIBRARY_ROOT = library,
      RENV_PATHS_LOCKFILE = lockfile
    )
  )
  renv::restore(
    project = project,
    library = library,
    lockfile = lockfile,
    rebuild = TRUE,
    prompt = FALSE
  )
  return(invisible())
  }
