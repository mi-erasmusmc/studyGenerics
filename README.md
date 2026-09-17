
<!-- README.md is generated from README.Rmd. Please edit that file -->

# studyGenerics

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/studyGenerics)](https://CRAN.R-project.org/package=studyGenerics)
[![R-CMD-check](https://github.com/mi-erasmusmc/studyGenerics/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mi-erasmusmc/studyGenerics/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/mi-erasmusmc/studyGenerics/graph/badge.svg)](https://app.codecov.io/gh/mi-erasmusmc/studyGenerics)
<!-- badges: end -->

`studyGenerics` provides small, tested functions for common tasks in
OMOP-CDM study packages developed at the Erasmus MC Department of
Medical Informatics.

## Installation

You can install the development version of studyGenerics from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("mi-erasmusmc/studyGenerics")
```

### Create a study package

Create the standard study-package folders, scripts, tests, and
documentation. Use `n_obj` to set the number of objective scripts.

``` r
studyGenerics::insertStructure(
  path = ".",
  n_obj = 3
)
```

It adds the following files and folders to an existing study package:

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

### Download concept sets from ATLAS

Use `pullConceptsAtlas()` to save ATLAS concept-set definitions in
`inst/concept_sets/<conceptSetType>/`. It requires access to the ATLAS
WebAPI.

``` r
studyGenerics::pullConceptsAtlas(
  conceptSetList = c(12345),
  conceptSetType = "example",
  baseUrl = "https://atlas.darwin-eu.org/WebAPI"
)
```

### Manage study files

Use the shared functions to validate data-partner names and create,
archive, or extract study results.

``` r
studyGenerics::arrangeCdmNames(labels)

studyGenerics::createResultsDir(
  outputDir,
  dbname
)

studyGenerics::zipStudyFiles(
  resultsDirName,
  outputDir,
  dbname
)

studyGenerics::unZipStudyFiles(
  path,
  pattern,
  negate,
  recursive,
  outputDir
)
```

### Updating summarised results

Use `updateColumnValues()` to replace values in a summarised-result
column, for example when preparing clearer cohort labels for
presentation.

``` r
studyGenerics::updateColumnValues(
  summarised_result = summarised_result,
  names_map = c(
    "old_cohort_name" = "Clear cohort name"
  ),
  variable = "group_level"
)
```

### Prepare dependencies for offline installation

Save packages from `renv.lock` to `renv/cellar`, then use that cellar to
restore the environment on a machine without internet access.

``` r
# Save packages in renv/cellar
studyGenerics::packageCellar()

# Restore packages from renv/cellar
studyGenerics::installCellar()
```

### Version control workflow

Configure `GITHUB_PAT` in `.Renviron`, then create an issue and branch,
open a pull request, and return to the latest `develop` branch.

``` r
# Create a GitHub issue and check out a branch named after it
studyGenerics::issueOpen(
  title = "Add study outcome",
  body = "Describe the planned change.",
  newBranch = TRUE
)

# After committing and pushing the branch, create a pull request to develop
studyGenerics::pullRequest(
  title = "Add study outcome",
  body = "Describe the implemented change.",
  base = "develop"
)

# After the pull request is merged, return to the latest develop branch
studyGenerics::devCheckout()
```
