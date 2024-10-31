
# WeatherSort作业的编写
## The Only Process
### Step 1:ScoreMapper.java
#### Data Structure of Step

#### Code for step
```java
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import java.io.IOException;

public class ScoreMapper extends Mapper<LongWritable, Text, Text, Text> {

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
        // 将输入行分割为字段
        String[] fields = value.toString().split(",");

        // 处理第一行表头
        if (fields.length != 4) {
            return;
        }

        // 获取学号和成绩
        String studentId = fields[0];
        double chineseScore = Double.parseDouble(fields[1]);
        double mathScore = Double.parseDouble(fields[2]);
        double englishScore = Double.parseDouble(fields[3]);

        // 计算总分
        double totalScore = chineseScore + mathScore + englishScore;

        // 构建输出值
        String outputValue = String.format("语文:%.1f, 数学:%.1f, 英语:%.1f, 总分:%.1f", chineseScore, mathScore, englishScore, totalScore);

        // 将学号和对应的成绩输出到上下文
        context.write(new Text(studentId), new Text(outputValue));
    }
}
```


### Step 2:ScoreReducer.java
#### Data Structure of Step

#### Code for step
```java
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class ScoreReducer extends Reducer<Text, Text, Text, Text> {
    private List<StudentScore> studentScores = new ArrayList<>();

    @Override
    protected void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
        // 遍历相同学号的所有成绩记录
        for (Text value : values) {
            // 将成绩信息存入StudentScore对象
            String[] scoreDetails = value.toString().split(", ");
            double totalScore = Double.parseDouble(scoreDetails[3].split(":")[1].trim());
            double mathScore = Double.parseDouble(scoreDetails[1].split(":")[1].trim());

            studentScores.add(new StudentScore(key.toString(), scoreDetails[0], scoreDetails[1], scoreDetails[2], totalScore, mathScore));
        }
    }

    @Override
    protected void cleanup(Context context) throws IOException, InterruptedException {
        // 按照总分和数学成绩进行排序
        Collections.sort(studentScores, new Comparator<StudentScore>() {
            @Override
            public int compare(StudentScore s1, StudentScore s2) {
                int totalScoreComparison = Double.compare(s2.getTotalScore(), s1.getTotalScore());
                if (totalScoreComparison == 0) {
                    return Double.compare(s2.getMathScore(), s1.getMathScore());
                }
                return totalScoreComparison;
            }
        });

        // 输出前10名
        for (int i = 0; i < Math.min(10, studentScores.size()); i++) {
            StudentScore studentScore = studentScores.get(i);
            context.write(new Text(studentScore.getStudentId()), new Text(studentScore.toString()));
        }
    }

    // 内部类，用于存储学生成绩信息
    private static class StudentScore {
        private String studentId;
        private String chineseScore;
        private String mathScore;
        private String englishScore;
        private double totalScore;
        private double mathScore;

        public StudentScore(String studentId, String chineseScore, String mathScore, String englishScore, double totalScore, double mathScore) {
            this.studentId = studentId;
            this.chineseScore = chineseScore;
            this.mathScore = mathScore;
            this.englishScore = englishScore;
            this.totalScore = totalScore;
            this.mathScore = mathScore;
        }

        public String getStudentId() {
            return studentId;
        }

        public double getTotalScore() {
            return totalScore;
        }

        public double getMathScore() {
            return mathScore;
        }

        @Override
        public String toString() {
            return String.format("语文:%s, 数学:%s, 英语:%s, 总分:%.1f", chineseScore, mathScore, englishScore, totalScore);
        }
    }
}
```

### Step 1:ScoreJob.java
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

public class ScoreJob {
    public static void main(String[] args) {
        Configuration config = new Configuration();
        try {
            Job job = Job.getInstance(config);
            job.setJobName("ScoreJob");
            job.setJarByClass(ScoreJob.class);

            // 设置Mapper和Reducer
            job.setMapperClass(ScoreMapper.class);
            job.setReducerClass(ScoreReducer.class);

            // 设置输入输出格式
            job.setInputFormatClass(TextInputFormat.class);
            job.setOutputFormatClass(TextOutputFormat.class);

            // 设置输出键值类型
            job.setOutputKeyClass(Text.class);
            job.setOutputValueClass(Text.class);

            // 设置输入输出路径
            TextInputFormat.addInputPath(job, new Path(args[0]));
            TextOutputFormat.setOutputPath(job, new Path(args[1]));
        }
    }
}
```





