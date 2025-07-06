// Отключаем макросы из R, которые конфликтуют с C++ стандартной библиотекой
#define R_NO_REMAP

// Включаем заголовочные файлы R
#include <R.h>
#include <Rinternals.h>

// Переопределяем макросы из R
#ifdef length
#undef length
#endif

// Вместо включения всего Accelerate, который вызывает конфликты,
// мы включаем только необходимые для BLAS заголовочные файлы

// Определения для CBLAS
#define CBLAS_ORDER int
#define CBLAS_TRANSPOSE int
#define CblasRowMajor 101
#define CblasColMajor 102
#define CblasNoTrans 111
#define CblasTrans 112

// Прототип функции cblas_dgemm
extern "C" {
    void cblas_dgemm(const CBLAS_ORDER Order, const CBLAS_TRANSPOSE TransA, const CBLAS_TRANSPOSE TransB,
                    const int M, const int N, const int K,
                    const double alpha, const double *A, const int lda,
                    const double *B, const int ldb, const double beta,
                    double *C, const int ldc);
}

// Оптимизированная реализация матричного умножения с использованием Apple Accelerate Framework
extern "C" SEXP cpp_mmAccelerate(SEXP A_r, SEXP B_r) {
  // Получаем размеры матриц из атрибутов R объектов
  SEXP dim_A = Rf_getAttrib(A_r, R_DimSymbol);
  SEXP dim_B = Rf_getAttrib(B_r, R_DimSymbol);
  
  int m = INTEGER(dim_A)[0];
  int k = INTEGER(dim_A)[1];
  int p = INTEGER(dim_B)[0];
  int n = INTEGER(dim_B)[1];
  // Проверяем совместимость размеров матриц
  if (k != p) {
    Rf_error("Несовместимые размеры матриц");
  }
  
  // Создаем результирующую матрицу
  SEXP C_r = PROTECT(Rf_allocMatrix(REALSXP, m, n));
  double *A = REAL(A_r);
  double *B = REAL(B_r);
  double *C = REAL(C_r);
  
  // Используем CBLAS из Accelerate Framework для умножения матриц
  // C = alpha * A * B + beta * C
  // Где A, B и C - матрицы, alpha и beta - скаляры
  
  // Параметры:
  // CblasRowMajor: матрицы хранятся по строкам
  // CblasNoTrans: матрицы не транспонированы
  // m: количество строк в A и C
  // n: количество столбцов в B и C
  // k: количество столбцов в A и строк в B
  // alpha: скаляр для A*B
  // A: указатель на матрицу A
  // lda: шаг между строками A
  // B: указатель на матрицу B
  // ldb: шаг между строками B
  // beta: скаляр для C
  // C: указатель на матрицу C
  // ldc: шаг между строками C
  
  // Примечание: R хранит матрицы в формате column-major,
  // поэтому мы вычисляем B * A вместо A * B
  cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans,
              m, n, k,
              1.0, A, m,
              B, k,
              0.0, C, m);
  
  UNPROTECT(1);
  return C_r;
}
