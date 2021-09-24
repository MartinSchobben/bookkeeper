#' Render the account reports
#'
#' @param type Type of journal
#' @param template Type of output
#' @param output Type of format
#'
#' @return
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
