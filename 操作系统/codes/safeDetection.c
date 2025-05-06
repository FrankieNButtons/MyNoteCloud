#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#define N 5  // 进程数
#define M 3  // 资源种类数

bool isSafe(int Available[M], int Allocation[N][M], int Need[N][M]) {
    int Work[M];
    bool Finish[N];
    int safeSequence[N];
    int count = 0;

    // Step 1: 初始化 Work 和 Finish
    memcpy(Work, Available, sizeof(Work));
    for (int i = 0; i < N; i++) Finish[i] = false;

    // Step 2: 循环查找满足条件的进程
    while (count < N) {
        bool found = false;
        for (int i = 0; i < N; i++) {
            if (!Finish[i]) {
                bool canAllocate = true;
                for (int j = 0; j < M; j++) {
                    if (Need[i][j] > Work[j]) {
                        canAllocate = false;
                        break;
                    }
                }

                // Step 3: 若找到则分配资源并标记
                if (canAllocate) {
                    for (int j = 0; j < M; j++) {
                        Work[j] += Allocation[i][j];
                    }
                    Finish[i] = true;
                    safeSequence[count++] = i;
                    found = true;
                }
            }
        }

        if (!found) {
            printf("系统处于不安全状态！\n");
            return false;
        }
    }

    // Step 4: 所有进程都完成，则系统安全
    printf("系统处于安全状态。\n安全序列为：");
    for (int i = 0; i < N; i++) {
        printf("P%d ", safeSequence[i]);
    }
    printf("\n");
    return true;
}


int main() {
    int Available[M] = {3, 3, 2};
    int Max[N][M] = {
        {7, 5, 3},
        {3, 2, 2},
        {9, 0, 2},
        {2, 2, 2},
        {4, 3, 3}
    };
    int Allocation[N][M] = {
        {0, 1, 0},
        {2, 0, 0},
        {3, 0, 2},
        {2, 1, 1},
        {0, 0, 2}
    };
    int Need[N][M];

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            Need[i][j] = Max[i][j] - Allocation[i][j];
        }
    }

    isSafe(Available, Allocation, Need);

    return 0;
}