#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP rust_mmTiny_cpp(SEXP, SEXP);
extern SEXP cpp_mmAccelerate(SEXP, SEXP);
extern SEXP get_performance_info(void);

static const R_CallMethodDef CallEntries[] = {
  /* Основные функции */
  {"rust_mmTiny_cpp", (DL_FUNC) &rust_mmTiny_cpp, 2},
  {"cpp_mmAccelerate", (DL_FUNC) &cpp_mmAccelerate, 2},
  {"get_performance_info", (DL_FUNC) &get_performance_info, 0},
  {NULL, NULL, 0}
};

void R_init_MatrixProd(DllInfo *dll)
{
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
