#' MatrixProd: High-Performance Matrix Multiplication for R
#'
#' @description
#' MatrixProd provides high-performance matrix multiplication functions for R,
#' with specialized implementations for different matrix sizes and hardware configurations.
#' Based on extensive benchmarking, this package offers optimized algorithms
#' that can achieve up to 397 GFLOPS on supported hardware.
#' 
#' @section Main Functions:
#' \describe{
#'   \item{\code{\link{fastMatMul}}}{Smart function that automatically selects the optimal algorithm}
#'   \item{\code{\link{mmTiny}}}{Ultra-fast implementation for small matrices (<500x500)}
#'   \item{\code{\link{cpuFastMatMul}}}{Optimized CPU implementation using hardware acceleration}
#'   \item{\code{\link{gpuMatMul}}}{GPU-accelerated implementation using OpenCL}
#'   \item{\code{\link{mmHuge}}}{Specialized version for very large matrices with memory optimization}
#' }
#'
#' @section Performance:
#' The package achieves the following performance levels:
#' \itemize{
#'   \item Small matrices (100x100): Up to 26.2 GFLOPS using Rust-based implementation
#'   \item Medium matrices (500x500): Up to 143.7 GFLOPS using GPU acceleration
#'   \item Large matrices (2000x2000): Up to 397 GFLOPS using C++ Metal GPU implementation
#' }
#'
#' @docType package
#' @name MatrixProd
#' @useDynLib MatrixProd, .registration = TRUE
#' @importFrom Rcpp evalCpp
#' @importFrom stats runif
NULL
