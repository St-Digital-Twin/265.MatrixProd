#!/usr/bin/env Rscript

# Базовый тест для проверки загрузки пакета MatrixProd

# Загрузка пакета
library(MatrixProd)

# Вывод информации о пакете
cat("Пакет MatrixProd успешно загружен\n")

# Создание тестовых матриц
set.seed(42)
A_small <- matrix(runif(10*10), 10, 10)
B_small <- matrix(runif(10*10), 10, 10)

# Проверка базовой функциональности
cat("Тестирование базового умножения матриц в R...\n")
C_base_small <- A_small %*% B_small
cat("Базовое умножение матриц выполнено успешно\n")

# Проверка доступности Metal
cat("\nПроверка доступности Metal GPU...\n")
metal_available <- try(is_metal_available(), silent = TRUE)
if (inherits(metal_available, "try-error")) {
  cat("Функция is_metal_available() вызвала ошибку\n")
} else {
  cat("Metal доступен:", metal_available, "\n")
}

# Проверка информации о производительности
cat("\nПроверка информации о производительности...\n")
perf_info <- try(get_performance_info(), silent = TRUE)
if (inherits(perf_info, "try-error")) {
  cat("Функция get_performance_info() вызвала ошибку\n")
} else {
  cat("Информация о производительности получена успешно\n")
  print(perf_info)
}

cat("\nТест завершен\n")
