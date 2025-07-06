#include <R.h>
#include <Rinternals.h>

// Объявляем внешние функции из Rust
extern void rust_mm_optimized(const double* a_ptr, const double* b_ptr, double* c_ptr, 
                             int m, int k, int n);
extern void rust_mm_blocked(const double* a_ptr, const double* b_ptr, double* c_ptr, 
                           int m, int k, int n);
extern void rust_mm_auto(const double* a_ptr, const double* b_ptr, double* c_ptr, 
                        int m, int k, int n);

// Обертка для оптимизированной Rust-реализации
SEXP rust_mmTiny_cpp(SEXP A_r, SEXP B_r) {
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
  
  // Вызываем оптимизированную Rust-функцию
  rust_mm_optimized(A, B, C, m, k, n);
  
  UNPROTECT(1);
  return C_r;
}

// Обертка для блочной Rust-реализации
SEXP rust_mmBlocked_cpp(SEXP A_r, SEXP B_r) {
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
  
  // Вызываем блочную Rust-функцию
  rust_mm_blocked(A, B, C, m, k, n);
  
  UNPROTECT(1);
  return C_r;
}

// Обертка для автоматического выбора Rust-реализации
SEXP rust_mmAuto_cpp(SEXP A_r, SEXP B_r) {
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
  
  // Вызываем автоматическую Rust-функцию
  rust_mm_auto(A, B, C, m, k, n);
  
  UNPROTECT(1);
  return C_r;
}
