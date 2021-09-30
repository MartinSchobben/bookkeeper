#' Add customers to a library
#'
#' `add_customer_entry()` creates a library of your customer while assigning a
#' unique ID, or customer number. This is used when creating invoices with
#' `render_invoice()`. Search entries with `search_customer()` and view the
#' whole database with `view_customer()`.
#'
#'
#' @param company Character string for company name.
#' @param name Character string for contact name.
#' @param street Character string for street name.
#' @param city Character string for city name.
#' @param country Character string for country name.
#' @param VAT Character string for VAT number.
#' @param keywords Keywords for searching the database.
#' @param search Determine whether multiple keywords are searched with the
#' boolean `"|"`, or `"&"` for an exclusive combination of keywords (default =
#' `"|"`).
#' @param ... Currently not supported.
#'
#' @return \code{tibble::\link[tibble:tibble]{tibble}()}
#' @export
#'
#' @examples
#' \dontrun{
#' # customer 1
#' add_customer_entry(
#'  "Fancy Stuff inc",
#'  "G. Janssen",
#'  "Liftweg 135",
#'  "7009 ZZ Doetinchem",
#'  "Netherlands",
#'  "NL10937277"
#' )
#' # customer 2
#' add_customer_entry(
#'  "Fancy Work",
#'  NA_character_,
#'  "Vleutensebaan 435",
#'  "8888 ZZ Haarlem",
#'  "Netherlands",
#'  "NL1093se44"
#'  }
add_customer_entry <- function(company, name, street, city, country, VAT) {

  # check args
  assertthat::assert_that(
    all(sapply(c(name, street, city, country, VAT), is.character))
    )

  # check for double entries
  if (fs::file_exists("customer-library/customer-library.RDS")) {
    if (readRDS("customer-library/customer-library.RDS")$VAT == VAT) {
      stop("Customer entry already exists.", call. = FALSE)
    }
  }

  # generate customer number
  customer_num <- customer_numbering(company, dir = "customer-library")

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

  # print
  customer_library
  }
#' @rdname add_customer_entry
#'
#' @export
search_customer <- function(keywords, search = "|") {

  # checks args
  assertthat::assert_that(is.character(keywords))
  assertthat::assert_that(is.character(search), search %in% c("|", "&"))

  # combine keywords with boolean for an exclusive or ..  search
  if (search == "&") {
    keywords <- purrr::map2_chr(
      keywords,
      rev(keywords),
      ~paste(.x, .y, sep = ".*")
    )
  }

  keywords <- stringr::str_c(keywords, collapse = "|")

  readRDS(fs::path("customer-library", "customer-library", ext = "RDS")) %>%
    dplyr::filter(stringr::str_detect(.data$company, keywords))
}
#' @rdname add_customer_entry
#'
#' @export
view_customer <- function(...) {

  customer_path <- fs::path("customer-library", "customer-library", ext = "RDS")

  if (fs::file_exists(customer_path)) {
    readRDS(customer_path)
  } else {
    stop("Customer database does not exist.", call. = FALSE)
  }

}

#-------------------------------------------------------------------------------
# helper functions
#-------------------------------------------------------------------------------

customer_numbering <- function(name, dir) {

  nums <- sapply(1:2, chars_to_numbers, name = name)
  num <- stringr::str_c(nums, collapse = "")

  # short cuts if dir does not exist
  if (!fs::file_exists(fs::path(dir, ".counter.RDS"))) {
    return(counter(stringr::str_c(num, "00", collapse = ""), dir))
    }

  # if dir exists counter is loaded
  if (fs::file_exists(fs::path(dir, ".counter.RDS"))) {

    counter <- readRDS(fs::path(dir, ".counter.RDS"))

    # check if two letter alphabetic entry exists
    # split counter to obtain numbers for alphabetic entry
    counter <- counter[stringr::str_sub(counter, 1, 4) %in% num]
    if (as.integer(num) %in% sapply(stringr::str_sub(counter, 1, 4), as.integer)) {
      # find maximum number of the
      num_max <- max(sapply(counter, as.integer))
      counter(sprintf("%06.0f", num_max), dir)
    } else {
      counter(stringr::str_c(num, "00", collapse = ""), dir)
    }
  }
}

chars_to_numbers <- function(name, position) {
  name <- stringr::str_to_lower(name)
  num <- which(letters == stringr::str_sub(name, position, position))
  sprintf("%02.0f", num)
}

counter <- function(num, dir) {

  num_int <- as.integer(num)

  # make counter file if needed
  if (!fs::file_exists(fs::path(dir, ".counter.RDS"))) {
    # make dir if needed
    if (!fs::dir_exists(dir)) fs::dir_create(dir)
    saveRDS(num, fs::path(dir, ".counter.RDS"))
  }

  # load counter
  counter <- readRDS(fs::path(dir, ".counter.RDS"))

  # increment counter
  num <- sprintf("%06.0f", inc(num_int))

  # save counter
  counter <- c(counter,  num)
  saveRDS(counter, fs::path(dir, ".counter.RDS"))

  # print
  num
}

inc <- function(x) {
  eval(substitute(x + 1, list(x = x)))
}
