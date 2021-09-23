# golden test
test_that("journal entry works", {
  expect_snapshot(add_entry(Sys.Date(), "$", 1000, 200, "credit",
                            "BFvaLenLenLn1", "Bank",
                            "start-up", "invoice.txt", 1))
  # clean-up
  fs::dir_delete("invoice-library")
  fs::file_delete(c("SBR.RDS", "journal.RDS"))
})


