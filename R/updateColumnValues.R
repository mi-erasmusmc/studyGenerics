#' Update values in a summarised result
#'
#' @description
#' Updates the character values of specific column(s) in a summarised result object
#' (e.g., changing cohort names to a more polished version for Shiny app labels)
#' according to a given name mapping.
#'
#' @param summarised_result The summarised result with values to update.
#' @param names_map A named vector containing the mapping between old and new names.
#' @param variable The column name(s) containing the values to be updated in the
#' summarised result object.
#'
#' @returns The summarised result itself with updated values.
#'
updateColumnValues <- function(
    summarised_result,
    names_map,
    variable
) {
  
  summarised_result[[variable]] <- dplyr::recode(
    summarised_result[[variable]],
    !!!names_map
  )
  
  return(summarised_result)
}