library(testthat)
context("Test rlasso")
library(hdm)


DGP_rlasso <- function(n, p, px){
  
  X <- matrix(rnorm(n*p), ncol=p)
  colnames(X) <- paste("x", 1:p, sep="")
  beta <- c(rep(2,px), rep(0,p-px))
  intercept <- 1
  y <- intercept + X %*% beta + rnorm(n)
  
  list(X = X, y = y, beta = beta)
}


set.seed(2)
ret <- DGP_rlasso(200, 100, 10)
X <- ret$X
y <- as.vector(ret$y)
beta <- ret$beta
frame <- as.data.frame(cbind(y, X))
colnames(frame) <- c("y", paste0("x", 1:100))
rm(ret)


test_that("rlasso - Input check x and y",{
  expect_is(rlasso(X, y), "rlasso")
  expect_is(rlasso(as.data.frame(X), y), "rlasso")
  expect_is(rlasso(X, as.vector(y)), "rlasso")
  expect_is(rlasso(as.data.frame(X), as.vector(y)), "rlasso")
  expect_is(rlasso(X[, 1, drop = FALSE], y), "rlasso")
  expect_is(rlasso(X[, 1, drop = FALSE], as.vector(y)), "rlasso")
  expect_is(rlasso(as.data.frame(X[, 1, drop = FALSE]), y), "rlasso")
  expect_is(rlasso(as.data.frame(X[, 1, drop = FALSE]), as.vector(y)), "rlasso")
})

test_that("rlasso - formula",{
  expect_is(rlasso(y ~ X), "rlasso")
  expect_is(rlasso(y ~ ., data = frame), "rlasso")
  expect_is(rlasso(y ~ x1, data = frame), "rlasso")
  expect_is(rlasso(y ~ x1 + x33 + x78, data = frame), "rlasso")
})


test_that("rlasso - Input check post, intercept and normalize",{
  expect_is(rlasso(X, y, post = FALSE), "rlasso")
  expect_is(rlasso(X, y, intercept = FALSE), "rlasso")
  expect_is(rlasso(X, y, normalize = FALSE), "rlasso")
  expect_is(rlasso(X, y, normalize = FALSE, intercept = FALSE), "rlasso")
  expect_is(rlasso(as.data.frame(X), y, intercept = FALSE, normalize = FALSE), "rlasso")
})

test_that("rlasso - Input check penalty",{
  expect_is(rlasso(X, y, penalty = list(homoscedastic = FALSE, X.dependent.lambda =FALSE)), "rlasso")
  expect_is(rlasso(X, y, penalty = list(homoscedastic = TRUE, X.dependent.lambda =FALSE)), "rlasso")
  expect_is(rlasso(X, y, penalty = list(homoscedastic = FALSE, X.dependent.lambda = TRUE)), "rlasso")
  expect_is(rlasso(X, y, penalty = list(homoscedastic = TRUE, X.dependent.lambda = TRUE, numSim = 4000)), "rlasso")
  expect_is(rlasso(X, y, penalty = list(homoscedastic = "none", X.dependent.lambda =FALSE, lambda.start = 100)), "rlasso")
  expect_is(rlasso(X, y, penalty = list(homoscedastic = "none", X.dependent.lambda = TRUE, lambda.start = 100)), "rlasso")
  expect_is(rlasso(X, y, intercept = FALSE, penalty = list(homoscedastic = "none", X.dependent.lambda =FALSE, lambda.start = 100)), "rlasso")
  expect_is(rlasso(X, y, penalty = list(homoscedastic = FALSE, X.dependent.lambda =FALSE, 
                                        lambda.start = NULL, c = 1.1, gamma = 0.1)), "rlasso")
})

test_that("rlasso - Input check control",{
  expect_is(rlasso(X, y, control = list(numIter = 15, tol = 10^-4, threshold = 10^-3)),"rlasso")
  expect_is(rlasso(X, y, control = list(numIter = 25)), "rlasso")         
})

test_that("rlasso - check methods",{
  expect_error(summary(rlasso(X, y), all = FALSE), NA)
  expect_error(print(rlasso(X, y)), NA)
  expect_error(model.matrix(rlasso(X, y)), NA)
  expect_error(model.matrix(rlasso(y ~ X)), NA)
  expect_error(model.matrix(rlasso(y ~ ., data = frame)), NA)
  expect_error(predict(rlasso(X, y)), NA)
  expect_error(predict(rlasso(X, y, intercept = FALSE)), NA)
  expect_error(predict(rlasso(y ~ X)), NA)
  expect_error(predict(rlasso(y ~ ., data = frame)), NA)
  expect_error(predict(rlasso(X, y), as.data.frame(2 * X)), NA)
  expect_error(predict(rlasso(y ~ X), as.data.frame(2 * X)), NA)
  expect_error(predict(rlasso(y ~ ., data = frame), as.data.frame(2 * X)), NA)
  #expect_that(predict(rlasso(y ~ ., data = frame), cbind(frame, rnorm(nrow(frame)))), not(throws_error()))
})


