# golden test
test_that("Check searches of account references", {
  usethis::local_project(force = TRUE)
  setup_book("reference-codes")
  # search
  expect_snapshot(check_account_ref("BFvaOvrVgbBej"))
  expect_snapshot(
    search_account_ref(c("lening", "mutaties"), "&", type =c("C", "D"))
    )
  # clean-up
  clean_book()
})
