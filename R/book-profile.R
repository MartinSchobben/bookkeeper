create_accountant <- function(.test = NULL) {
  # print("Enter your name:")
  accountant <- list()
  # company name
  accountant$company <- text_input(.test[1])
  # address
  accountant$`return-address` <- c()
  cat("Street and number:")
  accountant$`return-address`[1] <- text_input(.test[2])
  cat("Postalcode and city:")
  accountant$`return-address`[2] <- text_input(.test[3])
  cat("Country:")
  accountant$`return-address`[3] <- text_input(.test[4])
  # contact
  cat("Email:")
  accountant$`return-email` <- text_input(.test[5])
  cat("Phone:")
  accountant$`return-phone` <- text_input(.test[6])
  cat("Website:")
  accountant$`return-url` <- text_input(.test[7])
  # VAT and bank
  accountant$bank <- c()
  cat("VAT ID:")
  accountant$bank[1] <- paste("VAT ID:", text_input(.test[8]), sep = " ")
  cat("VAT number:")
  accountant$bank[2] <- paste("VAT:", text_input(.test[9]), sep = " ")
  cat("IBAN:")
  accountant$bank[3] <- paste("IBAN:", text_input(.test[10]), sep = " ")
  cat("BIC:")
  accountant$bank[4] <- paste("BIC:", text_input(.test[11]), sep = " ")


  ymlthis::yml(accountant) %>%
    ymlthis::yml_params(country = accountant$`return-address`[3]) %>%
    ymlthis::use_yml_file("_accountant.yml")
}

text_input <- function(.test = NULL) {
  call_args <- rlang::list2(what = character(), nmax = 1)
  if(is.character(.test)) call_args <- append(call_args, c(text = .test))
  rlang::exec("scan", rlang::splice(call_args))
  }
