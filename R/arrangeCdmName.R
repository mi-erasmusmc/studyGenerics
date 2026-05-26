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
  acronyms <- c(
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
  if (missing(labels)) {
    return(acronyms)
  } else {
    checkmate::assertCharacter(labels)
    if (all(labels %in% acronyms)) {
      result <- acronyms[acronyms %in% labels]
      return(result)
    } else {
      cli::cli_abort("cdm_name provided do not match")
    }
  }
}
