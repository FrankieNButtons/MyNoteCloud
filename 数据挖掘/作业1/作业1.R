setwd("E:/OneDrive/R Projects/Data Mining")


# 1. 测试教材代码
##########KNN分类
set.seed(12345)
x1<-runif(60,-1,1)  
x2<-runif(60,-1,1)  
y<-sample(c(0,1),size=60,replace=TRUE,prob=c(0.3,0.7))   
Data<-data.frame(Fx1=x1,Fx2=x2,Fy=y)  
SampleId<-sample(x=1:60,size=18)  
DataTest<-Data[SampleId,]   
DataTrain<-Data[-SampleId,]  

par(mfrow=c(2,2),mar=c(4,6,4,4))
plot(Data[,1:2],pch=Data[,3]+1,cex=0.8,xlab="x1",ylab="x2",main="全部样本")
plot(DataTrain[,1:2],pch=DataTrain[,3]+1,cex=0.8,xlab="x1",ylab="x2",main="训练样本和测试样本")
points(DataTest[,1:2],pch=DataTest[,3]+16,col=2,cex=0.8)

library("class")
errRatio<-vector()   
for(i in 1:30){    
  KnnFit<-knn(train=Data[,1:2],test=Data[,1:2],cl=Data[,3],k=i)
  CT<-table(Data[,3],KnnFit)  
  errRatio<-c(errRatio,(1-sum(diag(CT))/sum(CT))*100)     
}
plot(errRatio,type="l",xlab="近邻个数K",ylab="错判率(%)",main="近邻数K与错判率",ylim=c(0,80))

errRatio1<-vector()   
for(i in 1:30){
  KnnFit<-knn(train=DataTrain[,1:2],test=DataTest[,1:2],cl=DataTrain[,3],k=i) 
  CT<-table(DataTest[,3],KnnFit) 
  errRatio1<-c(errRatio1,(1-sum(diag(CT))/sum(CT))*100)    
}
lines(1:30,errRatio1,lty=2,col=2)

set.seed(12345)
errRatio2<-vector()   
for(i in 1:30){   
  KnnFit<-knn.cv(train=Data[,1:2],cl=Data[,3],k=i) 
  CT<-table(Data[,3],KnnFit)  
  errRatio2<-c(errRatio2,(1-sum(diag(CT))/sum(CT))*100)     
}
lines(1:30,errRatio2,col=2)

##############KNN回归
set.seed(12345)
x1<-runif(60,-1,1)  
x2<-runif(60,-1,1)  
y<-runif(60,10,20)   
Data<-data.frame(Fx1=x1,Fx2=x2,Fy=y)
SampleId<-sample(x=1:60,size=18)  
DataTest<-Data[SampleId,]  
DataTrain<-Data[-SampleId,]  
mseVector<-vector()    
for(i in 1:30){
  KnnFit<-knn(train=DataTrain[,1:2],test=DataTest[,1:2],cl=DataTrain[,3],k=i,prob=FALSE) 
  KnnFit<-as.double(as.vector(KnnFit))   
  mse<-sum((DataTest[,3]-KnnFit)^2)/length(DataTest[,3])   
  mseVector<-c(mseVector,mse)
}
plot(mseVector,type="l",xlab="近邻个数K",ylab="均方误差",main="近邻数K与均方误差",ylim=c(0,80))

##############天猫成交顾客的分类预测
library("class") 
Tmall_train<-read.table(file="天猫_Train_1.txt",header=TRUE,sep=",")
head(Tmall_train)
Tmall_train$BuyOrNot<-as.factor(Tmall_train$BuyOrNot)
Tmall_test<-read.table(file="天猫_Test_1.txt",header=TRUE,sep=",")
Tmall_test$BuyOrNot<-as.factor(Tmall_test$BuyOrNot)
set.seed(123456)
errRatio<-vector()   
for(i in 1:30){
  KnnFit<-knn(train=Tmall_train[,-1],test=Tmall_test[,-1],cl=Tmall_train[,1],k=i,prob=FALSE) 
  CT<-table(Tmall_test[,1],KnnFit) 
  errRatio<-c(errRatio,(1-sum(diag(CT))/sum(CT))*100)    
}
plot(errRatio,type="b",xlab="近邻个数K",ylab="错判率(%)",main="天猫成交顾客分类预测中的近邻数K与错判率")

