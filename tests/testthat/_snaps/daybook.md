# Check that daybook entries works

    Code
      add_daybook_entry(as.Date("2011-07-12"), "bank", 805020.01, "ABN-AMBRO", "loan",
      "start-up", "invoice.txt", 1, "credit", "$", 1000, 105, 45, VAT_class = c(
        "high VAT", "low VAT"))
    Output
      # A tibble: 1 x 12
        `date of transaction` daybook `account reference num~ entity   product comment
        <date>                <chr>                     <dbl> <chr>    <chr>   <chr>  
      1 2011-07-12            bank                    805020. ABN-AMB~ loan    start-~
      # ... with 6 more variables: invoice number <dbl>, direction <chr>,
      #   currency <chr>, amount <dbl>, high VAT <dbl>, low VAT <dbl>

---

    Code
      add_daybook_entry(as.Date("2011-07-13"), "bank", 805020.01, "ING", "loan",
      "start-up", "invoice2.txt", 2, "credit", "$", 3000, 200, VAT_class = "low VAT")
    Output
      # A tibble: 2 x 12
        `date of transaction` daybook `account reference num~ entity   product comment
        <date>                <chr>                     <dbl> <chr>    <chr>   <chr>  
      1 2011-07-12            bank                    805020. ABN-AMB~ loan    start-~
      2 2011-07-13            bank                    805020. ING      loan    start-~
      # ... with 6 more variables: invoice number <dbl>, direction <chr>,
      #   currency <chr>, amount <dbl>, high VAT <dbl>, low VAT <dbl>

