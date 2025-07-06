#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* Объявления внешних функций */
extern SEXP rust_mmTiny_cpp(SEXP A_r, SEXP B_r);
extern SEXP rust_mmBlocked_cpp(SEXP A_r, SEXP B_r);
extern SEXP rust_mmAuto_cpp(SEXP A_r, SEXP B_r);
extern SEXP cpp_mmAccelerate(SEXP A_r, SEXP B_r);
extern SEXP gpu_mmMetal(SEXP A_r, SEXP B_r);
extern SEXP is_metal_available();
extern SEXP get_performance_info();

static const R_CallMethodDef CallEntries[] = {
  {"rust_mmTiny_cpp", (DL_FUNC) &rust_mmTiny_cpp, 2},
  {"rust_mmBlocked_cpp", (DL_FUNC) &rust_mmBlocked_cpp, 2},
  {"rust_mmAuto_cpp", (DL_FUNC) &rust_mmAuto_cpp, 2},
  {"cpp_mmAccelerate", (DL_FUNC) &cpp_mmAccelerate, 2},
  {"gpu_mmMetal", (DL_FUNC) &gpu_mmMetal, 2},
  {"is_metal_available", (DL_FUNC) &is_metal_available, 0},
  {"get_performance_info", (DL_FUNC) &get_performance_info, 0},
  {NULL, NULL, 0}
};

void R_init_MatrixProd(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}
