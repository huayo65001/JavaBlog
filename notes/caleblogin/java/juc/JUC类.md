# JUC原子类

### JUC类汇总
#### JUC框架包含几个部分?
#### 每个部分有哪些核心的类?
#### 最最核心的类有哪些?
  

### JUC原子类：CAS, Unsafe和原子类详解
- 线程安全的实现方法有哪些? 
- 什么是CAS? 
- CAS使用示例，结合AtomicInteger给出示例? 
- CAS会有哪些问题? 
- 针对这这些问题，Java提供了哪几个解决的?
- AtomicInteger底层实现? CAS+volatile
- 请阐述你对Unsafe类的理解? 
- 说说你对Java原子类的理解? 包含13个，4组分类，说说作用和使用场景。
- AtomicStampedReference是什么?
- AtomicStampedReference是怎么解决ABA的? 内部使用Pair来存储元素值及其版本号
- java中还有哪些类可以解决ABA的问题? AtomicMarkableReference 

### LockSupport详解
- 为什么LockSupport也是核心基础类?AQS框架借助于两个类：Unsafe(提供CAS操作)和LockSupport(提供park/unpark操作)
- 写出分别通过wait/notify和LockSupport的park/unpark实现同步?
- LockSupport.park()会释放锁资源吗? 那么Condition.await()呢?
- Thread.sleep()、Object.wait()、Condition.await()、LockSupport.park()的区别? 重点 
- 如果在wait()之前执行了notify()会怎样?
- 如果在park()之前执行了unpark()会怎样?

        



