
# WeatherSort作业的编写
## The Only Process
### Step 1:WeatherMapper.java
#### Data Structure of Step

#### Code for step
```java
import java.io.IOException;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

// WeatherMapper类，负责将输入数据映射到中间键值对
public class WeatherMapper extends Mapper<LongWritable, Text, Text, Text> {
    @Override
    protected void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {
        // 将输入的一行文本转换为字符串并按制表符分割
        String[] strs = value.toString().split("\t");
        // 获取分割后的第一部分数据并按空格分割
        String[] strs1 = strs[0].split(" ");
        // 获取日期部分并按“-”分割，提取月份
        String[] strs2 = strs1[0].split("-");
        // 将月份作为key，整行数据作为value输出
        context.write(new Text(strs2[1]), value);
    }
}
```


### Step 2:WeatherReducer.java
#### Data Structure of Step

#### Code for step
```java
import java.io.IOException;
import java.util.*;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

// WeatherReducer类，负责处理Mapper的输出并进行归约
public class WeatherReducer extends Reducer<Text, Text, Text, NullWritable> {
    @Override
    protected void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
        // 使用优先队列来保持最高温度
        PriorityQueue<StructWeather> queue = new PriorityQueue<>(3, (a, b) -> Integer.compare(b.getTemp(), a.getTemp()));
        for (Text value : values) {
            // 按制表符分割每一行输入数据
            String[] strs = value.toString().split("\t");
            String date = strs[0]; // 获取日期
            int temp = Integer.parseInt(strs[1].substring(0, strs[1].length() - 1)); // 获取温度并转换为整数
            StructWeather weather = new StructWeather(); // 创建天气数据对象
            weather.setDate(date);
            weather.setTemp(temp);
            queue.add(weather);
            if (queue.size() > 3) {
                queue.poll();
            }
        }
        // 输出最高的三个温度
        List<StructWeather> top3 = new ArrayList<>(queue);
        // 根据温度降序排序
        Collections.sort(top3, (a, b) -> Integer.compare(b.getTemp(), a.getTemp()));
        // 记录输出格式：年月日和温度
        for (StructWeather weather : top3) {
            context.write(new Text(weather.getDate() + "\t" + weather.getTemp() + "c"), NullWritable.get()); // 输出日期和温度
        }
    }
}
```

### Step 1:WeatherJob.java
#### Data Structure of Step

#### Code for step
```java
import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

// WeatherJob类
public class WeatherJob {
    public static void main(String[] args) {
        // 创建Hadoop配置对象
        Configuration config = new Configuration();

        try {
            // 创建Job对象并配置基本信息
            Job job = Job.getInstance(config);
            job.setJarByClass(WeatherJob.class);
            job.setJobName("WeatherJob");

            // 设置Mapper和Reducer类
            job.setMapperClass(WeatherMapper.class);
            job.setReducerClass(WeatherReducer.class);

            // 设置Mapper的输出键值类型
            job.setMapOutputKeyClass(Text.class);
            job.setMapOutputValueClass(Text.class);

            // 设置Reducer的输出键值类型
            job.setOutputKeyClass(Text.class); // 假设使用Text作为输出的key
            job.setOutputValueClass(NullWritable.class); // 输出value为空

            // 设置输入文件路径
            FileInputFormat.addInputPath(job, new Path("hdfs://hadoop1:9000/input/weather.txt"));

            // 设置输出文件路径
            Path outpath = new Path("hdfs://hadoop1:9000/result_weather");
            FileSystem fs = FileSystem.get(config);

            // 检查输出路径是否存在，如果存在则删除
            if (fs.exists(outpath)) {
                fs.delete(outpath, true);
            }

            // 设置输出路径
            FileOutputFormat.setOutputPath(job, outpath);

            // 提交Job并等待完成
            System.exit(job.waitForCompletion(true) ? 0 : 1);
        } catch (ClassNotFoundException | InterruptedException e) {
            e.printStackTrace(); // 打印异常堆栈信息
        } catch (IOException e) {
            e.printStackTrace(); // 打印异常堆栈信息
        }
    }
}

```





