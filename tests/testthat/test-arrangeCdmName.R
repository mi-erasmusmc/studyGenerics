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
  arrangeCdmlabels(labels = labels) |>
    expect_equal(labels) |>
    expect_error()

  # Retrieving all labels
  arrangeCdmNames() |>
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
