# Download concept sets from ATLAS and save them in the package.

Retrieves each concept set definition from the ATLAS WebAPI, cleans the
concept set name for use as a file name and writes the JSON definition
to `inst/concept_sets/<conceptSetType>/`.

## Usage

``` r
pullConceptsAtlas(
  conceptSetList,
  conceptSetType,
  baseUrl = "https://atlas.darwin-eu.org/WebAPI",
  deletePrevious = TRUE,
  patternToRemove = c("p[0-9]{1}_c[0-9]{1}_[0-9]{3}_")
)
```

## Arguments

- conceptSetList:

  A numeric vector of ATLAS concept set IDs to download.

- conceptSetType:

  A character string used to group the downloaded concept set JSON files
  under `inst/concept_sets/`.

- baseUrl:

  A character string with the base URL of the ATLAS WebAPI.

- deletePrevious:

  A logical value indicating whether to delete existing files in the
  target `<conceptSetType>` folder before downloading the new concept
  sets.

- patternToRemove:

  A vector of regular expressions containing the pattern(s) to be
  removed from the ATLAS concept set names before creating the output
  JSON files.

## Value

A tibble with one row per downloaded concept set and the columns
`conceptSetId`, `originalName`, `cleanName`, and `jsonPath`.

## Examples

``` r

if (FALSE) { # \dontrun{
# Requires a connection to the ATLAS WebAPI
conceptSetList <- c(12345)
conceptSetType <- "example"
pullConceptsAtlas(
   conceptSetList = conceptSetList,
   conceptSetType = conceptSetType,
   baseUrl = "https://atlas.darwin-eu.org/WebAPI",
   deletePrevious = TRUE,
   patternToRemove = c("p[0-9]{1}_c[0-9]{1}_[0-9]{3}_") 
)
} # }
```
