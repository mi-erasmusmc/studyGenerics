#' Download zip-compressed Windows binaries from a renv.lock file
#'
#'A function that locates and downloads Windows binaries (.zip) from CRAN based on packages specified in a renv.lock file.
#' @param lockfile_path Path to renv.lock file, if empty will search for renv.lock in project directory
#' @param supplement Nested list of packages to supplement or use in place of a renv.lock file
#'
#' @param override_lock Logical. Default is FALSE. If set to TRUE and the same package is named in both the renv.lock and the supplement, the version called in the supplement will override the renv.lock
#' @param r_rels_vect A character vector of R minor releases
#' @param backupRrel A string of the R minor-release to use if preferred package version cannot be found under any of the minor releases specified in `r_rels_vect`
#' @param outDir Path to output directory for package zips. If left empty, an output directory will be created in project 'renv' directory
#'
#' @return In addition to downloading the specified packages into the outDir, returns a list of packages that were searched for as well as the URLs, versions (if found), etc.
#' @export
#'
#' @examples
#' pkg_status_list <- getPkgZips()
#'
#' # Format supp in this way:
#' devtools <- list(Package = "devtools", Version = "2.5.1")
#' duckdb <- list(Package = "duckdb", Version = "1.5.2")
#' supp <- list(Packages = list(devtools = devtools, duckdb = duckdb))
#'
#' pkg_status_list <- getPkgZips(supplement = supp)
#'
#' @details
#' If the package version is not found under any of the R minor releases, the package will be downloaded from the specified `backupRrel` regardless of package version specified in renv.lock
#' @import renv
#' @import cli
#' @import httr
#' @import here
#' @importFrom stats setNames
#' @importFrom utils download.file
getPkgZips <- function(lockfile_path = NULL, supplement = NULL, override_lock = FALSE, r_rels_vect = c("4.0", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6"), backupRrel = "4.4", outDir = NULL) {

  # If specific lockfile path wasn't provided
  if (is.null(lockfile_path)) {
    lockfile_path <- file.path(here::here(), "renv.lock")
  } else { # if still not found, keep NULL
    NULL
  }

  # If outDir path not specified
  if (is.null(outDir)) {
    outDir <- file.path(here::here(), "renv", "cellar")

    if (!dir.exists(outDir)) { # create the outDir if it doesn't already exist
      dir.create(outDir)
    }
  }

  # If lockfile_path not provided and renv.lock not found in project dir and no supplement provided
  if (is.null(lockfile_path) & is.null(supplement)) {
    stop("Silly goose, you need to specify the packages to be downloaded! Either create a renv.lock in your project directory, provide the path to another lockfile, or create a supplement list of packages and versions. Refer to the manual for list format:)", call. = FALSE)
  }

  # PACKAGES as df in case we need to rely on backupRrel ----
  con <- url(paste0("https://cran.r-project.org/bin/windows/contrib/", backupRrel, "/PACKAGES"))
  open(con)
  avail_packages <- as.data.frame(read.dcf(con))
  close(con)

  # Check which inputs have been provided and construct pkgsVers_list list accordingly ----
  if (!is.null(lockfile_path)) { # either provided lockfile or located renv.lock
    locklist <- renv::lockfile_read(lockfile_path)
  }

  # Combine locklist and supplement into one if both are provided
  if (exists("locklist") & !(is.null(supplement))) {

    # Check for overlap between packages supplied in locklist and supplement, handle accoding to override_lock
    lock_pkgs <- names(locklist$Packages)
    supp_pkgs <- names(supplement$Packages)

    intersect_pkgs <- intersect(lock_pkgs, supp_pkgs)

    if (override_lock == FALSE) {
      supplement[["Packages"]] <- supplement[["Packages"]][
        !(names(supplement[["Packages"]]) %in% intersect_pkgs)
      ]
    } else if (override_lock == TRUE) {
      locklist[["Packages"]] <- locklist[["Packages"]][
        !(names(locklist[["Packages"]]) %in% intersect_pkgs)
      ]
    }

    pkgsVers_list <- locklist # copy locklist

    pkgsVers_list$Packages <- c(pkgsVers_list$Packages, supplement[["Packages"]]) # append the supplement

  } else if (exists("locklist") & is.null(supplement)) {
    pkgsVers_list <- locklist
  } else if (!exists("locklist") & !(is.null(supplement))) {
    pkgsVers_list <- supplement
  }

  # Vector of all package names
  pkg_vector <- names(pkgsVers_list$Packages)

  # Initiate empty list to store requirements/dependencies into
  requirements <- list(Packages = list())

  # Search for specified package dependencies
  for (pkg in pkg_vector) {

    if (!is.null(pkgsVers_list[["Packages"]][[pkg]][["Requirements"]])) { # if a Requirements vector exist (like in a lockfile)

      reqs <- trimws(pkgsVers_list[["Packages"]][[pkg]][["Requirements"]]) # pull vector of requirements

      for (req in reqs) { # for each req

        # Check if it already exists in pkgsVers_list or requirements
        if (is.null(pkgsVers_list[["Packages"]][[req]]) & is.null(requirements[["Packages"]][[req]]) & req != "R") {

          req_list <- list(Package = req, # create a list following same format as the lockfile
                           Version = NULL)

          requirements$Packages <- c(requirements$Packages, setNames(list(req_list), req)) # append to the packages section of pkgsVers_list

        }
      }
    }
  }

  # Update the list, should now include all package, supplemental packages, and specified requirements
  pkgsVers_list$Packages <- c(pkgsVers_list$Packages, requirements[["Packages"]])

  # Set up ----
  pkg_results <- list() # initiate list to store package information (version, URL, R-version, etc.)

  pkg_vector <- names(pkgsVers_list$Packages) # pull vector of all packages from pkgsVers_list, overrides the previous versio used before searching for requirements

  # Searching URLs and downloading ----
  for (pkg in pkg_vector) {
    version <- pkgsVers_list$Packages[[pkg]]$Version # pull package version from pkgsVers_list

    if (!(is.null(version))) { # if a version is specified, then search!
      for (r_rel in sort(r_rels_vect, decreasing = TRUE)) { # try newest R version first
        found <- FALSE # initalize as FALSE
        test_url <- paste0("https://cran.r-project.org/bin/windows/contrib/", r_rel, "/", pkg, "_", version , ".zip")

        if (httr::HEAD(test_url)$status_code == 200) { # status_code = 200 checks for existence of the URL
          found <- TRUE
          url <- test_url

          cli::cli_alert_success(paste0("Found ", pkg, " v", version))
          pkg_list <- list(Package = pkg,
                           Version = version,
                           R_release = r_rel,
                           Status = "found",
                           URL = test_url) # store info here for reference by user

          download.file(url,
                        destfile = paste0(outDir, "/", pkg, "_", version, ".zip"),
                        quiet = FALSE)

          break # exit the inner loop as soon as viable URL is found
        }

      }
    }

    # If package version was not found (or no version specified), then search for the package version associated with supplied alternate R release
    if (!found | is.null(version)) {
      alt_version <- avail_packages$Version[avail_packages$Package == pkg] # pull pkg version associated with backup R release (default v4.4)
      test_url <- paste0("https://cran.r-project.org/bin/windows/contrib/", backupRrel, "/", pkg, "_", alt_version , ".zip")

      if (httr::HEAD(test_url)$status_code == 200) {
        found <- TRUE
        url <- test_url

        if (is.null(version)) {
          version <- "UNSPECIFIED" # override for print message, only used there within this statement
        }

        cli::cli_alert_warning(paste0("ALTERNATE: Found ", pkg, " v", alt_version, " under R v", backupRrel, " as an alternate to ", pkg, " v", version))
        pkg_list <- list(Package = pkg,
                         Version = alt_version,
                         R_release = backupRrel,
                         Status = "alternate-found",
                         URL = test_url)

        download.file(url,
                      destfile = paste0(outDir, "/", pkg, "_", alt_version, ".zip"),
                      quiet = FALSE)

      }

    }

    if (!found) { # if the package isn't found under the alternate version of R
      cli::cli_alert_danger(cat(paste0("PACKAGE NOT FOUND: Unable to find ", pkg, " v", version, " or a suitable alternate version under R v", backupRrel)), "\n")
      pkg_list <- list(Package = pkg,
                       Version = version,
                       R_release = NULL,
                       Status = "not-found",
                       URL = NULL)

    }



    pkg_results <- c(pkg_results, setNames(list(pkg_list), pkg)) # add the package lists to the larger list

  }

  # To stdout ----
  # Alt: could just append to a vector in the loops
  found <- names(pkg_results[sapply(pkg_results, function(x) x$Status == "found")])
  alt_found <- names(pkg_results[sapply(pkg_results, function(x) x$Status == "alternate-found")])
  not_found <- names(pkg_results[sapply(pkg_results, function(x) x$Status == "not-found")])

  cat("Summary for packages listed in", lockfile_path, "\n")
  if (length(unique(found)) > 0) {
    cli::cli_alert_success(paste("Found", length(unique(found)), "of", length(unique(pkg_vector)), "specified package(s)"))
  }

  if (length(unique(found)) > 0 & length(unique(found)) < length(unique(pkg_vector))) {
    cli::cli_alert_warning(paste("Identified alternate for", length(unique(alt_found)), "of", (length(unique(pkg_vector)) - length(unique(found))), "package(s) that were not found"))
  }

  if (length(unique(found)) + length(unique(alt_found)) != length(unique(not_found))) {
    cli::cli_alert_danger(paste0("Unable to find ", length(unique(not_found)), " package(s)"))
  }

  cat("Check the returned list for more details!")

  return(pkg_results)

}

