#' `packageCellar()` saves files from a renv.lock file into the 'cellar' folder in renv
#'
#' @param path Cellar path in character. If missing defaults to 'renv/cellar'.
#' @param project Project path in character. If missing defaults to `usethis::proj_get()`.
#' @param lockfile Lockfile file path in character. If missing defaults to 'renv.lock' at the project base level provided by `usethis::proj_get()`.
#' @param type A choice in characcter from either "complete" or "github" to download only packages from GH.
#' @returns Invisible
#'
#' @importFrom checkmate assertFileExists assertDirectoryExists assertChoice assertList
#' @importFrom renv lockfile_validate retrieve lockfile_read 
#' @importFrom purrr walk
#' @importFrom usethis proj_set
#' @export
#' @keywords internal
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
    path <- file.path(
      project,
      "renv",
      "cellar"
    )
    if (!dir.exists(path)) {
      dir.create(
        path,
        recursive = TRUE
      )
    }
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

#' `installCellar()` install files already saved in a cellar
#'
#' @param path Cellar path in character. If missing defaults to 'renv/cellar'.
#' @param project Project path in character. If missing defaults to `usethis::proj_get()`.
#' @param library Library path in characcter. If missing defauls to 'renv/library'.
#' @param lockfile Lockfile file path in character. If missing defaults to 'renv.lock' at the project base level provided by `usethis::proj_get()`.
#'  
#' @returns Invisible
#'
#' @importFrom checkmate assertFileExists assertDirectoryExists
#' @importFrom usethis proj_set
#' @export
installCellar <- function(
  path,
  project,
  library,
  lockfile
) {
  if (missing(project)) {
    project <- usethis::proj_get()
  }
  if (missing(path)) {
    path <- file.path(
      project,
      "renv",
      "cellar"
    ) |>
      normalizePath()
  }
  checkmate::assertDirectoryExists(path)
  if (missing(library)) {
    library <- file.path(
      project,
      "renv",
      "library"
    ) 
    library |> 
      dir.create(
        recursive = TRUE
      )
    library <- library |> 
      normalizePath()
  }
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
    "renv use of cache set to FALSE"
  )
  renv::settings$use.cache(
    FALSE,
    project = project
  )
  Sys.setenv(RENV_PATHS_ROOT = library)
  Sys.setenv(RENV_PATHS_LIBRARY = library)
  Sys.setenv(RENV_PATHS_LIBRARY_ROOT = library)
  Sys.setenv(RENV_PATHS_LOCKFILE = lockfile)  	 
  renv::restore(
    project = project,
    library = library,
    lockfile = lockfile,
    rebuild = TRUE,
    prompt = FALSE
  )
  return(invisible())
  }