# JUC线程池

### FutureTask

### ThreadPoolExecutor
#### 为什么要有线程池？
线程池能够对线程进行统一的分配，调优和监控
- 降低资源消耗
- 提高相应速度
- 提高线程的可管理性
#### Java是实现和管理线程池有哪些方式?  请简单举例如何使用。 
将工作单元与执行机制分离开，工作单元包括Runnable和Callable，执行机制由Executor框架提供。
#### 为什么很多公司不允许使用Executors去创建线程池? 那么推荐怎么使用呢? 
#### ThreadPoolExecutor有哪些核心的配置参数? 
- 一个集合线程workSet和一个阻塞队列workQueue，当用户向线程池提交一个任务时，会首先放入到阻塞队列中，线程会不断从阻塞队列中获取线程执行。如果阻塞队列中没有线程，线程将会被阻塞，直到队列中有任务了继续执行。
```java
public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue,
                          RejectedExecutionHandler handler)
```

- corePoolSize：核心线程数大小，当提交一个线程，线程池创建一个线程执行任务，知道线程池中的线程数达到corePoolSize，即使有其他空闲的线程能够执行新的线程，也会继续创建线程。
- maximumPoolSize：线程池中最大线程数量：当工作队列已满时，且当前线程数量小于最大线程数量，创建新的线程，继续执行任务。如果当前线程数量等于最大线程数量且工作队列已满，还在提交任务的话，执行相应的策略。
- keepAliveTime：空闲线程的最大存活时间。
- unit：时间单位
- workQueue：线程池中用到的缓冲队列
	- ArrayBlockingQueue：基于数组结构的有界阻塞队列。按FIFO排序任务。
	- LinkedBlockingQueue：基于链表的无界阻塞队列。
	- SynchronizedQueue：一个不存储元素的阻塞队列。每个插入操作必须等到另一个线程调用移除操作，否则插入操作一直处于阻塞状态。
	- PrioriBlockingQueue：具有优先级的无界阻塞队列。
- handler：线程池对拒绝任务的处理策略。
	- AbortPolicy：直接抛出异常，**默认策略**。
	- CallerRunPolicy：用调用者所在的线程来执行任务
	- DiscardOldestPolicy：丢弃阻塞队列中靠最前的任务，并执行当前任务。
	- DiscardPolicy：直接丢弃任务。

#### 请简要说明 ThreadPoolExecutor可以创建哪是哪三种线程池呢? 
- newFixedThreadPool
```java
public static ExecutorService newFixedThreadPool(int nThreads) {
    return new ThreadPoolExecutor(nThreads, nThreads,
                                0L, TimeUnit.MILLISECONDS,
                                new LinkedBlockingQueue<Runnable>());
}
```
即使线程池中没有可执行的线程时，也不会释放线程。
- newSingleThreadExecutor
```java
public static ExecutorService newSingleThreadExecutor() {
    return new FinalizableDelegatedExecutorService
        (new ThreadPoolExecutor(1, 1,
                                0L, TimeUnit.MILLISECONDS,
                                new LinkedBlockingQueue<Runnable>()));
}
```
只有一个线程。如果该线程异常结束，会重新创建一个新的线程来继续执行任务
- newCachedThreadPool
```java
public static ExecutorService newCachedThreadPool() {
    return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                    60L, TimeUnit.SECONDS,
                                    new SynchronousQueue<Runnable>());
}
```
线程池中的线程数可达到最大整数个。使用SynchronizedQueue来作为阻塞队列。
#### 当队列满了并且worker的数量达到maxSize的时候，会怎么样? 
- 会交给RejectedExecutionHandler来处理任务。
#### 说说ThreadPoolExecutor有哪些RejectedExecutionHandler策略? 默认是什么策略? 
- AbortPolicy：直接抛出异常，**默认策略**。
- CallerRunPolicy：用调用者所在的线程来执行任务
- DiscardOldestPolicy：丢弃阻塞队列中靠最前的任务，并执行当前任务。
- DiscardPolicy：直接丢弃任务。
#### 简要说下线程池的任务执行机制? execute –> addWorker –>runworker (getTask) 
- ctl：低位29位表示线程池中的数量，高3位表示线程池的运行状态。
#### 线程池中任务是如何提交的? 
#### 线程池中任务是如何关闭的? 
#### 在配置线程池的时候需要考虑哪些配置因素? 
#### 如何监控线程池的状态?