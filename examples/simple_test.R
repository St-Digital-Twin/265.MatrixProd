#!/usr/bin/env Rscript

# Простой тест для пакета MatrixProd

# Загрузка пакета
library(MatrixProd)

# Создание тестовых матриц
set.seed(42)
A_small <- matrix(runif(100*100), 100, 100)
B_small <- matrix(runif(100*100), 100, 100)

A_medium <- matrix(runif(500*500), 500, 500)
B_medium <- matrix(runif(500*500), 500, 500)

A_large <- matrix(runif(1000*1000), 1000, 1000)
B_large <- matrix(runif(1000*1000), 1000, 1000)

# Проверка базовой функциональности
cat("Тестирование базового умножения матриц в R...\n")
system.time(C_base_small <- A_small %*% B_small)

# Тестирование функции fastMatMul
cat("\nТестирование функции fastMatMul для малых матриц...\n")
system.time(C_fast_small <- fastMatMul(A_small, B_small, verbose = TRUE))

# Проверка корректности результата
max_diff_small <- max(abs(C_base_small - C_fast_small))
cat("\nМаксимальная разница между базовым и быстрым умножением:", max_diff_small, "\n")

# Тестирование для средних матриц
cat("\nТестирование для средних матриц (500x500)...\n")
system.time(C_base_medium <- A_medium %*% B_medium)
system.time(C_fast_medium <- fastMatMul(A_medium, B_medium, verbose = TRUE))

# Тестирование для больших матриц
cat("\nТестирование для больших матриц (1000x1000)...\n")
system.time(C_base_large <- A_large %*% B_large)
system.time(C_fast_large <- fastMatMul(A_large, B_large, verbose = TRUE))

cat("\nТест завершен успешно!\n")
