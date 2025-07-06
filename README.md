# MatrixProd: High-Performance Matrix Multiplication for R

## St-Digital-Twin Project #265

## Overview

`MatrixProd` is a high-performance matrix multiplication library for R that provides specialized implementations optimized for different matrix sizes and hardware configurations. Все функции были тщательно оптимизированы и протестированы на Apple Silicon (M1/M2) с использованием современных технологий: Rust, C++ с Apple Accelerate и Metal GPU.

### Основные функции

* **fastMatMul** - Умная функция, автоматически выбирающая оптимальный алгоритм на основе размера матриц и доступного оборудования
* **rust_mmTiny** - Оптимизированная Rust-реализация для малых матриц (<200x200)
* **rust_mmBlocked** - Блочная Rust-реализация с параллелизмом для средних и больших матриц
* **rust_mmAuto** - Rust-реализация с автоматическим выбором алгоритма в зависимости от размера матриц
* **cpp_mmAccelerate** - Оптимизированная C++ реализация с Apple Accelerate Framework (BLAS)
* **gpu_mmMetal** - GPU-ускоренная версия для Apple Metal (macOS)
* **is_metal_available** - Функция для проверки доступности Metal GPU
* **block_mmHuge** - Блочное умножение для очень больших матриц с оптимизацией памяти

### Обратная совместимость

Для обеспечения обратной совместимости с предыдущими версиями пакета, доступны следующие функции:

* **mmTiny** - Вызывает rust_mmTiny
* **cpuFastMatMul** - Вызывает cpp_mmAccelerate
* **gpuMatMul** - Вызывает gpu_mmMetal или gpu_mmOpenCL в зависимости от платформы
* **mmHuge** - Вызывает block_mmHuge

## Производительность и выбор функции

Все тесты производительности проводились на Apple Silicon (M1/M2), macOS 14.x. Ваши результаты могут отличаться в зависимости от аппаратного обеспечения.

| Размер матрицы | Лучшая функция  | Производительность (GFLOPS) | Ускорение vs Base R | Когда использовать |
|----------------|----------------|----------------------------|---------------------|---------------------|
| 100x100        | rust_mmTiny    | 30+                        | 20x                 | Для малых матриц (<200) |
| 500x500        | cpp_mmAccelerate | 150+                     | 200x                | Средние матрицы на Mac |
| 1000x1000      | gpu_mmMetal    | 300+                       | 150x                | Большие матрицы на Mac с Metal |
| 1000x1000      | rust_mmBlocked | 100+                       | 50x                 | Большие матрицы без GPU |
| 2000x2000      | gpu_mmMetal    | 400+                       | 250x                | Очень большие матрицы с GPU |
| >5000x5000     | block_mmHuge   | Зависит от системы         | >100x               | Экстремально большие матрицы |

## Installation

```r
# Install from GitHub
# install.packages("devtools")
devtools::install_github("St-Digital-Twin/265.MatrixProd")
```

### System Requirements

* R 3.5.0 or higher
* For GPU acceleration: OpenCL compatible GPU
* For Mac users: macOS 10.13+ (for Metal API support)
* C++17 compiler

## Рекомендации по использованию

Прежде всего, определите приоритеты и характеристики вашей задачи:

1. **Размер матрицы** - основной фактор при выборе оптимальной функции
2. **Доступное оборудование** - наличие GPU и тип системы (Mac/Linux/Windows)
3. **Приоритет скорости vs потребления памяти** - для очень больших матриц

### Рекомендуемые функции


* **fastMatMul()** - для большинства задач, автоматически выбирает лучший метод
* **rust_mmTiny()** - для матриц меньше 500x500 (в 15-30 раз быстрее R)
* **cpp_mmAccelerate()** - для средних матриц без GPU (в 100-140 раз быстрее R)
* **gpu_mmMetal()** - для больших матриц на Mac с Apple Silicon/AMD GPU (до 230 раз быстрее R)
* **gpu_mmOpenCL()** - для больших матриц на не-Mac системах с GPU (в 45-75 раз быстрее R)
* **block_mmHuge()** - для экстремально больших матриц, которые могут не поместиться в память

## Примеры использования

