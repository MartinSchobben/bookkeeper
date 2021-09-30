# numbering
test_that("increase invoice number", {
  # setup
  usethis::local_project(force = TRUE)
  setup_book()
  # tests
  expect_equal(customer_numbering("Fancy Stuff inc", "customer-library"), "060101")
  expect_equal(customer_numbering("Fancy Works", "customer-library"), "060102")
  # clean-up
  clean_book()
})

# error test
test_that("customer errors", {
  # setup
  usethis::local_project(force = TRUE)
  setup_book()
  # tests
  expect_error(view_customer(), "Customer database does not exist.")
  add_customer_entry(
    "Fancy Stuff inc",
    "G. Janssen",
    "Liftweg 135",
    "7009 ZZ Doetinchem",
    "Netherlands",
    "NL10937277"
  )
  expect_error(
    add_customer_entry(
      "Fancy Stuff inc",
      "G. Janssen",
      "Liftweg 135",
      "7009 ZZ Doetinchem",
      "Netherlands",
      "NL10937277"
    ),
    "Customer entry already exists."
  )
  # clean-up
  clean_book()
})

# golden test
test_that("customer entry works", {
  # setup
  usethis::local_project(force = TRUE)
  setup_book()
  # tests
  expect_snapshot(
    add_customer_entry(
      "Fancy Stuff inc",
      "G. Janssen",
      "Liftweg 135",
      "7009 ZZ Doetinchem",
      "Netherlands",
      "NL10937277"
    )
  )
  expect_snapshot(
    add_customer_entry(
      "Fancy Work",
      NA_character_,
      "Vleutensebaan 435",
      "7009 ZZ Haarlem",
      "Netherlands",
      "NL1093se44"
    )
  )
  # clean-up
  clean_book()
})

