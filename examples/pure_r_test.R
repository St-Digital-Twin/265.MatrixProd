#!/usr/bin/env Rscript

# Тест для проверки чистой R-реализации умножения матриц

# Загрузка пакета
library(MatrixProd)

# Создание тестовых матриц
set.seed(42)
A_small <- matrix(runif(100*100), 100, 100)
B_small <- matrix(runif(100*100), 100, 100)

A_medium <- matrix(runif(500*500), 500, 500)
B_medium <- matrix(runif(500*500), 500, 500)

# Проверка базовой функциональности
cat("Тестирование базового умножения матриц в R...\n")
system.time(C_base_small <- A_small %*% B_small)

# Тестирование функции pure_r_matmul для малых матриц
cat("\nТестирование функции pure_r_matmul для малых матриц...\n")
system.time(C_pure_small <- pure_r_matmul(A_small, B_small, verbose = TRUE))

# Проверка корректности результата
max_diff_small <- max(abs(C_base_small - C_pure_small))
cat("\nМаксимальная разница между базовым и pure_r умножением:", max_diff_small, "\n")

# Тестирование функции safe_matmul
cat("\nТестирование функции safe_matmul...\n")
system.time(C_safe_small <- safe_matmul(A_small, B_small, verbose = TRUE))

# Проверка корректности результата
max_diff_safe <- max(abs(C_base_small - C_safe_small))
cat("\nМаксимальная разница между базовым и safe_matmul умножением:", max_diff_safe, "\n")

# Тестирование блочного умножения
cat("\nТестирование блочного умножения для средних матриц...\n")
system.time(C_base_medium <- A_medium %*% B_medium)
system.time(C_block_medium <- pure_r_matmul(A_medium, B_medium, block_size = 64, verbose = TRUE))

# Проверка корректности результата
max_diff_medium <- max(abs(C_base_medium - C_block_medium))
cat("\nМаксимальная разница между базовым и блочным умножением:", max_diff_medium, "\n")

cat("\nТест завершен успешно!\n")
