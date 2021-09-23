#' Family of functions to query reference codes
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
#' # Use code reference to find description
#' check_account_ref("BFvaOvrVgbBej")
#' # Use keywords to find a code reference that reflect the invoice type
#' search_account_ref(c("lening", "mutaties"), "&", type =c("C", "D")
check_account_ref <- function(account_ref) {

  # checks args
  assertthat::assert_that(is.character(account_ref))

  readRDS("SBR.RDS") %>%
    dplyr::filter(`reference code` == account_ref)
}
#' @rdname check_account_ref
#'
#' @export
search_account_ref <- function(keywords, search = "|" ,type = c("C", "D")) {

  # checks args
  assertthat::assert_that(is.character(keywords))
  assertthat::assert_that(is.character(search), search %in% c("|", "&"))
  assertthat::assert_that(is.character(type), all(type %in% c("C", "D")))

  if (search == "&") {
    keywords <- purrr::map2_chr(
      keywords,
      rev(keywords),
      ~paste(.x, .y, sep = ".*")
    )
  }

  keywords <- stringr::str_c(keywords, collapse = "|")

  types <- stringr::str_c(type, collapse = "|")
  readRDS("SBR.RDS")  %>%
    dplyr::filter(stringr::str_detect(`description short`, keywords)) %>%
    dplyr::filter(stringr::str_detect(direction, types))
}

#-------------------------------------------------------------------------------
# Helper functions
#-------------------------------------------------------------------------------
# get code reference standard format per country
get_standard_business_reporting <- function() {

  if (!fs::file_exists("_accountant.yml")) create_accountant()

  # get country from accoutant's profile (yml)
  country <- yaml::read_yaml("_accountant.yml")$country

  tb_refs <- bookkeeper::code_refs %>%
    dplyr::filter(country == country) %>%
    purrr::flatten()

  httr::GET(tb_refs$url_ref, httr::write_disk(tf <- tempfile(fileext = ".xls")))
  callxl <- rlang::call2("read_xlsx", expr(tf), !!!tb_refs$args_read, .ns = "readxl")
  suppressMessages(eval(callxl)) %>%
    dplyr::select(!!!tb_refs$var_select) %>%
    tidyr::drop_na() %>%
    saveRDS("SBR.RDS")
}
