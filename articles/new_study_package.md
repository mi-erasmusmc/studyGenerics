# Create a Study Package

Use
[`insertStructure()`](https://mi-erasmusmc.github.io/studyGenerics/reference/insertStructure.md)
to set up a new OMOP study package with common folders, starter scripts,
tests, and package dependencies.

## Before you start

Create an empty R package and make sure you have internet access. The
setup installs the standard study-package dependencies.

## 1. Create an empty package

Create a package with `usethis`, or use **File \> New Project** in
RStudio.

``` r

usethis::create_package(
  path = "~/P1C1001"
)
```

## 2. Initialize the environment

Inside the new package, initialize `renv` and install `studyGenerics`.

``` r

renv::init()

renv::install("mi-erasmusmc/studyGenerics")
```

## 3. Insert the study structure

Run
[`insertStructure()`](https://mi-erasmusmc.github.io/studyGenerics/reference/insertStructure.md)
from the package directory. `n_obj` sets the number of objective scripts
to create.

``` r

studyGenerics::insertStructure(
  path = ".",
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

## 4. Next steps

Add concept sets to `inst/concept_sets/`, develop the study code in
`R/`, then generate documentation with `devtools::document()` and check
the package with `devtools::check()`.
