#' `issueOpen()` is a wrapper for gh::gh() to quickly create an issue
#' in the current GitHub repository.
#' 
#' @description
#' Set GITHUB_PAT in .Renviron. It will use the same authentication
#' in the background as with `gh` https://gh.r-lib.org/articles/managing-personal-access-tokens.html
#'
#' @param title A character string giving the issue title.
#' @param body A character string giving the issue body.
#' @param newBranch Logical. Whether to create and check out a branch named
#' after the new issue. Defaults to `FALSE`.
#'
#' @returns URL of the created issue.
#' @importFrom checkmate assertCharacter assertLogical assertTRUE checkClass
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' # It requires GITHUB_PAT
#' issueOpen(
#'    title = "Add study outcome",
#'    body = "Describe the planned change.",
#'    newBranch = TRUE
#' )
#' }
issueOpen <- function(
  title, 
  body,
  newBranch = FALSE
) {
  requireInstall("gh")
  requireInstall("gert")
  checkmate::assertCharacter(
    title,
    len = 1,
    any.missing = FALSE
  )
  title_word_count <- length(
    regmatches(
      title,
      gregexpr(
        "\\S+",
        title,
        perl = TRUE
      ))[[1]])
  checkmate::assertTRUE(title_word_count >= 2)
  checkmate::assertCharacter(body)
  checkmate::assertLogical(newBranch)
  checkmate::assertTRUE(gh::gh_token_exists())
  issue_data <- gh::gh(
    "POST /repos/{owner}/{repo}/issues",
    owner = gh::gh_tree_remote()$username,
    repo = gh::gh_tree_remote()$repo,
    title = title,
    body = body
  )
  issue_created <- checkmate::checkClass(
    issue_data,
    "gh_response"
  )
  if (isTRUE(issue_created)) {
    issue_url <- issue_data$html_url
    if (isTRUE(newBranch)) {
      branch_title <- stringr::word(title, 1, 2) |>
        tolower() |>
        stringr::str_replace_all(
          pattern = " ",
          replacement = "_"
        )
      branch_name <- glue::glue(
        "{issue_data$number}_{branch_title}"
      )
      gert::git_branch_create(
        branch = branch_name,
        ref = gert::git_branch(),
        checkout = TRUE,
        force = FALSE,
        repo = "."
      )
      gert::git_push(
        remote = "origin",
        set_upstream = TRUE
      )
    }
    message("Issue created: ", issue_url)
    return(invisible(issue_url))
  }
}

#' `pullRequest()` is a wrapper for gh::gh() to quickly create a pull request
#' to merge the current branch.
#' 
#' @description
#' Set GITHUB_PAT in .Renviron. It will use the same authentication
#' in the background as with `gh` https://gh.r-lib.org/articles/managing-personal-access-tokens.html
#'
#' @param title A character string giving the pull request title.
#' @param body A character string giving the pull request body.
#' @param base A character string giving the target branch. Defaults to "develop".
#'
#' @returns URL of the created pull request.
#' @importFrom checkmate assertCharacter assertLogical assertTRUE checkClass
#' @export
#' 
#' @examples
#' \dontrun{
#' # It requires GITHUB_PAT
#' pullRequest(
#'    title = "Add study outcome",
#'    body = "Describe the implemented change.",
#'    base = "develop"
#' )
#' }
pullRequest <- function(
  title,
  body,
  base = "develop"
) {
  requireInstall("gh")
  requireInstall("gert")
  checkmate::assertCharacter(
    title,
    len = 1,
    any.missing = FALSE
  )
  title_word_count <- length(
    regmatches(
      title,
      gregexpr(
        "\\S+",
        title,
        perl = TRUE
      ))[[1]])
  checkmate::assertTRUE(title_word_count >= 2)
  checkmate::assertCharacter(body)
  checkmate::assertTRUE(gh::gh_token_exists())
  prData <- gh::gh(
    "POST /repos/{owner}/{repo}/pulls",
    owner = gh::gh_tree_remote()$username,
    repo = gh::gh_tree_remote()$repo,
    head  = gert::git_branch(),
    base  = base,
    title = title,
    body = body
  )
  pr_created <- checkmate::checkClass(
    prData,
    "gh_response"
  )
  if (isTRUE(pr_created)) {
    pr_url <- prData$html_url
    message("Pull request created: ", pr_url)
    return(invisible(pr_url))
  }
}

#' `devCheckout()` checks out the `develop` branch and pulls its latest changes.
#' 
#' @description
#' Checks out the `develop` branch and pulls changes from its remote.
#'
#' @param verbose Logical. Whether to show Git pull progress. Defaults to
#' `FALSE`; a concise completion message is always shown.
#'
#' @returns Invisibly, the result of pulling `develop`.
#' @export
#' 
#' @examples
#' \dontrun{
#' # Requires access to the configured Git remote
#' devCheckout()
#' }
devCheckout <- function(verbose = FALSE) {
  requireInstall("gert")
  checkmate::assertLogical(verbose, len = 1, any.missing = FALSE)
  branch <- "develop"
  if (gert::git_branch_exists(branch)) {
    gert::git_branch_checkout(
      branch = "develop",
      force = FALSE,
      orphan = FALSE,
      repo = "."
    )
    pull_result <- gert::git_pull(verbose = verbose)
    message("Checked out and updated develop.")
    return(invisible(pull_result))
  }
  invisible(NULL)
}
