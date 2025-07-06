#' Pure R Matrix Multiplication
#'
#' @description 
#' A matrix multiplication function implemented in pure R.
#' This is a fallback implementation when native functions are not available.
#'
#' @param A numeric matrix, first operand
#' @param B numeric matrix, second operand
#' @param block_size integer, size of blocks for block multiplication (optional)
#' @param verbose logical, whether to print diagnostic information
#'
#' @return A numeric matrix that is the product of A and B
#'
#' @examples
#' A <- matrix(runif(100), 10, 10)
#' B <- matrix(runif(100), 10, 10)
#' C <- pure_r_matmul(A, B)
#'
#' @export
pure_r_matmul <- function(A, B, block_size = NULL, verbose = FALSE) {
  # Проверка размеров матриц
  if (!is.matrix(A) || !is.matrix(B)) {
    stop("Аргументы A и B должны быть матрицами")
  }
  
  m <- nrow(A)
  k <- ncol(A)
  n <- ncol(B)
  
  if (nrow(B) != k) {
    stop("Несовместимые размеры матриц: ncol(A) != nrow(B)")
  }
  
  if (verbose) {
    cat("Matrix multiplication: [", m, "x", k, "] * [", k, "x", n, "]\n")
    cat("Using pure R implementation\n")
  }
  
  # Если размер блока не указан, выбираем оптимальный
  if (is.null(block_size)) {
    # Для небольших матриц используем простое умножение
    if (max(m, k, n) < 100) {
      return(simple_matmul_r(A, B))
    } else {
      # Для больших матриц используем блочное умножение
      block_size <- 64  # Оптимальный размер блока для кэша L1/L2
      return(block_matmul_r(A, B, block_size))
    }
  } else {
    # Используем указанный размер блока
    return(block_matmul_r(A, B, block_size))
  }
}

#' Simple Matrix Multiplication in Pure R
#'
#' @param A numeric matrix, first operand
#' @param B numeric matrix, second operand
#'
#' @return A numeric matrix that is the product of A and B
#'
#' @keywords internal
simple_matmul_r <- function(A, B) {
  m <- nrow(A)
  k <- ncol(A)
  n <- ncol(B)
  
  # Создаем результирующую матрицу
  C <- matrix(0, m, n)
  
  # Простое матричное умножение
  for (i in 1:m) {
    for (j in 1:n) {
      sum <- 0
      for (l in 1:k) {
        sum <- sum + A[i, l] * B[l, j]
      }
      C[i, j] <- sum
    }
  }
  
  return(C)
}

#' Block Matrix Multiplication in Pure R
#'
#' @param A numeric matrix, first operand
#' @param B numeric matrix, second operand
#' @param block_size integer, size of blocks
#'
#' @return A numeric matrix that is the product of A and B
#'
#' @keywords internal
block_matmul_r <- function(A, B, block_size = 64) {
  m <- nrow(A)
  k <- ncol(A)
  n <- ncol(B)
  
  # Создаем результирующую матрицу
  C <- matrix(0, m, n)
  
  # Блочное матричное умножение
  for (i0 in seq(1, m, by = block_size)) {
    imax <- min(i0 + block_size - 1, m)
    for (j0 in seq(1, n, by = block_size)) {
      jmax <- min(j0 + block_size - 1, n)
      for (l0 in seq(1, k, by = block_size)) {
        lmax <- min(l0 + block_size - 1, k)
        
        # Умножение блоков
        for (i in i0:imax) {
          for (j in j0:jmax) {
            sum <- C[i, j]  # Получаем текущее значение
            for (l in l0:lmax) {
              sum <- sum + A[i, l] * B[l, j]
            }
            C[i, j] <- sum
          }
        }
      }
    }
  }
  
  return(C)
}

#' Fast Matrix Multiplication with Pure R Fallback
#'
#' @description 
#' A wrapper around fastMatMul that falls back to pure R implementation
#' if native functions are not available.
#'
#' @param A numeric matrix, first operand
#' @param B numeric matrix, second operand
#' @param method character string specifying the method to use (optional)
#' @param verbose logical, whether to print diagnostic information
#'
#' @return A numeric matrix that is the product of A and B
#'
#' @examples
#' A <- matrix(runif(100), 10, 10)
#' B <- matrix(runif(100), 10, 10)
#' C <- safe_matmul(A, B)
#'
#' @export
safe_matmul <- function(A, B, method = "auto", verbose = FALSE) {
  # Пробуем использовать fastMatMul
  result <- tryCatch({
    fastMatMul(A, B, method = method, verbose = verbose)
  }, error = function(e) {
    if (verbose) {
      cat("Native implementation failed with error:", e$message, "\n")
      cat("Falling back to pure R implementation\n")
    }
    # Используем чистую R реализацию как запасной вариант
    pure_r_matmul(A, B, verbose = verbose)
  })
  
  return(result)
}
