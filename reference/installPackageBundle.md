# Install default package bundle

Installs a predefined set of DARWIN EU®/OHDSI packages into the study
project and updates their dependencies. The standard package list
includes the packages omopgenerics, PhenotypeR, DrugExposureDiagnostics,
CohortConstructor, IncidencePrevalence, DrugUtilisation,
CohortCharacteristics, CohortSurvival, visOmopResults and
DarwinShinyModules.

## Usage

``` r
installPackageBundle(path)
```

## Arguments

- path:

  A valid path to the study project in character.

## Value

An invisible list of the installed packages.
