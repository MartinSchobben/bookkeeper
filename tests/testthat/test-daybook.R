# golden test
test_that("Check that daybook entries works", {
  # setup
  usethis::local_project(force = TRUE)
  setup_book("daybook")
  # enter invoice for creditors to daybook
  expect_snapshot(
    add_daybook_entry(
      as.Date("2011-07-12"),
      "bank",
      0805020.01,
      "ABN-AMBRO",
      "start-up",
      "invoice.txt",
      1,
      "credit",
      "$",
      1000,
      105,
      45,
      VAT_class = c("high VAT", "low VAT")
    )
  )
  expect_snapshot(
    add_daybook_entry(
      as.Date("2011-07-13"),
      "bank",
      0805020.01,
      "ING",
      "start-up",
      "invoice2.txt",
      2,
      "credit",
      "$",
      3000,
      200,
      VAT_class = "low VAT"
    )
  )
  # clean-up
  clean_book()
})
