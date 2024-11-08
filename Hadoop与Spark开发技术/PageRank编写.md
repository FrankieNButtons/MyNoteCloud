# PageRank编写
## Principles of PageRank
### Fomula
$$PR(i) = \frac{1-d}{N} + d \sum_{P_i=1}^{N} \frac{PR(j)}{L(j)}$$


### Calculated By Hand
#### Raw Data
```plaintext
A  B D
B  C
C  A B E
D  B C
E  
```
#### Step 1
#### Initialization
```plaintext
A  1.0  B D
B  1.0  C
C  1.0  A B E
D  1.0  B C
E  1.0
```
#### Map
```plaintext
A  1.0  B0.5 D0.5
B  1.0  C1.0
C  1.0  A0.33 B0.33 E0.33
```
## Codes For PageRank
### Raw Data Format
```plaintext
A  1,0 B D
B  1.0 C
C  1.0 A B E
D  1.0 B C
E  1.0
```
### Step 1:Abstract Nodes
#### Data Structure of Step
#### Code for Step
```java
import org.apache.commons.lang.StringUtils;
import org.apache.hadoop.io.Writable;

public class Node(){
    private double pageRank = 1.0;
    private String[] adjancentNames;

    public void setPageRank(double pageRank) {
        this.pageRank = pageRank;
    }

    public String[] getAdjancentNodeNames() {

    }


    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(pageRank);

        if (get)AdjancentNames() != null){
            sb.append(Stringutils.join(getAdjancentNames(), "\t"));
        }
        return sb.toString();
    }

    public static Node fromMR(String value){
        // value:  形如"1.0 B D"
        // 将value字符串转化为Node对象
        String[] parts = StringUtils.split(value, "\t");
        Node node = new Node();
        node.setPageRank(Double.valueOf(parts[0]));
        if (parts.length > 1){
            node.setAdjancentNames(StringUtils.split(parts[1], "\t"));
        }
    }
}
```


### Step 2:pageRankMapper.java
#### Data Structure of Step
|   Step   | File     | Splitting Data | TextInputFormat                                    | Map                        | TextOutputFormat                    |
|-------------|:--------:|----------------|---------------------------------------------------|----------------------------|------------------------------------|
|Key| Raw Data | ---------------> | key1: 行首字节偏移量Int Long（Java类）<br> | （）<br>---------------> | key2: 词汇—文件名<br>value2: 词频  |
|Value|      | ---------------> | value1: （）

#### Code for Step
```java


public class pageRankMapper extends Mapper<Text, Text, Text, Text> {
    @Override
    protected void map(Text key, Text value, Context context) throws IOException, InterruptedException {
        String pageName = key.toString();
        Node node = new Node();
        // 第一次运行特殊处理
        int runMapCounter = new context.getConfiguration().setInt("runMapCounter", 1);
        if (runMapCounter == 1){
            Node.fromMR("1.0\t" + value.toString());
        }
        else {
            node = Node.fromMR(value.toString());
        }
        context.write(new Text(pageName), new Text(node.toString()));
        //
        //


        if (node.getAdjancentNodeNames()){
            double = outPage = node.getPageRank() / node.getAdjancentNames().length;
            for (String pageName : node.getAdjancentNodeNames){
                context.write(new Text(pageName), new Text(outPage + ""));
            }
        }
        }
    }
}
```

### Step 2:pageRankReducer.java
#### Data Structure of Step
| TextInputFormat | Shuffle ||
|---------------|----------| --------- |
| key2: 词汇—文件名<br> | Partition, Sort, Merge <br>--------------------------> |   |
||||

#### Code for Step
```java
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
import java.io.IOException;

public class pageRankReducer extends Reducer<Text, Text, Text, Text> {
@Override
protected void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
    double sum = 0.0;
    Node sourceNode = new Node();
    for (Text value : values){
        Node node = Node.fromMR(value.toString());
        
    }


}
}
```


### Step 3:DriverJob.java

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
