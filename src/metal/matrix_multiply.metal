#include <metal_stdlib>
using namespace metal;

// Шейдер для умножения матриц на GPU с использованием Metal
kernel void matrix_multiply(device const float* A [[buffer(0)]],
                           device const float* B [[buffer(1)]],
                           device float* C [[buffer(2)]],
                           constant int& M [[buffer(3)]],
                           constant int& N [[buffer(4)]],
                           constant int& K [[buffer(5)]],
                           uint2 gid [[thread_position_in_grid]]) {
    // Проверка границ
    if (gid.x >= N || gid.y >= M) return;
    
    // Вычисление элемента результирующей матрицы
    float sum = 0.0f;
    for (int i = 0; i < K; i++) {
        sum += A[gid.y * K + i] * B[i * N + gid.x];
    }
    
    // Запись результата
    C[gid.y * N + gid.x] = sum;
}
