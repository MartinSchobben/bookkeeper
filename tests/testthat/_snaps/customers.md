# customer entry works

    Code
      add_customer_entry("Fancy Stuff inc", "G. Janssen", "Liftweg 135",
        "7009 ZZ Doetinchem", "Netherlands", "NL10937277")
    Output
      # A tibble: 1 x 7
        `customer number` company         name       street      city    country VAT  
        <chr>             <chr>           <chr>      <chr>       <chr>   <chr>   <chr>
      1 060101            Fancy Stuff inc G. Janssen Liftweg 135 7009 Z~ Nether~ NL10~

---

    Code
      add_customer_entry("Fancy Work", NA_character_, "Vleutensebaan 435",
        "7009 ZZ Haarlem", "Netherlands", "NL1093se44")
    Output
      # A tibble: 2 x 7
        `customer number` company         name       street    city     country VAT   
        <chr>             <chr>           <chr>      <chr>     <chr>    <chr>   <chr> 
      1 060101            Fancy Stuff inc G. Janssen Liftweg ~ 7009 ZZ~ Nether~ NL109~
      2 060102            Fancy Work      <NA>       Vleutens~ 7009 ZZ~ Nether~ NL109~