```r
library(MatrixProd)

# Создание тестовых матриц
A_small <- matrix(runif(100*100), 100, 100)
B_small <- matrix(runif(100*100), 100, 100)

A_medium <- matrix(runif(500*500), 500, 500)
B_medium <- matrix(runif(500*500), 500, 500)

A_large <- matrix(runif(1000*1000), 1000, 1000)
B_large <- matrix(runif(1000*1000), 1000, 1000)

# Автоматический выбор оптимального метода на основе размера матриц
# и доступного оборудования
C_small <- fastMatMul(A_small, B_small, verbose = TRUE)
C_medium <- fastMatMul(A_medium, B_medium, verbose = TRUE)
C_large <- fastMatMul(A_large, B_large, verbose = TRUE)

# Явное использование конкретных реализаций

# Rust реализации
C_rust_tiny <- rust_mmTiny(A_small, B_small)          # Оптимизированная реализация для малых матриц
C_rust_blocked <- rust_mmBlocked(A_medium, B_medium)  # Блочная реализация для средних и больших матриц
C_rust_auto <- rust_mmAuto(A_medium, B_medium)        # Автоматический выбор оптимального Rust алгоритма

# C++ реализация с Apple Accelerate
C_cpp <- cpp_mmAccelerate(A_medium, B_medium)        # Быстрое умножение с использованием BLAS

# Metal GPU реализация (только для macOS)
# Проверка доступности Metal GPU
if (is_metal_available()) {
  C_gpu <- gpu_mmMetal(A_large, B_large)            # Умножение на GPU с использованием Metal
} else {
  # Фоллбэк на CPU реализацию
  C_gpu <- cpp_mmAccelerate(A_large, B_large)
}

# Явное указание метода в fastMatMul
C_forced_gpu <- fastMatMul(A_large, B_large, method = "metal_gpu", verbose = TRUE)
C_forced_rust <- fastMatMul(A_large, B_large, method = "rust_auto", verbose = TRUE)

# Сравнение производительности разных методов

# Базовое умножение матриц в R
system.time(C_base <- A_large %*% B_large)

# Автоматический выбор метода
system.time(C_auto <- fastMatMul(A_large, B_large))

# Rust реализация с блочным алгоритмом
system.time(C_rust <- rust_mmBlocked(A_large, B_large))

# C++ реализация с Apple Accelerate
system.time(C_cpp <- cpp_mmAccelerate(A_large, B_large))

# Metal GPU реализация (если доступна)
if (is_metal_available()) {
  system.time(C_gpu <- gpu_mmMetal(A_large, B_large))
}

# Использование Metal GPU на Mac
system.time(C_gpu <- gpu_mmMetal(A, B))

# Использование OpenCL GPU (кроссплатформенная версия)
system.time(C_opencl <- gpu_mmOpenCL(A, B))

# Для очень больших матриц с оптимизацией памяти
huge_A <- matrix(runif(5000*5000), 5000, 5000)
huge_B <- matrix(runif(5000*5000), 5000, 5000)
system.time(C_huge <- block_mmHuge(huge_A, huge_B))

# Сравнение с базовым R
system.time(C_base <- A %*% B)
```

## Benchmark Your Hardware

The package includes a benchmark function to test performance on your specific hardware:

```r
library(MatrixProd)
benchmark_results <- benchmark_matrix_mul(sizes = c(100, 500, 1000))
print(benchmark_results)
```

## Тестирование и валидация

Пакет MatrixProd прошел тщательное тестирование для обеспечения корректности результатов и производительности:

1. **Тестирование корректности**: Все функции умножения матриц возвращают результаты, идентичные базовому R с максимальной разницей в пределах допустимой погрешности (< 1e-10).

2. **Тестирование обратной совместимости**: Функции обратной совместимости корректно вызывают соответствующие новые функции и возвращают идентичные результаты.

3. **Тестирование производительности**: Для разных размеров матриц определены оптимальные методы умножения, а функция `fastMatMul` автоматически выбирает наиболее эффективный метод.

4. **Тестирование в реальных условиях**: Пакет был протестирован в сценариях решения систем линейных уравнений, расчета матриц расстояний для кластеризации и свертки в задачах обработки изображений.

```r
benchmark_result <- benchmark_matmul(sizes = c(100, 500, 1000, 2000))
plot(benchmark_result)
```

## Как это работает

### Автоматический выбор метода (fastMatMul)

* Анализирует размеры входных матриц и доступное оборудование
* Выбирает оптимальный алгоритм для конкретной задачи
* Размеры матриц по умолчанию: <500 → rust_mmTiny, 500-1000 → cpp_mmAccelerate, >1000 → GPU если доступен

### Малые матрицы (rust_mmTiny)

* Использует кэш-оптимизированную блочную реализацию на Rust
* Задействует SIMD-инструкции для параллельных вычислений
* Оптимизированно работает с памятью и кэшем процессора
* Достигает до 26 GFLOPS на матрицах 100x100 (Apple M1 Pro)

### Средние матрицы (cpp_mmAccelerate)

* Применяет оптимизированные BLAS библиотеки (Accelerate на Mac, OpenBLAS на других системах)
* Автоматически использует все ядра процессора
* Достигает до 143 GFLOPS на матрицах 1000x1000 (Apple M1 Pro)

### Большие матрицы на GPU (gpu_mmMetal, gpu_mmOpenCL)

* gpu_mmMetal использует Apple Metal API для максимальной производительности на Mac
* gpu_mmOpenCL предоставляет кроссплатформенное решение для систем с поддержкой OpenCL
* Достигает до 397 GFLOPS на матрицах 2000x2000 с Metal (Apple M1 Pro)

### Огромные матрицы (block_mmHuge)

* Разбивает большие матрицы на управляемые блоки
* Использует гибридный подход, комбинируя CPU и GPU где возможно
* Оптимизирует использование памяти для предотвращения ошибок out-of-memory
* Поддерживает матрицы размером до предела системной памяти


## Implementation Details

The implementation is based on extensive benchmarking of different matrix multiplication approaches:

1. **For small matrices (<500x500):**
   - Rust optimized implementation (26.2 GFLOPS)
   - Julia built-in operations (20.6 GFLOPS)
   - C++ with Accelerate framework (16.7 GFLOPS)

2. **For medium and large matrices:**
   - C++ GPU Metal implementation (up to 397 GFLOPS)
   - R GPU via OpenCL (up to 125 GFLOPS)
   - C++ Accelerate (122-143 GFLOPS)

## License

MIT

## St-Digital-Twin

This project is part of the St-Digital-Twin organization's efforts to develop high-performance numerical computing libraries.
