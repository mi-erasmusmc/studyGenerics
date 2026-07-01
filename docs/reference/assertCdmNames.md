# \`assertCdmNames()\` verifies if data partner's names are correct and display an error if incorrect

\`assertCdmNames()\` verifies if data partner's names are correct and
display an error if incorrect

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

Invisible if labels are correct

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
