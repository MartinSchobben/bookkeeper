## code to prepare `code_refs` dataset goes here
code_refs <- tibble::tibble(
  country = "Netherlands",
  country_code = "NL",
  url_ref = "https://www.referentiegrootboekschema.nl/sites/default/files/kennisbank/Defversie%20RGS%203.3-8-dec-2020.xlsx",
  args_read = list(list(sheet = 3, skip = 1, col_types = "text")),
  var_select =
    list(
      c(
    `reference code` = "Referentiecode...4",
    `reference number` = "Referentienummer",
    `description short` = "Omschrijving (verkort)",
    `description long` = "Omschrijving",
     direction = "D/C"
      )
    )
)

usethis::use_data(code_refs, internal = TRUE, overwrite = TRUE)
