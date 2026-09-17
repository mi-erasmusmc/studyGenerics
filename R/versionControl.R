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
#'    title = "An issue title",
#'    body = "Description of issue",
#'    newBranch = FALSE
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
    cli::cli_alert_success(
      "Issue created at:"
    )
    cat(issue_data$html_url, "\n")
    invisible(issue_data$html_url)
  }
  if (isTRUE(issue_created) & isTRUE(newBranch)) {
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
#'    title = "A PR title",
#'    body = "Description of PR",
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
    cli::cli_alert_success(
      "Pull request created at:"
    )
    cat(prData$html_url, "\n")
    invisible(prData$html_url)
  }
}

#' `devCheckout()` checks out the `develop` branch and pulls its latest changes.
#' 
#' @description
#' Checks out the `develop` branch and pulls changes from its remote.
#'
#' @returns Git log messages after checking out and pulling 'develop'
#' @export
#' 
#' @examples
#' \dontrun{
#' # Requires access to the configured Git remote
#' devCheckout(
#' )
#' }
devCheckout <- function() {
  requireInstall("gert")
  branch <- "develop"
  if (gert::git_branch_exists(branch)) {
    gert::git_branch_checkout(
      branch = "develop",
      force = FALSE,
      orphan = FALSE,
      repo = "."
    )
    gert::git_pull()
  }
}
