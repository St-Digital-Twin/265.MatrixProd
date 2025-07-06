# Импорт внутренних функций не требуется, так как они находятся в том же пакете

# Явно объявляем используемые функции для линтера
#' @importFrom .GlobalEnv cpp_mmAccelerate

#' Check if Metal is available on the system
#'
#' @description 
#' Checks if the current system supports Metal GPU acceleration.
#'
#' @return Logical value indicating if Metal is available
#'
#' @examples
#' \dontrun{
#' if(is_metal_available()) {
#'   # Use Metal acceleration
#' }
#' }
#'
#' @export
is_metal_available <- function() {
  # Simple check for macOS
  is_mac <- .Platform$OS.type == "unix" && grepl("darwin", R.version$os)
  
  # For now, just return if we're on Mac
  # In a real implementation, would check Metal API availability
  return(is_mac)
}

# Stub implementation for gpu_mmMetal
# In a real implementation, this would call native Metal code
#' @rdname gpu_mmMetal
gpu_mmMetal <- function(A, B) {
  warning("Metal GPU implementation is not available in this version. Using CPU implementation instead.")
  # Используем функцию из того же пакета
  return(cpp_mmAccelerate(A, B))
}

#' OpenCL GPU Matrix Multiplication
#'
#' @description 
#' Performs matrix multiplication using OpenCL GPU acceleration.
#' This is a stub implementation that falls back to CPU acceleration.
#'
#' @param A First matrix
#' @param B Second matrix
#' @return Matrix product A * B
#'
#' @examples
#' \dontrun{
#' A <- matrix(runif(100), 10, 10)
#' B <- matrix(runif(100), 10, 10)
#' C <- gpu_mmOpenCL(A, B)
#' }
#'
#' @export
gpu_mmOpenCL <- function(A, B) {
  warning("OpenCL GPU implementation is not available in this version. Using CPU implementation instead.")
  return(cpp_mmAccelerate(A, B))
}
