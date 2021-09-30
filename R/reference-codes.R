#' Family of functions to query reference codes.
#'
#' Often accountants use standardized reference codes to assign booking to
#' certain journal posts and account on the general ledger. These functions make
#' it easy to query this database; checking the description of the account based
#' on the reference code (`check_account_ref()`) and search the reference code
#' given a set of keywords describing the post (`search_account_ref()`). The
#' reference codes are currently only supported for the Dutch
#' \href{https://www.referentiegrootboekschema.nl/ondernemers/werken-met-rgs}{RGS}
#' reference code scheme.
#'
#' @param account_ref A character string of the account reference code.
#' @param keywords A character string or vector to query the data base reference
#' code description fields.
#' @param search A character indicating whether the search is inclusive ("|") or
#' exclusive ("&").
#' @param type A character string or vector indicating whether debit ("D") or
#' credit ("C) is consulted.
#'
#' @return One or more entries form the coder reference database in tibble
#' format.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # have an account made
#' create_accountant()
#'
#' # Use code reference to find description
#' check_account_ref("101010")
#'
#' # Use keywords to find a code reference that reflect the invoice type
#' search_account_ref(c("lening", "mutaties"), "&", type =c("C", "D"))
#' }
check_account_ref <- function(account_ref) {

  # checks args
  assertthat::assert_that(is.character(account_ref))

  # load references (or from create source if needed)
  if (!fs::file_exists(".SBR.RDS")) get_standard_business_reporting()
  readRDS(".SBR.RDS") %>%
    dplyr::filter(.data$`reference code` == account_ref)
}
#' @rdname check_account_ref
#'
#' @export
search_account_ref <- function(keywords, search = "|" ,type = c("C", "D")) {

  # checks args
  assertthat::assert_that(is.character(keywords))
  assertthat::assert_that(is.character(search), search %in% c("|", "&"))
  assertthat::assert_that(is.character(type), all(type %in% c("C", "D")))

  # exclusive or inclusive search
  if (search == "&") {
    keywords <- purrr::map2_chr(
      keywords,
      rev(keywords),
      ~paste(.x, .y, sep = ".*")
    )
  }

  # final regex
  keywords <- stringr::str_c(keywords, collapse = "|")
  types <- stringr::str_c(type, collapse = "|")

  # load references (or from create source if needed)
  if (!fs::file_exists(".SBR.RDS")) get_standard_business_reporting()
  readRDS(".SBR.RDS")  %>%
    dplyr::filter(stringr::str_detect(.data$`description short`, keywords)) %>%
    dplyr::filter(stringr::str_detect(.data$direction, types))
}

#-------------------------------------------------------------------------------
# Helper functions
#-------------------------------------------------------------------------------
# get code reference standard format per country
get_standard_business_reporting <- function() {

  if (!fs::file_exists("_accountant.yml")) create_accountant()

  # get country from accoutant's profile (yml)
  country <- yaml::read_yaml("_accountant.yml")$country

  tb_refs <- code_refs %>%
    dplyr::filter(country == country) %>%
    purrr::flatten()

  httr::GET(tb_refs$url_ref, httr::write_disk(tf <- tempfile(fileext = ".xls")))
  callxl <- rlang::call2("read_xlsx", expr(tf), !!!tb_refs$args_read, .ns = "readxl")
  suppressMessages(eval(callxl)) %>%
    dplyr::select(!!!tb_refs$var_select) %>%
    # select for one man business
    dplyr::filter(.data$`one-man business` == 1) %>%
    tidyr::drop_na() %>%
    saveRDS(".SBR.RDS")
}
