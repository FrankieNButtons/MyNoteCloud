
# InvertIndex编写
## First MapReduce Job
### Step 1:FirstMapper.java
#### Data Structure of Step
| File     | Splitting Data | TextInputFormat                                    | Map                        | TextOutputFormat                    |
|----------|----------------|---------------------------------------------------|----------------------------|------------------------------------|
| Raw Data | ---------------> | key1: 行首字节偏移量（默认）<br>value1: 该行字符串（默认） | （）<br>---------------> | key2: 词汇—文件名<br>value2: 词频  |

#### Code for Step
```java
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
import java.io.IOException;

public class FirstMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    private Text outputKey = new Text();
    private IntWritable outputValue = new IntWritable(1);
    private String fileName;

    @Override
    protected void setup(Context context) throws IOException, InterruptedException {
        // 获取当前输入文件的文件名
        FileSplit fs = (FileSplit) context.getInputSplit();
        fileName = fs.getPath().getName();
    }

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        // 按空格分割文本行，得到单词
        String[] words = value.toString().split(" ");

        // 遍历每个单词并生成输出键值对
        for (String word : words) {
            // 创建输出键，格式为 "word--filename"
            outputKey.set(word + "--" + fileName);
            // 输出键值对到上下文
            context.write(outputKey, outputValue);
        }
    }
}
```

### Step 2:FirstReducer.java
#### Data Structure of Step
| TextInputFormat | Shuffle |
|---------------|----------|
| key2: 词汇—文件名<br> value2: 词频 | ------->
#### Code for Step
```java
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
import java.io.IOException;

public class FirstReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
        int sum = 0;

        // 累加每个单词在不同文件中的出现次数
        for (IntWritable value : values) {
            sum += value.get();
        }

        // 输出单词及其总出现次数
        context.write(key, new IntWritable(sum));
    }
}

```


### Step 3:FirstJob.java

#### Data Structure of Step

#### Code for Step
```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;

public class FirstJob {
    public static void main(String[] args) throws Exception {
        // 创建 Hadoop 配置
        Configuration config = new Configuration();

        // 创建 Job 实例
        Job job = Job.getInstance(config, "InvertIndex");
        job.setJarByClass(FirstJob.class);
        job.setMapperClass(FirstMapper.class);
        job.setReducerClass(FirstReducer.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(TextOutputFormat.class);

        // 设置输入和输出路径
        FileInputFormat.addInputPath(job, new Path("hdfs://hadoop1:9000/input/docs"));
        Path outPath = new Path("hdfs://hadoop1:9000/output");
        FileOutputFormat.setOutputPath(job, outPath);

        // 检查输出路径是否已存在，如果存在则删除
        FileSystem fs = FileSystem.get(config);
        if (fs.exists(outPath)) {
            fs.delete(outPath, true);
        }
    }
}
```


### 打包程序
```bash
mvn clean package
```

### 运行程序
```bash
hadoop jar target/InvertIndex-1.0-SNAPSHOT.jar FirstJob
```

## Second MapReduce Job
### Step 1:SecondMapper.java
#### Data Structure of Step
| File | Spliting Data | TextInputFormat | Map（LongWritable, Text, Text, Text） | TextOnputFormat | Context | Shuffle
|----------|----------------|----------------|----------------------------|--------------------|---------|------------------
| Raw Data | ---------------> | key: 行首字节偏移量（默认）\n value: 该行字符串（默认） | ---------------> | key2: 词汇\n value2: 文件名->词频 | ---------------> | key3: 文件名\n value3: 词汇——词频

#### Code for Step
```java
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

public class SecondMapper extends Mapper<LongWritable, Text, Text, Text> {
    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        // 分割输入行，格式为 "word--filename\tcount"
        String[] split = value.toString().split("--");
        String word = split[0]; // 获取单词
        String[] fileInfo = split[1].split("\t");

        // 构建输出值，格式为 "filename-->count"
        StringBuilder outputValue = new StringBuilder();
        for (String fileEntry : fileInfo) {
            String[] parts = fileEntry.split("\t");
            String fileName = parts[0]; // 文件名
            String count = parts[1]; // 计数

            // 将文件名和计数添加到输出值
            outputValue.append(fileName).append("-->").append(count).append(" ");
        }

        // 将输出值去掉最后一个空格
        if (outputValue.length() > 0) {
            outputValue.setLength(outputValue.length() - 1);
        }

        // 输出键值对
        context.write(new Text(word), new Text(outputValue.toString()));
    }
}
```

### Step 2:SecondReducer.java
#### Data Structure of Step


#### Code for Step
```java
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

public class SecondReducer extends Reducer<Text, Text, Text, Text> {
    @Override
    public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
        StringBuilder sb = new StringBuilder();

        // 遍历所有值并拼接
        for (Text value : values) {
            sb.append(value.toString()).append(" ");
        }

        // 去掉最后一个空格
        if (sb.length() > 0) {
            sb.setLength(sb.length() - 1);
        }

        // 输出最终的键值对
        context.write(key, new Text(sb.toString()));
    }
}
```

### Step 3:SecondJob.java
#### Data Structure of Step


#### Code for Step
```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;

public class SecondJob {
    public static void main(String[] args) {
        Configuration config = new Configuration();
        try {
            Job job = Job.getInstance(config, "InvertIndex");
            job.setJobName("InvertIndex");

            // 设置输入和输出路径
            // 确保传入的args包含输入和输出路径
            Path inputPath = new Path(args[0]);
            Path outputPath = new Path(args[1]);
            // 清除输出路径（如果存在）
            outputPath.getFileSystem(config).delete(outputPath, true);

            // 设置Mapper和Reducer
            job.setMapperClass(InvertIndexMapper.class);
            job.setReducerClass(InvertIndexReducer.class);

            // 设置输入和输出格式
            job.setInputFormatClass(TextInputFormat.class);
            job.setOutputFormatClass(TextOutputFormat.class);

            // 设置输出键值类型
            job.setOutputKeyClass(Text.class);
            job.setOutputValueClass(Text.class);

            // 设置输入输出路径
            TextInputFormat.addInputPath(job, inputPath);
            TextOutputFormat.setOutputPath(job, outputPath);

            // 提交作业
            System.exit(job.waitForCompletion(true) ? 0 : 1);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```