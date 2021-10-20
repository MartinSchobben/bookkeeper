# Not exportet, useful for building and testing package
clean_book <- function() {
  if (fs::file_exists("_accountant.yml")) fs::file_delete("_accountant.yml")
  if (fs::file_exists(".SBR.RDS")) fs::file_delete(".SBR.RDS")
  if (fs::file_exists(".bill.RDS")) fs::file_delete(".bill.RDS")
  if (fs::dir_exists("customer-library")) fs::dir_delete("customer-library")
  if (fs::dir_exists("invoice-library")) fs::dir_delete("invoice-library")
  if (fs::dir_exists("daybook")) fs::dir_delete("daybook")
}
