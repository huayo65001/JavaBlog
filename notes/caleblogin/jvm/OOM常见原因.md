# OOM
## 堆溢出
```java
java.lang.OutOfMemoryError: Java heap space
```
#### 原因
1. 代码中可能存在大对象分配。
2. 可能存在内存泄漏，导致在多次GC之后，还是无法找到一块足够大的内存容纳当前对象。
#### 解决办法
1. 检查是否存在大对象的分配，最有可能的是大数组分配。
2. 通过jmap命令，把堆内存dump下来，使用mat工具分析一下，检查是否存在内存泄漏的问题。
3. 如果没有找到明显的内存泄漏，使用-Xmx加大堆内存。
4. 检查是否有大量的自定义的finalizable对象，也有可能是框架内部提供的，考虑其存在的必要性。
## 方法栈溢出
```java
java.lang.OutOfMemoryError : unable to create new native Thread
```
#### 原因
1. 创建了大量的线程导致的。
#### 解决办法
1. 通过-Xss降低每个线程栈大小的容量。
2. 线程总数也受到系统空闲内存和操作系统的限制，检查是否有该系统有一下限制：
- /proc/sys/kernel/pid_max
- /proc/sys/kernel/thread-max
- maxuserprocess（ulimit -u）
- /proc/sys/vm/maxmapcount
## 永久代/元空间溢出
```java
java.lang.OutOfMemoryError: PermGen spacejava.lang.OutOfMemoryError: Metaspace
```
#### 原因
永久代是HotSpot虚拟机对方法区的具体实现，存放了被虚拟机加载的类信息、常量、静态变量、编译后的代码缓存等。
1. 在java7之前，频繁错误的使用String.intern()方法
2. 运行期间生成了大量的代理类，导致方法区被撑爆。
3. 应用长时间运行，没有重启。
#### 解决办法
1. 检查是否永久代空间或者元空间设置过小。
2. 检查代码中是否存在大量反射操作。
3. dump之后通过mat检查是否有大量由于反射生成的代理类。
4. 重启jvm。

## GC overhead limit exceeded
```java
java.lang.OutOfMemoryError：GC overhead limit exceeded
```
#### 原因
1. 一般都是堆太小导致的，超过98%的时间用来做GC并且回收了不到2%的堆内存时会抛出此异常。
#### 解决办法
1. 检查项目中是否有大量的死循环或有使用大内存的代码，优化代码。
2. dump内存，检查是否有内存泄漏，如果没有，加大内存。
## 非常规溢出
### 分配超大数组
```java
java.lang.OutOfMemoryError: Requested array size exceeds VM limit
```
#### 原因
一般是由于不合理的数组分配请求导致的，在为数组分配内存之前，JVM会执行一项检查，要分配的数组在该平台是否可以寻址(addressable)，如果不能寻址就会抛出这个错误。
#### 解决办法
检查代码中是否有创建超大数组的地方。
### swap溢出
```java
java.lang.OutOfMemoryError: Out of swap space
```
#### 原因
1. swap分区大小分配不足。
2. 其他进程消耗了所有的内存。
#### 解决办法
1. 其他服务进程可以选择性的拆分出去。
2. 加大swap分区大小或加大机器内存大小。
### 本地方法栈溢出
```java
java.lang.OutOfMemoryError: stack_trace_with_native_method
```
#### 原因
本地方法在运行时出现了内存分配失败，和之前的方法栈溢出不同，方法栈溢出发生在 JVM 代码层面，而本地方法溢出发生在JNI代码或本地方法处。