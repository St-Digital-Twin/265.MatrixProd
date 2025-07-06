
#' @title Backward Compatibility Wrappers
#' @description
#' These functions provide backward compatibility with previous versions
#' of the package. They simply call the new functions with updated names.
#'
#' @name compatibility
NULL

#' @rdname compatibility
#' @export
mmTiny <- function(A, B) {
  rust_mmTiny(A, B)
}

#' @rdname compatibility
#' @export
cpuFastMatMul <- function(A, B) {
  cpp_mmAccelerate(A, B)
}

#' @rdname compatibility
#' @export
gpuMatMul <- function(A, B) {
  # Try Metal first, fall back to OpenCL
  if (is_metal_available()) {
    gpu_mmMetal(A, B)
  } else {
    gpu_mmOpenCL(A, B)
  }
}

#' @rdname compatibility
#' @export
mmHuge <- function(A, B) {
  block_mmHuge(A, B)
}

