test_that("make account", {
  usethis::local_project(force = TRUE)
  setup_book()
  text <-
    c(
      "FAIReLABS",
      "Modelstraat 12",
      "3017 KH Amsterdam",
      "Netherlands",
      "schobbenmartin@gmail.com",
      "03012345",
      "https://martinschobben.github.io/webpage/",
      "12345678",
      "NL123456789B01",
      "NL99ABCD0123456789",
      "AAAABBCCDD"
    )
  expect_invisible(create_accountant(.text = text, quiet = TRUE))
  # clean-up
  clean_book()
})
