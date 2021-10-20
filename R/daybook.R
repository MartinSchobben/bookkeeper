#' Add daybook entries
#'
#' This function is mainly used as a standalone when adding invoices from a
#' creditor to you administration.
#'
#' @param date Date of transaction.
#' @param daybook A character string for the daybook type (sales, purchases,
#' bank, memorial).
#' @param account A numeric value for ledger account number.
#' @param entity Describe the transaction (i.e., the company).
#' @param comment Describe in more detail the transaction.
#' @param invoice_file The path to the invoice file.
#' @param invoice_num The invoice number as given on the invoice as a numeric
#' value.
#' @param direction The direction of the transaction, usually `"credit"`, when
#' using the function as a stand-alone.
#' @param currency A character string for the currency of the transaction.
#' @param amount A numeric value for the amount of the transaction.
#' @param ... A numeric value or vector of numeric values for the absolute
#' value(s) of VAT included in the invoice.
#' @param VAT_class A variable for the VAT class of the transaction. Supply a
#' character vector with the same number of element as VAT object supplied to
#' the ellipses (`...`).
#'
#' @export
#' @examples
#' \dontrun{
#' add_daybook_entry(
#'  Sys.Date(),
#'  "sales",
#'  1050,
#'  "Super-store",
#'  "A bunch of things",
#'  "invoice.txt",
#'  1,
#'  "credit",
#'  "$",
#'  1000,
#'  210,
#'  "high-VAT"
#' )
#' }
add_daybook_entry <- function(date, daybook, account, entity, comment,
                              invoice_file, invoice_num, direction,
                              currency, amount, ..., VAT_class) {

  # load references (or from create source if needed)
  if (!fs::file_exists(".SBR.RDS")) get_standard_business_reporting()
  account_refs <- readRDS(".SBR.RDS")[,"reference number", drop = TRUE] %>%
    as.numeric()

  # check args
  assertthat::assert_that(lubridate::is.Date(date))
  assertthat::assert_that(
    all(sapply(c(amount, account, invoice_num), is.numeric))
  )
  assertthat::assert_that(
    all(sapply(
      c(currency, direction, entity, comment, VAT_class),
      is.character
    ))
  )
  # levels of day book
  lvl_daybook <- c("sales", "purchases", "bank", "memorial")
  assertthat::assert_that(
    direction %in% c("debit", "credit"),
    daybook %in% lvl_daybook,
    account %in% account_refs,
    msg = "Argument level is not according to naming conventions for accounting adopted here. Please, see the documentation."
    )

  # make new name for invoice file and store in dedicated lib
  invoice_name <- paste(
    entity,
    direction,
    invoice_num,
    as.character(date),
    sep = "_"
    )

  # store user call args
  daybook_args <- rlang::enquos(
    date,
    daybook,
    account,
    entity,
    comment,
    invoice_num,
    direction,
    currency,
    amount,
    ...
    )

  # names of daybook library variables
  daybook_nms <- c(
    "date of transaction",
    "daybook",
    "account reference number",
    "entity",
    "comment",
    "invoice number",
    "direction",
    "currency",
    "amount"
  ) %>%
    append(VAT_class)

  # add names to args
  daybook_args <- rlang::set_names(daybook_args, nm = daybook_nms)

  # names for invoice library variables
  invoice_args <- rlang::enquos(
    `file name` = invoice_name,
    `invoice number` = invoice_num
    )

  # daybook entry
  daybook <- library_entry("daybook", daybook_args)

  # invoice library
  library_entry("invoice-library", invoice_args)

  # save invoice
  if (!is.null(invoice_file)) {
    assertthat::assert_that(fs::is_file(invoice_file))
    fs::dir_create("invoice-library", "credit")
    fs::file_copy(
      invoice_file,
      fs::path(
        "invoice-library",
        "credit",
        invoice_name,
        ext = fs::path_ext(invoice_file)
      )
    )
  }

  # print daybook
  daybook
}

#-------------------------------------------------------------------------------
# Helper functions
#-------------------------------------------------------------------------------
library_entry <- function(library_name, vars, .create_dir = TRUE,
                          .alt_path = NULL) {

  path_to_library <- fs::path(library_name, ext = "RDS")

  if (isTRUE(.create_dir)) {
    fs::dir_create(library_name)
    path_to_library <- fs::path(library_name, path_to_library)
  }

  if (isFALSE(.create_dir) & !is.null(.alt_path)) {
    if (!fs::dir_exists(.alt_path)) fs::dir_create(.alt_path)
    path_to_library <- fs::path(.alt_path, path_to_library)
  }

  path_lg <- fs::file_exists(path_to_library)

  library_entry <- rlang::call2(
    if (isTRUE(path_lg)) "add_row" else "tibble",
    if (isTRUE(path_lg)) add_variable(readRDS(path_to_library), vars),
    rlang::splice(vars),
    .ns = "tibble"
    ) %>%
    eval()

  # save library
  saveRDS(library_entry, path_to_library)
  library_entry
}


add_variable <- function(library_file, vars) {

  # return if not needed, otherwise add new vars
  if(!any(colnames(library_file) %in% names(vars))) {
    library_file
  } else {
    library_nms <- names(vars)
    new_vars <- library_nms[!library_nms %in% colnames(library_file)]
    new_vars <- rlang::set_names(rep(NA, length(new_vars)), nm = new_vars)
    dplyr::mutate(library_file, !!!new_vars)
  }
}
