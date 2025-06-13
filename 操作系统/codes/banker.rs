

// 银行家算法 Rust 实现，模拟资源分配与安全性检测
use std::fmt;

const N: usize = 5; // 进程数
const M: usize = 3; // 资源种类数

fn print_matrix(
    allocation: &[[i32; M]; N],
    max: &[[i32; M]; N],
    need: &[[i32; M]; N],
    available: &[i32; M],
) {
    println!("假设 T₀ 时刻的系统状态如下：\n");

    println!(
        "{:10}{:14}{:14}{:14}",
        "Allocation", "Max", "Need", "Available"
    );
    println!("      A  B  C     A  B  C     A  B  C    A  B  C");

    for i in 0..N {
        print!("P{}   ", i);
        for j in 0..M {
            print!("{:2} ", allocation[i][j]);
        }
        print!("   ");
        for j in 0..M {
            print!("{:2} ", max[i][j]);
        }
        print!("   ");
        for j in 0..M {
            print!("{:2} ", need[i][j]);
        }
        if i == 0 {
            print!("  ");
            for j in 0..M {
                print!("{:2} ", available[j]);
            }
        }
        println!();
    }
    println!();
}

fn main() {
    let allocation = [
        [0, 1, 0],
        [2, 0, 0],
        [3, 0, 2],
        [2, 1, 1],
        [0, 0, 2],
    ];

    let max = [
        [7, 5, 3],
        [3, 2, 2],
        [9, 0, 2],
        [2, 2, 2],
        [4, 3, 3],
    ];

    let mut available = [3, 3, 2];

    let mut need = [[0; M]; N];
    for i in 0..N {
        for j in 0..M {
            need[i][j] = max[i][j] - allocation[i][j];
        }
    }

    print_matrix(&allocation, &max, &need, &available);

    println!("执行银行家算法动态检测过程：\n");

    let mut finish = [false; N];
    let mut work = available.clone();
    let mut safe_seq = Vec::new();

    while safe_seq.len() < N {
        let mut found = false;

        for i in 0..N {
            if !finish[i] {
                let can_run = (0..M).all(|j| need[i][j] <= work[j]);

                if can_run {
                    print!("-> 进程 P{} 可以执行，释放资源前 Work: ", i);
                    for j in 0..M {
                        print!("{:2} ", work[j]);
                    }
                    println!();

                    for j in 0..M {
                        work[j] += allocation[i][j];
                    }

                    print!("   进程 P{} 执行完毕，释放资源后 Work: ", i);
                    for j in 0..M {
                        print!("{:2} ", work[j]);
                    }
                    println!("\n");

                    finish[i] = true;
                    safe_seq.push(i);
                    found = true;
                }
            }
        }

        if !found {
            println!("系统不处于安全状态，无法继续找到安全序列。");
            return;
        }
    }

    print!("系统处于安全状态，安全序列为：");
    for i in 0..safe_seq.len() {
        print!("P{} ", safe_seq[i]);
    }
    println!();
}