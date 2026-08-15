#' `issueOpen()` is a wrapper for gh::gh() to swiftly post 
#' in the GitHub repository of the current project
#'
#' @param title of the issue in character
#' @param body of the issue in character
#' @param newBranch Logical. Default TRUE, will open a new
#' branch in GitHub format
#'
#' @returns A message with the link of the issue
#' @importFrom checkmate assertCharacter assertLogical assertTRUE checkClass
#' @importFrom gh gh gh_tree_remote gh_token_exists
#' @importFrom gert git_branch_create git_branch
#' @export
#' @examples
issueOpen <- function(
  title, 
  body,
  newBranch = FALSE
) {
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

#' `pullRequest()` is a wrapper for gh::gh() to swiftly ask merging
#' code from the current branch
#'
#' @param title of the issue in character
#' @param body of the issue in character
#' @param base The target branch, in character. Defaults to "develop"
#'
#' @returns A message with the link of the issue
#' @importFrom checkmate assertCharacter assertLogical assertTRUE checkClass
#' @importFrom gh gh gh_tree_remote gh_token_exists
#' @importFrom gert git_branch_create git_branch
#' @export
#' @examples
pullRequest <- function(
  title,
  body,
  base = "develop"
) {
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

developCheckout <- function() {
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
