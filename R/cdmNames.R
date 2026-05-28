#' `assertCdmNames()` verifies if data partner's names are correct and display an error if incorrect
#'
#' @param labels A character vector to filter specific cdm_names
#'
#' @returns Invisible if labels are incorrect
#' @importFrom checkmate assertCharacter
#' @importFrom cli cli_abort
#' @importFrom glue glue glue_collapse
#' @export
#'
#' @examples
#' # Filter a group of acryonims
#' labels <- c(
#'   "BCR",
#'   "IQVIA LPD Belgium",
#'   "IQVIA US - AmbEMR",
#'   "IQVIA US - PMTX+"
#' )
#' assertCdmNames(labels = labels)
assertCdmNames <- function(labels, expected) {
  checkmate::assertCharacter(labels)
  if (missing(expected)) {
    expected <- cdmNames()
  }
  if (all(labels %in% expected)) {
    return(invisible())
    } else {
      actual_str <- glue::glue(
        "{glue::glue_collapse(labels, sep = \"', '\")}"
        )
      expected_str <- glue::glue(
        "{glue::glue_collapse(expected, sep = \"', '\")}"
        )
      cli::cli_abort(
        message = c(
          "!" = "A label doesn't match with expectations:",
          "x" = "Actual: {actual_str}",
          "i" = "Expected: {expected_str}"
        )
      )
    }
  }

#' `arrangeCdmNames()` retrieves data partners acronyms arranged by country alphabetical order
#'
#' @param labels A character vector to filter specific cdm_names
#'
#' @returns A character vector
#' @importFrom checkmate assertCharacter
#' @importFrom cli cli_abort
#' @export
#'
#' @examples
#' # Filter a group of acryonims
#' labels <- c(
#'   "BCR",
#'   "IQVIA LPD Belgium",
#'   "IQVIA US - AmbEMR",
#'   "IQVIA US - PMTX+"
#' )
#' arrangeCdmNames(labels = labels)
arrangeCdmNames <- function(labels) {
  assertCdmNames(labels)
  checkmate::assertCharacter(labels)
  cdmNames <- cdmNames()
  cdmNames[cdmNames %in% labels]
}

cdmNames <- function() {
  c(
    "BCR",
    "IQVIA LPD Belgium",
    "UZA",
    "NAIS",
    "DK-DHR",
    "EBB",
    "HARMONY Platform",
    "HARMONY-ALL",
    "HARMONY-AML",
    "HARMONY-CML",
    "HARMONY-MM",
    "FinOMOP-ACI Varha",
    "FinOMOP-HUS",
    "FinOMOP-TaUH Pirha",
    "FinOMOP-THL",
    "APHM",
    "CDW Bordeaux",
    "SNDS",
    "InGef RDB",
    "IQVIA DA Germany",
    "UMD",
    "PGH",
    "SUCD",
    "Pedianet",
    "POLIMI",
    "LDH",
    "CRN",
    "NLHR",
    "NLHR@UiO:PERINATAL",
    "EMDB-ULSEDV",
    "EMDB-ULSGE",
    "EMDB-ULSRA",
    "ULSM-RT",
    "BIFAP",
    "H12O",
    "HUVM",
    "IMASIS",
    "PRISIB",
    "SIDIAP", "VID",
    "HI-SPEED",
    "IPCI",
    "NCR",
    "CPRD AURUM",
    "CPRD Aurum Linked",
    "CPRD GOLD",
    "UKBB",
    "IQVIA US - AmbEMR",
    "IQVIA US - PMTX+"
  )
}
