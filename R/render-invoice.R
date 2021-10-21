#' Create an invoice
#'
#' Generate an \code{komaletter::\link[komaletter:komaletter]{komaletter}} type
#' invoice by first compiling all cost posts in a bill with `add_bill_entry()`,
#' and finishing the bill with `make_bill()`, before rendering the invoice with
#' `render_invoice()`. You can search for the customer number with the
#' `search_customer()` in your own customer database.
#'
#' @param customer_num Customer number as a six digit character string.
#' @param bill Default is set to `NULL` but the compiled bill can be provided as
#' a `data.frame()` or \code{tibble::\link[tibble:tibble]{tibble}()}. However,
#' `add_bill_entry` and `make_bill()` should be used to generate the `tibble`.
#' @param lang Language, currently only supports English (`"en"`) and
#' Dutch (`"nl"`).
#' @param account The ledger account number as a character string. The
#' respective account number for country specific standard codes can be
#' looked-up with `search_account_ref()`. Currently defaults to the Dutch
#' \href{https://www.referentiegrootboekschema.nl/ondernemers/werken-met-rgs}{RGS}
#' code for debtors.
#' @param open_doc Should the Rmd file be opened
#' (default = \code{rlang::\link[rlang:is_interactive]{is_interactive}()}).
#' @param quiet Should message not be printed (default = `FALSE`).
#' @param description Add a description of the item.
#' @param VAT Add VAT as a percentage to bill entry.
#' @param currency Add currency as to bill entry.
#' @param price Add price to bill entry.
#' @param .group Add grouping key to bill entry (default = `"items"`).
#' @param currency_out Currency to be used on the bill (default = `"€"`).
#' @param lang Language, defaults to English (`"en"`).
#' @param .save Logical indicating whether to save the bill in RDS format.
#' @param .bill Manual entry of bill as a
#' \code{tibble::\link[tibble:tibble]{tibble}} (Default = `NULL`).
#'
#'
#' @return A \code{komaletter::\link[komaletter:komaletter]{komaletter}} or
#' \code{tibble::\link[tibble:tibble]{tibble}}.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' # make customer database
#' add_customer_entry(
#'  "Fancy Work",
#'  NA_character_,
#'  "Vleutensebaan 435",
#'  "7009 ZZ Haarlem",
#'  "Netherlands",
#'  "NL1093se44"
#'  )
#'
#' # initiate bill
#' add_bill_entry(
#'  "Tekstproductie (80 uur à € 70)",
#'  21,
#'  "€",
#'  5600
#' )
#'
#' # entry
#' add_bill_entry(
#'   "Ontwerp (vaste prijs)",
#'   21,
#'   "€",
#'   1250
#'   )
#'
#' # entry
#' add_bill_entry(
#'   "10 foto’s à € 150",
#'   21,
#'   "€",
#'   1500
#'  )
#'
#' # entry
#' add_bill_entry(
#'  "Vormgeving (30 uur à € 60)",
#'  21,
#'  "€",
#'  1800
#' )
#'
#' # entry
#' add_bill_entry(
#'  "1 kg Suiker",
#'  9,
#'  "€",
#'  3000
#' )
#'
#' # compile bille
#' make_bill(lang = "nl")
#'
#' # Look-up customers (if none exist, first create a customer database)
#' view_customer()
#'
#' # render invoice
#' render_invoice("060101", lang = "nl")
#' }
#'
render_invoice <- function(customer_num, bill = NULL, lang = "en",
                           account = search_account_ref("Handelsdebiteuren")$`reference number`,
                           open_doc = rlang::is_interactive(),
                           quiet = FALSE) {

  # checks args
  assertthat::assert_that(is.character(customer_num), nchar(customer_num) == 6)
  assertthat::assert_that(is.character(account), is.character(lang))
  assertthat::assert_that(is.data.frame(bill) | is.null(bill))
  assertthat::assert_that(is.logical(open_doc), is.logical(quiet))

  # invoice counter
  invoice_num <- invoice_numbering("invoice-library")

  # load accountant profile
  if (fs::file_exists("_accountant.yml")) {
    accountant_profile <- yaml::read_yaml("_accountant.yml")
  } else {
    create_accountant()
  }

  # address from customer library
  address_path <- fs::path("customer-library", "customer-library", ext = "RDS")
  if (fs::file_exists(address_path)) {
    address <- readRDS(address_path) %>%
      dplyr::filter(.data$`customer number` == customer_num)
  } else {
    stop("Make sure to create a customer database first.", call. = FALSE)
  }

  # latex template
  template <- rmd_template_path(
    template = paste0("invoice-", lang),
    path = "skeleton.Rmd"
    )

  # make new name for invoice file and store in dedicated lib
  invoice_name <- paste(
    accountant_profile$company,
    "debit",
    invoice_num,
    as.character(Sys.Date()),
    sep = "_"
    )
  fs::dir_create("invoice-library", "debit")

  # load bill if not supplied
  if (is.null(bill)) {
    bill_path <- fs::path("invoice-library", "debit", ".bill", ext = "RDS")
    if (!fs::file_exists(bill_path)) stop("Create a bill first!")
    bill <- readRDS(bill_path)
  }

  # add invoice to daybook
  add_daybook_entry(
    Sys.Date(),
    "sales",
    as.numeric(account), # Debiteuren RGS
    accountant_profile$company,
    "Your service",
    NULL,
    as.numeric(invoice_num),
    "debit",
    unique(bill$currency),
    dplyr::filter(bill, .data$group == "total")$price,
    !!! dplyr::filter(bill, stringr::str_detect(.data$group, "VAT"))$price,
    VAT_class = dplyr::filter(bill, stringr::str_detect(.data$group, "VAT"))$group
    )

  # translate VAT taxonomy
  if (lang != "en") {
    bank_trans <- VAT_translator(accountant_profile$bank, lang, "en")
  }

  # make yml and rmarkdown from template
  letter_id <- list(
    address = unname(unlist(address)[!is.na(address)][-1]),
    subject = if (lang == "en") "INVOICE" else if (lang == "nl") "FACTUUR",
    customer = customer_num,
    invoice = invoice_num,
    lang = lang,
    bank = bank_trans,
    params =
      append(
        accountant_profile$params,
        list(
          invoice_num = invoice_num,
          customer_num = customer_num,
          data = paste0(invoice_name, ".RDS")
          # data = ".bill.RDS"
          )
      )
    ) %>%
    append(ymlthis::yml_discard(accountant_profile, c("params", "bank"))) %>%
    ymlthis::yml() %>%
    ymlthis::use_rmarkdown(
      fs::path("invoice-library", "debit", invoice_name, ext = "Rmd"),
      template = template,
      quiet = quiet,
      open_doc = open_doc
      )

  # save bill
  saveRDS(bill, fs::path("invoice-library", "debit", invoice_name, ext = "RDS"))

  # discard temporary bill
  fs::file_delete(bill_path)
}
#' @rdname render_invoice
#'
#' @export
add_bill_entry <- function(description, VAT, currency, price, .group = "items",
                           .save = TRUE) {

  # checks args
  assertthat::assert_that(
    all(sapply(c(description, currency, .group), is.character))
    )
  assertthat::assert_that(is.numeric(VAT), is.numeric(price))

  # capture args
  bill_args <- rlang::enquos(
    description = description,
    VAT_class = VAT,
    currency = currency,
    price = price,
    group = .group
    )

  # invoice library
  library_entry(
    ".bill",
    bill_args,
    .create_dir = FALSE,
    .alt_path = if (isTRUE(.save)) fs::path("invoice-library", "debit"),
    .save = .save
  )

}
#' @rdname render_invoice
#'
#' @export
make_bill <- function(currency_out = intToUtf8(8364), lang = "en",
                      .save = TRUE, .bill = NULL) {

  # checks args
  assertthat::assert_that(
    all(sapply(c(currency_out, lang), is.character))
  )

  # read saved bill if .bill == NULL or use bill argument
  if (is.null(.bill)) {
    bill <- readRDS(fs::path("invoice-library", "debit", ".bill", ext = "RDS"))
  } else {
    bill <- .bill
  }

  # calculation names for language
  calc_nms <- dplyr::select(trans_langs, .data$ID, .data$type, {{lang}}) %>%
    dplyr::filter(.data$type == "bill")

  # convert to currency (INCLUDED IN THE FUTURE)

  # calculate VAT and totals
  totals <- vat_calculater(bill, calc_nms, lang)

  new_bill <- dplyr::bind_rows(bill, totals)
  if (isTRUE(.save)) {
    saveRDS(
      new_bill,
      fs::path("invoice-library", "debit", ".bill", ext = "RDS")
      )
  }
  new_bill
}
#' @rdname render_invoice
#'
#' @export
kable_bill <- function(.bill) {
  n_upper <-nrow(tidyr::drop_na(.bill))
  bill <- dplyr::mutate(
    .bill,
    VAT_class =
      dplyr::if_else(is.na(.data$VAT_class), "", paste("Btw", .data$VAT_class, "%")),
    price = sprintf("%.2f", .data$price)
  ) %>%
    dplyr::select(-.data$group)

  # print
  kableExtra::kbl(bill, booktabs = TRUE, col.names = NULL, align = "lccr") %>%
    kableExtra::kable_styling(full_width = TRUE, font_size = 10) %>%
    kableExtra::row_spec(
      c(n_upper, nrow(bill) - 1),
      hline_after = TRUE
    ) %>%
    kableExtra::row_spec(
      nrow(bill),
      bold = TRUE,
      hline_after = TRUE
    ) %>%
    kableExtra::column_spec(1, width = "30em") %>%
    kableExtra::column_spec(2, width = "5em") %>%
    kableExtra::column_spec(3, width = "2em") %>%
    kableExtra::column_spec(4, width = "4em") %>%
    kableExtra::add_indent((n_upper + 3) : nrow(bill) - 1)
}

