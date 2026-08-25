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

  The summarised result with values to update.

- names_map:

  A named vector containing the mapping between old and new names.

- variable:

  The column name(s) containing the values to be updated in the
  summarised result object.

## Value

The summarised result itself with updated values.
