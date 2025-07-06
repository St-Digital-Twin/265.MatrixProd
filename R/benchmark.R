#' Benchmark Matrix Multiplication Performance
#'
#' @description 
#' Run performance benchmarks for matrix multiplication using different methods
#' and matrix sizes. This function helps determine the optimal method for your
#' specific hardware configuration.
#'
#' @param sizes Vector of matrix sizes to benchmark. Default: c(100, 500, 1000, 2000)
#' @param methods Vector of methods to benchmark. Default: c("R", "tiny", "cpu", "gpu")
#' @param iterations Number of iterations for each benchmark. Default: 3
#' @param verbose Logical; whether to print progress. Default: TRUE
#'
#' @return A data frame with benchmark results containing columns:
#'   Size, Method, Time_ms, GFLOPS, Speedup
#'
#' @examples
#' \dontrun{
#' # Run the benchmark
#' results <- benchmark_matmul()
#'
#' # Plot the results
#' plot(results)
#' }
#'
#' @export
benchmark_matmul <- function(sizes = c(100, 500, 1000, 2000),
                             methods = c("R", "tiny", "cpu", "gpu"),
                             iterations = 3,
                             verbose = TRUE) {
  
  # Check for required packages
  if (!requireNamespace("bench", quietly = TRUE)) {
    stop("Package 'bench' is required for benchmarking. Please install it.")
  }
  
  # Initialize results data frame
  results <- data.frame(
    Size = numeric(),
    Method = character(),
    Time_ms = numeric(),
    GFLOPS = numeric(),
    Speedup = numeric(),
    stringsAsFactors = FALSE
  )
  
  # Check GPU availability
  has_gpu <- "gpu" %in% methods && tryCatch({
    requireNamespace("gpuR", quietly = TRUE) && gpuR::detectGPUs() > 0
  }, error = function(e) FALSE)
  
  if ("gpu" %in% methods && !has_gpu) {
    warning("GPU method requested but no compatible GPU found. Skipping GPU benchmarks.")
    methods <- setdiff(methods, "gpu")
  }
  
  # Run benchmarks for each size and method
  for (size in sizes) {
    if (verbose) cat(sprintf("Benchmarking matrices of size %d x %d...\n", size, size))
    
    # Create test matrices
    A <- matrix(runif(size * size), size, size)
    B <- matrix(runif(size * size), size, size)
    
    # Calculate theoretical FLOPS for this matrix size
    # For matrix multiplication, FLOPS = 2 * n³ (n multiplications and n additions for each element)
    flops <- 2 * size^3
    
    # Base R implementation (for reference)
    if ("R" %in% methods) {
      if (verbose) cat("  Benchmarking R base...\n")
      
      time_r <- bench::mark(
        base_r = A %*% B,
        min_iterations = iterations,
        max_iterations = iterations * 2,
        check = FALSE
      )
      
      mean_time_r <- mean(time_r$time) / 1e6  # Convert to milliseconds
      gflops_r <- (flops / mean_time_r) / 1e6  # GFLOPS calculation
      
      results <- rbind(results, data.frame(
        Size = size,
        Method = "R_base",
        Time_ms = mean_time_r,
        GFLOPS = gflops_r,
        Speedup = 1.0,
        stringsAsFactors = FALSE
      ))
    }
    
    # Tiny method
    if ("tiny" %in% methods) {
      if (verbose) cat("  Benchmarking mmTiny...\n")
      
      time_tiny <- bench::mark(
        tiny = mmTiny(A, B),
        min_iterations = iterations,
        max_iterations = iterations * 2,
        check = FALSE
      )
      
      mean_time_tiny <- mean(time_tiny$time) / 1e6
      gflops_tiny <- (flops / mean_time_tiny) / 1e6
      
      results <- rbind(results, data.frame(
        Size = size,
        Method = "mmTiny",
        Time_ms = mean_time_tiny,
        GFLOPS = gflops_tiny,
        Speedup = ifelse("R" %in% methods, mean_time_r / mean_time_tiny, NA),
        stringsAsFactors = FALSE
      ))
    }
    
    # CPU method
    if ("cpu" %in% methods) {
      if (verbose) cat("  Benchmarking cpuFastMatMul...\n")
      
      time_cpu <- bench::mark(
        cpu = cpuFastMatMul(A, B),
        min_iterations = iterations,
        max_iterations = iterations * 2,
        check = FALSE
      )
      
      mean_time_cpu <- mean(time_cpu$time) / 1e6
      gflops_cpu <- (flops / mean_time_cpu) / 1e6
      
      results <- rbind(results, data.frame(
        Size = size,
        Method = "cpuFastMatMul",
        Time_ms = mean_time_cpu,
        GFLOPS = gflops_cpu,
        Speedup = ifelse("R" %in% methods, mean_time_r / mean_time_cpu, NA),
        stringsAsFactors = FALSE
      ))
    }
    
    # GPU method
    if ("gpu" %in% methods && has_gpu) {
      if (verbose) cat("  Benchmarking gpuMatMul...\n")
      
      # Need to handle the first call separately as it includes compilation time
      invisible(gpuMatMul(matrix(runif(10*10), 10, 10), matrix(runif(10*10), 10, 10)))
      
      time_gpu <- bench::mark(
        gpu = gpuMatMul(A, B),
        min_iterations = iterations,
        max_iterations = iterations * 2,
        check = FALSE
      )
      
      mean_time_gpu <- mean(time_gpu$time) / 1e6
      gflops_gpu <- (flops / mean_time_gpu) / 1e6
      
      results <- rbind(results, data.frame(
        Size = size,
        Method = "gpuMatMul",
        Time_ms = mean_time_gpu,
        GFLOPS = gflops_gpu,
        Speedup = ifelse("R" %in% methods, mean_time_r / mean_time_gpu, NA),
        stringsAsFactors = FALSE
      ))
    }
    
    # Automatic method
    if ("auto" %in% methods) {
      if (verbose) cat("  Benchmarking fastMatMul (auto)...\n")
      
      time_auto <- bench::mark(
        auto = fastMatMul(A, B),
        min_iterations = iterations,
        max_iterations = iterations * 2,
        check = FALSE
      )
      
      mean_time_auto <- mean(time_auto$time) / 1e6
      gflops_auto <- (flops / mean_time_auto) / 1e6
      
      results <- rbind(results, data.frame(
        Size = size,
        Method = "fastMatMul_auto",
        Time_ms = mean_time_auto,
        GFLOPS = gflops_auto,
        Speedup = ifelse("R" %in% methods, mean_time_r / mean_time_auto, NA),
        stringsAsFactors = FALSE
      ))
    }
  }
  
  # Set the class for custom plotting
  class(results) <- c("matmul_benchmark", class(results))
  
  return(results)
}

#' Plot Matrix Multiplication Benchmark Results
#'
#' @param x A data frame with benchmark results from benchmark_matmul()
#' @param ... Additional parameters (not used)
#'
#' @return A ggplot2 object with the benchmark visualization
#'
#' @importFrom graphics plot
#' @method plot matmul_benchmark
#' @export
plot.matmul_benchmark <- function(x, ...) {
  # Check for ggplot2
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for plotting. Please install it.")
  }
  
  # Create plot with log scale for better visualization
  p <- ggplot2::ggplot(x, ggplot2::aes(x = factor(Size), y = GFLOPS, fill = Method)) +
    ggplot2::geom_bar(stat = "identity", position = "dodge") +
    ggplot2::scale_y_continuous(trans = "log10") +
    ggplot2::labs(
      title = "Matrix Multiplication Performance",
      subtitle = "Performance in GFLOPS (higher is better)",
      x = "Matrix Size",
      y = "GFLOPS (log scale)"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      legend.position = "bottom",
      plot.title = ggplot2::element_text(face = "bold"),
      axis.title = ggplot2::element_text(face = "bold")
    )
  
  return(p)
}
