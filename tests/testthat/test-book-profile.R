test_that("multiplication works", {
  text <- c("FAIReLABS", "Modelstraat12", "3017KHAmsterdam", "Netherlands", "schobbenmartin@gmail.com", "03012345", "https://martinschobben.github.io/webpage/", "12345678", " NL123456789B01", "NL99ABCD0123456789", "AAAABBCCDD")
  create_accountant(.test = text)
})
