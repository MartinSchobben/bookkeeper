render_invoice <- function(address, customer_num, invoice_num) {

  letter_id <- list(
    address = address,
    subject = "INVOICE",
    customer = customer_num,
    invoice = invoice_num,
    lang = "nl"
    ) %>%
    append(yaml::read_yaml("_accountant.yml")) %>%
    ymlthis::yml() %>%
    ymlthis::yml_output(bookkeeper:::komaletter()) %>%
    ymlthis::use_rmarkdown("my_letter.Rmd")
}


komaletter <- function(..., keep_tex=FALSE){

  template <- system.file("rmarkdown", "templates", "invoice", "resources",
                          "template.tex", package="bookkeeper")
  default_lco <- system.file("rmarkdown", "templates", "invoice", "resources",
                             "maintainersDelight.lco", package="bookkeeper")
  default_lco <- sub("\\.[^.]*$", "", default_lco)

  base <- inherit_pdf_document(..., template=template, keep_tex=keep_tex,
                               md_extensions=c("-autolink_bare_uris"),
                               pandoc_args=c(paste0("--variable=lco_default:",
                                                    default_lco)))

  base$knitr$opts_chunk$prompt    <- FALSE
  base$knitr$opts_chunk$comment   <- '# '
  base$knitr$opts_chunk$highlight <- TRUE

  return(base)
}


# Call rmarkdown::pdf_document and mark the return value as inheriting pdf_document
inherit_pdf_document <- function(...){
  fmt <- rmarkdown::pdf_document(...)
  fmt$inherits <- "pdf_document"

  return(fmt)
}
