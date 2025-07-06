#include <R.h>
#include <Rinternals.h>

// Информация о производительности - отдельная реализация
SEXP get_performance_info(void) {
  SEXP result = PROTECT(allocVector(REALSXP, 8));
  double *res_ptr = REAL(result);
  
  // Заполняем базовой информацией
  res_ptr[0] = 1.0;  // Есть Accelerate framework (macOS)
  res_ptr[1] = 0.0;  // Нет OpenCL
  res_ptr[2] = 0.0;  // Нет Metal
  res_ptr[3] = 8.0;  // Примерное количество потоков CPU
  res_ptr[4] = 1.0;  // Базовый уровень поддержки SIMD
  res_ptr[5] = 10.0; // Примерная производительность для малых матриц (GFLOPS)
  res_ptr[6] = 20.0; // Примерная производительность для средних матриц (GFLOPS)
  res_ptr[7] = 0.0;  // Нет GPU для больших матриц
  
  UNPROTECT(1);
  return result;
}
