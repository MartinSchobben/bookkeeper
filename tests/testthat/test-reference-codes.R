# golden test
test_that("multiplication works", {
  expect_snapshot(check_account_ref("BFvaOvrVgbBej"))
  expect_snapshot(search_account_ref(c("lening", "mutaties"), "&", type =c("C", "D")))
})
