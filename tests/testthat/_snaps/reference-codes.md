# Check searches of account references

    Code
      check_account_ref("BFvaOvrVgbBej")
    Output
      # A tibble: 0 x 6
      # ... with 6 variables: reference code <chr>, reference number <chr>,
      #   description short <chr>, description long <chr>, one-man business <chr>,
      #   direction <chr>

---

    Code
      search_account_ref(c("lening", "mutaties"), "&", type = c("C", "D"))
    Output
      # A tibble: 2 x 6
        `reference code` `reference number` `description short`   `description long`  
        <chr>            <chr>              <chr>                 <chr>               
      1 BLasSakLvlOvm    0805030.07         Overige mutaties len~ Overige mutaties le~
      2 BLasSakOvlOvm    0805040.07         Overige mutaties len~ Overige mutaties le~
      # ... with 2 more variables: one-man business <chr>, direction <chr>

