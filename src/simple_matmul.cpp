// Максимально простая реализация без использования Rcpp и других сложных зависимостей
#include <R.h>
#include <Rinternals.h>

// Простая реализация матричного умножения для проверки работоспособности
extern "C" SEXP rust_mmTiny_cpp(SEXP A_r, SEXP B_r) {
  // Получаем размеры матриц
  SEXP dim_A = getAttrib(A_r, R_DimSymbol);
  SEXP dim_B = getAttrib(B_r, R_DimSymbol);
  
  int m = INTEGER(dim_A)[0];
  int k = INTEGER(dim_A)[1];
  int n = INTEGER(dim_B)[1];
  
  if (INTEGER(dim_B)[0] != k) {
    error("Несовместимые размеры матриц");
  }
  
  // Создаем результирующую матрицу
  SEXP C_r = PROTECT(allocMatrix(REALSXP, m, n));
  double *A = REAL(A_r);
  double *B = REAL(B_r);
  double *C = REAL(C_r);
  
  // Простое матричное умножение
  for (int i = 0; i < m; i++) {
    for (int j = 0; j < n; j++) {
      double sum = 0.0;
      for (int l = 0; l < k; l++) {
        sum += A[i + l * m] * B[l + j * k];
      }
      C[i + j * m] = sum;
    }
  }
  
  UNPROTECT(1);
  return C_r;
}

// Простая реализация матричного умножения для проверки работоспособности
extern "C" SEXP cpp_mmAccelerate(SEXP A_r, SEXP B_r) {
  // Просто вызываем ту же функцию для проверки
  return rust_mmTiny_cpp(A_r, B_r);
}

// Информация о производительности перенесена в отдельный файл performance_info.c
