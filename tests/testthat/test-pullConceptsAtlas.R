# Create a WebAPI response without contacting the server.
webApiResponse <- function(body, status = 200L) {
  structure(
    list(
      status_code = status,
      headers = list(`content-type` = "application/json"),
      content = charToRaw(body),
      url = "https://example.org/WebAPI"
    ),
    class = "response"
  )
}

# These packages are optional for studyGenerics, but needed for these tests.
skipWithoutWebApiDependencies <- function() {
  for (package in c("httr", "RJSONIO", "lubridate", "rlang")) {
    skip_if_not_installed(package)
  }
}

test_that("getConceptSetDefinition downloads the definition and its concept list", {
  skipWithoutWebApiDependencies()

  # Record the requests and return example responses.
  urls <- character()
  local_mocked_bindings(GET = function(url, ...) {
    urls <<- c(urls, url)
    configs <- list(...)
    headers <- unlist(lapply(configs, function(x) x$headers))
    expect_equal(unname(headers["Authorization"]), "Bearer example-token")
    request_options <- unlist(lapply(configs, function(x) x$options))
    expect_equal(unname(request_options["followlocation"]), 0)
    if (endsWith(url, "/info")) {
      return(webApiResponse('{"version":"2.14.0"}'))
    }
    if (endsWith(url, "/expression")) {
      return(webApiResponse('{"items":[{"concept":{"CONCEPT_ID":123},"isExcluded":false}]}'))
    }
    webApiResponse('{"id":1,"name":"Example"}')
  }, .package = "httr")

  # Get the concept set using a test token.
  result <- getConceptSetDefinition(
    conceptSetId = 1,
    baseUrl = "https://example.org/WebAPI/",
    authHeader = "example-token"
  )

  # Expect a version check, a definition request, and a concept-list request.
  expect_equal(
    urls,
    paste0(
      "https://example.org/WebAPI",
      c("/info", "/conceptset/1", "/conceptset/1/expression")
    )
  )
  expect_equal(result$name, "Example")
  expect_equal(result$expression$items[[1]]$concept$CONCEPT_ID, 123)
  expect_false(result$expression$items[[1]]$isExcluded)
})

test_that("getConceptSetDefinition reads the different WebAPI expression formats", {
  skipWithoutWebApiDependencies()

  # Return the definition directly, without a separate concept-list request.
  definition <- list(name = "Example", expression = list(items = list()))
  local_mocked_bindings(.GET = function(url, authHeader = "") {
    if (endsWith(url, "/info")) {
      return(webApiResponse('{"version":"2.14.0"}'))
    }
    expect_false(endsWith(url, "/expression"))
    webApiResponse(jsonlite::toJSON(definition, auto_unbox = TRUE))
  })

  # WebAPI may store the concept list under any of these names.
  for (field in c("expression", "specification", "design")) {
    definition <- list(name = "Example")
    definition[[field]] <- list(items = list())
    result <- getConceptSetDefinition(
      conceptSetId = 1,
      baseUrl = "https://example.org/WebAPI",
      authHeader = ""
    )
    expect_equal(result$expression, list(items = list()))
  }

  # A JSON string is parsed, and a date in milliseconds is converted.
  definition <- list(name = "Example", expression = '{"items":[]}', createdDate = 0)
  result <- getConceptSetDefinition(
    conceptSetId = 1,
    baseUrl = "https://example.org/WebAPI",
    authHeader = ""
  )
  expect_true(is.list(result$expression))
  expect_s3_class(result$createdDate, "POSIXct")
  expect_equal(as.numeric(result$createdDate), 0)
  # Invalid JSON should give a clear error.
  definition$expression <- "invalid json"
  expect_error(
    getConceptSetDefinition(1, "https://example.org/WebAPI", authHeader = ""),
    "invalid JSON expression"
  )
})

test_that("WebAPI errors do not include the token", {
  skipWithoutWebApiDependencies()

  # Return each HTTP error without making a real request.
  status <- 401L
  local_mocked_bindings(GET = function(...) webApiResponse("{}", status),
                        .package = "httr")
  expected_errors <- c(
    "401" = "webapi-unauthorized",
    "403" = "webapi-forbidden",
    "404" = "webapi-notfound",
    "500" = "webapi-server"
  )
  for (status_code in names(expected_errors)) {
    status <- as.integer(status_code)
    error <- tryCatch(
      .GET("https://example.org/WebAPI/info", authHeader = "example-token"),
      error = identity
    )
    expect_s3_class(error, expected_errors[[status_code]])
    expect_false(grepl("example-token", conditionMessage(error), fixed = TRUE))
  }
  # Redirects should also stop the request.
  status <- 302L
  expect_error(.GET("https://example.org/WebAPI/info"), class = "http_302")
})

