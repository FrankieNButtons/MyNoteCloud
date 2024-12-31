## PySpark作业（实验四）
### `order.txt`相关
#### 地区归并
```python
import json

def read_txt_as_json(file_path):
    orders = []
    with open(file_path, "r") as file:
        for line in file:
            json_objects = line.strip().split("|")
            for json_obj in json_objects:
                order_dict = json.loads(json_obj)
                orders.append(order_dict)

    return orders
orders = read_txt_as_json("./data/order.txt")
print(orders)




from pyspark.sql import SparkSession

# 初始化SparkSession
spark = SparkSession.builder.appName("OrderProcessing").getOrCreate()

# 使用PySpark RDD读取字典列表数据
orders_rdd = spark.sparkContext.parallelize(orders)

# 过滤出'areaName'为'北京'的订单，并提取出"北京_商品类别"的组合
beijing_rdd = orders_rdd.filter(lambda x: x['areaName'] == '北京') \
                        .map(lambda x: f"北京_{x['category']}")

# 去重
unique_beijing_categories_rdd = beijing_rdd.distinct()

# 收集并显示结果
result = unique_beijing_categories_rdd.collect()

# 输出结果
print(result)

# 停止SparkSession
spark.stop()
```
#### 统计计算
```python
import json

def read_txt_as_json(file_path):
    orders = []
    with open(file_path, "r") as file:
        # 按行读取数据
        for line in file:

            json_objects = line.strip().split("|")
            for json_obj in json_objects:
                order_dict = json.loads(json_obj)
                orders.append(order_dict)

    return orders
orders = read_txt_as_json("./data/order.txt")
print(orders)




from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("OrderProcessing").getOrCreate()
orders_rdd = spark.sparkContext.parallelize(orders)

# 1. 按地区统计订单数量
order_count_by_area_rdd = orders_rdd.map(lambda x: (x['areaName'], 1)) \
                                    .reduceByKey(lambda a, b: a + b)

# 2. 按地区统计订单总金额
# 由于'money'是字符串类型，需先将其转换为浮动类型进行求和
order_amount_by_area_rdd = orders_rdd.map(lambda x: (x['areaName'], float(x['money']))) \
                                     .reduceByKey(lambda a, b: a + b)

# 3. 获取结果并打印

# 统计订单数量
print("按地区统计订单数量:")
order_count_result = order_count_by_area_rdd.collect()
for area, count in order_count_result:
    print(f"{area}: {count}")

# 统计订单总金额（按金额从高到低排序）
print("\n按地区统计订单总金额(从高到低):")
order_amount_result = order_amount_by_area_rdd.sortBy(lambda x: x[1], ascending=False).collect()
for area, total_amount in order_amount_result:
    print(f"{area}: {total_amount:.2f}元")

# 停止SparkSession
spark.stop()
```
#### 基于Scala与Spark-Shell的 `SprkSQL`实战
```scala
spark.sql("""
  SELECT d.theyear, MAX(SumOfAmount) AS MaxOrderAmount 
  FROM orderAmountView AS order_amount 
  JOIN tbDate d ON order_amount.dateid = d.dateid 
  GROUP BY d.theyear
""").show()
```
```scala
spark.sql("""
  SELECT a.theyear, a.itemid, a.MaxAmount, b.SumOfAmount
  FROM (
    SELECT theyear, itemid, MAX(SumOfAmount) AS MaxAmount
    FROM yearAllSell
    GROUP BY theyear, itemid
  ) AS a
  JOIN yearAllSell AS b ON a.theyear = b.theyear AND a.itemid = b.itemid
  WHERE a.MaxAmount = b.SumOfAmount
""").show()

```