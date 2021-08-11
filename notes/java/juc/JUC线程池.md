# JUC线程池

### FutureTask

### ThreadPoolExecutor
#### 为什么要有线程池？
线程池能够对线程进行统一的分配，调优和监控
- 降低资源消耗
- 提高响应速度
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

- corePoolSize：核心线程数大小，当提交一个线程，线程池创建一个线程执行任务，直到线程池中的线程数达到corePoolSize，即使有其他空闲的线程能够执行新的线程，也会继续创建线程。
- maximumPoolSize：线程池中最大线程数量：当工作队列已满时，且当前线程数量小于最大线程数量，创建新的线程，将入blockqueue中继续执行任务。如果当前线程数量等于最大线程数量且工作队列已满，还在提交任务的话，执行相应的策略。
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
线程池中的线程数可达到最大整数个。使用SynchronizedQueue来作为阻塞队列，当线程的空闲时间超过keepAliveTime，会自动释放线程资源。当提交任务时，如果没有空闲线程，将创建新线程执行任务，会造成一定的系统开销。
(1) 主线程调用SynchronousQueue的offer方法放入task，假如线程池中有空闲线程尝试获取task，即调用了poll()方法，则主线程将task交给空闲线程。
(2) 如果没有空闲线程，则创建一个空闲线程执行任务。
(3) 如果空闲线程60s内没有执行任务，将释放线程资源。
#### 当队列满了并且worker的数量达到maxSize的时候，会怎么样? 
- 会交给RejectedExecutionHandler来处理任务。
#### 说说ThreadPoolExecutor有哪些RejectedExecutionHandler策略? 默认是什么策略? 
- AbortPolicy：直接抛出异常，**默认策略**。
- CallerRunPolicy：用调用者所在的线程来执行任务
- DiscardOldestPolicy：丢弃阻塞队列中靠最前的任务，并执行当前任务。
- DiscardPolicy：直接丢弃任务。
#### 简要说下线程池的任务执行机制? execute –> addWorker –>runworker (getTask) 
- ctl：低位29位表示线程池中的数量，高3位表示线程池的运行状态。
- execute
1. 首先判断当前线程池中执行的任务数量是否小于核心线程数，(1)如果小于核心线程数的话，通过addWork新建一个线程，并将任务添加到该线程中，然后启动该线程从而执行任务。(2)如果当前执行的任务数量大于等于核心线程数，①如果处于RUNNING状态，并将当前任务成功加入Work队列中，再次获取线程池的状态，如果线程池的状态不是RUNING，则需要将加进去的任务移除，并尝试判断线程是否执行完毕，同时执行拒绝策略。如果当前线程池为空，则创建一个新的线程并执行。②如果当前线程池不是处于RUNNING状态或者将提交的任务放入阻塞队列失败，通过addWork新建一个线程并将任务添加到该线程池中，然后启动该线程从而执行任务，如果addWork执行失败，执行拒绝策略。
- addWork
通过ReentrantLock获取全局锁
1. 用来创建新的工作线程，如果返回true说明创建和启动工作线程成功，否则的话返回就是false
2. 首先CAS将工作数量加1，如果当前线程池处于关闭状态，return false，如果当前工作队列也满了，返回false，否则一直cas尝试，直到成功为止。
3. 如果线程池状态为RUNNING，并且线程的状态是存活的，则将工作线程添加到工作线程集合中。firstTask == null 证明只新建线程而不执行任务。如果成功的添加工作线程，则调用Work内部的线程实例启动真实的线程实例。如果线程启动失败，需要将工作线程中移除对应的Worker。
- runWorker
继承了AQS，可以方便的实现线程的中止操作。
实现了Runnable接口，可以将自身作为一个任务在线程池中执行。
当前执行的任务作为参数传入Worker的构造方法
1. 线程启动后，启动unlock释放锁，设置AQS的状态为0，表示运行可中断。
2. Worker执行firstTask或者从WorkQueue中获取任务。①进行加锁操作，保证线程不被其他线程中断。②检查线程池状态，如果线程池处于中断状态，当前线程会被中断。③执行beforeExecute()方法。④执行任务的run方法。⑤执行afterExecute()方法。⑥解锁。
#### 线程池中任务是如何提交的? 
#### 线程池中任务是如何关闭的? 
- shutdown():关闭线程池，线程池状态为SHUTDOWN，线程池不再接受新的任务，但是队列中的任务需要执行完毕。
- shutdownNow():关闭线程池，线程池的状态为STOP，线程池会终止当前正在运行的任务，并停止处理排队的任务，并返回正在等待执行的list。
#### 在配置线程池的时候需要考虑哪些配置因素? 
#### 如何监控线程池的状态?