# JUC锁

### ReetrantLock详解
- 什么是可重入，什么是可重入锁？它用来解决什么问题
- ReetrantLock的核心是AQS，那么它怎么来实现的，继承吗，说说类内部结构关系。
- ReentrantLock是如何实现公平锁的
- ReentrantLock是如何实现非公平锁的
- ReentrantLock默认实现的是公平锁还是非公平锁？
- 使用ReentrantLock实现公共锁和非公平锁的实例？
- ReentrantLock和Synchronized的比较？


#### ReetrantLock继承关系

#### ReentrantLock内部类

#### ReentrantLock是如何实现加锁的，把AQS里的方法也说一遍

#### ReentrantLock默认实现的是公平锁还是非公平锁




### ReetrantReadWriteLock详解
- 为什么有了ReentrantLock还需要ReentrantReadWriteLock？
- ReentrantReadWriteLock底层实现原理？
- ReentrantReadWriteLock底层读写状态如何设计的？高16位读锁，低16位写锁
- 读锁和写锁的最大数量是多少？
- 本地线程计数器ThreadLocalHoldCounter是用来做什么的？
- 缓存计数器HoldCounter是用来做什么的？
- 写锁的获取与释放是怎么实现的？
- 读锁的获取与释放是怎么实现的？
- ReentrantReadWriteLock为什么不支持锁升级？
- 什么是锁的升降级

#### 