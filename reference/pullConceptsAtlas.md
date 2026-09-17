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
  patternToRemove = c("p[0-9]{1}_c[0-9]{1}_[0-9]{3}_"),
  authHeader = Sys.getenv("ATLAS_TOKEN")
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

- authHeader:

  Authorization header for the WebAPI. Defaults to
  `Sys.getenv("ATLAS_TOKEN")`. Use `""` for a public WebAPI.

## Value

A tibble with one row per downloaded concept set and the columns
`conceptSetId`, `originalName`, `cleanName`, and `fileName`.

## Details

Requires the optional CRAN packages `httr`, `RJSONIO`, `lubridate`, and
`rlang`. For a protected WebAPI, set `ATLAS_TOKEN` in your local
`.Renviron` file and restart R. The token may include the `Bearer `
prefix. It is sent only to the supplied WebAPI. Do not commit the token
to version control. The internal retrieval helpers are adapted from
OHDSI's `ROhdsiWebApi` under the Apache License 2.0; see
`inst/COPYRIGHTS` in the package source.

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
