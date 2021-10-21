#' Get path to Rmd template
#'
#' This function comes from the package `readr`, and has been modified to access
#' the bundled datasets in directory `inst/rmarkdown/templates` of `bookkeeper`.
#' This function make them easy to access. This function is modified from
#' `readr_example()` of the package
#' \href{https://readr.tidyverse.org/}{readr}.
#'
#' @param path Name of file. If `NULL`, the Rmarkdown skeleton file is listed.
#' @param template The name of the template.
#' @param type Type of file Rmd `skeleton` or `resources` tex files.
#' @export
#' @examples
#' rmd_template_path()
#' rmd_template_path("2018-01-19-GLENDON")
rmd_template_path <- function(template = "invoice-en", type = "skeleton", path = NULL) {
  if (is.null(path)) {
    dir(
      system.file(
        "rmarkdown",
        "templates",
        template,
        type,
        path,
        package = "bookkeeper"
        )
      )
  } else {
    system.file(
      "rmarkdown",
      "templates",
      template,
      type,
      path,
      package = "bookkeeper",
      mustWork = TRUE
    )
  }
}
