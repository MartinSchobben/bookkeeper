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
  account_refs <- readRDS("SBR.RDS")[,"reference code", drop=TRUE]

  # check args
  assertthat::assert_that(lubridate::is.Date(date))
  assertthat::assert_that(is.numeric(amount), is.numeric(invoice_num))
  assertthat::assert_that(
    is.character(currency),
    is.character(direction), direction %in% c("debit", "credit"),
    is.character(account_ref), account_ref %in% account_refs,
    is.character(entity),
    is.character(comment)
    )
  assertthat::assert_that(fs::is_file(invoice_file))

  # check if journal exists
  if (!fs::file_exists("journal.RDS")) {
    create_journal()
  }

  # check if invoice library exists
  if (!fs::dir_exists("invoice-library")) {
    create_library()
  }

  # format invoice number six digit integer
  invoice_num <- sprintf("%06.0f", invoice_num)

  # journal entry
  journal <- readRDS("journal.RDS") %>%
    tibble::add_row(
      `date of payment` = as.character(date),
      currency,
      amount,
      VAT,
      direction,
      `reference code` = account_ref,
      entity,
      comment,
      `invoice number` = invoice_num
      )
  saveRDS(journal, "journal.RDS")

  # make new name for invoice file and store in dedicated lib
  invoice_name <- paste(entity, direction, invoice_num, as.character(date), sep = "_")
  fs::file_copy(
    invoice_file,
    fs::path("invoice-library", invoice_name, ext = fs::path_ext(invoice_file))
    )
  # change permissions to read_only
  fs::file_chmod(
    fs::path("invoice-library", invoice_name, ext = fs::path_ext(invoice_file)),
    "a+r--"
    )

  # add invoice library entry to documentation
  readRDS("invoice-library/invoice-library.RDS") %>%
    tibble::add_row(
      `file name` = invoice_name,
      `invoice number` = invoice_num
      ) %>%
    saveRDS("invoice-library/invoice-library.RDS")

  # print journal
  journal
}

create_journal <- function() {

  tibble::tibble(
    `date of payment` = character(),
    currency = character(),
    amount = numeric(),
    VAT = numeric(),
    direction = character(),
    `reference code` = character(),
    entity = character(),
    comment = character(),
    `invoice number` = character()
    ) %>%
    saveRDS("journal.RDS")

}

create_library <- function() {

  fs::dir_create("invoice-library")
  tibble::tibble(`file name` = character(), `invoice number` = character()) %>%
    saveRDS("invoice-library/invoice-library.RDS")

}



