


#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#define N 5 // 进程数量
#define M 3 // 资源种类数量

bool detectDeadlock(int Available[M], int Allocation[N][M], int Request[N][M]) {
    bool Finish[N];
    int Work[M];
    memcpy(Work, Available, sizeof(Work));

    // 初始化 Finish 向量
    for (int i = 0; i < N; i++) {
        bool isZero = true;
        for (int j = 0; j < M; j++) {
            if (Allocation[i][j] != 0) {
                isZero = false;
                break;
            }
        }
        Finish[i] = isZero;
    }

    // 步骤 2：尝试找到满足条件的进程
    while (true) {
        bool found = false;

        for (int i = 0; i < N; i++) {
            if (!Finish[i]) {
                bool canGrant = true;
                for (int j = 0; j < M; j++) {
                    if (Request[i][j] > Work[j]) {
                        canGrant = false;
                        break;
                    }
                }

                if (canGrant) {
                    // 释放资源
                    for (int j = 0; j < M; j++) {
                        Work[j] += Allocation[i][j];
                    }
                    Finish[i] = true;
                    found = true;
                }
            }
        }

        if (!found) break;
    }

    // 若存在 Finish[i] == false，说明存在死锁
    bool deadlock = false;
    for (int i = 0; i < N; i++) {
        if (!Finish[i]) {
            deadlock = true;
            printf("检测到死锁：进程 P%d 被阻塞。\n", i);
        }
    }

    return deadlock;
}

// 示例主函数进行测试
int main() {
    int Available[M] = {3, 3, 2};

    int Allocation[N][M] = {
        {0, 1, 0},
        {2, 0, 0},
        {3, 0, 3},
        {2, 1, 1},
        {0, 0, 2}
    };

    int Request[N][M] = {
        {0, 0, 0},
        {2, 0, 2},
        {0, 0, 0},
        {1, 0, 0},
        {0, 0, 2}
    };

    bool hasDeadlock = detectDeadlock(Available, Allocation, Request);

    if (!hasDeadlock) {
        printf("系统当前无死锁。\n");
    }

    return 0;
}