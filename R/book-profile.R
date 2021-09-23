create_accountant <- function() {
  print("Enter your name:")
  accountant <- list()
  accountant$name <- scan(what = character(), nmax = 1)
  print("Enter your surname:")
  accountant$surname <- scan(what = character(), nmax = 1)
  print("Country:")
  accountant$country <- scan(what = character(), nmax = 1)
  yaml::write_yaml(accountant, "_accountant.yml")
}
