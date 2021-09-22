#' Add journal entry
#'
#'
#' @export
#' @example
#' add_entry(Sys.Date(), 1000, "$", "credit", "To Jack", "112245")
add_entry <- function(invoice, date, amount, currency, type, company, comment, ref_num) {

  # check args
  assertthat::assert_that(fs::is_file(invoice))
  assertthat::assert_that(lubridate::is.Date(date))
  assertthat::assert_that(is.numeric(amount), is.numeric(ref_num))
  assertthat::assert_that(is.character(currency), is.character(type),
                          is.character(company), is.character(comment))

  # check if journal exists
  if (!fs::file_exists("journal.RDS")) {
    create_journal()
  }

  # check if invoice library exists
  if (!fs::dir_exists("invoice-library")) {
    create_library()
  }

  journal <- readRDS("journal.RDS") %>%
    tibble::add_row(
      `date of payment` = as.character(date),
      amount,
      currency,
      type,
      company,
      comment,
      `reference number` = ref_num
      )
  saveRDS(journal, "journal.RDS")

  name_invoice <- paste(company, type, as.character(date), sep = "_")
  fs::file_move(invoice, fs::path("invoice-library", name_invoice, ext = fs::path_ext(invoice)))
  readRDS("invoice-library/invoice-library.RDS") %>%
    tibble::add_row(`file name` = name_invoice, `reference number` = ref_num) %>%
    saveRDS("invoice-library/invoice-library.RDS")
  journal
}

create_journal <- function() {

  tibble::tibble(
    `date of payment` = character(),
    amount = numeric(),
    currency = character(),
    type = character(),
    company = character(),
    comment = character(),
    `reference number`= numeric()
    ) %>%
    saveRDS("journal.RDS")

}

create_library <- function() {

  fs::dir_create("invoice-library")
  tibble::tibble(`file name` = character(), `reference number` = numeric()) %>%
    saveRDS("invoice-library/invoice-library.RDS")

}
