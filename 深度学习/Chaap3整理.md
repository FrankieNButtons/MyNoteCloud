# 逻辑回归与多层感知机

## 逻辑回归

逻辑回归是一种用于二分类问题的线性模型，通过 Sigmoid 函数将线性输出映射为概率。

### 模型公式

假设输入特征向量为 $\mathbf{x} = [x_1, x_2, \dots, x_n]$，权重向量为 $\omega = [\omega_1, \omega_2, \dots, \omega_n]$，偏置为 $b$，则线性组合为：
$$
z = \mathbf{x} \cdot \omega^\top + b
$$
预测概率：
$$
\hat{y} = \sigma(z) = \frac{1}{1 + e^{-z}}
$$

### 交叉熵损失

对于 $m$ 个样本的二分类任务，交叉熵损失：
$$
\mathcal{L} = -\frac{1}{m}\sum_{i=1}^m\Bigl[y^{(i)}\ln\hat{y}^{(i)} + (1-y^{(i)})\ln(1-\hat{y}^{(i)})\Bigr]
$$

### 推导过程

1. **前向传播**  
   - 计算线性组合：  
     $$
     z^{(i)} = \mathbf{x}^{(i)} \cdot \omega^\top + b
     $$
   - 计算预测值：  
     $$
     \hat{y}^{(i)} = \sigma(z^{(i)}) = \frac{1}{1 + e^{-z^{(i)}}}
     $$

2. **损失计算**  
   - 使用交叉熵损失函数，见上节。

3. **反向传播（梯度推导）**  
   - 对 $\hat{y}^{(i)}$ 求导：  
     $$
     \frac{\partial \mathcal{L}}{\partial \hat{y}^{(i)}} = -\frac{1}{m}\Bigl(\frac{y^{(i)}}{\hat{y}^{(i)}} - \frac{1 - y^{(i)}}{1 - \hat{y}^{(i)}}\Bigr)
     $$
   - 对 $z^{(i)}$ 求导：  
     $$
     \frac{\partial \hat{y}^{(i)}}{\partial z^{(i)}} = \hat{y}^{(i)}(1 - \hat{y}^{(i)})
     $$
   - 链式法则合并：  
     $$
     \frac{\partial \mathcal{L}}{\partial z^{(i)}} 
     = \frac{\partial \mathcal{L}}{\partial \hat{y}^{(i)}} \cdot \frac{\partial \hat{y}^{(i)}}{\partial z^{(i)}} 
     = -\frac{1}{m}\Bigl(\frac{y^{(i)}}{\hat{y}^{(i)}} - \frac{1 - y^{(i)}}{1 - \hat{y}^{(i)}}\Bigr)\hat{y}^{(i)}(1 - \hat{y}^{(i)})
     = \frac{1}{m}(\hat{y}^{(i)} - y^{(i)})
     $$

4. **参数更新**  
   $$
   \omega := \omega - \eta\frac{\partial \mathcal{L}}{\partial \omega},\quad
   b := b - \eta\frac{\partial \mathcal{L}}{\partial b}
   $$
   其中
   $$
   \frac{\partial \mathcal{L}}{\partial \omega}
   = \frac{1}{m}\sum_{i=1}^m(\hat{y}^{(i)} - y^{(i)})\mathbf{x}^{(i)},\quad
   \frac{\partial \mathcal{L}}{\partial b}
   = \frac{1}{m}\sum_{i=1}^m(\hat{y}^{(i)} - y^{(i)})
   $$

```python
# 逻辑回归示例
import numpy as np

def sigmoid(z):
    return 1 / (1 + np.exp(-z))

# 训练数据：简单的二分类示例
X = np.array([[0.5], [1.5], [3.0], [4.5]])
y = np.array([0, 0, 1, 1])

# 初始化参数
omega = np.zeros(X.shape[1])
b = 0.0
eta = 0.1
m = len(y)

# 训练1000轮
for epoch in range(1000):
    z = X.dot(omega) + b
    y_hat = sigmoid(z)
    grad_w = (1/m) * X.T.dot(y_hat - y)
    grad_b = (1/m) * np.sum(y_hat - y)
    omega -= eta * grad_w
    b -= eta * grad_b

print(f"训练后参数：omega={omega}, b={b}")
```

