#' Add journal entry
#'
#'
#' @export
#' @examples
#' add_entry(Sys.Date(), "$", 1000, 200, "credit", "BFvaLenLenLn1", "The bank",
#'           "start-up", "invoice.pdf", 1)
add_entry <- function(date, currency, amount, VAT, direction, account_ref,
                      entity, comment, invoice_file, invoice_num) {

  # load account types (or from source if needed)
  if (!fs::file_exists("SBR.RDS")) get_standard_business_reporting()
  account_refs <- readRDS("SBR.RDS")[,"reference code", drop = TRUE]

  # check args
  assertthat::assert_that(lubridate::is.Date(date))
  assertthat::assert_that(is.numeric(amount), is.numeric(invoice_num))
  assertthat::assert_that(
    all(sapply(c(currency, direction, account_ref, entity, comment), is.character))
    )
  assertthat::assert_that(
    direction %in% c("debit", "credit"),
    account_ref %in% account_refs,
    msg = "This is not according to naming conventions for accounting."
    )
  assertthat::assert_that(fs::is_file(invoice_file))

  # make new name for invoice file and store in dedicated lib
  invoice_name <- paste(entity, direction, invoice_num, as.character(date), sep = "_")
  # format invoice number six digit integer
  invoice_num <- sprintf("%06.0f", invoice_num)

  # store user call args
  # names for journal library variables
  journal_args <- rlang::enquos(
    `date of payment` = date,
    currency = currency,
    amount = amount,
    VAT = VAT,
    direction = direction,
    `reference code` = account_ref,
    entity = entity,
    comment = comment,
    `invoice number` = invoice_num
    )

  # names for invoice library variables
  invoice_args <- rlang::enquos(
    `file name` = invoice_name,
    `invoice number` = invoice_num
    )

  # journal entry
  journal <- library_entry("journal", journal_args)

  # invoice library
  library_entry("invoice-library", invoice_args)

  # save invoice
  fs::file_copy(
    invoice_file,
    fs::path("invoice-library", invoice_name, ext = fs::path_ext(invoice_file))
    )
  # change permissions to read_only
  fs::file_chmod(
    fs::path("invoice-library", invoice_name, ext = fs::path_ext(invoice_file)),
    "a+r--"
    )

  # print journal
  journal
}

#-------------------------------------------------------------------------------
# Helper functions
#-------------------------------------------------------------------------------
library_entry <- function(library_name, vars, .create_dir = TRUE) {

  dir_name <- NULL
  if (isTRUE(.create_dir)) {
    fs::dir_create(library_name)
    dir_name <- library_name
  }

  path_to_library <- fs::path(dir_name, library_name, ext = "RDS")
  path_lg <- fs::file_exists(path_to_library)

  library_entry <- rlang::call2(
    if (isTRUE(path_lg)) "add_row" else "tibble",
    if (isTRUE(path_lg)) readRDS(path_to_library),
    rlang::splice(vars),
    .ns = "tibble"
    ) %>%
    eval()
  saveRDS(library_entry, path_to_library)
  library_entry
}
