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
### 10000000内最长序列（DP优化）
```Scala
import scala.collection.mutable

object CollatzConjecture {
  val memo = mutable.Map[Long, Int](1L -> 1)

  def collatzLength(n: Long): Int = {
    memo.getOrElseUpdate(n, {
      if (n % 2 == 0) {
        1 + collatzLength(n / 2)
      } else {

        1 + collatzLength(3 * n + 1)
      }
    })
  }

  def main(args: Array[String]): Unit = {
    val startTime = System.currentTimeMillis()

    var longestSeqLength = 0
    var startNumber = 0

    for (i <- 1 to 10000000) {
      val length = collatzLength(i)
      if (length > longestSeqLength) {
        longestSeqLength = length
        startNumber = i
      }


      if (i % 1000000 == 0) {
        println(s"已处理到 $i ...")
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
### 数组索引
```Scala
import scala.collection.mutable.ArrayBuffer

object ArraySwap {
  def swapAdjacentElements(arr: Array[Int]): ArrayBuffer[Int] = {
    val buffer = ArrayBuffer.from(arr) // 将Array转为ArrayBuffer以便操作
    for (i <- 0 until buffer.length - 1 by 2) {
      // 每隔2个索引交换元素
      val temp = buffer(i)
      buffer(i) = buffer(i + 1)
      buffer(i + 1) = temp
    }
    buffer
  }

  def main(args: Array[String]): Unit = {
    val inputArray = Array(16, 99, 20, 48, 100, 66, 10, 3, 8)
    val swappedArray = swapAdjacentElements(inputArray)
    println(swappedArray.mkString(", ")) // 输出结果
  }
}
```
### 字符串合并
```Scala
object StringManipulation {
  def main(args: Array[String]): Unit = {
    println("请输入第一个字符串：")
    val str1 = scala.io.StdIn.readLine()

    println("请输入第二个字符串：")
    val str2 = scala.io.StdIn.readLine()
    
    val mergedStr = (str1 + str2).toUpperCase

    println(s"合并后的字符串为：$mergedStr")
    println(s"合并后的字符串长度为：${mergedStr.length}")


    val secondLastChar = mergedStr(mergedStr.length - 2)
    println(s"倒数第二个字符为：$secondLastChar")


    val trimmedStr = mergedStr.tail.init
    println(s"去掉首尾字符的字符串为：$trimmedStr")
  }
}
```
### 文件IO
```Scala
import scala.io.Source
import java.io.PrintWriter

object FileProcessor {
  def main(args: Array[String]): Unit = {
    // 读取输入文件
    val inputFile = Source.fromFile("data/1.txt")
    val lines = inputFile.getLines()

    // 创建输出文件
    val out = new PrintWriter("data/output.txt")

    // 处理每一行
    for (line <- lines) {
      // 去掉首尾空格并转换为大写
      val trimmedLine = line.trim.toUpperCase

      // 计算每行的长度
      val length = trimmedLine.length

      // 将每行的内容按要求格式化并写入到输出文件
      out.write(s"$trimmedLine\t$length\n")
    }

    // 关闭文件
    inputFile.close()
    out.close()
  }
}
```
