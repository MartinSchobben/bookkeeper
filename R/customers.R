#' Add customer to library
#'
#' @param company Character string for company name.
#' @param name Character string for contact name.
#' @param street Character string for street name.
#' @param city Character string for city name.
#' @param country Character string for country name.
#' @param VAT Character string for VAT number.
#'
#' @return
#' @export
#'
#' @examples
add_customer <- function(company, name, street, city, country, VAT) {

  # check args
  assertthat::assert_that(all(sapply(c(name, street, city, country, VAT), is.character)))

  # check for double entries
  if (fs::file_exists("customer-library/customer-library.RDS")) {
    if (readRDS("customer-library/customer-library.RDS")$VAT == VAT) {
      stop("Customer entry already exists.", call. = FALSE)
    }
  }

  # generate customer number
  customer_num <- customer_numbering(company)

  # args
  customer_args <- rlang::enquos(
    `customer number` = customer_num,
    company = company,
    name = name,
    street = street,
    city = city,
    country = country,
    VAT = VAT
  )

  # customer library
  customer_library <- library_entry("customer-library", customer_args)

  # start counter
  if (!fs::file_exists("customer-library/.counter.RDS")) {
    saveRDS(customer_library$`customer number`, "customer-library/.counter.RDS")
  }

  # print
  customer_library
  }

#-------------------------------------------------------------------------------
# helper functions
#-------------------------------------------------------------------------------

customer_numbering <- function(name) {
  nums <- sapply(1:2, chars_to_numbers, name = name)
  counter(stringr::str_c(stringr::str_c(nums, collapse = ""), "00"))
}

chars_to_numbers <- function(name, position) {
  name <- stringr::str_to_lower(name)
  num <- which(letters == stringr::str_sub(name, position, position))
  sprintf("%02.0f", num)
}

counter <- function(num) {

  # short cut
  if (!fs::file_exists("customer-library/.counter.RDS")) return(num)

  num_int <- as.integer(num)
  counter <- readRDS("customer-library/.counter.RDS")

  if (num_int %in% sapply(counter, as.integer)) {
    num <- sprintf("%06.0f", inc(num_int))
    counter <- c(counter,  num)
    saveRDS(counter, "customer-library/.counter.RDS")
    return(num)
  }
  num
}

inc <- function(x) {
  eval(substitute(x + 1, list(x = x)))
}
