#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define N 5
#define M 3

void printMatrixToConsole(int Allocation[N][M], int Max[N][M], int Need[N][M], int Available[M]) {
    printf("假设 T₀ 时刻的系统状态如下：\n\n");

    printf("%10s%14s%14s%14s\n", "Allocation", "Max", "Need", "Available");
    printf("      A  B  C     A  B  C     A  B  C    A  B  C\n");

    for (int i = 0; i < N; i++) {
        printf("P%-1d   ", i);
        for (int j = 0; j < M; j++) printf("%2d ", Allocation[i][j]);
        printf("   ");
        for (int j = 0; j < M; j++) printf("%2d ", Max[i][j]);
        printf("   ");
        for (int j = 0; j < M; j++) printf("%2d ", Need[i][j]);
        if (i == 0) {
            printf("  ");
            for (int j = 0; j < M; j++) printf("%2d ", Available[j]);
        }
        printf("\n");
    }

    printf("\n");
}


int main() {
    int Allocation[N][M] = {
        {0, 1, 0},
        {2, 0, 0},
        {3, 0, 2},
        {2, 1, 1},
        {0, 0, 2}
    };

    int Max[N][M] = {
        {7, 5, 3},
        {3, 2, 2},
        {9, 0, 2},
        {2, 2, 2},
        {4, 3, 3}
    };

    int Available[M] = {3, 3, 2};

    int Need[N][M];
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            Need[i][j] = Max[i][j] - Allocation[i][j];
        }
    }

    printMatrixToConsole(Allocation, Max, Need, Available);

    // 动态分配过程 - 银行家算法核心
    printf("执行银行家算法动态检测过程：\n\n");

    bool Finish[N] = {false};
    int Work[M];
    for (int i = 0; i < M; i++) {
        Work[i] = Available[i];
    }

    int safeSeq[N];
    int count = 0;

    while (count < N) {
        bool found = false;
        for (int i = 0; i < N; i++) {
            if (!Finish[i]) {
                bool canRun = true;
                for (int j = 0; j < M; j++) {
                    if (Need[i][j] > Work[j]) {
                        canRun = false;
                        break;
                    }
                }

                if (canRun) {
                    printf("-> 进程 P%d 可以执行，释放资源前 Work: ", i);
                    for (int j = 0; j < M; j++) printf("%2d ", Work[j]);
                    printf("\n");

                    for (int j = 0; j < M; j++) {
                        Work[j] += Allocation[i][j];
                    }

                    printf("   进程 P%d 执行完毕，释放资源后 Work: ", i);
                    for (int j = 0; j < M; j++) printf("%2d ", Work[j]);
                    printf("\n\n");

                    Finish[i] = true;
                    safeSeq[count++] = i;
                    found = true;
                }
            }
        }

        if (!found) {
            printf("系统不处于安全状态，无法继续找到安全序列。\n");
            return 1;
        }
    }

    printf("系统处于安全状态，安全序列为：");
    for (int i = 0; i < N; i++) {
        printf("P%d ", safeSeq[i]);
    }
    printf("\n");

    return 0;
}