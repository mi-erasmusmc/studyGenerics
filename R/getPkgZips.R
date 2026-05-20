#' Download zip-compressed Windows binaries from a renv.lock file
#'
#'A function that locates and downloads Windows binaries (.zip) from CRAN based on packages specified in a renv.lock file.
#' @param lockfile_path Path to renv.lock file
#' @param r_rels_vect A character vector of R minor releases
#' @param backupRrel A string of the R minor-release to use if preferred package version cannot be found under any of the minor releases specified in `r_rels_vect`
#' @param cellarDir Path to renv-cellar
#'
#' @return Returns a list of packages that were searched for as well as the URLs, versions (if found), etc.
#' @export
#'
#' @examples
#' \dontrun{
#' pkg_status_list <- getPkgZips(lockfile_path = "path/to/renv.lock", r_rels_vect = c("4.3", "4.4", "4.5", "4.6"), backupRrel = "4.5", cellarDir = "path/to/renv-cellar")
#' }
#'
#' @details
#' In the case that the package version is not found under any of the R minor releases, the package will be downloaded from the specified `backupRrel` regardless of package version specified in renv.lock
#' @import renv
#' @import cli
#' @import httr
#' @importFrom stats setNames
#' @importFrom utils download.file

getPkgZips <- function(lockfile_path, r_rels_vect = c("4.0", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6"), backupRrel = "4.4", cellarDir) {

  # PACKAGES as df in case we need to rely on backupRrel
  con <- url(paste0("https://cran.r-project.org/bin/windows/contrib/", backupRrel, "/PACKAGES"))
  open(con)
  avail_packages <- as.data.frame(read.dcf(con))
  close(con)

  pkg_results <- list() # initiate list to store package information (version, URL, R-version, etc.)

  locklist <- renv::lockfile_read(lockfile_path) # read renv.lock into a list

  pkg_vector <- names(locklist$Packages) # pull vector of all packages from locklist

  for (pkg in pkg_vector) {
    version <- locklist$Packages[[pkg]]$Version # pull package version from locklist

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
                      destfile = paste0(cellarDir, "/", pkg, "_", version, ".zip"),
                      quiet = FALSE)

        break # exit the inner loop as soon as viable URL is found
      }

    }
    # If package version was not found, then search for the package version associated with supplied alternate R release
    if (!found) {
      alt_version <- avail_packages$Version[avail_packages$Package == pkg] # pull pkg version associated with backup R release (default v4.4)
      test_url <- paste0("https://cran.r-project.org/bin/windows/contrib/", backupRrel, "/", pkg, "_", alt_version , ".zip")

      if (httr::HEAD(test_url)$status_code == 200) {
        found <- TRUE
        url <- test_url

        cli::cli_alert_warning(paste0("ALTERNATE: Found ", pkg, " v", alt_version, " under R v", backupRrel, " as an alternate to ", pkg, " v", version))
        pkg_list <- list(Package = pkg,
                         Version = alt_version,
                         R_release = backupRrel,
                         Status = "alternate-found",
                         URL = test_url)

        download.file(url,
                      destfile = paste0(cellarDir, "/", pkg, "_", alt_version, ".zip"),
                      quiet = FALSE)

      }

    }

    if (!found) { # if the package isn't found under the alternate version of R
      cli::cli_alert_danger(paste0("PACKAGE NOT FOUND: Unable to find ", pkg, " v", version, " or a suitable alternate version under R v", version))
      pkg_list <- list(Package = pkg,
                       Version = version,
                       R_release = NULL,
                       Status = "not-found",
                       URL = NULL)

    }



    pkg_results <- c(pkg_results, setNames(list(pkg_list), pkg)) # add the package lists to the larger list

  }

  # Alt: could just append to a vector in the loops
  found <- names(pkg_results[sapply(pkg_results, function(x) x$Status == "found")])
  alt_found <- names(pkg_results[sapply(pkg_results, function(x) x$Status == "alternate-found")])
  not_found <- names(pkg_results[sapply(pkg_results, function(x) x$Status == "not-found")])

  cat("Summary for packages listed in", lockfile_path, "\n")
  if (length(unique(found)) > 0) {
    cli::cli_alert_success(paste("Found", length(unique(found)), "of", length(unique(pkg_vector)), "package(s)"))
  }

  if (length(unique(found)) > 0 & length(unique(found)) < length(unique(pkg_vector))) {
    cli::cli_alert_warning(paste("Found alternates for", length(unique(alt_found)), "of", length(unique(pkg_vector)), "package(s)"))
  }

  if (length(unique(found)) + length(unique(alt_found)) != length(unique(not_found))) {
    cli::cli_alert_danger(paste0("Unable to find ", length(unique(not_found)), " package(s)"))
  }

  cat("Check the returned list for more details!")

  return(pkg_results)

}
