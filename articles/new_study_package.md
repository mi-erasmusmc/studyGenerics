# Inserting a New Package Structure

## Create an empty project

First, create a new empty project for your new study package with the
package use this or from the menu in RStudio (Menu \> File \> New
Project). The package will open a new instance of Positron or Rstudio.

``` r

library(usethis)

usethis::create_package(
  path = "~/P1C1001"
  )
```

## Initiate an environment

Inside the new study package use `renv` to initialise a new environment
to start installing packages and install `studyGenerics`

``` r

library(renv)

renv::init()

renv::install("mi-erasmusmc/studyGenerics")
```

## Insert the structure

Finally, use the function
[`studyGenerics::insertStructure`](https://mi-erasmusmc.github.io/studyGenerics/reference/insertStructure.md)
to create a common configuration of packages and files to start
developing a study package. You can use the parameter `n_obj` to define
the number of objectives in your study. This will create a file to write
a script for each objective in the /R folder.

``` r

library(studyGenerics)

studyGenerics::insertStructure(
  path = ".", # Default to create the study structure in the package you are currently in
  n_obj = 3 # Default 3, in number.
)
```
