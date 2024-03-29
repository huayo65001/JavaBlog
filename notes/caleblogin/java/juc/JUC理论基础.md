﻿# JUC理论基础

## Java并发-理论基础
- 线程安全指的是：在堆内存中的数据由于可以被任何线程访问到，在没有限制的情况下存在被意外修改的风险
- 多线程的出现是要解决什么问题的? 
- 线程不安全是指什么? 举例说明 
- 并发出现线程不安全的本质什么? 可见性，原子性和有序性。
- Java是怎么解决并发问题的? 3个关键字，JMM和8个Happens-Before
- 线程安全是不是非真即假? 不是 
- 线程安全有哪些实现思路? 
- 如何理解并发和并行的区别?


## Java并发-线程基础
- 线程有哪几种状态?
- 分别说明从一种状态到另一种状态转变有哪些方式?
- 通常线程有哪几种使用方式? 
- 基础线程机制有哪些? 
- 线程的中断方式有哪些? 
- 线程的互斥同步方式有哪些? 如何比较和选择?
- 线程之间有哪些协作方式?

## JAVA并发-理论基础

### 多线程的出现是要解决什么问题的? 

为了平衡CPU、内存、I/O设备之间速度差异，计算机体系结构、操作系统、编译程序都做出了贡献。
- CPU增加了缓存，以均衡与内存的速度差异。//导致`可见性`问题；
- 操作系统增加了进程、线程，以分时复用CPU，进而均衡CPU与I/O设备的速度差异。//导致`原子性`问题
- 编译程序优化指令执行次序，使得缓存能够得到更加合理地利用。//导致`有序性`问题

### 线程不安全是指什么? 举例说明 
如果多个线程对同一个共享数据进行访问而不采取同步操作的话，那么操作的结果是不一致的。
通过创建1000个线程对某一个变量进行自增操作，得出的结果可能小于1000
### 并发出现线程不安全的本质什么? 
可见性，原子性和有序性。
- 可见性：一个线程对共享变量的修改，另一个线程能够立刻看到。
```java
// 线程1执行的代码
int i = 0;
i = 10;
// 线程2执行的代码
j = i;
```
假如执行线程1的是CPU1，执行线程2的是CPU2，线程1对i进行修改，当执行i=10时，将i的初始值加载到CPU1的高速缓存中，i被赋值为10，CPU1中的i值变为10，此时并未立刻写入到主存中。
此时线程2执行j=i，它会先去主存读取i的值并加载到CPU2的缓存当中，注意此时内存当中i的值还是0，那么就会使得j的值为0，而不是10。 这就是可见性问题，线程1对变量i修改了之后，线程2没有立即看到线程1修改的值。
    
- 原子性：分时复用引起
原子性即一个操作或多个操作在执行过程中要么全部执行不会被任何因素打断，要不都不执行。
- 有序性：重排序引起
        
### Java是怎么解决并发问题的? 3个关键字，JMM和8个Happens-Before
- 三个关键字：synchronized、volatile、final
- JMM
- Happens-before

### 线程安全是不是非真即假? 不是 
### 线程安全有哪些实现思路? 
- 互斥同步
- 非阻塞同步
- 无同步方案

### 如何理解并发和并行的区别?
并发：同一个时间段内，多个任务都在执行
并行：同一时间点，多个任务都在执行