#!/usr/bin/env Rscript

# Тест для проверки функции fastMatMul с методом "auto"

# Загрузка пакета
library(MatrixProd)

# Создание тестовых матриц
set.seed(42)
A_small <- matrix(runif(100*100), 100, 100)
B_small <- matrix(runif(100*100), 100, 100)

# Проверка базовой функциональности
cat("Тестирование базового умножения матриц в R...\n")
system.time(C_base_small <- A_small %*% B_small)

# Тестирование функции fastMatMul с методом "auto"
cat("\nТестирование функции fastMatMul с методом 'auto'...\n")
tryCatch({
  system.time(C_auto <- fastMatMul(A_small, B_small, method = "auto", verbose = TRUE))
  cat("\nУмножение с методом 'auto' выполнено успешно\n")
  
  # Проверка корректности результата
  max_diff <- max(abs(C_base_small - C_auto))
  cat("Максимальная разница между базовым и быстрым умножением:", max_diff, "\n")
}, error = function(e) {
  cat("Ошибка при использовании метода 'auto':", e$message, "\n")
})

# Тестирование с методом "cpu"
cat("\nТестирование функции fastMatMul с методом 'cpu'...\n")
tryCatch({
  system.time(C_cpu <- fastMatMul(A_small, B_small, method = "cpu", verbose = TRUE))
  cat("\nУмножение с методом 'cpu' выполнено успешно\n")
  
  # Проверка корректности результата
  max_diff <- max(abs(C_base_small - C_cpu))
  cat("Максимальная разница между базовым и CPU умножением:", max_diff, "\n")
}, error = function(e) {
  cat("Ошибка при использовании метода 'cpu':", e$message, "\n")
})

# Тестирование с методом "gpu"
cat("\nТестирование функции fastMatMul с методом 'gpu'...\n")
tryCatch({
  system.time(C_gpu <- fastMatMul(A_small, B_small, method = "gpu", verbose = TRUE))
  cat("\nУмножение с методом 'gpu' выполнено успешно\n")
  
  # Проверка корректности результата
  max_diff <- max(abs(C_base_small - C_gpu))
  cat("Максимальная разница между базовым и GPU умножением:", max_diff, "\n")
}, error = function(e) {
  cat("Ошибка при использовании метода 'gpu':", e$message, "\n")
})

cat("\nТест завершен\n")