####天猫数据KNN分类讨论变量重要性
library("class")  
par(mfrow=c(2,2))
set.seed(123456)
errRatio<-vector()   
for(i in 1:30){
  KnnFit<-knn(train=Tmall_train[,-1],test=Tmall_test[,-1],cl=Tmall_train[,1],k=i,prob=FALSE) 
  CT<-table(Tmall_test[,1],KnnFit) 
  errRatio<-c(errRatio,(1-sum(diag(CT))/sum(CT))*100)    
}
plot(errRatio,type="l",xlab="近邻个数K",ylab="错判率(%)",main="近邻数K与错判率")
errDelteX<-errRatio[7]
for(i in -2:-5){
  fit<-knn(train=Tmall_train[,c(-1,i)],test=Tmall_test[,c(-1,i)],cl=Tmall_train[,1],k=7)
  CT<-table(Tmall_test[,1],fit)
  errDelteX<-c(errDelteX,(1-sum(diag(CT))/sum(CT))*100)
}
plot(errDelteX,type="l",xlab="剔除变量",ylab="剔除错判率(%)",main="剔除变量与错判率(K=7)",cex.main=0.8)
xTitle=c("1:全体变量","2:消费活跃度","3:活跃度","4:成交有效度","5:活动有效度")
legend("topright",legend=xTitle,title="变量说明",lty=1,cex=0.6)   
FI<-errDelteX[-1]+1/4   
wi<-FI/sum(FI)       
GLabs<-paste(c("消费活跃度","活跃度","成交有效度","活动有效度"),round(wi,2),sep=":")
pie(wi,labels=GLabs,clockwise=TRUE,main="输入变量权重",cex.main=0.8)
ColPch=as.integer(as.vector(Tmall_test[,1]))+1
plot(Tmall_test[,c(2,4)],pch=ColPch,cex=0.7,xlim=c(0,50),ylim=c(0,50),col=ColPch,
     xlab="消费活跃度",ylab="成交有效度",main="二维特征空间中的观测",cex.main=0.8)


# 2. 复现教材P127页模拟分析

set.seed(12345)
x1 <- runif(60, -1, 1)  # 生成x1为均匀分布
x2 <- runif(60, -1, 1)  # 生成x2为均匀分布
y <- sample(c(0, 1), size = 60, replace = TRUE, prob = c(0.3, 0.7))  # 随机指派类别标签1和0，概率分别为0.3和0.7

Data <- data.frame(Fx1 = x1, Fx2 = x2, Fy = y)  # 创建数据框

SampleId <- sample(x = 1:60, size = 18)  # 随机选择测试样本
DataTest <- Data[SampleId, ]  # 测试样本集
DataTrain <- Data[-SampleId, ]  # 训练样本集

# 绘图设置
par(mfrow = c(2, 2), mar = c(4, 6, 4, 4))

# 绘制全部样本
plot(Data[, 1:2], pch = Data[, 3] + 1, cex = 0.8, xlab = "x1", ylab = "x2", main = "全部样本")
plot(DataTrain[, 1:2], pch = DataTrain[, 3] + 1, cex = 0.8, xlab = "x1", ylab = "x2", main = "训练样本")
points(DataTest[, 1:2], pch = DataTest[, 3] + 16, col = 2, cex = 0.8)  # 测试样本

library(class)
errRatio <- vector()  # 全部观测的错判率向量

# 计算训练集和测试集的错判率
for (i in 1:30) {
  KnnFit <- knn(train = Data[, 1:2], test = Data[, 1:2], cl = as.factor(Data[, 3]), k = i)
  CT <- table(Data[, 3], KnnFit)  # 计算混淆矩阵
  errRatio <- c(errRatio, (1 - sum(diag(CT)) / sum(CT)) * 100)  # 计算错判率（百分比）
}

plot(errRatio, type = "l", xlab = "近邻个数 K", ylab = "错判率 (%)", main = "近邻数 K 与错判率", ylim = c(0, 80))

# 测试样本错判率向量（旁置法）
errRatio1 <- vector()
for (i in 1:30) {
  KnnFit <- knn(train = DataTrain[, 1:2], test = DataTest[, 1:2], cl = as.factor(DataTrain[, 3]), k = i)
  CT <- table(DataTest[, 3], KnnFit)  # 计算混淆矩阵
  errRatio1 <- c(errRatio1, (1 - sum(diag(CT)) / sum(CT)) * 100)  # 计算错判率（百分比）
}

lines(1:30, errRatio1, col = 2)  # 添加测试样本错判率线

# 留一法错判率向量
errRatio2 <- vector()
for (i in 1:30) {
  KnnFit <- knn.cv(train = Data[, 1:2], cl = as.factor(Data[, 3]), k = i)  # 留一法交叉验证
  CT <- table(Data[, 3], KnnFit)  # 计算混淆矩阵
  errRatio2 <- c(errRatio2, (1 - sum(diag(CT)) / sum(CT)) * 100)  # 计算错判率（百分比）
}

lines(1:30, errRatio2, col = 3)  # 添加留一法错判率线

