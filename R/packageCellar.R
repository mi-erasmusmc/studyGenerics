#' `packageCellar()` saves files from a renv.lock file into the 'cellar' folder in renv
#'
#' @param lockfile A valid path to a lockfile in character.
#' @param cellarDir A valid path to the cellar in character. If no value is assigned, it will create renv/cellar 
#' @param type A choice in characcter from either "complete" or "github" to download only packages from GH.
#' 
#' @returns Invisible
#'
#' @importFrom checkmate assertFileExists assertDirectoryExists assertChoice assertList
#' @importFrom renv lockfile_validate retrieve paths lockfile_read 
#' @importFrom purrr walk
#' @importFrom usethis proj_set
#' @export
#' @keywords internal
packageCellar <- function(
  lockfile,
  cellarDir,
  type = "complete"
) {
  if (missing(lockfile)) {
    lockfile <- file.path(
      usethis::proj_path(),
      "renv.lock"
    )
  }
  if (missing(cellarDir)) {
    cellarDir <- file.path(
      usethis::proj_path(),
      "renv",
      "cellar"
    )
    if (!dir.exists(cellarDir)) {
      dir.create(
        cellarDir,
        recursive = TRUE
      )
    }
  }
  checkmate::assertFileExists(lockfile)
  renv::lockfile_validate(lockfile = lockfile)
  checkmate::assertDirectoryExists(cellarDir)
  checkmate::assertChoice(type, c("complete", "github"))
  requireInstall("purrr")
  switch(
    type,
    complete = renv::retrieve(
      lockfile = lockfile,
      destdir = cellarDir
    ),
    github = retrieveGithub(
      lockfile = lockfile,
      cellarDir = cellarDir
    )
  )
  return(invisible())
}

retrieveGithub <- function(
  lockfile,
  cellarDir
) {
  checkmate::assertDirectoryExists(cellarDir)
  checkmate::assertFileExists(lockfile)
  packageList(
    lockfile = lockfile,
    type = "github"
  ) |> 
    downloadGithub(
      cellarDir
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
  cellarDir
) {
  checkmate::assertList(packageData)
  checkmate::assertDirectoryExists(cellarDir)
  purrr::walk(
    packageData,
    function(
      DarwinShinyModules,
      cellarDir
    ) {
      packages <- paste(
        DarwinShinyModules$RemoteUsername,
        DarwinShinyModules$RemoteRepo,
        sep = "/"
      )
      renv::retrieve(
        packages = packages,
        destdir = cellarDir
      )
    },
    cellarDir
  )
}

#' `installCellar()` install files already saved in a cellar
#'
#' @param path A valid path to the cellar (generally renv/cellar)
#' @param cellarDir A valid path to the cellar in character. If no value is assigned, it will create renv/cellar 
#' @param type A choice in characcter from either "complete" or "github" to download only packages from GH.
#' 
#' @returns Invisible
#'
#' @importFrom checkmate assertFileExists assertDirectoryExists assertChoice assertList
#' @importFrom renv lockfile_validate retrieve lockfile_read 
#' @importFrom purrr walk
#' @importFrom usethis proj_set
#' @export
#' @keywords internal
installCellar <- function(path) {
  if (missing(path)) {
    path <- file.path(
      usethis::proj_path(),
      "renv",
      "cellar"
    )
  }
  path <- normalizePath(path)
  checkmate::assertDirectoryExists(path)
  package_name <- list.files(
    path
  ) 
  packages <- list.files(
    path,
    full.names = TRUE
  )
  if (length(packages) == 0) {
    cli::cli_abort(
      glue::glue(
        "No packages found in cellar {path}"
      )
    )
  }
  for (i in seq_along(packages)) {
    installed <- tryCatch(
      expr = {
        install.packages(
          pkgs = packages[i],
          repos = NULL,
          type = "source",
          quiet = FALSE
        )
        TRUE
      },
      error = function(e) {
        cli::cli_alert_warning(
          glue::glue(
            "Could not install {package_name[i]} {e$message}"
          )
        )
        FALSE
      }
    )
    if (!installed) {
      next
    }
  }
}