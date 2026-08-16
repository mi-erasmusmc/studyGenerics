# \`issueOpen()\` is a wrapper for gh::gh() to swiftly post in the GitHub repository of the current project

\`issueOpen()\` is a wrapper for gh::gh() to swiftly post in the GitHub
repository of the current project

## Usage

``` r
issueOpen(title, body, newBranch = FALSE)
```

## Arguments

- title:

  of the issue in character

- body:

  of the issue in character

- newBranch:

  Logical. Default TRUE, will open a new branch in GitHub format

## Value

A message with the link of the PR
