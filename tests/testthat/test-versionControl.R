test_that("devCheckout reports completion only when verbose", {
  testthat::local_mocked_bindings(
    git_branch_exists = function(...) TRUE,
    git_branch_checkout = function(...) "/tmp/repo",
    git_pull = function(...) "/tmp/repo",
    .package = "gert"
  )

  quiet_result <- expect_silent(withVisible(devCheckout()))
  expect_false(quiet_result$visible)
  expect_identical(quiet_result$value, "/tmp/repo")

  expect_message(
    verbose_result <- withVisible(devCheckout(verbose = TRUE)),
    "Checked out and updated develop."
  )
  expect_false(verbose_result$visible)
  expect_identical(verbose_result$value, "/tmp/repo")
})
