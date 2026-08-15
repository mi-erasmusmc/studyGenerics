# Test on  getPkgZips(): creation of dir and download of zips from project specific renv.lock ----
test_that("Package zips are actually downloaded to renv/cellar from studyGenerics renv.lock", {
  msgs <- capture_messages(getPkgZips())

  expect_true(dir.exists("renv/cellar")) # the default directory was created

  expect_true(any(grepl("Found 27 of 33 specified package\\(s)", msgs)))
  expect_true(any(grepl("Identified alternate for 1 of 6 package\\(s) that were not found", msgs)))
  expect_true(any(grepl("Unable to find 5 package\\(s)", msgs)))

  n_files <- length(list.files("renv/cellar"))
  n_zips <- length(list.files("renv/cellar", pattern = "\\.zip$"))

  expect_equal(n_files, n_zips) # the dir should only contain zips

  expect_equal(n_zips, 28) # at the time of testing on the project renv.lock, should have 28 zips

  # print(msgs)

})

# Test on lockfile only as input ----
test_that("Message checks - lockfile only", {

  lockfile <- mockLock()
  msgs <- capture_messages(pkg_summary <- getPkgZips(lockfile_path = lockfile))

  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find DarwinShinyModules v0.4.0 or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find utils vUNSPECIFIED or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find methods vUNSPECIFIED or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find tools vUNSPECIFIED or a suitable alternate version under R v4.4", msgs)))

  expect_true(any(grepl("ALTERNATE: Found renv v1.2.2 under R v4.4 as an alternate to renv v1.0.11", msgs)))
  expect_true(any(grepl("Found xfun v0.58", msgs)))
  expect_true(any(grepl("ALTERNATE: Found dplyr v1.2.1 under R v4.4 as an alternate to dplyr vUNSPECIFIED", msgs))) # from Requirements

  expect_true(any(grepl("Found 9 of 53 specified package\\(s)", msgs)))
  expect_true(any(grepl("Identified alternate for 40 of 44 package\\(s) that were not found", msgs)))
  expect_true(any(grepl("Unable to find 4 package\\(s)", msgs)))

  # print(msgs)
})

# Test on  lockfile + supp, override_lock = FALSE ----
test_that("Message checks - lockfile + supp, override_lock = FALSE", {

  msgs <- capture_messages(pkg_summary <- getPkgZips(lockfile_path = lockfile, supplement = supp))

  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find DarwinShinyModules v0.4.0 or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find utils vUNSPECIFIED or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find methods vUNSPECIFIED or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find tools vUNSPECIFIED or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("ALTERNATE: Found renv v1.2.2 under R v4.4 as an alternate to renv v1.0.11", msgs)))
  expect_true(any(grepl("Found xfun v0.58", msgs)))


  expect_true(any(grepl("Found devtools v2.5.2", msgs)))
  expect_true(any(grepl("Found RPostgres v1.4.10 under R v4.4 as an alternate to RPostgres", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find tidyrr v1.3.2 or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("Found dplyr v1.2.1 under R v4.4 as an alternate to dplyr v0.6", msgs))) # from supplement

  expect_true(any(grepl("Found 10 of 56 specified package\\(s)", msgs)))
  expect_true(any(grepl("Identified alternate for 41 of 46 package\\(s) that were not found", msgs)))
  expect_true(any(grepl("Unable to find 5 package\\(s)", msgs)))

  # print(msgs)

})

# Test on  lockfile + supp, override_lock = TRUE ----
test_that("Message checks - lockfile + supp, override_lock = TRUE", {

  lockfile <- mockLock()
  msgs <- capture_messages(pkg_summary <- getPkgZips(lockfile_path = lockfile, supplement = supp, override_lock = TRUE))

  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find DarwinShinyModules v0.4.0 or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find utils vUNSPECIFIED or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find methods vUNSPECIFIED or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find tools vUNSPECIFIED or a suitable alternate version under R v4.4", msgs)))

  # These should be TRUE if override_lock = FALSE, so we expect_false
  expect_false(any(grepl("ALTERNATE: Found renv v1.2.2 under R v4.4 as an alternate to renv v1.0.11", msgs)))
  expect_false(any(grepl("Found xfun v0.58", msgs)))

  # These should be TRUE if override_lock = TRUE
  expect_true(any(grepl("Found renv v1.0.7", msgs)))
  expect_true(any(grepl("ALTERNATE: Found xfun v0.57 under R v4.4 as an alternate to xfun vUNSPECIFIED", msgs)))

  expect_true(any(grepl("Found devtools v2.5.2", msgs)))
  expect_true(any(grepl("Found RPostgres v1.4.10 under R v4.4 as an alternate to RPostgres", msgs)))
  expect_true(any(grepl("PACKAGE NOT FOUND: Unable to find tidyrr v1.3.2 or a suitable alternate version under R v4.4", msgs)))
  expect_true(any(grepl("Found dplyr v1.2.1 under R v4.4 as an alternate to dplyr v0.6", msgs))) # from supplement

  expect_true(any(grepl("Found 10 of 56 specified package\\(s)", msgs)))
  expect_true(any(grepl("Identified alternate for 41 of 46 package\\(s) that were not found", msgs)))
  expect_true(any(grepl("Unable to find 5 package\\(s)", msgs)))

  # print(msgs)

})

test_that("mockLock()", {

  lockfile <- mockLock()
  # Create a supplementary file ----
  supp <- list(
    Packages = list(
      devtools = list(
        Package = "devtools",
        Version = "2.5.2"
      ), # 2.5.2 exists in multiple releases, should pick from the newest (R v4.6)
      dplyr = list(
        Package = "dplyr",
        Version = "0.6"
      ), # there is no 0.6 in any of the releases, should get v1.2.1 as alternate from R v4.4
      tidyrr = list(
        Package = "tidyr",
        Version = "1.3.2"
      ), # tidyrr does not exist
      RPostgres = list(
        Package = "RPostgres",
        Version = NULL
      ), # no version provided, should get v1.4.10 as alternate from R v4.4
      renv = list(
        Package = "renv",
        Version = "1.0.7"
      ), # renv already exists in lockfile, if override_lock = TRUE, should get v1.0.7 from R v4.2
      xfun = list(
        Package = "xfun",
        Version = NULL
      )
    )
  ) # xfun already exists in lockfile, if override_lock = TRUE, should get v0.57 from R v4.4
  # Sanity check of counts ----
  lock <- renv::lockfile_read(lockfile)
  pkgs <- names(lock[["Packages"]])
  supps <- names(supp[["Packages"]])
  reqs <- unique(unlist(lapply(pkgs, function(pkg) {
    lock[["Packages"]][[pkg]]$Requirements
  })))
  reqs <- reqs[reqs != "R"]
  # reqs_wo_overlap <- reqs[!reqs %in% intersect(c(pkgs,supps), reqs)] # reqs that don't already exist in pkgs+supps
  n_pkgs <- length(pkgs)
  n_supps <- length(supps)
  n_reqs <- length(reqs)
  # n_reqs_wo_overlap <- length(reqs_wo_overlap)
  n_all <- length(unique(c(pkgs, supps, reqs)))

  expect_equal(n_pkgs, 11)
  expect_equal(n_supps, 6) # 2 overlap with pkgs in lockfile, don't count unique as we have diff versions
  expect_equal(n_reqs, 46)
  # expect_equal(n_reqs_wo_overlap, 41)
  expect_equal(n_all, 56) # not 58 bc of the supps overlap

})



