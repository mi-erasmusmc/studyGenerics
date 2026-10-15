# Create a Study Package

Use
[`insertStructure()`](https://mi-erasmusmc.github.io/studyGenerics/reference/insertStructure.md)
to set up a new OMOP study package with common folders, starter scripts,
tests, and package dependencies.

## Create the study package

Choose a new, empty directory and supply it explicitly. The example uses
a temporary directory so it does not write to the current working
directory or a home directory. Make sure you have internet access
because the setup installs the standard study-package dependencies.
`n_obj` sets the number of objective scripts to create.

``` r

study_path <- file.path(tempdir(), "P1-C1-001")
dir.create(study_path)

studyGenerics::insertStructure(
  studyName = "P1-C1-001",
  path = study_path,
  n_obj = 3
)
```

The package will include:

    studyPackage/
    ├── R/
    │   ├── createCohorts.R
    │   ├── runStudy.R
    │   ├── runDiagnostics.R
    │   ├── utils.R
    │   ├── globals.R
    │   ├── merge.R
    │   └── objective1.R, ..., objective<n_obj>.R
    ├── inst/
    │   ├── cohorts/
    │   └── concept_sets/
    ├── extras/
    │   ├── CodeToRun.R
    │   └── pullConceptSetsFromAtlas.R
    ├── man/
    ├── tests/
    │   └── testthat/test-*.R
    ├── LICENSE.md
    ├── NEWS.md
    └── README.Rmd

## Next steps

Add concept sets to `inst/concept_sets/`, develop the study code in
`R/`, then generate documentation with `devtools::document()` and check
the package with `devtools::check()`.
