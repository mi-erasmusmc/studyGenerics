test_that("devCheckout reports completion and forwards verbose to Git", {
  pull_options <- NULL
  testthat::local_mocked_bindings(
    git_branch_exists = function(...) TRUE,
    git_branch_checkout = function(...) "/tmp/repo",
    git_pull = function(...) {
      pull_options <<- list(...)
      "/tmp/repo"
    },
    .package = "gert"
  )

  expect_message(
    quiet_result <- withVisible(devCheckout()),
    "Checked out and updated develop."
  )
  expect_false(quiet_result$visible)
  expect_identical(quiet_result$value, "/tmp/repo")
  expect_identical(pull_options$verbose, FALSE)

  expect_message(
    verbose_result <- withVisible(devCheckout(verbose = TRUE)),
    "Checked out and updated develop."
  )
  expect_false(verbose_result$visible)
  expect_identical(verbose_result$value, "/tmp/repo")
  expect_identical(pull_options$verbose, TRUE)
})
