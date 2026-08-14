# \`arrangeCdmNames()\` verifies if data partner's acronyms are valie and returns a vector ordered by country alphabetical order

\`arrangeCdmNames()\` verifies if data partner's acronyms are valie and
returns a vector ordered by country alphabetical order

## Usage

``` r
arrangeCdmNames(labels)
```

## Arguments

- labels:

  A character vector of data partners acronyms

## Value

A character vector

## Examples

``` r
# Verifies acronyms are valid and sorts them in the correct order
labels <- c(
  "BCR",
  "IQVIA US - PMTX+",
  "IQVIA US - AmbEMR",
  "IQVIA LPD Belgium"
  )
arrangeCdmNames(labels = labels)
#> [1] "BCR"               "IQVIA LPD Belgium" "IQVIA US - AmbEMR"
#> [4] "IQVIA US - PMTX+" 
```
