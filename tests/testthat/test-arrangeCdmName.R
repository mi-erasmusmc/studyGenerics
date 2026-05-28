test_that("assertCdmNames works", {

  # Filter a group of acryonims
  labels <- c(
    "BCR",
    "IQVIA LPD Belgium",
    "NLHR@UiO:PERINATAL",
    "IQVIA US - AmbEMR",
    "IQVIA US - PMTX+"
  )
  assertCdmNames(labels = labels) |>
    expect_invisible()

  # Error acronim do not match
  labels <- c(
    "BCRX", # Mispelled acronym
    "IQVIA LPD Belgium",
    "NLHR@UiO:PERINATAL",
    "IQVIA US - AmbEMR",
    "IQVIA US - PMTX+"
  )
  assertCdmNames(labels = labels) |>
    expect_error()

  # Retrieving all labels
  expect_error({
    assertCdmNames()
  })
})

test_that("arrangeCdmlabels returns required acronyma in order", {

  # Filter a group of acryonims
  labels <- c(
    "BCR",
    "IQVIA LPD Belgium",
    "NLHR@UiO:PERINATAL",
    "IQVIA US - AmbEMR",
    "IQVIA US - PMTX+"
  )
  arrangeCdmNames(labels = labels) |>
    expect_equal(labels)

  # Error acronim do not match
  labels <- c(
    "BCRX", # Mispelled acronym
    "IQVIA LPD Belgium",
    "NLHR@UiO:PERINATAL",
    "IQVIA US - AmbEMR",
    "IQVIA US - PMTX+"
  )
  arrangeCdmNames(labels = labels) |>
    expect_error()

  expect_error({
    arrangeCdmNames()
  })
})

test_that("cdmNames retrieves all acronyms", {

  cdmNames() |>
    expect_equal(c(
      "BCR",
      "IQVIA LPD Belgium",
      "UZA",
      "NAIS",
      "DK-DHR",
      "EBB",
      "HARMONY Platform",
      "HARMONY-ALL",
      "HARMONY-AML",
      "HARMONY-CML",
      "HARMONY-MM",
      "FinOMOP-ACI Varha",
      "FinOMOP-HUS",
      "FinOMOP-TaUH Pirha",
      "FinOMOP-THL",
      "APHM",
      "CDW Bordeaux",
      "SNDS",
      "InGef RDB",
      "IQVIA DA Germany",
      "UMD",
      "PGH",
      "SUCD",
      "Pedianet",
      "POLIMI",
      "LDH",
      "CRN",
      "NLHR",
      "NLHR@UiO:PERINATAL",
      "EMDB-ULSEDV",
      "EMDB-ULSGE",
      "EMDB-ULSRA",
      "ULSM-RT",
      "BIFAP",
      "H12O",
      "HUVM",
      "IMASIS",
      "PRISIB",
      "SIDIAP", "VID",
      "HI-SPEED",
      "IPCI",
      "NCR",
      "CPRD AURUM",
      "CPRD Aurum Linked",
      "CPRD GOLD",
      "UKBB",
      "IQVIA US - AmbEMR",
      "IQVIA US - PMTX+"
    ))

})


