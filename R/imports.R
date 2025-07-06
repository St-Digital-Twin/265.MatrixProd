#' @importFrom Rcpp evalCpp
#' @useDynLib MatrixProd, .registration = TRUE
NULL

# Объявляем глобальные переменные для подавления предупреждений линтера
utils::globalVariables(c(
  "_get_performance_info",
  "_rust_mmTiny_cpp",
  "_rust_mmBlocked_cpp",
  "_rust_mmAuto_cpp",
  "_cpp_mmAccelerate",
  "_gpu_mmMetal",
  "_is_metal_available"
))
