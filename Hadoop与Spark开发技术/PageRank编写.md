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
D  1.0  B0.5 C0.5
```

#### Reduce
```plaintext
A  0.33  B D
B  0.83  C
C  1.5  A B E
D  0.5  B C
E  0.33
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
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

public class Node implements Writable {
    private double pageRank = 1.0;
    private String[] adjacentNames;

    // 默认构造函数，Hadoop反序列化时需要
    public Node() {}

    public double getPageRank() {
        return pageRank;
    }

    public void setPageRank(double pageRank) {
        this.pageRank = pageRank;
    }

    public String[] getAdjacentNames() {
        return adjacentNames;
    }

    public void setAdjacentNames(String[] adjacentNames) {
        this.adjacentNames = adjacentNames;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(pageRank);

        if (getAdjacentNames() != null) {
            sb.append("\t").append(StringUtils.join(getAdjacentNames(), "\t"));
        }
        return sb.toString();
    }

    public static Node fromMR(String value) {
        // 将MR输出字符串转换为Node对象
        String[] parts = StringUtils.split(value, "\t");
        Node node = new Node();
        node.setPageRank(Double.parseDouble(parts[0]));
        if (parts.length > 1) {
            String[] adj = new String[parts.length - 1];
            System.arraycopy(parts, 1, adj, 0, parts.length - 1);
            node.setAdjacentNames(adj);
        }
        return node;
    }

    @Override
    public void write(DataOutput out) throws IOException {
        out.writeDouble(pageRank);
        if (adjacentNames != null) {
            out.writeInt(adjacentNames.length);
            for (String adj : adjacentNames) {
                Text.writeString(out, adj);
            }
        } else {
            out.writeInt(0);
        }
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        pageRank = in.readDouble();
        int size = in.readInt();
        if (size > 0) {
            adjacentNames = new String[size];
            for (int i = 0; i < size; i++) {
                adjacentNames[i] = Text.readString(in);
            }
        } else {
            adjacentNames = null;
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
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import java.io.IOException;

public class PageRankMapper extends Mapper<Text, Text, Text, Text> {

    @Override
    protected void map(Text key, Text value, Context context) throws IOException, InterruptedException {
        String pageName = key.toString();
        Node node;

        // 第一次运行时设置特殊的PageRank初始化
        int runMapCounter = context.getConfiguration().getInt("runMapCounter", 1);
        if (runMapCounter == 1) {
            // 第一次运行，初始化PageRank为1.0
            node = Node.fromMR("1.0\t" + value.toString());
        } else {
            // 解析输入值生成Node对象
            node = Node.fromMR(value.toString());
        }

        // 输出该页面及其PageRank和链接关系
        context.write(new Text(pageName), new Text(node.toString()));

        // 计算和输出该页面PageRank值的分配
        if (node.getAdjacentNames() != null) {
            double outPageRank = node.getPageRank() / node.getAdjacentNames().length;
            for (String adjPageName : node.getAdjacentNames()) {
                // 为每个链接的页面输出分配的PageRank值
                context.write(new Text(adjPageName), new Text(String.valueOf(outPageRank)));
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
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

public class PageRankReducer extends Reducer<Text, Text, Text, Text> {

    private static final double DAMPING_FACTOR = 0.85;

    @Override
    protected void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
        double sum = 0.0;
        Node sourceNode = new Node();

        for (Text value : values) {
            String content = value.toString();
            if (content.startsWith("1.0") || content.contains("\t")) {
                // 这是该网页的节点数据
                sourceNode = Node.fromMR(content);
            } else {
                // 这是传入的PageRank分值
                sum += Double.parseDouble(content);
            }
        }

        // 计算新的PageRank值
        double newPageRank = (1 - DAMPING_FACTOR) + DAMPING_FACTOR * sum;
        sourceNode.setPageRank(newPageRank);

        // 输出更新后的Node对象，包含新的PageRank值和链接关系
        context.write(key, new Text(sourceNode.toString()));
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
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;

public class PageRankDriver {

    public static void main(String[] args) throws Exception {
        // 检查参数
        if (args.length < 3) {
            System.err.println("Usage: PageRankDriver <input_path> <output_path> <iterations>");
            System.exit(-1);
        }

        String inputPath = args[0];
        String outputPath = args[1];
        int iterations = Integer.parseInt(args[2]);

        // 创建 Hadoop 配置
        Configuration config = new Configuration();
        FileSystem fs = FileSystem.get(config);

        for (int i = 0; i < iterations; i++) {
            Job job = Job.getInstance(config, "PageRank Iteration " + (i + 1));
            job.setJarByClass(PageRankDriver.class);
            job.setMapperClass(PageRankMapper.class);
            job.setReducerClass(PageRankReducer.class);

            // 设置Mapper和Reducer的输出类型
            job.setMapOutputKeyClass(Text.class);
            job.setMapOutputValueClass(Text.class);
            job.setOutputKeyClass(Text.class);
            job.setOutputValueClass(Text.class);

            // 设置输入输出格式
            job.setInputFormatClass(TextInputFormat.class);
            job.setOutputFormatClass(TextOutputFormat.class);

            // 设置输入和输出路径
            Path input = i == 0 ? new Path(inputPath) : new Path(outputPath + "/iter" + i);
            Path output = new Path(outputPath + "/iter" + (i + 1));

            FileInputFormat.addInputPath(job, input);
            FileOutputFormat.setOutputPath(job, output);

            // 删除上次迭代的输出路径
            if (fs.exists(output)) {
                fs.delete(output, true);
            }

            // 提交作业并等待完成
            if (!job.waitForCompletion(true)) {
                System.exit(1);
            }
        }
        System.out.println("PageRank completed successfully.");
    }
}

```


### 打包程序
```bash
mvn clean package
```

### 运行程序
```bash
hadoop jar target/InvertIndex-1.0-SNAPSHOT.jar PageRankDriver
```
