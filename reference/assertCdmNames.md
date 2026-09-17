# `assertCdmNames()` verifies whether data partner names are valid and displays an error if they are not.

`assertCdmNames()` verifies whether data partner names are valid and
displays an error if they are not.

## Usage

``` r
assertCdmNames(labels, expected)
```

## Arguments

- labels:

  A character vector of data partner acronyms

- expected:

  A character vector of expected data partner acronyms. If omitted, the
  package's built-in CDM names are used.

## Value

Returns invisibly if all labels are valid.

## Examples

``` r
# Assert if acronyms are correct
labels <- c(
  "BCR",
  "IQVIA LPD Belgium",
  "IQVIA US - AmbEMR",
  "IQVIA US - PMTX+"
)
assertCdmNames(labels = labels)
```