## 多层感知机

多层感知机是一种前馈神经网络，由多层全连接层和非线性激活函数组成。

### 网络结构与公式

- 隐藏层输出：  
  $$
  \mathbf{h} = \phi(\mathbf{x}\cdot W_h^\top + \mathbf{b}_h)
  $$
- 输出层（线性部分）：  
  $$
  \mathbf{z} = \mathbf{h}\cdot W_o^\top + \mathbf{b}_o
  $$
- SoftMax 层：  
  $$
  \hat{y}_j = \frac{e^{z_j}}{\sum_{k=1}^C e^{z_k}}
  $$

### SoftMax 与交叉熵推导

1. **交叉熵损失（多分类）**  
   $$
   \mathcal{L} = -\sum_{j=1}^C y_j\ln\hat{y}_j
   $$

2. **梯度推导**  
   - 对 SoftMax 输入 $z_j$ 求导：  
     $$
     \frac{\partial \mathcal{L}}{\partial z_j}
     = \sum_{k=1}^C \frac{\partial \mathcal{L}}{\partial \hat{y}_k}\frac{\partial \hat{y}_k}{\partial z_j}
     = \sum_{k=1}^C\bigl(-\frac{y_k}{\hat{y}_k}\bigr)\bigl(\hat{y}_k(\delta_{kj} - \hat{y}_j)\bigr)
     = \hat{y}_j - y_j
     $$

   - 对参数 $W_o$ 和偏置 $\mathbf{b}_o$：  
     $$
     \frac{\partial \mathcal{L}}{\partial W_o}
     = (\hat{\mathbf{y}} - \mathbf{y})\,\mathbf{h}^\top,\quad
     \frac{\partial \mathcal{L}}{\partial \mathbf{b}_o}
     = \hat{\mathbf{y}} - \mathbf{y}
     $$

```python
# 多层感知机示例
import numpy as np

def relu(x):
    return np.maximum(0, x)

def softmax(z):
    exp_z = np.exp(z - np.max(z, axis=1, keepdims=True))
    return exp_z / exp_z.sum(axis=1, keepdims=True)

# 示例数据
X = np.array([[0.1, 0.2], [0.2, 0.1], [0.9, 0.8], [0.8, 0.9]])
y = np.array([[1, 0], [1, 0], [0, 1], [0, 1]])

# 网络结构
input_dim, hidden_dim, output_dim = 2, 3, 2
Wh = np.random.randn(hidden_dim, input_dim)
bh = np.zeros((1, hidden_dim))
Wo = np.random.randn(output_dim, hidden_dim)
bo = np.zeros((1, output_dim))
eta = 0.01

# 一次前向传播示例
h = relu(X.dot(Wh.T) + bh)
z = h.dot(Wo.T) + bo
y_hat = softmax(z)
print("预测概率：", y_hat)
```

## 数值差分简介

数值差分是一种通过有限差分近似计算导数的方法，常用形式包括：

- 前向差分：  
  $$
  f'(x)\approx \frac{f(x+h)-f(x)}{h}
  $$

- 后向差分：  
  $$
  f'(x)\approx \frac{f(x)-f(x-h)}{h}
  $$

- 中心差分：  
  $$
  f'(x)\approx \frac{f(x+h)-f(x-h)}{2h}
  $$

中心差分在同样的步长 $h$ 下通常具有更高的精度，但需要更多的函数评估。

```python
# 数值差分示例
def numerical_diff(f, x, h=1e-5):
    return (f(x + h) - f(x - h)) / (2 * h)

# 示例函数：f(x) = x^2
def f(x):
    return x**2

x0 = 2.0
print(f"f'({x0}) 近似值：", numerical_diff(f, x0))
```