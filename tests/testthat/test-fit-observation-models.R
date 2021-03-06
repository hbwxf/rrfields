if (interactive()) options(mc.cores = parallel::detectCores())

ITER <- 600
CHAINS <- 2
SEED <- 9999
TOL <- 0.25 # %
TOL_df <- .25 # %

nknots <- 10
gp_sigma <- 0.3

# ------------------------------------------------------
# a negative binomial model

test_that("mvt-nb2 model fits", {
  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()
  set.seed(SEED)

  sigma <- 8
  df <- 5
  b0 <- 7
  n_draws <- 8
  gp_scale <- 1.6

  s <- sim_rrfield(df = df, n_draws = n_draws, gp_scale = gp_scale,
    gp_sigma = gp_sigma, sd_obs = sigma, n_knots = nknots,
    obs_error = "nb2", B = b0)
  # print(s$plot)

  m <- rrfield(y ~ 1, data = s$dat, time = "time", station = "station_id",
    lat = "lat", lon = "lon", nknots = nknots,
    iter = ITER, chains = CHAINS, obs_error = "nb2",
    estimate_df = FALSE, fixed_df_value = df,
    control = list(adapt_delta = 0.9), seed = SEED)

  p <- predict(m)

  b <- tidy(m, estimate.method = "median")
  expect_equal(b[b$term == "nb2_phi[1]", "estimate"], sigma, tol = sigma * TOL)
  expect_equal(b[b$term == "gp_sigma", "estimate"], gp_sigma, tol = gp_sigma * TOL)
  expect_equal(b[b$term == "gp_scale", "estimate"], gp_scale, tol = gp_scale * TOL)
  expect_equal(b[b$term == "B[1]", "estimate"], b0, tol = gp_scale * TOL)
})

# ------------------------------------------------------
# a Gamma observation model

test_that("mvt-gamma model fits", {
  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()

  set.seed(SEED)

  sigma <- 0.3
  df <- 10
  b0 <- 2
  n_draws <- 15
  gp_scale <- 1.6

  s <- sim_rrfield(df = df, n_draws = n_draws, gp_scale = gp_scale,
    gp_sigma = gp_sigma, sd_obs = sigma, n_knots = nknots,
    obs_error = "gamma", B = b0)
  # print(s$plot)

  m <- rrfield(y ~ 1, data = s$dat, time = "time", station = "station_id",
    lat = "lat", lon = "lon", nknots = nknots,
    iter = ITER, chains = CHAINS, obs_error = "gamma",
    estimate_df = FALSE, fixed_df_value = df, seed = SEED)

  p <- predict(m)

  b <- tidy(m, estimate.method = "median")
  expect_equal(b[b$term == "CV[1]", "estimate"], sigma, tol = sigma * TOL)
  expect_equal(b[b$term == "gp_sigma", "estimate"], gp_sigma, tol = gp_sigma * TOL)
  expect_equal(b[b$term == "gp_scale", "estimate"], gp_scale, tol = gp_scale * TOL)
  expect_equal(b[b$term == "B[1]", "estimate"], b0, tol = gp_scale * TOL)
})

# ------------------------------------------------------
# a binomial observation model

test_that("mvt-binomial model fits", {
  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()

  set.seed(SEED)

  nknots <- 12
  gp_sigma <- 1.2
  df <- 10
  b0 <- 0
  n_draws <- 15
  gp_scale <- 2.1

  s <- sim_rrfield(df = df, n_draws = n_draws, gp_scale = gp_scale,
    gp_sigma = gp_sigma, sd_obs = sigma, n_knots = nknots,
    obs_error = "binomial", B = b0)
  # print(s$plot)
  # out <- reshape2::melt(s$proj)
  # names(out) <- c("time", "pt", "y")
  # out <- dplyr::arrange_(out, "time", "pt")
  # out$lon <- s$dat$lon
  # out$lat <- s$dat$lat
  # ggplot2::ggplot(out, ggplot2::aes(lon, lat, colour = plogis(y))) + ggplot2::geom_point() +
  #   ggplot2::facet_wrap(~time)

  m <- rrfield(y ~ 0, data = s$dat, time = "time", station = "station_id",
    lat = "lat", lon = "lon", nknots = nknots,
    iter = ITER, chains = CHAINS, obs_error = "binomial",
    estimate_df = FALSE, fixed_df_value = df, seed = SEED)
  # m
  #
  # p <- predict(m)
  # p <- predict(m, interval = "prediction")

  b <- tidy(m, estimate.method = "median")
  expect_equal(b[b$term == "gp_sigma", "estimate"], gp_sigma, tol = gp_sigma * TOL)
  expect_equal(b[b$term == "gp_scale", "estimate"], gp_scale, tol = gp_scale * TOL)
})

# ------------------------------------------------------
# a poisson observation model

test_that("mvt-poisson model fits", {
  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()

  set.seed(SEED)

  nknots <- 12
  gp_sigma <- 0.8
  df <- 10
  b0 <- 3
  n_draws <- 15
  gp_scale <- 2.1

  s <- sim_rrfield(df = df, n_draws = n_draws, gp_scale = gp_scale,
    gp_sigma = gp_sigma, sd_obs = sigma, n_knots = nknots,
    obs_error = "poisson", B = b0)
  # print(s$plot)
  # hist(s$dat$y)

  m <- rrfield(y ~ 1, data = s$dat, time = "time", station = "station_id",
    lat = "lat", lon = "lon", nknots = nknots,
    iter = ITER, chains = CHAINS, obs_error = "poisson",
    estimate_df = FALSE, fixed_df_value = df, seed = SEED)
  m

  b <- tidy(m, estimate.method = "median")
  expect_equal(b[b$term == "gp_sigma", "estimate"], gp_sigma, tol = gp_sigma * TOL)
  expect_equal(b[b$term == "gp_scale", "estimate"], gp_scale, tol = gp_scale * TOL)
  expect_equal(b[b$term == "B[1]", "estimate"], b0, tol = gp_scale * TOL)
})
