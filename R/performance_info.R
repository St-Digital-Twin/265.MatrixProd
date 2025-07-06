#' Get Performance Information
#'
#' @description 
#' Returns information about available hardware and performance capabilities
#' for matrix multiplication operations.
#'
#' @details
#' This function queries the system for hardware capabilities and returns
#' a numeric vector with the following information:
#' \itemize{
#'   \item [1] Accelerate framework availability (1 = available, 0 = not available)
#'   \item [2] OpenCL availability (1 = available, 0 = not available)
#'   \item [3] Metal availability (1 = available, 0 = not available)
#'   \item [4] Number of available CPU threads
#'   \item [5] SIMD support level (0 = none, 1 = basic, 2 = advanced)
#'   \item [6] Small matrix performance estimate (GFLOPS)
#'   \item [7] Medium matrix performance estimate (GFLOPS)
#'   \item [8] Large matrix performance estimate (GFLOPS)
#' }
#'
#' @return A numeric vector with performance information
#'
#' @examples
#' # Get hardware capabilities
#' perf_info <- get_performance_info()
#' print(perf_info)
#'
#' @export
get_performance_info <- function() {
  # Call the native implementation
  .Call("get_performance_info")
}
