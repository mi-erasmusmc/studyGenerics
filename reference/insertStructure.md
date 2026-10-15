# Set up study structure

Creates the standard structure required for a new OMOP study package. It
includes standard folders, R scripts, test and documentation files and
it installs a default list of DARWIN EU®/OHDSI packages.

## Usage

``` r
insertStructure(studyName, path, n_obj = 3)
```

## Arguments

- studyName:

  Character string identifying the study, for example `"P1-C1-001"`.
  Hyphens and spaces are removed to create the package name.

- path:

  Character string identifying an existing study folder in which the
  package will be created.

- n_obj:

  Number of study objectives, default `n_obj = 3`.

## Value

No return value.

## Examples

``` r
if (FALSE) { # \dontrun{

# Create the package in an existing study folder
study_path <- file.path(tempdir(), "P1-C1-001")
dir.create(study_path)
studyGenerics::insertStructure(
  studyName = "P1-C1-001",
  path = study_path
)

# - Initialize NAMESPACE
devtools::document()

# - Check package is valid
devtools::check()
} # }
```
