# Not exportet, useful for building and testing package
setup_book <- function(type = NULL) {
  if (is.null(type)) return(invisible())
  if (type == "reference-codes" & !fs::file_exists("_accountant.yml")) {
    text <-
      c(
        "FAIReLABS",
        "Modelstraat 12",
        "3017 KH Amsterdam",
        "Netherlands",
        "somebody@gmail.com",
        "03012345",
        "https://martinschobben.github.io/webpage/",
        "12345678",
        "NL123456789B01",
        "NL99ABCD0123456789",
        "AAAABBCCDD"
      )
    # create account
    create_accountant(.text = text, quiet = TRUE)
  }
  if (type == "daybook" & !fs::file_exists(".SBR.RDS")) {
    setup_book("reference-codes")
    # get references
    get_standard_business_reporting()
  }
  if (type == "render-invoice" & !fs::file_exists(fs::path("customer-library", "customer-library", ext = "RDS"))) {
    setup_book("reference-codes")
    setup_book("daybook")
    # make customer database
    add_customer_entry(
      "Fancy Work",
      NA_character_,
      "Vleutensebaan 435",
      "7009 ZZ Haarlem",
      "Netherlands",
      "NL1093se44"
    )

  }
  # if (fs::dir_exists("customer-library")) fs::dir_delete("customer-library")
  # if (fs::dir_exists("invoice-library")) fs::dir_delete("invoice-library")
  # if (fs::dir_exists("daybook")) fs::dir_delete("daybook")
}

