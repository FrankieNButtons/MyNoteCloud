# PySpark的SQL与DSL实战
## WordCount任务

## `movie.data`任务
### 创建SpakSession并读取数据
```python

```
### 
### 查询为高分电影（`rank`>4）打分最多的用户并求出其打分的平均分
```python
# 1.查询为高分电影打分最多的用户
user_id = df.where("rank>4").\
             groupBy("user_id").\
             count().\
             orderBy("count",ascending=False).\
             limit(1).\
             first()["user_id"]
$ 
df.filter(df["user_id"]==user_id).\
   select(F.around(F.avg("rank"), 2)).show()

```
