testthat::test_that("e2e: module content is updated when a data is filtered in filter panel", {
  app <- TealAppDriver$new(
    data = simple_teal_data(),
    modules = modules(
      example_module(label = "Module_1"),
      example_module(label = "Module_2")
    ),
    filter = teal_slices(
      teal_slice(id = "iris_species", dataname = "iris", varname = "Species", multiple = TRUE),
      teal_slice(id = "mtcars_cyl", dataname = "mtcars", varname = "cyl", selected = c(4, 6)),
      teal_slice(id = "mtcars_drat", dataname = "mtcars", varname = "drat", selected = c(3, 4)),
      teal_slice(id = "mtcars_gear", dataname = "mtcars", varname = "gear")
    )
  )

  app$wait_for_idle(timeout = default_idle_timeout)

  old_output <- app$get_active_module_output("text")

  app$set_active_filter_selection("iris", "Species", c("setosa", "versicolor"))

  testthat::expect_false(
    identical(old_output, app$get_active_module_output("text"))
  )

  app$stop()
})

testthat::test_that("e2e: filtering a module-specific filter is refected in other shared module", {
  app <- TealAppDriver$new(
    data = simple_teal_data(),
    modules = modules(
      example_module(label = "Module_1"),
      example_module(label = "Module_2")
    ),
    filter = teal_slices(
      teal_slice(id = "iris_species", dataname = "iris", varname = "Species", multiple = TRUE),
      teal_slice(id = "mtcars_cyl_1", dataname = "mtcars", varname = "cyl", selected = c(4, 6)),
      teal_slice(id = "mtcars_cyl_2", dataname = "mtcars", varname = "cyl", selected = c(4, 6)),
      module_specific = TRUE,
      mapping = list(
        "Module_1" = c("iris_species", "mtcars_cyl_1"),
        "Module_2" = c("iris_species", "mtcars_cyl_2")
      )
    )
  )

  app$wait_for_idle(timeout = default_idle_timeout)

  expect_equal(
    app$get_active_filter_selection("iris", "Species"),
    c("setosa", "versicolor", "virginica")
  )

  app$navigate_teal_tab("Module_2")
  app$wait_for_idle(timeout = default_idle_timeout)

  app$set_active_filter_selection("iris", "Species", c("setosa"))

  app$navigate_teal_tab("Module_1")
  app$wait_for_idle(timeout = default_idle_timeout)

  expect_equal(
    app$get_active_filter_selection("iris", "Species"),
    c("setosa")
  )

  app$stop()
})

testthat::test_that("e2e: filtering a module-specific filter is not refected in other unshared modules", {
  app <- TealAppDriver$new(
    data = simple_teal_data(),
    modules = modules(
      example_module(label = "Module_1"),
      example_module(label = "Module_2")
    ),
    filter = teal_slices(
      teal_slice(id = "iris_species", dataname = "iris", varname = "Species", multiple = TRUE),
      teal_slice(id = "mtcars_cyl_1", dataname = "mtcars", varname = "cyl", selected = c(4, 6)),
      teal_slice(id = "mtcars_cyl_2", dataname = "mtcars", varname = "cyl", selected = c(4, 6)),
      module_specific = TRUE,
      mapping = list(
        "Module_1" = c("iris_species", "mtcars_cyl_1"),
        "Module_2" = c("iris_species", "mtcars_cyl_2")
      )
    )
  )

  app$wait_for_idle(timeout = default_idle_timeout)

  expect_equal(
    app$get_active_filter_selection("mtcars", "cyl"),
    c("4", "6")
  )

  app$navigate_teal_tab("Module_2")
  app$wait_for_idle(timeout = default_idle_timeout)

  app$set_active_filter_selection("mtcars", "cyl", c("4"))

  app$navigate_teal_tab("Module_1")
  app$wait_for_idle(timeout = default_idle_timeout)

  expect_equal(
    app$get_active_filter_selection("mtcars", "cyl"),
    c("4", "6")
  )

  app$stop()
})