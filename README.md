
<!-- README.md is generated from README.Rmd. Please edit that file -->

# studyGenerics

<!-- badges: start -->

[![R-CMD-check](https://github.com/mi-erasmusmc/StudyToolBelt/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mi-erasmusmc/StudyToolBelt/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Code should be readable, and it is the main means of communication for
software developers. The objective of `studyGenerics()` is to centralise
common functions (including functions considered trivial!) used in
epidemiological analyses performed at the Erasmus MC Department of
Medical Informatics.

More than trying to ‘standardise’ how to write a study package, we use
this project to save (and, more importantly, test) frequently used
functions that make our life easier.

The intention is to break our own silos and learn how to better
communicate our ideas and best practices, so we can work more
effectively as a team on common ground. Please feel free to contribute.

## Installation

You can install the development version of studyGenerics from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("mi-erasmusmc/studyGenerics")
```

### Sharing the same structure

For instance, we have a function that creates the specific structure we
need for a study.

``` r
studyGenerics::insertStructure(
    path = ".",
    n_obj = 3
  ) 
```

The file structure of the package will contain most of the elements that
we use more frequently.

    |-studyPackage
      |-R/
        |-createCohorts.R
        |-runStudy.R
        |-objective1.R
        |-objective2.R
        |-objective3.R
        ...
      |-inst/
        |-concept_set/
        |-cohorts/
      |-LICENSE
      |-README.rmd
      |-extras/
        |-CodeToRun.R
        |-pullFromATLAS.R
        |-shiny/
      |-tests/
      |-renv/

### Unifying approaches

Even in the same development team, people may prefer different tools for
routine tasks (such as logging or even saving zip files). Here we try to
find common ground, test functions, and avoid unnecessary bugs from
small and less complicated methods, from asserting data partner names to
making sure we are zipping results to the correct folder.

``` r
studyGenerics::arrangeCdmNames(
  labels
  )

studyGenerics::createResultsDir(
   outputDir,
   dbname
)

studyGenerics::zipStudyFiles(
  resultsDirName,
  outputDir,
  dbname)

studyGenerics::unZipStudyFiles(
  path,
  pattern,
  negate,
  recursive,
  outputDir
  )
```

### Smoother processes

Furthermore, in `studyGenerics()` we also develop functions that make
our life easier, such as saving an R virtual environment in a cellar on
macOS and later using that folder to `renv::restore()` on a Windows
machine without internet access.

``` r

studyGenerics::getPkgZips(
  lockfile_path, 
  supplement, 
  override_lock,
  r_rels_vect,
  backupRrel,
  outDir
  ) 
```
