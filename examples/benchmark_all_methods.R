# Пример использования всех методов умножения матриц
# и сравнение их производительности

library(MatrixProd)
library(microbenchmark)
library(ggplot2)

# Явные импорты функций из пакета MatrixProd для подавления предупреждений линтера
rust_mmTiny <- MatrixProd::rust_mmTiny
rust_mmBlocked <- MatrixProd::rust_mmBlocked
rust_mmAuto <- MatrixProd::rust_mmAuto
cpp_mmAccelerate <- MatrixProd::cpp_mmAccelerate
gpu_mmMetal <- MatrixProd::gpu_mmMetal
is_metal_available <- MatrixProd::is_metal_available
fastMatMul <- MatrixProd::fastMatMul

# Функция для создания случайных матриц заданного размера
create_random_matrices <- function(size) {
  A <- matrix(runif(size * size), size, size)
  B <- matrix(runif(size * size), size, size)
  list(A = A, B = B)
}

# Функция для проверки правильности результата
verify_result <- function(result, reference, tolerance = 1e-10) {
  max_diff <- max(abs(result - reference))
  if (max_diff > tolerance) {
    warning(sprintf("Results differ by %g, which exceeds tolerance %g", 
                   max_diff, tolerance))
    return(FALSE)
  }
  return(TRUE)
}

# Функция для расчета GFLOPS
calculate_gflops <- function(size, time_seconds) {
  # Для умножения матриц NxN требуется 2*N^3 операций с плавающей точкой
  flops <- 2 * size^3
  gflops <- flops / (time_seconds * 1e9)
  return(gflops)
}

# Функция для тестирования всех методов
benchmark_all_methods <- function(size, times = 5) {
  cat(sprintf("\nBenchmarking matrix multiplication for %dx%d matrices\n", size, size))
  
  # Создаем матрицы
  matrices <- create_random_matrices(size)
  A <- matrices$A
  B <- matrices$B
  
  # Рассчитываем эталонный результат с помощью базового R
  cat("Computing reference result with base R... ")
  reference <- A %*% B
  cat("Done.\n")
  
  # Список доступных методов
  methods <- c("base_r", "rust_tiny", "rust_blocked", "rust_auto", "cpp_accelerate")
  
  # Добавляем Metal GPU, если доступен
  has_metal <- tryCatch({
    is_metal_available()
  }, error = function(e) FALSE)
  
  if (has_metal) {
    methods <- c(methods, "metal_gpu")
    cat("Metal GPU acceleration is available.\n")
  } else {
    cat("Metal GPU acceleration is NOT available.\n")
  }
  
  # Функции для каждого метода
  method_functions <- list(
    base_r = function() A %*% B,
    rust_tiny = function() rust_mmTiny(A, B),
    rust_blocked = function() rust_mmBlocked(A, B),
    rust_auto = function() rust_mmAuto(A, B),
    cpp_accelerate = function() cpp_mmAccelerate(A, B)
  )
  
  if (has_metal) {
    method_functions$metal_gpu <- function() gpu_mmMetal(A, B)
  }
  
  # Проверяем корректность результатов
  cat("Verifying results:\n")
  for (method in methods) {
    cat(sprintf("  - %s: ", method))
    result <- method_functions[[method]]()
    if (verify_result(result, reference)) {
      cat("Correct\n")
    } else {
      cat("INCORRECT!\n")
    }
  }
  
  # Запускаем бенчмарк
  cat("\nRunning benchmark...\n")
  benchmark_results <- microbenchmark(
    list = method_functions,
    times = times
  )
  
  # Выводим результаты
  print(benchmark_results)
  
  # Рассчитываем GFLOPS
  results_df <- summary(benchmark_results)
  results_df$gflops <- calculate_gflops(size, results_df$mean / 1e9)
  
  # Выводим таблицу GFLOPS
  cat("\nPerformance in GFLOPS:\n")
  results_table <- data.frame(
    Method = results_df$expr,
    `Time (ms)` = round(results_df$mean / 1e6, 2),
    GFLOPS = round(results_df$gflops, 2)
  )
  print(results_table[order(-results_table$GFLOPS), ])
  
  # Визуализация результатов
  p <- ggplot(results_df, aes(x = reorder(expr, -results_df$gflops), y = results_df$gflops, fill = expr)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = round(results_df$gflops, 1)), vjust = -0.5) +
    theme_minimal() +
    labs(
      title = sprintf("Matrix Multiplication Performance (%dx%d)", size, size),
      x = "Method",
      y = "Performance (GFLOPS)",
      fill = "Method"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  print(p)
  
  # Возвращаем результаты для дальнейшего анализа
  return(list(
    benchmark = benchmark_results,
    summary = results_df,
    plot = p
  ))
}

# Запускаем тесты для разных размеров матриц
sizes <- c(100, 500, 1000, 2000)
results <- list()

for (size in sizes) {
  # Пропускаем очень большие матрицы, если не хватает памяти
  if (size^2 * 8 * 3 > 8 * 1024 * 1024 * 1024) {  # Пропускаем, если нужно больше 8 ГБ
    cat(sprintf("Skipping size %d (requires too much memory)\n", size))
    next
  }
  
  results[[as.character(size)]] <- benchmark_all_methods(size)
}

# Рекомендация по выбору метода
cat("\n\nRecommendations based on benchmark results:\n")
cat("- For small matrices (up to 200x200): Use rust_mmTiny\n")
cat("- For medium matrices (200x200 to 1000x1000): Use cpp_mmAccelerate\n")
if (has_metal) {
  cat("- For large matrices (over 1000x1000): Use gpu_mmMetal\n")
} else {
  cat("- For large matrices (over 1000x1000): Use rust_mmBlocked\n")
}
cat("- For automatic selection: Use fastMatMul() with method='auto'\n")

# Демонстрация автоматического выбора метода
cat("\nDemonstrating automatic method selection with fastMatMul:\n")
for (size in c(50, 150, 750, 1500)) {
  if (size^2 * 8 * 3 <= 8 * 1024 * 1024 * 1024) {  # Проверяем доступность памяти
    matrices <- create_random_matrices(size)
    cat(sprintf("Size %dx%d: ", size, size))
    result <- fastMatMul(matrices$A, matrices$B, verbose = TRUE)
    cat("\n")
  }
}
