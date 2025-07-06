# MatrixProd: High-Performance Matrix Multiplication for R

## St-Digital-Twin Project #265

## Overview

`MatrixProd` is a high-performance matrix multiplication library for R that provides specialized implementations optimized for different matrix sizes and hardware configurations. Все функции были тщательно оптимизированы и протестированы на Apple M1 Pro с 32GB RAM.

### Основные функции

* **fastMatMul** - Умная функция, автоматически выбирающая оптимальный алгоритм
* **rust_mmTiny** - Rust-реализация для малых матриц (<500x500)
* **cpp_mmAccelerate** - Оптимизированная C++ реализация с Apple Accelerate Framework
* **gpu_mmMetal** - GPU-ускоренная версия для Apple Metal (macOS)
* **gpu_mmOpenCL** - GPU-ускоренная версия через OpenCL (кроссплатформенная)
* **block_mmHuge** - Блочное умножение для очень больших матриц с оптимизацией памяти

### Обратная совместимость

Для обеспечения обратной совместимости с предыдущими версиями пакета, доступны следующие функции:

* **mmTiny** - Вызывает rust_mmTiny
* **cpuFastMatMul** - Вызывает cpp_mmAccelerate
* **gpuMatMul** - Вызывает gpu_mmMetal или gpu_mmOpenCL в зависимости от платформы
* **mmHuge** - Вызывает block_mmHuge

## Производительность и выбор функции

Все тесты производительности проводились на Apple M1 Pro, 32GB RAM, macOS 12.5. Ваши результаты могут отличаться в зависимости от аппаратного обеспечения.

| Размер матрицы | Лучшая функция  | Производительность (GFLOPS) | Ускорение vs Base R | Когда использовать |
|----------------|----------------|----------------------------|---------------------|---------------------|
| 100x100        | rust_mmTiny    | 26.2                       | 15x                 | Для малых матриц (<500) |
| 500x500        | gpu_mmMetal    | 143.7                      | 189x                | Средние матрицы на Mac с GPU |
| 500x500        | cpp_mmAccelerate | 105.0                    | 138x                | Средние матрицы без GPU |
| 1000x1000      | gpu_mmMetal    | 283.7                      | 140x                | Большие матрицы на Mac |
| 1000x1000      | gpu_mmOpenCL   | 90.5                       | 45x                 | Большие матрицы на не-Mac с GPU |
| 2000x2000      | gpu_mmMetal    | 397.0                      | 230x                | Очень большие матрицы с GPU |
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
A <- matrix(runif(1000*1000), 1000, 1000)
B <- matrix(runif(1000*1000), 1000, 1000)

# Автоматический выбор метода на основе размера матрицы
system.time(C <- fastMatMul(A, B))

# Явный выбор конкретной реализации для малых матриц
small_A <- matrix(runif(100*100), 100, 100)
small_B <- matrix(runif(100*100), 100, 100)
system.time(C_small <- rust_mmTiny(small_A, small_B))

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
