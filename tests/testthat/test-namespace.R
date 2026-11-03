test_that("renv is not imported into the namespace (#181)", {
  expect_false("renv" %in% names(getNamespaceImports("studyGenerics")))
})
