# 💥 手动编译 fastQTL + Rmath 静态库（无网络/无 sudo 环境）

> 本文记录了在服务器中无法访问 `conda-forge` 且无 `sudo` 权限时，如何手动安装 `libRmath.a` 并成功编译 [fastQTL](http://fastqtl.sourceforge.net/)。

---

## 📌 背景说明

在以下环境中：

- 无法通过 `conda install` 下载 `r-mathlib`（网络超时）；
- 无法使用 `make install` 将 `libRmath.a` 安装到 `/usr/local`（权限不足）；
- 服务器可用 `/usr/bin/gcc` 编译器；
- 具备下载并手动编译源码的能力。

---

## ✅ 步骤 1：下载并编译 Rmath（R 官方源码）

### 1.1 下载 R 源码

在本地联网环境中执行：

~~~bash
wget https://cran.r-project.org/src/base/R-4/R-4.3.1.tar.gz
scp R-4.3.1.tar.gz your_user@login:~/
~~~

### 1.2 编译 Rmath 库

~~~bash
tar -xzf R-4.3.1.tar.gz
cd R-4.3.1/src/nmath/standalone
make
~~~

生成：

- `libRmath.a`：静态数学库
- `../../include/Rmath.h`：头文件

---

## ✅ 步骤 2：将编译产物复制到用户目录

~~~bash
mkdir -p ~/.local/lib64
cp libRmath.a ~/.local/lib64/

mkdir -p ~/rmath/include
cp ../../include/Rmath.h ~/rmath/include/
~~~

---

## ✅ 步骤 3：准备 fastQTL 并修改 Makefile

### 3.1 克隆 fastQTL

~~~bash
git clone https://github.com/francois-a/fastqtl.git
cd fastqtl
~~~

### 3.2 修改 Makefile（关键！）

用文本编辑器打开：

~~~bash
nano Makefile
~~~

将：

~~~makefile
LIB_MATH=../../R-3.2.4/src/nmath/standalone/libRmath.a
~~~

替换为：

~~~makefile
LIB_MATH=/home/your_user/.local/lib64/librmath.a
~~~

将旧的头文件路径：

~~~makefile
-I../../R-3.2.4/src/include
~~~

替换为：

~~~makefile
-I/home/your_user/rmath/include
~~~

并确认最后链接指令用了 `$(LIB_MATH)` 变量。

保存后退出（`Ctrl+O` → `Enter` → `Ctrl+X`）。

---

## ✅ 步骤 4：编译 fastQTL

~~~bash
make clean
make -B
~~~

编译成功时会输出：
~~~bash
g++ … -o bin/fastQTL
~~~

---

## ✅ 步骤 5：运行验证

~~~bash
./bin/fastQTL --help
~~~

输出如下即为成功：

~~~bash
Fast QTL
  * Authors : Olivier DELANEAU, Halit ONGEN, Alfonso BUIL & Manolis DERMITZAKIS
  * Contact : olivier.delaneau@gmail.com
  * Webpage : http://fastqtl.sourceforge.net/
  * Version : v2.184_gtex

Basic options:
  --help                                Produces this help
  --silent                              Silent mode on terminal
  --seed arg (=1753351634)              Random number seed. Useful to replicate
                                        runs.

Input/Output files:
  -L [ --log ] arg (=fastQTL_date_time_UUID.log)
                                        Screen output is copied in this file.
  -V [ --vcf ] arg                      Genotypes in VCF format.
  -B [ --bed ] arg                      Phenotypes in BED format.
  -C [ --cov ] arg                      Covariates in TXT format.
  -G [ --grp ] arg                      Phenotype groups in TXT format.
  -O [ --out ] arg                      Output file.

Exclusion/Inclusion files:
  --exclude-samples arg                 List of samples to exclude.
  --include-samples arg                 List of samples to include.
  --exclude-sites arg                   List of sites to exclude.
  --include-sites arg                   List of sites to include.
  --exclude-phenotypes arg              List of phenotypes to exclude.
  --include-phenotypes arg              List of phenotypes to include.
  --exclude-covariates arg              List of covariates to exclude.
  --include-covariates arg              List of covariates to include.

Parameters:
  --normal                              Normal transform the phenotypes.
  -W [ --window ] arg (=1000000)        Cis-window size.
  -T [ --threshold ] arg (=1)           P-value threshold used in nominal pass 
                                        of association
  --maf-threshold arg (=0)              Minor allele frequency threshold used 
                                        when parsing genotypes
  --ma-sample-threshold arg (=0)        Minimum number of samples carrying the 
                                        minor allele; used when parsing 
                                        genotypes
  --global-af-threshold arg (=0)        AF threshold for all samples in VCF 
                                        (used to filter AF in INFO field)
  --interaction-maf-threshold arg (=0)  MAF threshold for interactions, applied
                                        to lower and upper half of samples

Modes:
  -P [ --permute ] arg                  Permutation pass to calculate corrected
                                        p-values for molecular phenotypes.
  --psequence arg                       Permutation sequence.
  --map arg                             Map best QTL candidates per molecular 
                                        phenotype.
  --map-full                            Scan full cis-window to discover 
                                        independent signals.
  --interaction arg                     Test for interactions with variable 
                                        specified in file.
  --report-best-only                    Report best variant only (nominal mode)

Parallelization:
  -K [ --chunk ] arg                    Specify which chunk needs to be 
                                        processed
  --commands arg                        Generates all commands
  -R [ --region ] arg                   Region of interest.
~~~

---

## ✅ 总结信息

| 项目 | 路径 |
|------|------|
| Rmath 静态库 | `~/.local/lib64/librmath.a` |
| Rmath 头文件 | `~/rmath/include/Rmath.h` |
| fastQTL 可执行文件 | `~/fastqtl/bin/fastQTL` |

---

## 🧠 小提示

- 如果 `make` 时仍引用旧路径，请确认你执行了 `make clean`；
- 若使用多个样本构建 pipeline，可将这些变量写入脚本统一管理；
- 不建议使用 `make install`，避免权限问题。

---

## ✨ 致谢

本手册由 @Frankie 手动测试编写，适用于集群、校内服务器等无法访问外部仓库的编译需求。