test_that("getConceptSetDefinition checks the URL and concept-set ID", {
  skipWithoutWebApiDependencies()

  # Tokens require HTTPS, and concept-set IDs must be whole numbers.
  expect_error(
    getConceptSetDefinition(1, "http://example.org/WebAPI", authHeader = "example-token"),
    "Use HTTPS"
  )
  expect_error(
    getConceptSetDefinition(1.5, "https://example.org/WebAPI", authHeader = "")
  )
})

test_that("public WebAPI requests work without a token and reject incomplete responses", {
  skipWithoutWebApiDependencies()

  # Check that public requests have no authorization header.
  local_mocked_bindings(GET = function(url, ...) {
    headers <- unlist(lapply(list(...), function(x) x$headers))
    expect_false("Authorization" %in% names(headers))
    webApiResponse("{}")
  }, .package = "httr")
  # The server must provide its version and a valid concept-set definition.
  expect_error(
    getConceptSetDefinition(1, "https://example.org/WebAPI", authHeader = ""),
    "Could not verify the WebAPI version"
  )
  local_mocked_bindings(getWebApiVersion = function(...) "2.14.0")
  expect_error(
    getConceptSetDefinition(1, "https://example.org/WebAPI", authHeader = ""),
    "invalid concept-set definition"
  )
})

test_that("pullConceptsAtlas saves concept sets with clean file names", {
  skipWithoutWebApiDependencies()

  # Save files in a temporary study folder.
  test_root <- withr::local_tempdir()
  local_mocked_bindings(here = function(...) file.path(test_root, ...), .package = "here")
  # Return two example concept sets instead of contacting ATLAS.
  local_mocked_bindings(.GET = function(url, authHeader = "") {
    if (endsWith(url, "/info")) {
      return(webApiResponse('{"version":"2.14.0"}'))
    }
    id <- as.numeric(basename(url))
    webApiResponse(jsonlite::toJSON(list(
      id = id, name = paste(id, "Lung Cancer"),
      expression = list(items = list(list(concept = list(CONCEPT_ID = id))))
    ), auto_unbox = TRUE))
  })
  result <- pullConceptsAtlas(
    conceptSetList = c(1, 2),
    conceptSetType = "example",
    baseUrl = "https://example.org/WebAPI",
    authHeader = ""
  )

  # Check the returned summary and the contents of each saved file.
  expect_equal(result$conceptSetId, c(1, 2))
  expect_equal(result$fileName, c("1_lung_cancer.json", "2_lung_cancer.json"))
  for (i in seq_len(nrow(result))) {
    output <- file.path(test_root, "inst", "concept_sets", "example", result$fileName[i])
    expect_true(file.exists(output))
    expression <- jsonlite::fromJSON(output, simplifyVector = FALSE)
    expect_equal(expression$items[[1]]$concept$CONCEPT_ID, i)
  }
})

test_that("pullConceptsAtlas stops before creating files if httr is missing", {
  test_root <- withr::local_tempdir()
  local_mocked_bindings(here = function(...) file.path(test_root, ...), .package = "here")
  # Simulate a missing package without uninstalling anything.
  local_mocked_bindings(requireInstall = function(package) {
    if (package == "httr") {
      stop("'httr' must be installed to use this function.")
    }
  })
  expect_error(
    pullConceptsAtlas(conceptSetList = 1, conceptSetType = "example", authHeader = ""),
    "'httr' must be installed"
  )
  expect_false(dir.exists(file.path(test_root, "inst")))
})

test_that("pullConceptsAtlas downloads real ATLAS concept sets using ATLAS_TOKEN", {
  skip_on_cran()
  skipWithoutWebApiDependencies()
  skip_if(
    !nzchar(Sys.getenv("ATLAS_TOKEN")),
    "ATLAS_TOKEN is not set; live test skipped"
  )

  # Use the real server, but save the downloads in a temporary folder.
  test_root <- withr::local_tempdir()
  local_mocked_bindings(here = function(...) file.path(test_root, ...), .package = "here")

  downloaded_concepts <- pullConceptsAtlas(
    conceptSetList = c(5305, 5293),
    conceptSetType = "cancer_cohorts",
    baseUrl = "https://atlas.darwin-eu.org/WebAPI",
    deletePrevious = TRUE,
    patternToRemove = c("p4-c4-002", "onconet", "hierarchy_based")
  )
  # Expect both lung cancer concept sets and valid JSON files.
  expect_equal(downloaded_concepts$conceptSetId, c(5305, 5293))
  expect_true(all(grepl("lung_cancer", downloaded_concepts$fileName)))
  for (file_name in downloaded_concepts$fileName) {
    output <- file.path(test_root, "inst", "concept_sets", "cancer_cohorts", file_name)
    expect_true(file.exists(output))
    expect_true(jsonlite::validate(paste(readLines(output), collapse = "\n")))
  }
})
