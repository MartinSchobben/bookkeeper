# Setup bill without saving intermediates.

    Code
      make_bill(lang = "nl", .save = FALSE, .bill = bill)
    Output
      # A tibble: 4 x 5
        description                VAT_class currency price group    
        <chr>                          <dbl> <chr>    <dbl> <chr>    
      1 Vormgeving (30 uur à € 60)        21 €         1800 items    
      2 Subtotaal                         NA €         1800 sub_total
      3 Btw 21 %                          NA €          378 high VAT 
      4 Totaal                            NA €         2178 total    

# two bill entries at once

    Code
      add_bill_entry(c("10 foto’s à € 150", "Vormgeving (30 uur à € 60)"), 21, "€", c(
        1500, 1800))
    Output
      # A tibble: 2 x 5
        description                VAT_class currency price group
        <chr>                          <dbl> <chr>    <dbl> <chr>
      1 10 foto’s à € 150                 21 €         1500 items
      2 Vormgeving (30 uur à € 60)        21 €         1800 items