# 再次设置随机种子
set.seed(12345)
x1 <- runif(60, -1, 1)  # 生成x1为均匀分布
x2 <- runif(60, -1, 1)  # 生成x2为均匀分布
y <- runif(60, 10, 20)  # 因变量为均匀分布

Data <- data.frame(Fx1 = x1, Fx2 = x2, Fy = y)  # 创建数据框
SampleId <- sample(x = 1:60, size = 18)  # 随机选择测试样本
DataTest <- Data[SampleId, ]  # 测试样本集
DataTrain <- Data[-SampleId, ]  # 训练样本集

mseVector <- vector()  # 均方误差向量
for (i in 1:30) {
  KnnFit <- knn(train = DataTrain[, 1:2], test = DataTest[, 1:2], cl = DataTrain[, 3], k = i, prob = FALSE)
  KnnFit <- as.numeric(as.vector(KnnFit))  # 将结果转换为数值型向量
  mse <- sum((DataTest[, 3] - KnnFit)^2) / length(DataTest[, 3])  # 计算均方误差
  mseVector <- c(mseVector, mse)  # 添加均方误差
}

# 绘制均方误差图
plot(mseVector, type = "l", xlab = "近邻个数 K", ylab = "均方误差", main = "近邻数 K 与均方误差", ylim = c(0, 80))









# 3.对鸢尾花数据集进行K-Means聚类并进行可视化
## 基础KNN方法
# 加载必要的包
library(class)
library(ggplot2)
library(caret)

# 使用iris数据集
data(iris)
set.seed(123)

### 打乱数据集并分割为训练集和测试集
iris_shuffled <- iris[sample(nrow(iris)), ]
train_index <- 1:100
train_set <- iris_shuffled[train_index, ]
test_set <- iris_shuffled[-train_index, ]

### 提取特征和标签
train_x <- train_set[, -5]  # 特征
train_y <- train_set[, 5]    # 标签
test_x <- test_set[, -5]      # 特征
test_y <- test_set[, 5]       # 标签

### KNN分类
k <- 3  # 选择K值
predictions <- knn(train = train_x, test = test_x, cl = train_y, k = k)

###创建混淆矩阵
confusion_matrix <- confusionMatrix(predictions, test_y)
print(confusion_matrix)

### 可视化分类结果
iris_plot <- ggplot(test_set, aes(x = Sepal.Length, y = Sepal.Width, color = predictions)) +
  geom_point(size = 3) +
  labs(title = "KNN Classification of Iris Dataset",
       x = "Sepal Length",
       y = "Sepal Width") +
  theme_minimal() +
  scale_color_manual(values = c("setosa" = "red", "versicolor" = "green", "virginica" = "blue"))

### 显示可视化结果
print(iris_plot)










## 基础K-Means方法
library(ggplot2)
library(caret)

### 选择要进行聚类的特征
iris_data <- iris[, -5]

### 设置K值
set.seed(42)
k <- 3

### 执行K-Means聚类
kmeans_result <- kmeans(iris_data, centers = k)

### 将聚类结果添加到数据框中
iris$Cluster <- as.factor(kmeans_result$cluster)

### 可视化聚类结果
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Cluster)) +
  geom_point(size = 3) +
  labs(title = "K-Means Clustering on Iris Dataset",
       x = "Sepal Length",
       y = "Sepal Width") +
  theme_minimal()

### 创建混淆矩阵
confusion_matrix <- table(iris$Species, iris$Cluster)
print(confusion_matrix)





## 使用决策树模型
library(rpart)
library(rpart.plot)
library(caret)

set.seed(123)

### 打乱数据集并分割为训练集和测试集
iris_shuffled <- iris[sample(nrow(iris)), ]
train_index <- 1:100
train_set <- iris_shuffled[train_index, ]
test_set <- iris_shuffled[-train_index, ]

### 决策树模型训练
tree_model <- rpart(Species ~ ., data = train_set, method = "class")

### 预测
predictions <- predict(tree_model, test_set, type = "class")

### 创建混淆矩阵
confusion_matrix <- confusionMatrix(predictions, test_set$Species)
print(confusion_matrix)

### 可视化决策树
rpart.plot(tree_model, main = "Decision Tree for Iris Dataset", 
           extra = 104, varlen = 0, faclen = 0)

### 可视化分类结果
iris_plot <- ggplot(test_set, aes(x = Sepal.Length, y = Sepal.Width, color = predictions)) +
  geom_point(size = 3) +
  labs(title = "Decision Tree Classification of Iris Dataset",
       x = "Sepal Length",
       y = "Sepal Width") +
  theme_minimal() +
  scale_color_manual(values = c("setosa" = "red", "versicolor" = "green", "virginica" = "blue"))

### 显示可视化结果
print(iris_plot)

