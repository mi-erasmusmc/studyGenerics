# `pullRequest()` is a wrapper for gh::gh() to quickly create a pull request to merge the current branch.

Set GITHUB_PAT in .Renviron. It will use the same authentication in the
background as with `gh`
https://gh.r-lib.org/articles/managing-personal-access-tokens.html

## Usage

``` r
pullRequest(title, body, base = "develop")
```

## Arguments

- title:

  A character string giving the pull request title.

- body:

  A character string giving the pull request body.

- base:

  A character string giving the target branch. Defaults to "develop".

## Value

URL of the created pull request.

## Examples

``` r
if (FALSE) { # \dontrun{
# It requires GITHUB_PAT
pullRequest(
   title = "Add study outcome",
   body = "Describe the implemented change.",
   base = "develop"
)
} # }
```
