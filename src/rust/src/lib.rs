use libc::{c_double, c_int};
use ndarray::{Array2, ArrayView2};
use rayon::prelude::*;
use std::slice;

// Оптимизированная реализация умножения матриц на Rust
// с использованием параллелизма и SIMD-оптимизаций
#[no_mangle]
pub extern "C" fn rust_mm_optimized(
    a_ptr: *const c_double,
    b_ptr: *const c_double,
    c_ptr: *mut c_double,
    m: c_int,
    k: c_int,
    n: c_int,
) {
    // Преобразуем указатели в срезы Rust
    let m = m as usize;
    let k = k as usize;
    let n = n as usize;

    // Безопасно преобразуем указатели в срезы Rust
    let a_slice = unsafe { slice::from_raw_parts(a_ptr, m * k) };
    let b_slice = unsafe { slice::from_raw_parts(b_ptr, k * n) };
    let c_slice = unsafe { slice::from_raw_parts_mut(c_ptr, m * n) };

    // Создаем представления ndarray для матриц
    // R хранит матрицы в формате column-major, поэтому учитываем это
    let a = ArrayView2::from_shape((k, m), a_slice).unwrap().t();
    let b = ArrayView2::from_shape((n, k), b_slice).unwrap().t();

    // Создаем результирующую матрицу
    let mut c = Array2::zeros((m, n));

    // Используем параллельную обработку для умножения матриц
    c.axis_iter_mut(ndarray::Axis(0))
        .into_par_iter()
        .enumerate()
        .for_each(|(i, mut row)| {
            for j in 0..n {
                let mut sum = 0.0;
                for l in 0..k {
                    sum += a[[i, l]] * b[[l, j]];
                }
                row[j] = sum;
            }
        });

    // Копируем результат обратно в C-массив
    // с учетом column-major формата R
    for i in 0..m {
        for j in 0..n {
            c_slice[i + j * m] = c[[i, j]];
        }
    }
}

// Блочная реализация умножения матриц для больших матриц
#[no_mangle]
pub extern "C" fn rust_mm_blocked(
    a_ptr: *const c_double,
    b_ptr: *const c_double,
    c_ptr: *mut c_double,
    m: c_int,
    k: c_int,
    n: c_int,
) {
    // Преобразуем указатели в срезы Rust
    let m = m as usize;
    let k = k as usize;
    let n = n as usize;

    // Безопасно преобразуем указатели в срезы Rust
    let a_slice = unsafe { slice::from_raw_parts(a_ptr, m * k) };
    let b_slice = unsafe { slice::from_raw_parts(b_ptr, k * n) };
    let c_slice = unsafe { slice::from_raw_parts_mut(c_ptr, m * n) };

    // Создаем представления ndarray для матриц
    // R хранит матрицы в формате column-major, поэтому учитываем это
    let a = ArrayView2::from_shape((k, m), a_slice).unwrap().t();
    let b = ArrayView2::from_shape((n, k), b_slice).unwrap().t();

    // Создаем результирующую матрицу
    let mut c = Array2::zeros((m, n));

    // Определяем размер блока
    const BLOCK_SIZE: usize = 64;

    // Блочное умножение матриц
    for i_block in (0..m).step_by(BLOCK_SIZE) {
        let i_end = std::cmp::min(i_block + BLOCK_SIZE, m);
        
        for j_block in (0..n).step_by(BLOCK_SIZE) {
            let j_end = std::cmp::min(j_block + BLOCK_SIZE, n);
            
            for k_block in (0..k).step_by(BLOCK_SIZE) {
                let k_end = std::cmp::min(k_block + BLOCK_SIZE, k);
                
                // Умножение блоков матриц
                for i in i_block..i_end {
                    for j in j_block..j_end {
                        let mut sum = 0.0;
                        for l in k_block..k_end {
                            sum += a[[i, l]] * b[[l, j]];
                        }
                        c[[i, j]] += sum;
                    }
                }
            }
        }
    }

    // Копируем результат обратно в C-массив
    // с учетом column-major формата R
    for i in 0..m {
        for j in 0..n {
            c_slice[i + j * m] = c[[i, j]];
        }
    }
}

// Функция для определения оптимального алгоритма в зависимости от размера матриц
#[no_mangle]
pub extern "C" fn rust_mm_auto(
    a_ptr: *const c_double,
    b_ptr: *const c_double,
    c_ptr: *mut c_double,
    m: c_int,
    k: c_int,
    n: c_int,
) {
    if m <= 512 && k <= 512 && n <= 512 {
        // Для малых матриц используем оптимизированный алгоритм
        rust_mm_optimized(a_ptr, b_ptr, c_ptr, m, k, n);
    } else {
        // Для больших матриц используем блочный алгоритм
        rust_mm_blocked(a_ptr, b_ptr, c_ptr, m, k, n);
    }
}
