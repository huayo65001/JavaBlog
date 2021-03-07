# JUC学习笔记（3）

- JUC类汇总
    - JUC框架包含几个部分?
    - 每个部分有哪些核心的类?
    - 最最核心的类有哪些?

---

- JUC原子类：CAS, Unsafe和原子类详解
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

---
        



