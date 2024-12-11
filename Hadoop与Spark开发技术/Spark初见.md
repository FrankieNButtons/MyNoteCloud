# Spark分析计算框架
## Spark的底层
### RDD（Resilient Distributed Dataset）弹性分布式数据集
#### 特点
1. RDD是分布式数据集，是Spark的分布式数据抽象，是Spark的编程模型
2. 分布式内存计算的统一分析引擎
3. 可对任意类型的数据进行自定义分布式计算，包括文件、数据库等
4. RDD是只读的，不能修改，但可以进行转换，转换得到新的RDD
5. RDD的弹性
    - 存储的弹性：内存磁盘自动切换
    - 容错的弹性：出现丢失可以恢复（检查点或血缘重算）
    - 计算的弹性：计算分层
    - 分片的弹性：根据需要重新分片
#### RDD的运行模式
1. RDD的创建
2. RDD的转换
3. RDD的缓存
4. RDD的行动
5. RDD的输出
### Spark的特点


1. **与Hadoop比较**
   - 不像Hadoop一样提供整个计算平台，只提供计算引擎，而Spark则提供了计算引擎和计算框架。
   - Hadoop基于进程并行，而Spark基于线程并行。
   - Hadoop基于文件，而Spark基于内存。
   - Hadoop基于MapReduce，而Spark基于SparkCore。
2. **主要基于DAG优化算子**
2. **有比较丰富的框架（重要）**
   - Spark Core
   - Spark SQL
   - Spark Streaming
   - Spark MLlib
   - Spark GraphX
### Spark的运行模式
1. 本地模式（单机）
2. 集群模式
3. Standalone 集群模式
4. YARN 集群模式
5. Mesos 集群模式（C++）
6. Spark-Shell（基于Scala）
## Spark的编程模式
### PySpark案例
#### Map
```python

```
#### FlatMap
```python
from pyspark import SparkConf, SparkContext


```

