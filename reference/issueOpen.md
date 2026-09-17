# `issueOpen()` is a wrapper for gh::gh() to quickly create an issue in the current GitHub repository.

Set GITHUB_PAT in .Renviron. It will use the same authentication in the
background as with `gh`
https://gh.r-lib.org/articles/managing-personal-access-tokens.html

## Usage

``` r
issueOpen(title, body, newBranch = FALSE)
```

## Arguments

- title:

  A character string giving the issue title.

- body:

  A character string giving the issue body.

- newBranch:

  Logical. Whether to create and check out a branch named after the new
  issue. Defaults to `FALSE`.

## Value

URL of the created issue.

## Examples

``` r
if (FALSE) { # \dontrun{
# It requires GITHUB_PAT
issueOpen(
   title = "Add study outcome",
   body = "Describe the planned change.",
   newBranch = TRUE
)
} # }
```
