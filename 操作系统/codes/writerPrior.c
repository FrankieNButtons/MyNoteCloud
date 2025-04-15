#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

sem_t wrt, readSem;
sem_t mutex1, mutex2;
int readerCount = 0;
int writerCount = 0;

void* writer(void* arg) {
    int id = *((int*)arg);
    while (1) {
        sleep(2);

        sem_wait(&mutex2);
        writerCount++;
        if (writerCount == 1)
            sem_wait(&readSem);  // 第一个写者阻止读者进入
        sem_post(&mutex2);

        sem_wait(&wrt);
        printf("📝 Writer %d is writing...\n", id);
        sleep(1);
        printf("✅ Writer %d finished writing.\n", id);
        sem_post(&wrt);

        sem_wait(&mutex2);
        writerCount--;
        if (writerCount == 0)
            sem_post(&readSem);  // 最后一个写者允许读者进入
        sem_post(&mutex2);

        sleep(1);
    }
    return NULL;
}

void* reader(void* arg) {
    int id = *((int*)arg);
    while (1) {
        sleep(1);

        sem_wait(&readSem);      // 若有写者，不能进入
        sem_wait(&mutex1);
        readerCount++;
        if (readerCount == 1)
            sem_wait(&wrt);      // 第一个读者阻止写者写
        sem_post(&mutex1);
        sem_post(&readSem);      // 让其他读者进来

        printf("📖 Reader %d is reading...\n", id);
        sleep(1);
        printf("✅ Reader %d finished reading.\n", id);

        sem_wait(&mutex1);
        readerCount--;
        if (readerCount == 0)
            sem_post(&wrt);      // 最后一个读者释放写者
        sem_post(&mutex1);

        sleep(1);
    }
    return NULL;
}

int main() {
    pthread_t rtid[5], wtid[2];
    int rids[5] = {1, 2, 3, 4, 5};
    int wids[2] = {1, 2};

    sem_init(&wrt, 0, 1);
    sem_init(&readSem, 0, 1);
    sem_init(&mutex1, 0, 1);
    sem_init(&mutex2, 0, 1);

    for (int i = 0; i < 5; i++) {
        pthread_create(&rtid[i], NULL, reader, &rids[i]);
    }

    for (int i = 0; i < 2; i++) {
        pthread_create(&wtid[i], NULL, writer, &wids[i]);
    }

    for (int i = 0; i < 5; i++) {
        pthread_join(rtid[i], NULL);
    }
    for (int i = 0; i < 2; i++) {
        pthread_join(wtid[i], NULL);
    }

    sem_destroy(&wrt);
    sem_destroy(&readSem);
    sem_destroy(&mutex1);
    sem_destroy(&mutex2);

    return 0;
}
