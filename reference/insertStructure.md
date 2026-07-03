# Set up study structure

Creates the standard structure required for a new OMOP study package. It
includes standard folders, R scripts, test and documentation files and
it installs a default list of DARWIN EU®/OHDSI packages.

## Usage

``` r
insertStructure(path = ".", n_obj = 3)
```

## Arguments

- path:

  Character string identifying the path to the study project, default
  \`"."\`.

- n_obj:

  Number of study objectives, default \`n_obj = 3\`.

## Value

No return value.

## Details

It assumes an active R project has already been created and the \`renv\`
initialized.
