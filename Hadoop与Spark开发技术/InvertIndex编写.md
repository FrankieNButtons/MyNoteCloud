
# 
## First MapReduce Job
### Step 1:FirstMapper.java
#### Data Structure of Step
| File | Spliting Data | TextInputFormat | Map | TextOnputFormat | Context | Shuffle
| Raw Data | ----------> | key: 行首字节偏移量\n value: 该行字符串 | ----------> | key2: 词汇——文件名\n value2: 词频 | 

#### Code for Step
```java
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
import java.io.IOException;


public class FirstMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
    @Override
    protected void setup(Context context) throws IOException, InterruptedException {
        FileSplit fs = (FileSplit) context.getInputSplit();
        fileName = fs.getPath().getName();
        
    }


    
    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        String[] words
    })
}
```

### Step 2:FirstReducer.java
#### Data Structure of Step
||
#### Code for Step
```java
import org.apache.hadoop.io.IntWritable;

public class FirstReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
        int sum = 0;
        for (IntWritable value : values) {
            sum += value.get();
            context.write(key, new IntWritable(sum));
        }
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
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;



public static void main(String[] args) {
    Configuration config = new Configuration(); 




    Job job = Job.getInstance(config, "InvertIndex");
    job.setJobName("InvertIndex");
    job.setJarByClass(FirstRun.class);
    job.setMapperClass(FirstMapper.class);
    job.setReducerClass(FirstReducer.class);
    job.setMapOutputKeyClass(Text.class);
    job.setMapOutputValueClass(IntWritable.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    job.setInputFormatClass(TextInputFormat.class);
    job.setOutputFormatClass(TextOutputFormat.class);
    
    

    FileInputFormat.addInputPath(job, new Path("hdfs://hadoop1:9000/input/docs"));
    Path outPath = new Path("hdfs://hadoop1:9000/output");
    FileOutputFormat.setOutputPath(job, new Path(outPath));
    if (FileSystem.get(config).exists(outPath)){
        
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
| File | Spliting Data | TextInputFormat | Map | TextOnputFormat | Context | Shuffle
| Raw Data | ----------> | key: 行首字节偏移量\n value: 该行字符串 | ----------> | key2: 词汇——文件名\n value2: 词频 |

