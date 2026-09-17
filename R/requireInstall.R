requireInstall <- function(package) {
    if (!requireNamespace(package, quietly = TRUE)) {
    cli::cli_abort(
      glue::glue(
        "'{package}' must be installed to use this function."
      )
    )
  }
  return(invisible())
}