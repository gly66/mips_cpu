# MIPS_CPU

## 介绍

天津大学2021 fall 计算机组成与体系结构实验

```shell

CPU_core 目录下存放MINIMIPS32的RTL代码

Doc      目录下存放实验报告及设计文档

Soc_test 目录下存放测试所需coe文件及汇编,C程序

TEMU     目录下存放TEMU仿真器

环境配置 目录存放环境配置文档

```

## 环境配置

进入'环境配置'目录下，根据附件2配置基本环境与交叉编译环境

## 实验任务分析与划分
### Lab1 TEMU仿真器的设计
- [x] TEMU调试器的编写  
- [x] 第一阶段指令:算术逻辑/移位指令    
- [x] 第一阶段指令:数据移动/分支跳转指令  
- [x] 5种异常处理
- [x] 第二阶段指令：访存指令  
- [x] 第二阶段指令：自陷指令  
- [x] 第二阶段指令：特权指令
- [x] GUI 
- [x] 实验报告 
- [x] 测试用例 

**如何运行GUI？**

```shell
1. 进入MIPS_CPU/TEMU目录下
2. 使用python3 temp.py运行GUI
```


### Lab2 MIPS32流水线处理器的设计与实现

**负责人：周磊 江明航**

- [x] 已完成

### Lab3 流水线处理器的冒险消除与异常处理

**负责人：高乐瑜 李丰杰**

- [x] 已完成

### 免试任务：AXI环境适配

**负责人：祝佳宁    黄家龙    李丰杰**

- [x] 已完成

## 如何开始本地开发？

```shell
git clone https://gitee.com/FengJay/mips_cpu.git
```
下载到本地后执行下列操作
```shell
git checkout -b 你的分支名
//期间可能要求输入username之类的本地认证信息
```
然后开始本地开发

提交
```shell
git add .
git commit -m ""
git push origin Your branch name
```

## 协作时间节点及注意点

* 每人开设一个自己的分支，在自己分支进行存档，提交
* 每周日我会将各个分支的代码与主分支合并

