# journal entry works

    Code
      add_entry(Sys.Date(), "$", 1000, 200, "credit", "BFvaLenLenLn1", "Bank",
      "start-up", "invoice.txt", 1)
    Output
      # A tibble: 1 x 9
        `date of payment` currency amount   VAT direction `reference code` entity
        <chr>             <chr>     <dbl> <dbl> <chr>     <chr>            <chr> 
      1 2021-09-24        $          1000   200 credit    BFvaLenLenLn1    Bank  
      # ... with 2 more variables: comment <chr>, invoice number <chr>

