# \`pullRequest()\` is a wrapper for gh::gh() to swiftly ask merging code from the current branch

\`pullRequest()\` is a wrapper for gh::gh() to swiftly ask merging code
from the current branch

## Usage

``` r
pullRequest(title, body, base = "develop")
```

## Arguments

- title:

  of the issue in character

- body:

  of the issue in character

- base:

  The target branch, in character. Defaults to "develop"

## Value

A message with the link of the issue
