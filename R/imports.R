#' @importFrom Rcpp evalCpp
#' @useDynLib MatrixProd, .registration = TRUE
NULL

# Объявляем глобальные переменные для подавления предупреждений линтера
utils::globalVariables(c(
  "_get_performance_info",
  "_rust_mmTiny_cpp",
  "_cpp_mmAccelerate"
))
