#' Download concept sets from ATLAS and save them in the package.
#'
#' Retrieves each concept set definition from the ATLAS WebAPI, cleans the
#' concept set name for use as a file name and writes the JSON definition to
#' `inst/concept_sets/<conceptSetType>/`.
#'
#' @param conceptSetList A numeric vector of ATLAS concept set IDs to download.
#' @param conceptSetType A character string used to group the downloaded concept
#' set JSON files under `inst/concept_sets/`.
#' @param baseUrl A character string with the base URL of the ATLAS WebAPI.
#' @param deletePrevious A logical value indicating whether to delete existing files in
#' the target `<conceptSetType>` folder before downloading the new concept sets.
#' @param patternToRemove A vector of regular expressions containing the pattern(s)
#' to be removed from the ATLAS concept set names before creating the output JSON files.
#' By default, matches
#'
#' @returns A tibble with one row per downloaded concept set and the columns
#' `conceptSetId`, `originalName`, `cleanName`, and `jsonPath`.
#'
#' @importFrom checkmate assertCharacter assertDouble
#' @importFrom here here
#' @importFrom jsonlite toJSON
#' @importFrom glue glue
#' @importFrom dplyr tibble bind_rows
#' @importFrom stringr str_to_lower str_remove str_replace_all
#' @importFrom ParallelLogger logInfo
#' @keywords internal
pullConceptsAtlas <- function(
    conceptSetList,
    conceptSetType,
    baseUrl = "https://atlas.darwin-eu.org/WebAPI",
    deletePrevious = TRUE,
    patternToRemove = c("p[0-9]{1}_c[0-9]{1}_[0-9]{3}_")
  ) {

  checkmate::assertDouble(conceptSetList)
  checkmate::assertCharacter(conceptSetType)
  checkmate::assertCharacter(baseUrl)
  checkmate::assertLogical(deletePrevious)
  checkmate::assertCharacter(patternToRemove)
  if (!requireNamespace("ROhdsiWebApi", quietly = TRUE)) {
    stop(
      "Package 'ROhdsiWebApi' is required to pull concept sets from ATLAS.",
      call. = FALSE
    )
  }

  # --- Extract IDs ---
  ParallelLogger::logInfo(glue::glue("Extracting ids from excel file"))

  concept_set_ids <- conceptSetList
  if (length(concept_set_ids) == 0) {
    stop(glue::glue("No concept sets were found in the concept set list when looking for type: {conceptSetType}"))
  }

  results_list <- list()

  # --- Loop through IDs and Download ---
  ParallelLogger::logInfo(
    glue::glue(
      "Downloading and processing {length(concept_set_ids)} concept sets"
    )
  )

  # Folder management
  folder_path <- here::here("inst", "concept_sets", conceptSetType)
  if (!dir.exists(folder_path)) {
    ParallelLogger::logInfo(glue::glue("Creating folder {folder_path}"))
    dir.create(folder_path, recursive = TRUE)
  } else {
    if (isTRUE(deletePrevious)) {
      ParallelLogger::logInfo(glue::glue("Deleting previous concept sets"))
      unlink(list.files(folder_path, full.names = TRUE, recursive = TRUE), recursive = TRUE)
    }
  }

  for (id in conceptSetList) {

    ParallelLogger::logInfo(
      glue::glue(
        "Retrieving concept set {id} from ATLAS."
      )
    )

    # Fetch definition
    conceptSet <- ROhdsiWebApi::getConceptSetDefinition(
      conceptSetId = id,
      baseUrl = baseUrl
    )

    # Clean concept set name
    clean_name <- conceptSet$name |>
      stringr::str_to_lower() |>
      stringr::str_replace_all(
        c(
          "^\\s+|\\s+$" = "",  # remove leading or trailing whitespaces
          "^[0-9]+_" = "",     # remove initial sequence of digits followed by _
          "[\\s()]" = "_"      # replace inner whitespaces, ( or ) with _
        )
      )
    for (pattern in patternToRemove) {
      clean_name <- clean_name |>
        stringr::str_remove(pattern)
    }
    clean_name <- clean_name |>
      stringr::str_replace_all(
        c(
          "_+" = "_",          # replace multiple _ with single _
          "^_|_$" = ""         # remove any leading or trailing _ if any
        )
      )

    # Convert expression to JSON
    jsonConceptSet <- jsonlite::toJSON(
      conceptSet$expression,
      auto_unbox = TRUE,
      pretty = TRUE
    )

    if (id %in% c(5402, 5403, 5404, 5405, 5406, 5407, 5408)) {
      clean_name <- paste(
        "breast_cancer",
        clean_name,
        sep = "_"
      )
    }

    # Save file
    file_name <- paste0(
      clean_name,
      ".json"
    )
    writeLines(
      jsonConceptSet,
      file.path(
        folder_path,
        file_name
      )
    )
    results_list[[length(results_list) + 1]] <- dplyr::tibble(
      conceptSetId = id,
      originalName = conceptSet$name,
      cleanName = clean_name,
      fileName = file_name
    )
  }

  ParallelLogger::logInfo(
    glue::glue(
      "Concept sets downloaded to {folder_path}"
    )
  )

  # --- Return Summary ---
  results_df <- dplyr::bind_rows(
    results_list
  )
  return(results_df)
}
