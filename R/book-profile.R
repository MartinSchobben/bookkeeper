#' Create an accountant account
#'
#' This creates an user account for a `bookkeeper` project with details
#' concerning the company, such as; address, banking and tax details. By default
#' the `yml` file is added to an `gitignore` file, if available, to
#' prevent leakage of sensitive information.
#'
#' @param .text Vector of character string of length 11. In consecutive order
#' listing; company name, street and street number, zip code and city, country,
#' email address, phone number, website, VAT ID, VAT tax number, IBAN and BIC.
#' @param quiet Prevents messages from being printed to the console (default =
#' `FALSE`).
#'
#' @return `yml` file
#' @export
#'
#' @examples
#' \dontrun{
#' # By reading data from the console
#' create_accountant()
#'
#' # By adding a vector of length 11 with company name, street and street number
#' , zip code and city, country, email address, phone number, website, VAT ID,
#' VAT tax number, IBAN and BIC.
#' text <- c(
#'  "FAIReLABS",
#'  "Modelstraat 12",
#'  "3017 KH Amsterdam",
#'  "Netherlands",
#'  "schobbenmartin\@gmail.com",
#'  "03012345",
#'  "https://martinschobben.github.io/webpage/",
#'  "12345678",
#'  "NL123456789B01",
#'  "NL99ABCD0123456789",
#'  "AAAABBCCDD"
#' )
#'
#' create_accountant(.text = text, quiet = TRUE)
#' }
create_accountant <- function(.text = NULL, quiet = FALSE) {
  # print("Enter your name:")
  accountant <- list()
  # company name
  accountant$company <- text_input(.text[1], quiet = quiet)
  # address
  accountant$`return-address` <- c()
  if (isFALSE(quiet)) cat("Street and number:")
  accountant$`return-address`[1] <- text_input(.text[2], quiet = quiet)
  if (isFALSE(quiet)) cat("Postalcode and city:")
  accountant$`return-address`[2] <- text_input(.text[3], quiet = quiet)
  if (isFALSE(quiet)) cat("Country:")
  accountant$`return-address`[3] <- text_input(.text[4], quiet = quiet)
  # contact
  if (isFALSE(quiet)) cat("Email:")
  accountant$`return-email` <- text_input(.text[5], quiet = quiet)
  if (isFALSE(quiet)) cat("Phone:")
  accountant$`return-phone` <- text_input(.text[6], quiet = quiet)
  if (isFALSE(quiet)) cat("Website:")
  accountant$`return-url` <- text_input(.text[7], quiet = quiet)
  # VAT and bank
  accountant$bank <- c()
  if (isFALSE(quiet)) cat("VAT ID:")
  accountant$bank[1] <- paste("VAT ID:", text_input(.text[8],quiet = quiet), sep = " ")
  if (isFALSE(quiet)) cat("VAT tax number:")
  accountant$bank[2] <- paste("VAT tax number:", text_input(.text[9], quiet = quiet), sep = " ")
  if (isFALSE(quiet)) cat("IBAN:")
  accountant$bank[3] <- paste("IBAN:", text_input(.text[10], quiet = quiet), sep = " ")
  if (isFALSE(quiet)) cat("BIC:")
  accountant$bank[4] <- paste("BIC:", text_input(.text[11], quiet = quiet), sep = " ")


  ymlthis::yml(accountant) %>%
    ymlthis::yml_params(
      country = accountant$`return-address`[3],
      bank_num = accountant$bank[3]
      ) %>%
    ymlthis::use_yml_file("_accountant.yml", git_ignore = TRUE, quiet = quiet)
}

text_input <- function(.text = NULL, quiet) {
  call_args <- rlang::list2(what = character(), nmax = 1)
  if(is.character(.text)) call_args <- append(call_args, c(text = .text, sep = ":"))
  rlang::exec("scan", rlang::splice(call_args), quiet = quiet)
  }
