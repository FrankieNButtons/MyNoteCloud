#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

// 信号量和全局变量
sem_t wrt;
sem_t mutex;
int readcount = 0;

void* writer(void* arg) {
    int id = *((int*)arg);
    while (1) {
        sleep(2);  // 模拟写操作前的等待
        sem_wait(&wrt);  // 等待写权限
        printf("📝 Writer %d is writing...\n", id);
        sleep(1);  // 模拟写操作
        printf("✅ Writer %d finished writing.\n", id);
        sem_post(&wrt);  // 释放写权限
        sleep(1);
    }
    return NULL;
}

void* reader(void* arg) {
    int id = *((int*)arg);
    while (1) {
        sleep(1);  // 模拟读操作前的等待
        sem_wait(&mutex);
        readcount++;
        if (readcount == 1) {
            sem_wait(&wrt);  // 第一个读者阻止写者写入
        }
        sem_post(&mutex);

        printf("📖 Reader %d is reading...\n", id);
        sleep(1);  // 模拟读操作
        printf("✅ Reader %d finished reading.\n", id);

        sem_wait(&mutex);
        readcount--;
        if (readcount == 0) {
            sem_post(&wrt);  // 最后一个读者释放写权限
        }
        sem_post(&mutex);
        sleep(1);
    }
    return NULL;
}

int main() {
    pthread_t rtid[5], wtid[2];
    int rids[5] = {1, 2, 3, 4, 5};
    int wids[2] = {1, 2};

    sem_init(&mutex, 0, 1);
    sem_init(&wrt, 0, 1);

    // 创建读者线程
    for (int i = 0; i < 5; i++) {
        pthread_create(&rtid[i], NULL, reader, &rids[i]);
    }

    // 创建写者线程
    for (int i = 0; i < 2; i++) {
        pthread_create(&wtid[i], NULL, writer, &wids[i]);
    }

    // 主线程等待（实际上程序会无限运行）
    for (int i = 0; i < 5; i++) {
        pthread_join(rtid[i], NULL);
    }
    for (int i = 0; i < 2; i++) {
        pthread_join(wtid[i], NULL);
    }

    sem_destroy(&mutex);
    sem_destroy(&wrt);

    return 0;
}