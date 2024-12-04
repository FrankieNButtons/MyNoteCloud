# 第一次`Scala`相关作业
## 阶乘的两种实现
```scala
import scala.io.StdIn._

object FactorialSum {

  // 递归实现阶乘
  def factorialRecursive(n: Int): Int = {
    if (n == 0) 1
    else n * factorialRecursive(n - 1)
  }

  // 迭代实现阶乘
  def factorialIterative(n: Int): Int = {
    var result = 1
    for (i <- 1 to n) {
      result *= i
    }
    result
  }

  // 传值参数实现阶乘和
  def factorialSumByValue(n: Int): Int = {
    var sum = 0
    for (i <- 1 to n) {
      val res = factorialIterative(i)
      println(s"factorial(${i})=${res}")
      sum += res
    }
    sum
  }

  // 传名参数实现阶乘和
  def factorialSumByReference(n: Int): Int = {
    var sum = 0
    for (i <- 1 to n) {
      val res = factorialRecursive(i)
      println(s"factorial(${i})=${res}")
      sum += res
    }
    sum
  }

  def main(args: Array[String]): Unit = {
    println("请输入一个数：")
    val num = readInt()

    println(s"递归方法（传名参数）阶乘和: ${factorialSumByReference(num)}")
    println(s"迭代方法（传值参数）阶乘和: ${factorialSumByValue(num)}")
  }
}
```

## 考拉兹数列的呈现
### 自由计算
```scala
import scala.io.StdIn._

object CollatzConjecture {

  // 求取考拉兹序列
  def collatzSequence(n: Int): Unit = {
    var number = n
    var max = number
    var maxPos = 0
    var count = 0
    
    print("(")
    while (number != 1) {
      count += 1
      if (number > max) {
        max = number
        maxPos = count
      }
      number = if (number % 2 == 0) number / 2 else 3 * number + 1
      print(number + " ")
    }
    println(")")
    count += 1

    println(s"考拉兹序列中的最大值是：$max")
    println(s"最大值的位置是：$maxPos")
    println(s"考拉兹序列的整数个数是：$count")
  }

  def main(args: Array[String]): Unit = {
    print("请输入求取考拉兹数列的起始数字：")
    val n = readInt()
    collatzSequence(n)
  }
}
```
### 10000000内最长序列
```Scala
import scala.io.StdIn._

object CollatzConjecture {

  // 计算考拉兹序列的长度
  def collatzLength(n: Int): Int = {
    var count = 1
    var number = n
    while (number != 1) {
      number = if (number % 2 == 0) number / 2 else 3 * number + 1
      count += 1
    }
    count
  }

  def main(args: Array[String]): Unit = {
    val startTime = System.currentTimeMillis()

    var longestSeqLength = 0
    var startNumber = 0

    // 在1到10000000之间寻找最长的考拉兹序列
    for (i <- 1 to 10000000) {
      val length = collatzLength(i)
      if (length > longestSeqLength) {
        longestSeqLength = length
        startNumber = i
      }
    }

    val endTime = System.currentTimeMillis()
    val timeTaken = endTime - startTime

    println(s"最长考拉兹序列的起始数是：$startNumber")
    println(s"最长考拉兹序列的长度是：$longestSeqLength")
    println(s"运行时间为：$timeTaken 毫秒")
  }
}

```