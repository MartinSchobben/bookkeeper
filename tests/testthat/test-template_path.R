test_that("path to template", {
  expect_equal(
    fs::path_file(rmd_template_path(path = "skeleton.Rmd")),
    "skeleton.Rmd"
    )
})
