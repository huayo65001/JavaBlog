# JUC学习笔记（4）

标签（空格分隔）： JUC

---

- JUC锁：LockSupport详解
    - 为什么LockSupport也是核心基础类?AQS框架借助于两个类：Unsafe(提供CAS操作)和LockSupport(提供park/unpark操作)
    - 写出分别通过wait/notify和LockSupport的park/unpark实现同步?
    - LockSupport.park()会释放锁资源吗? 那么Condition.await()呢?
    - Thread.sleep()、Object.wait()、Condition.await()、LockSupport.park()的区别? 重点 
    - 如果在wait()之前执行了notify()会怎样?
    - 如果在park()之前执行了unpark()会怎样?

---

- JUC锁：锁核心类AQS详解
    - 什么是AQS? 为什么它是核心? 
    - AQS的核心思想是什么? 它是怎么实现的? 底层数据结构等
    - AQS有哪些核心的方法? 
    - AQS定义什么样的资源获取方式?AQS定义了两种资源获取方式：独占(只有一个线程能访问执行，又根据是否按队列的顺序分为公平锁和非公平锁，如ReentrantLock)和共享(多个线程可同时访问执行，如Semaphore、CountDownLatch、 CyclicBarrier)。ReentrantReadWriteLock可以看成是组合式，允许多个线程同时对某一资源进行读。 
    - AQS底层使用了什么样的设计模式? 模板
    - AQS的应用示例? 
    



