test_that("multiplication works", {
  render_invoice(c("Fancy Stuff inc", "t.a.v. mevrouw G. Janssen",
                   "Liftweg 135","7009 ZZ Doetinchem"), 1, 1)
})
