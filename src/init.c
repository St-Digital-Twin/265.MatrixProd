#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP tiny_matmul(SEXP, SEXP);
extern SEXP cpu_fast_matmul(SEXP, SEXP);
extern SEXP get_performance_info(void);

static const R_CallMethodDef CallEntries[] = {
  {"tiny_matmul", (DL_FUNC) &tiny_matmul, 2},
  {"cpu_fast_matmul", (DL_FUNC) &cpu_fast_matmul, 2},
  {"get_performance_info", (DL_FUNC) &get_performance_info, 0},
  {NULL, NULL, 0}
};

void R_init_MatrixProd(DllInfo *dll)
{
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
