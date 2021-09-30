## code to prepare `trans_langs` dataset goes here
trans_langs <- tibble::tibble(
  ID = c("sub_total", "VAT", "total", "VAT_id", "VAT_num"),
  type = c(rep("bill", 3), rep("invoice", 2)),
  nl = c("Subtotaal", "Btw", "Totaal", "KVK", "Btw-id"),
  en = c("Subtotal", "VAT", "Total", "VAT ID", "VAT tax number")
)

## code to prepare `code_refs` dataset goes here
code_refs <- tibble::tibble(
  country = "Netherlands",
  country_code = "NL",
  url_ref = "https://www.referentiegrootboekschema.nl/sites/default/files/kennisbank/Defversie%20RGS%203.3-8-dec-2020.xlsx",
  args_read = list(list(sheet = 2, skip = 1, col_types = "text")),
  var_select =
    list(
      c(
        `reference code` = "Referentiecode",
        `reference number` = "Referentienummer",
        `description short` = "Omschrijving (verkort)",
        `description long` = "Omschrijving",
        `one-man business` = "EZ/VOF...12",
        direction = "D/C"
      )
    )
)


usethis::use_data(trans_langs, code_refs, internal = TRUE, overwrite = TRUE)
