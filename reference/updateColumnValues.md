# Update values in a summarised result

Updates the character values of specific column(s) in a summarised
result object (e.g., changing cohort names to a more polished version
for Shiny app labels) according to a given name mapping.

## Usage

``` r
updateColumnValues(summarised_result, names_map, variable)
```

## Arguments

- summarised_result:

  The summarised-result object whose values will be updated.

- names_map:

  A named vector containing the mapping between old and new names.

- variable:

  The column name(s) containing the values to be updated in the
  summarised result object.

## Value

The summarised result itself with updated values.

## Examples

``` r
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
#> `result_type`, `package_name`, and `package_version` added to settings.
names_map <- c(
 "acetaminophen" = "Acetaminophen cohort",
 "diclofenac" ="Diclofenac cohort (outdated)",
 "ibuprofen" = "Ibuprofen cohort"
)
x <- updateColumnValues(
 summarised_result = x,
 names_map = names_map,
 variable = "group_level"
)
```
