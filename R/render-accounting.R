#' Render the account reports
#'
#' @param type Type of journal
#' @param template Type of output
#' @param output Type of format
#'
#' @return Rmarkdown file
#' @export
#'
render_accounting <- function(type, template, output = "bookdown::pdf_book") {

  yaml::write_yaml(
    list(
      book_filename = "accounting_report",
      delete_merged_file = TRUE
      ),
    "_bookdown.yml"
    )

  # make rmd parts
  rmarkdown::draft(paste0(template, ".Rmd"), template, package = "bookkeeper")
  bookdown::render_book(output_format = output)
}
#' @return
make_journal <- function(daybook, .lowVAT = 9, .highVAT = 21) {

  ref_code

  if (daybook$daybook == "sales") {
    daybook <- filter(daybook, .data$daybook == "sales")
    # debiteuren
    debit <- c("BVorDebHad" = sum(daybook$amount))
    # net gains
    credit <- "WOmz"
      if (good == "manufactured goods") credit <- paste0(credit, "Nop")
      if (good == "trading goods") credit <- paste0(credit, "Noh")
      if (good == "services") credit <- paste0(credit, "Nod")
    # tax
    readr::parse_number("VAT 21 %")

  }


}

#add_journal_entry
