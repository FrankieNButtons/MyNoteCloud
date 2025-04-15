#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

// 信号量和变量定义
sem_t mutex, wrt, writer_mutex;
int readcount = 0;

void* writer(void* arg) {
    int id = *((int*)arg);
    while (1) {
        sleep(2);  // 模拟写前等待

        sem_wait(&writer_mutex); // 更严格的等待，防止读者插队
        sem_wait(&wrt);          // 写者锁
        printf("📝 Writer %d is writing...\n", id);
        sleep(1);                // 模拟写操作
        printf("✅ Writer %d finished writing.\n", id);
        sem_post(&wrt);

        // 如果没有读者了，允许其他写者进入
        if (readcount == 0)
            sem_post(&writer_mutex);

        sleep(1);
    }
    return NULL;
}

void* reader(void* arg) {
    int id = *((int*)arg);
    while (1) {
        sleep(1);  // 模拟读前等待

        sem_wait(&mutex);
        readcount++;
        if (readcount == 1) {
            sem_wait(&wrt);  // 第一个读者阻止写者写
        }
        sem_post(&mutex);

        printf("📖 Reader %d is reading...\n", id);
        sleep(1);  // 模拟读操作
        printf("✅ Reader %d finished reading.\n", id);

        sem_wait(&mutex);
        readcount--;
        if (readcount == 0) {
            sem_post(&wrt);  // 最后一个读者允许写者写
            sem_post(&writer_mutex);  // 通知写者可以准备进入
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

    // 初始化信号量
    sem_init(&mutex, 0, 1);
    sem_init(&wrt, 0, 1);
    sem_init(&writer_mutex, 0, 1);

    // 创建读者线程
    for (int i = 0; i < 5; i++) {
        pthread_create(&rtid[i], NULL, reader, &rids[i]);
    }

    // 创建写者线程
    for (int i = 0; i < 2; i++) {
        pthread_create(&wtid[i], NULL, writer, &wids[i]);
    }

    // 无限运行等待线程（实际可 Ctrl+C 终止）
    for (int i = 0; i < 5; i++) {
        pthread_join(rtid[i], NULL);
    }
    for (int i = 0; i < 2; i++) {
        pthread_join(wtid[i], NULL);
    }

    sem_destroy(&mutex);
    sem_destroy(&wrt);
    sem_destroy(&writer_mutex);

    return 0;
}
