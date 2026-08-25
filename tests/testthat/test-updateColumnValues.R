test_that("updateColumnValues updates summarised result correctly", {
  
  # Create mock summarised result
  x <- dplyr::tibble(
    "result_id" = 1L,
    "cdm_name" = "cprd",
    "group_name" = "cohort_name",
    "group_level" = c(
      "acetaminophen",
      "acetaminophen",
      "diclofenac",
      "ibuprofen"
      ),
    "strata_name" = "sex &&& age_group",
    "strata_level" = c(
      "male &&& <40",
      "male &&& >=40",
      "male &&& >=40",
      "male &&& >=40"
      ),
    "variable_name" = "number_subjects",
    "variable_level" = NA_character_,
    "estimate_name" = "count",
    "estimate_type" = "integer",
    "estimate_value" = c("5", "15", "8", "12"),
    "additional_name" = "overall",
    "additional_level" = "overall"
  ) |>
    omopgenerics::newSummarisedResult()
  
  # Define mapping to custom new names
  names_map <- c(
    "acetaminophen" = "Acetamoniphen cohort",
    "diclofenac" ="Diclofenac cohort (outdated)",
    "ibuprofen" = "Ibuprofen cohort"
  )
  
  # Test function
  x <- updateColumnValues(
    summarised_result = x,
    names_map = names_map,
    variable = "group_level"
  )
  
  check_names <- all(x$group_level %in% unname(names_map))
  expect_true(check_names)
  
})
