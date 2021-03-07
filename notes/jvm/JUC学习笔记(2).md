# JUC学习笔记（2）

标签（空格分隔）： JUC

---

- 关键字：synchronized详解
    - Synchronized可以作用在哪里? 分别通过对象锁和类锁进行举例。
    - Synchronized本质上是通过什么保证线程安全的? 分三个方面回答：加锁和释放锁的原理，可重入原理，保证可见性原理。
    - Synchronized有什么样的缺陷?  Java Lock是怎么弥补这些缺陷的。
    - Synchronized和Lock的对比，和选择?
    - Synchronized在使用时有何注意事项?
    - Synchronized修饰的方法在抛出异常时,会释放锁吗?
    - 多个线程等待同一个synchronized锁的时候，JVM如何选择下一个获取锁的线程? 
    - Synchronized使得同时只有一个线程可以执行，性能比较差，有什么提升的方法? 
    - 我想更加灵活地控制锁的释放和获取(现在释放锁和获取锁的时机都被规定死了)，怎么办? 
    - 什么是锁的升级和降级? 什么是JVM里的偏向锁、轻量级锁、重量级锁?
    - 不同的JDK中对Synchronized有何优化?

---
- 关键字：volatile详解
    - volatile关键字的作用是什么? 
    - volatile能保证原子性吗?
    - 之前32位机器上共享的long和double变量的为什么要用volatile?现在64位机器上是否也要设置呢? 
    - i++为什么不能保证原子性? 
    - volatile是如何实现可见性的?  内存屏障。 
    - volatile是如何实现有序性的?  happens-before等
    - 说下volatile的应用场景?
    
---

- 关键字：final详解
    - 所有的final修饰的字段都是编译期常量吗?
    - 如何理解private所修饰的方法是隐式的final?
    - 说说final类型的类如何拓展?比如String是final类型，我们想写个MyString复用所有String中方法，同时增加一个新的toMyString()的方法，应该如何做? 
    - final方法可以被重载吗? 可以
    - 父类的final方法能不能够被子类重写? 不可以
    - 说说final域重排序规则? 说说final的原理? 
    - 使用 final 的限制条件和局限性?

---

### Synchronized可以作用在哪里? 分别通过对象锁和类锁进行举例。
#### 对象锁
对象锁包括方法锁和同步代码块锁
#### 类锁
包括synchronized修饰的静态方法和指定对象为class对象
### Synchronized本质上是通过什么保证线程安全的? 分三个方面回答：加锁和释放锁的原理，可重入原理，保证可见性原理。
### Synchronized有什么样的缺陷?  Java Lock是怎么弥补这些缺陷的。
### Synchronized和Lock的对比，和选择?
### Synchronized在使用时有何注意事项?
### Synchronized修饰的方法在抛出异常时,会释放锁吗?
Synchronized修饰的方法无论方法执行完毕还是抛出异常，都会释放锁。
### 多个线程等待同一个synchronized锁的时候，JVM如何选择下一个获取锁的线程? 
### Synchronized使得同时只有一个线程可以执行，性能比较差，有什么提升的方法? 
### 我想更加灵活地控制锁的释放和获取(现在释放锁和获取锁的时机都被规定死了)，怎么办? 
### 什么是锁的升级和降级? 什么是JVM里的偏向锁、轻量级锁、重量级锁?
### 不同的JDK中对Synchronized有何优化?

    



