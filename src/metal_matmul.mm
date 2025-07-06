// Отключаем макросы из R, которые конфликтуют с C++ стандартной библиотекой
#define R_NO_REMAP

// Включаем заголовочные файлы R
#include <R.h>
#include <Rinternals.h>

// Переопределяем макросы из R
#ifdef length
#undef length
#endif

// Защита от конфликта с COMPLEX из R
#ifdef COMPLEX
#undef COMPLEX
#endif

// Включаем заголовочные файлы Metal после отключения конфликтующих макросов
#include <Foundation/Foundation.h>
#include <Metal/Metal.h>

// Глобальные переменные для Metal
static id<MTLDevice> device = nil;
static id<MTLLibrary> library = nil;
static id<MTLFunction> function = nil;
static id<MTLComputePipelineState> pipelineState = nil;
static id<MTLCommandQueue> commandQueue = nil;
static bool metal_initialized = false;

// Функция для инициализации Metal
bool initialize_metal() {
    if (metal_initialized) return true;
    
    @autoreleasepool {
        // Получаем устройство Metal по умолчанию
        device = MTLCreateSystemDefaultDevice();
        if (!device) {
            Rprintf("Metal не поддерживается на этом устройстве\n");
            return false;
        }
        
        // Загружаем шейдер из файла
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"matrix_multiply" ofType:@"metallib"];
        if (!path) {
            // Если не нашли в бандле, ищем в директории пакета
            path = @"/Library/Frameworks/R.framework/Versions/4.3-arm64/Resources/library/MatrixProd/libs/matrix_multiply.metallib";
        }
        
        if (!path || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            Rprintf("Не удалось найти файл шейдера matrix_multiply.metallib\n");
            return false;
        }
        
        // Загружаем библиотеку Metal
        library = [device newLibraryWithFile:path error:&error];
        if (!library) {
            Rprintf("Ошибка загрузки библиотеки Metal: %s\n", [[error localizedDescription] UTF8String]);
            return false;
        }
        
        // Получаем функцию шейдера
        function = [library newFunctionWithName:@"matrix_multiply"];
        if (!function) {
            Rprintf("Не удалось найти функцию matrix_multiply в библиотеке Metal\n");
            return false;
        }
        
        // Создаем пайплайн
        pipelineState = [device newComputePipelineStateWithFunction:function error:&error];
        if (!pipelineState) {
            Rprintf("Ошибка создания пайплайна: %s\n", [[error localizedDescription] UTF8String]);
            return false;
        }
        
        // Создаем очередь команд
        commandQueue = [device newCommandQueue];
        if (!commandQueue) {
            Rprintf("Не удалось создать очередь команд Metal\n");
            return false;
        }
        
        metal_initialized = true;
        return true;
    }
}

// Функция для проверки доступности Metal
extern "C" SEXP is_metal_available() {
    SEXP result = PROTECT(Rf_allocVector(LGLSXP, 1));
    LOGICAL(result)[0] = initialize_metal();
    UNPROTECT(1);
    return result;
}

// Функция для умножения матриц с использованием Metal
extern "C" SEXP gpu_mmMetal(SEXP A_r, SEXP B_r) {
    // Инициализируем Metal
    if (!initialize_metal()) {
        Rf_error("Metal не инициализирован");
    }
    
    // Получаем размеры матриц
    SEXP dim_A = Rf_getAttrib(A_r, R_DimSymbol);
    SEXP dim_B = Rf_getAttrib(B_r, R_DimSymbol);
    
    int M = INTEGER(dim_A)[0];
    int K = INTEGER(dim_A)[1];
    int N = INTEGER(dim_B)[1];
    
    if (INTEGER(dim_B)[0] != K) {
        Rf_error("Несовместимые размеры матриц");
    }
    
    // Создаем результирующую матрицу
    SEXP C_r = PROTECT(Rf_allocMatrix(REALSXP, M, N));
    double *A = REAL(A_r);
    double *B = REAL(B_r);
    double *C = REAL(C_r);
    
    @autoreleasepool {
        // Создаем буферы для матриц
        size_t A_size = M * K * sizeof(float);
        size_t B_size = K * N * sizeof(float);
        size_t C_size = M * N * sizeof(float);
        
        id<MTLBuffer> bufferA = [device newBufferWithLength:A_size options:MTLResourceStorageModeShared];
        id<MTLBuffer> bufferB = [device newBufferWithLength:B_size options:MTLResourceStorageModeShared];
        id<MTLBuffer> bufferC = [device newBufferWithLength:C_size options:MTLResourceStorageModeShared];
        id<MTLBuffer> bufferM = [device newBufferWithBytes:&M length:sizeof(int) options:MTLResourceStorageModeShared];
        id<MTLBuffer> bufferN = [device newBufferWithBytes:&N length:sizeof(int) options:MTLResourceStorageModeShared];
        id<MTLBuffer> bufferK = [device newBufferWithBytes:&K length:sizeof(int) options:MTLResourceStorageModeShared];
        
        // Копируем данные из R в буферы Metal
        float *dataA = (float *)bufferA.contents;
        float *dataB = (float *)bufferB.contents;
        
        // Конвертируем double в float
        for (int i = 0; i < M * K; i++) {
            dataA[i] = (float)A[i];
        }
        
        for (int i = 0; i < K * N; i++) {
            dataB[i] = (float)B[i];
        }
        
        // Создаем командный буфер
        id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
        
        // Создаем энкодер вычислений
        id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
        
        // Устанавливаем пайплайн
        [computeEncoder setComputePipelineState:pipelineState];
        
        // Устанавливаем буферы
        [computeEncoder setBuffer:bufferA offset:0 atIndex:0];
        [computeEncoder setBuffer:bufferB offset:0 atIndex:1];
        [computeEncoder setBuffer:bufferC offset:0 atIndex:2];
        [computeEncoder setBuffer:bufferM offset:0 atIndex:3];
        [computeEncoder setBuffer:bufferN offset:0 atIndex:4];
        [computeEncoder setBuffer:bufferK offset:0 atIndex:5];
        
        // Вычисляем размер сетки и группы потоков
        MTLSize gridSize = MTLSizeMake(N, M, 1);
        
        // Определяем оптимальный размер группы потоков
        NSUInteger threadGroupWidth = pipelineState.threadExecutionWidth;
        NSUInteger threadGroupHeight = pipelineState.maxTotalThreadsPerThreadgroup / threadGroupWidth;
        MTLSize threadGroupSize = MTLSizeMake(threadGroupWidth, threadGroupHeight, 1);
        
        // Запускаем вычисления
        [computeEncoder dispatchThreads:gridSize threadsPerThreadgroup:threadGroupSize];
        [computeEncoder endEncoding];
        
        // Запускаем командный буфер и ждем завершения
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];
        
        // Копируем результат обратно в R
        float *dataC = (float *)bufferC.contents;
        for (int i = 0; i < M * N; i++) {
            C[i] = (double)dataC[i];
        }
    }
    
    UNPROTECT(1);
    return C_r;
}
