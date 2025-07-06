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
  return(cpp_mmAccelerate(A, B))
}
