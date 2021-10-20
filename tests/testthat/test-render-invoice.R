# numbering
test_that("increase invoice number", {
  # setup
  usethis::local_project(force = TRUE)
  setup_book()
  expect_equal(invoice_numbering("invoice-library"), "000001")
  clean_book()
})


# file test with saving intermediate
test_that("increase invoice number", {
  # setup
  usethis::local_project(force = TRUE)
  setup_book("daybook")
  # no customer database
  expect_error(
    render_invoice("060101", lang = "nl", open_doc = FALSE, quiet = TRUE),
    "Make sure to create a customer database first."
    )
  # make customer database
  add_customer_entry(
    "Fancy Work",
    NA_character_,
    "Vleutensebaan 435",
    "7009 ZZ Haarlem",
    "Netherlands",
    "NL1093se44"
  )
  # no bill throw error
  expect_error(
    render_invoice("060101", lang = "nl", open_doc = FALSE, quiet = TRUE),
    "Create a bill first!"
  )
  # initiate bill
  add_bill_entry(
    "Tekstproductie (80 uur à € 70)",
    21,
    "€",
    5600
  )
  # entry
  add_bill_entry(
    "Ontwerp (vaste prijs)",
    21,
    "€",
    1250
  )
  # entry
  add_bill_entry(
    "10 foto’s à € 150",
    21,
    "€",
    1500
  )
  # entry
  add_bill_entry(
    "Vormgeving (30 uur à € 60)",
    21,
    "€",
    1800
  )
  # entry
  add_bill_entry(
    "1 kg Suiker",
    9,
    "€",
    3000
  )
  make_bill(lang = "nl")
  expect_message(
    render_invoice("060101", lang = "nl", open_doc = FALSE),
    regexp = '(invoice-library/debit/(.)*\\.Rmd)|(<no active project>)'
    )
  # clean-up
  clean_book()
  })

# file test without saving intermediate
test_that("Setup bill without saving intermediates.", {
  # setup
  usethis::local_project(force = TRUE)
  setup_book("daybook")
  # bill entry
  add_bill_entry(
    "Vormgeving (30 uur à € 60)",
    21,
    "€",
    1800,
    .save = FALSE
  )
  expect_false(fs::dir_exists("invoice-library"))
  # clean-up
  clean_book()
})

#check translator
test_that("translator check", {
  # setup
  usethis::local_project(force = TRUE)
  setup_book("render-invoice")
  # read account
  accountant_profile <- yaml::read_yaml("_accountant.yml")
  # test
  expect_equal(
    VAT_translator(accountant_profile$bank[1:2], lang_out = "nl"),
    c("KVK: 12345678", "Btw-id: NL123456789B01")
  )
  # clean-up
  clean_book()
})

# two bill entries at once
test_that("two bill entries at once", {
  # setup
  usethis::local_project(force = TRUE)
  expect_snapshot(
    # double entry
    add_bill_entry(
      c("10 foto’s à € 150", "Vormgeving (30 uur à € 60)"),
      21,
      "€",
      c(1500, 1800)
    )
  )
  # clean-up
  clean_book()
})

