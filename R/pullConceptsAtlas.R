#' Download concept sets from ATLAS and save them in the package.
#'
#' Retrieves each concept set definition from the ATLAS WebAPI, cleans the
#' concept set name for use as a file name and writes the JSON definition to
#' `inst/concept_sets/<conceptSetType>/`.
#'
#' @details
#' Requires the optional CRAN packages `httr`, `RJSONIO`, `lubridate`, and `rlang`.
#' For a protected WebAPI, set `ATLAS_TOKEN` in your local `.Renviron` file and
#' restart R. The token may include the `Bearer ` prefix. It is sent only to
#' the supplied WebAPI. Do not commit the token to version control.
#' The internal retrieval helpers are adapted from OHDSI's `ROhdsiWebApi`
#' under the Apache License 2.0; see `inst/COPYRIGHTS` in the package source.
#'
#' @param conceptSetList A numeric vector of ATLAS concept set IDs to download.
#' @param conceptSetType A character string used to group the downloaded concept
#' set JSON files under `inst/concept_sets/`.
#' @param baseUrl A character string with the base URL of the ATLAS WebAPI.
#' @param deletePrevious A logical value indicating whether to delete existing files in
#' the target `<conceptSetType>` folder before downloading the new concept sets.
#' @param patternToRemove A vector of regular expressions containing the pattern(s)
#' to be removed from the ATLAS concept set names before creating the output JSON files.
#' @param authHeader Authorization header for the WebAPI. Defaults to
#' `Sys.getenv("ATLAS_TOKEN")`. Use `""` for a public WebAPI.
#'
#' @returns A tibble with one row per downloaded concept set and the columns
#' `conceptSetId`, `originalName`, `cleanName`, and `fileName`.
#'
#' @importFrom checkmate assertCharacter assertDouble
#' @importFrom here here
#' @importFrom jsonlite toJSON
#' @importFrom glue glue
#' @importFrom dplyr tibble bind_rows
#' @importFrom stringr str_to_lower str_remove str_replace_all
#' @importFrom ParallelLogger logInfo
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#' # Requires a connection to the ATLAS WebAPI
#' conceptSetList <- c(12345)
#' conceptSetType <- "example"
#' pullConceptsAtlas(
#'    conceptSetList = conceptSetList,
#'    conceptSetType = conceptSetType,
#'    baseUrl = "https://atlas.darwin-eu.org/WebAPI",
#'    deletePrevious = TRUE,
#'    patternToRemove = c("p[0-9]{1}_c[0-9]{1}_[0-9]{3}_")
#' )
#' }
pullConceptsAtlas <- function(
    conceptSetList,
    conceptSetType,
    baseUrl = "https://atlas.darwin-eu.org/WebAPI",
    deletePrevious = TRUE,
    patternToRemove = c("p[0-9]{1}_c[0-9]{1}_[0-9]{3}_"),
    authHeader = Sys.getenv("ATLAS_TOKEN")
  ) {

  checkmate::assertDouble(conceptSetList)
  checkmate::assertCharacter(conceptSetType)
  checkmate::assertCharacter(baseUrl)
  checkmate::assertLogical(deletePrevious)
  checkmate::assertCharacter(patternToRemove)
  for (package in c("httr", "RJSONIO", "lubridate", "rlang")) {
    requireInstall(package)
  }
  checkmate::assertString(authHeader)

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
    conceptSet <- getConceptSetDefinition(
      conceptSetId = id,
      baseUrl = baseUrl,
      authHeader = authHeader
    )

    # Clean concept set name
    clean_name <- conceptSet$name |>
      stringr::str_to_lower() |>
      stringr::str_replace_all(
        c(
          "^\\s+|\\s+$" = "",  # remove leading or trailing whitespaces
          "^[0-9]+" = "",      # remove initial sequence of digits
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
          "-+|–+" = "_",       # replace - (hyphen) and – (dash) with _
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

# Adapted from OHDSI/ROhdsiWebApi, commit:
# 5911ab0973ee18c5e72b62c6b999dc1f1bb21e79
# https://github.com/OHDSI/ROhdsiWebApi/tree/5911ab0973ee18c5e72b62c6b999dc1f1bb21e79/R
# Sources: AutoGeneratedDefinitions.R, GetPostDeleteDefinition.R, Private.R,
# WebApi.R, httrWrappers.R. See inst/COPYRIGHTS for the function/source mapping.
#
# Copyright 2022 Observational Health Data Sciences and Informatics
#
# The original files are part of ROhdsiWebApi (AutoGeneratedDefinitions.R
# carries the upstream notice "This file is part of FeatureExtraction").
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Modified for studyGenerics: internal helpers limited to concept-set retrieval;
# conditional dependencies; explicit request-scoped authentication instead of a
# cached package environment; authenticated version checks; request timeouts;
# no redirects; input/response checks; standard HTTP errors instead of metadata
# lookups on failure. Date conversion and JSON expression parsing are retained.

getConceptSetDefinition <- function(conceptSetId, baseUrl,
                                    authHeader = Sys.getenv("ATLAS_TOKEN")) {
  for (package in c("httr", "RJSONIO", "lubridate", "rlang")) {
    requireInstall(package)
  }
  checkmate::assertInt(conceptSetId, lower = 1)
  checkmate::assertString(baseUrl, min.chars = 1)
  checkmate::assertString(authHeader)
  baseUrl <- gsub("/+$", "", baseUrl)
  if (!grepl("^https?://", baseUrl, ignore.case = TRUE)) {
    stop("baseUrl must be an HTTP or HTTPS WebAPI URL.", call. = FALSE)
  }
  if (nzchar(authHeader) && !grepl("^https://", baseUrl, ignore.case = TRUE)) {
    stop("Use HTTPS when sending an ATLAS token.", call. = FALSE)
  }
  result <- getDefinition(id = conceptSetId, baseUrl = baseUrl,
                          category = "conceptSet", authHeader = authHeader)
  return(result)
}

getDefinition <- function(id, baseUrl, category, authHeader = "") {
  checkmate::assertChoice(category, "conceptSet")
  .checkBaseUrl(baseUrl, authHeader)
  argument <- .getStandardCategories()
  url <- paste0(baseUrl, "/", argument$categoryUrl, "/", id)
  response <- httr::content(.GET(url, authHeader = authHeader),
                            as = "parsed", type = "application/json")
  if (!is.list(response) || !is.character(response$name) ||
      length(response$name) != 1L || is.na(response$name)) {
    stop("WebAPI returned an invalid concept-set definition.", call. = FALSE)
  }
  if (is.null(response$expression)) {
    if (!is.null(response$specification)) {
      response$expression <- response$specification
      response$specification <- NULL
    } else if (!is.null(response$design)) {
      response$expression <- response$design
      response$design <- NULL
    } else {
      urlExpression <- paste0(url, "/", argument$categoryUrlGetExpression)
      response$expression <- httr::content(
        .GET(urlExpression, authHeader = authHeader),
        as = "parsed", type = "application/json"
      )
    }
  }
  if (is.character(response$expression)) {
    if (length(response$expression) != 1L ||
        !jsonlite::validate(response$expression)) {
      stop("WebAPI returned an invalid JSON expression.", call. = FALSE)
    }
    response$expression <- RJSONIO::fromJSON(
      response$expression, nullValue = NA, digits = 23
    )
    for (name in names(response)) {
      if (grepl("date", tolower(name))) {
        response[[name]] <- .convertToDateTime(response[[name]])
      }
    }
  }
  if (!is.list(response$expression)) {
    stop("WebAPI returned an invalid concept-set expression.", call. = FALSE)
  }
  return(response)
}

.getStandardCategories <- function() {
  data.frame(categoryStandard = "conceptSet", categoryUrl = "conceptset",
             categoryUrlGetExpression = "expression")
}

.checkBaseUrl <- function(baseUrl, authHeader = "") {
  webApiVersion <- getWebApiVersion(baseUrl, authHeader)
  if (is.null(webApiVersion) || length(webApiVersion) == 0L) {
    stop("Could not verify the WebAPI version. Check baseUrl and network access.",
         call. = FALSE)
  }
}

getWebApiVersion <- function(baseUrl, authHeader = "") {
  response <- .GET(paste0(baseUrl, "/info"), authHeader = authHeader)
  httr::content(response, as = "parsed", type = "application/json")$version
}

.GET <- function(url, authHeader = "") {
  .request(url, method = "GET", authHeader = authHeader)
}

.request <- function(url, method, authHeader = "") {
  requireInstall("httr")
  requireInstall("rlang")
  checkmate::assertChoice(method, "GET")
  headers <- httr::accept_json()
  if (nzchar(authHeader)) {
    if (!grepl("^Bearer[[:space:]]", authHeader, ignore.case = TRUE)) {
      authHeader <- paste("Bearer", authHeader)
    }
    headers <- httr::add_headers(Accept = "application/json",
                                 Authorization = authHeader)
  }
  response <- httr::GET(url, headers, httr::timeout(30),
                        httr::config(followlocation = 0L))
  status <- httr::status_code(response)
  if (status == 401L) {
    rlang::abort("HTTP 401: Unauthorized. Check ATLAS_TOKEN or authHeader.",
                 class = "webapi-unauthorized")
  }
  if (status == 403L) {
    rlang::abort("HTTP 403: You do not have permission to access this WebAPI resource.",
                 class = "webapi-forbidden")
  }
  if (status == 404L) {
    rlang::abort("HTTP 404: The WebAPI resource was not found.",
                 class = "webapi-notfound")
  }
  if (status == 500L) {
    rlang::abort("HTTP 500: The WebAPI encountered an internal server error.",
                 class = "webapi-server")
  }
  httr::stop_for_status(response)
  if (status != 200L) {
    stop(sprintf("Unexpected WebAPI HTTP status: %s.", status), call. = FALSE)
  }
  response
}

.millisecondsToDate <- function(milliseconds) {
  if (is.numeric(milliseconds)) {
    milliseconds <- lubridate::as_datetime(milliseconds / 1000,
                                            tz = Sys.timezone())
  }
  milliseconds
}

.convertToDateTime <- function(x) {
  requireInstall("lubridate")
  if (is.numeric(x)) {
    x <- .millisecondsToDate(x)
  } else if (is.character(x)) {
    x <- stringr::str_trim(x)
    x <- lubridate::as_datetime(
      x, tz = Sys.timezone(),
      format = lubridate::guess_formats(
        x, orders = c("y-m-d H:M", "y-m-d H:M:S", "ymdHMS", "ymd HMS")
      )[1]
    )
  }
  x
}