# invoice counter
invoice_numbering <- function(dir) {
  if (!fs::file_exists(fs::path(dir, ".counter.RDS"))) {
    num <- sprintf("%06.0f", 0)
  } else {
    counter <- readRDS(fs::path(dir, ".counter.RDS"))
    num <- counter[length(counter)]
  }
  counter(num, dir)
}

# translate the VAT taxonomy between languages
VAT_translator <- function(words, lang_out, lang_in = "en") {
  original <- purrr::map_chr(words, ~stringr::str_split(.x, ":")[[1]][1])
  trans <- purrr::map_chr(original, ~translator(.x, lang_out, lang_in))
  trans[is.na(trans)] <- original[is.na(trans)]
  stringr::str_replace(words, original, trans)
}

translator <- function(word, lang_out, lang_in) {
  trans_in <- trans_langs[, lang_in, drop = TRUE]
  trans_lg <- stringr::str_detect(trans_in, paste0("^\\Q", word, "\\E$"))
  if (any(trans_lg)) {
    return(trans_langs[trans_lg, lang_out, drop = TRUE])
  } else {
    return(NA_character_)
  }
}

# to calculate VAT from inclusive bill prices
vat_calculater <- function(bill, calc_nms, lang) {

  dplyr::group_by(bill, .data$VAT_class) %>%
    dplyr::summarise(
      VAT_class = unique(.data$VAT_class),
      sub_totals = sum(.data$price),
      .groups = "drop_last"
    ) %>%
    dplyr::mutate(
      VAT_class = .data$VAT_class,
      sub_total = sum(.data$sub_totals),
      VAT = .data$VAT_class / 100 * .data$sub_totals,
      total = sum(.data$VAT) + .data$sub_total,
      .keep = "unused"
    ) %>%
    tidyr::pivot_longer(- .data$VAT_class, names_to = "group", values_to = "price") %>%
    dplyr::distinct(.data$group, .data$price, .keep_all = TRUE) %>%
    dplyr::mutate(
      group =
        forcats::fct_relevel(.data$group, "sub_total", "VAT", "total"),
      description =
        forcats::fct_recode(
          .data$group,
          !!!rlang::set_names(calc_nms$ID, dplyr::pull(calc_nms, {{lang}}))
          ),
      currency = unique(bill$currency)
    ) %>%
    dplyr::arrange(.data$description) %>%
    dplyr::mutate(
      description =
        dplyr::if_else(
          .data$group == "VAT",
          paste(.data$description, .data$VAT_class, "%", sep = " "),
          as.character(.data$description)
        ),
      group = dplyr::case_when(
        .data$VAT_class == max(.data$VAT_class) & .data$group == "VAT" ~
          "high VAT",
        .data$VAT_class == min(.data$VAT_class) & .data$group == "VAT" ~
          "low VAT",
        TRUE ~ as.character(.data$group)
        ),
      VAT_class = NA
    )
}
