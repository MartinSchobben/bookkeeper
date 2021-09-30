# Check that daybook entries works

    Code
      add_daybook_entry(Sys.Date(), "bank", 805020.01, "ABN-AMBRO", "start-up",
      "invoice.txt", 1, "credit", "$", 1000, 105, 45, VAT_class = c("high VAT",
        "low VAT"))
    Output
      # A tibble: 1 x 11
        `date of transaction` daybook `account refere~ entity comment `invoice number`
        <date>                <chr>              <dbl> <chr>  <chr>              <dbl>
      1 2021-09-30            bank             805020. ABN-A~ start-~                1
      # ... with 5 more variables: direction <chr>, currency <chr>, amount <dbl>,
      #   high VAT <dbl>, low VAT <dbl>

---

    Code
      add_daybook_entry(Sys.Date(), "bank", 805020.01, "ING", "start-up",
      "invoice2.txt", 2, "credit", "$", 3000, 200, VAT_class = "low VAT")
    Output
      # A tibble: 2 x 11
        `date of transaction` daybook `account refere~ entity comment `invoice number`
        <date>                <chr>              <dbl> <chr>  <chr>              <dbl>
      1 2021-09-30            bank             805020. ABN-A~ start-~                1
      2 2021-09-30            bank             805020. ING    start-~                2
      # ... with 5 more variables: direction <chr>, currency <chr>, amount <dbl>,
      #   high VAT <dbl>, low VAT <dbl>

