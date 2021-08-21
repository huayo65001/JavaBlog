[TOC]

### 1.进程

进程就是程序的一次执行过程，是系统运行程序的基本单位，是资源分配的最小单位。系统运行一个程序即从进程创建运行到消亡的过程。

在Java中，运行main函数时启动一个JVM进程，而main函数所在的线程就是这个进程的主线程。

### 2.线程

线程是CPU调度的基本单位，一个进程中可以有多个线程，共享进程的堆和方法区的资源（线程共享），但每个线程有自己独立的虚拟机栈、本地方法栈、程序计数器（线程私有）。

### 3.程序计数器为什么私有

字节码解释器通过程序计数器来判断需要执行的下一条指令，多线程下的程序计数器主要用来记录线程执行的位置，从而当线程被切换回来时恢复线程运行位置。

执行本地方法时，程序计数器记录的是undefined地址，只有执行java方法时，程序计数器记录的才是下一条指令的地址。

程序计数器私有主要是为了线程切换后能恢复到正确的执行位置。

### 4.虚拟机栈和本地方法栈为什么私有

虚拟机栈：java方法执行是会创建一个栈帧存储局部变量表、操作数栈、常量池引用等信息。从方法调用到执行结束的过程对应栈帧在虚拟机栈的入栈出栈操作。

本地方法栈：跟虚拟机栈类似，是为本地方法服务。Hotspot虚拟机中本地方法栈跟虚拟机栈合并。

虚拟机栈和本地方法栈私有主要是保证线程中的局部变量不被外界访问到。

### 5.并发、并行

并发是同一时间段内，可以执行多个任务。

并行是单位时间内，可以执行多个任务。

### 6.为什么使用多线程

线程是程序运行的最小单位，是轻量级进程，线程间的切换和调度成本小于进程。cpu多核时多个线程可以同时运行，减少线程切换时的开销。

单核：cpu单核时，使用多线程的作用是提高cpu和I/O设备的利用率，当使用单线程时，会有一个设备空闲，利用率低；使用多线程理想状态下设备的利用率是100%。

多核：cpu多核时，使用多线程的作用主要是提高cpu的利用率。

### 7.线程的生命周期

初始状态、运行状态、阻塞状态、等待状态、超时等待状态、终止状态。

##### 1.初始状态

线程被构建，但还没有调用start()方法。

##### 2.运行状态

Java线程将操作系统的运行状态和就绪状态统称为运行状态。

##### 3.阻塞状态

线程由于等待进入synchronized块或synchronized方法而阻塞。获取到锁结束。

##### 4.等待状态

线程进入等待状态，表示当前线程需要等待其他线程做出一些特定动作（通知或中断）。

当执行wait()后，线程进入等待状态，需要其他线程通知notify()才能返回。

##### 5.超时等待状态

不同于等待状态，可在指定时间自行返回。

##### 6.终止状态

线程执行完毕。

### 8.上下文切换

线程数大于cpu数，而一个cpu核心任何时刻只能被一个线程调用，为了让所有线程都可以执行，采用时间片轮转的方式分配cpu资源。当一个线程的时间片用完后会进入就绪状态，将cpu资源给其他线程使用，这个过程就是上下文切换。

任务从保存到再加载的过程就是一次上下文切换。

### 9.死锁

##### 1.四个条件

互斥条件、请求并保持条件、不可剥夺条件、循环等待条件。

##### 2.策略

**预防死锁**

程序运行前预防发生死锁。

破坏互斥条件。（一般不）

破坏请求并保持条件。

破坏不可剥夺条件。

破坏循环等待条件。

**避免死锁**

程序运行中避免发生死锁。

使用银行家算法等算法。如果一个状态下有一个推进顺序能使所有进程都顺利获取到资源并执行，则是安全状态。

**死锁检测死锁恢复**

不试图阻止死锁，发生死锁后进行恢复。

环路等待发生死锁。

E：资源总量，A：资源剩余量，C：每个进程拥有资源量，D：每个进程请求资源量。

死锁恢复：杀死进程，回滚恢复，抢占恢复。

**鸵鸟策略**

发生死锁什么也不做。解决死锁问题代价很高，不处理死锁问题能获得更高的性能。

### 10.sleep()和wait()

sleep()不会释放锁，wait()会释放锁。

两者都可以暂停线程的执行。sleep()用来暂停线程，wait()用于线程通信和交互。

wait()被调用后，线程不会自动苏醒，除非有其他线程调用notify()或notifyAll()。sleep()调用后，线程会自动苏醒。

### 11.调用start()会自动执行run()，为何不直接调用run()

new一个Thread，线程会进入初始状态。调用start()方法，会启动一个线程并使线程进入就绪状态，当分配到时间片时就会执行。strat()会执行线程的准备工作，并自动执行run()，这是真正的多线程。

而直接执行run()方法，会把run()方法作为main线程下的普通方法去执行，不是多线程。

调用start()会启动线程并进入就绪状态，直接调用run()不会用多线程执行。

### 12.synchronized

synchronized关键字解决的是多个线程之间访问资源的同步性，synchronized关键字可以保证被修饰的方法或代码块在任意时刻只有一个线程执行。

##### 1.使用方式

**修饰实例方法：**对对象实例加锁，进入同步代码前要获得当前对象实例的锁。

**修饰静态方法：**对类加锁，会作用到类的所有对象实例。因为静态成员不属于实例对象，是类成员。一个线程调用对象实例的非静态synchronized方法，另一个线程可以调用类的静态synchronized方法。

**修饰代码块：**指定加锁对象，给类或对象加锁。

synchronized(this/Object)：给指定对象实例加锁。

synchronized(类.class)：给类加锁。

##### 2.双重校验锁实现单例

```java
public static class Singleton{
        private volatile static Singleton instance;

        private Singleton() {};

        public static Singleton getInstance(){
            if (instance == null){
                synchronized (Singleton.class){
                    if (instance == null){
                        instance = new Singleton();
                    }
                }
            }
            return instance;
        }
    }
```

volatile很有必要：

instance = new Singleton()实际分三步进行：为instance分配内存空间、初始化instance、将instance指向分配的内存地址。

由于JVM的指令重排特性，可能第二步执行后再执行第三步。这样一个线程执行了第一步、第三步，另一个线程调用getInstance()发现instance不为空，则返回instance，但此时instance还未初始化。使用volatile关键字可以禁止JVM的指令重排，保证多线程环境下单例正常运行。

##### 3.构造方法可以使用synchronized吗

不能，构造方法本身线程安全，不存在同步构造方法。

##### 4.synchronized底层原理

**修饰语句块：**通过monitorenter和monitorexit指令实现同步。monitorenter指向同步代码块的开始位置，monitorexit指向同步代码块的结束位置。

JVM中，Monitor是基于C++实现的，每个对象都内置一个Objectmonitor对象。另外wait、notify方法也依赖Monitor对象，这就是为什么只有在同步的块或方法中才能调用wait和notify方法。

执行monitorenter时，会试图获取对象的锁，如果锁的计数器为0则可以获取，获取后计数器加1。

执行monitorexit时，释放锁，计数器减1。

**修饰方法：**没有使用monitorenter等指令，而是使用ACC_SYNCHRONIZED标识，JVM通过这个标识判断一个方法是否是同步方法，并执行相应的同步调用。

**总结：**两者本质都是对monitor的获取。

##### 5.synchronized和ReentrantLock区别

**可重入锁：**两者都是可重入锁。

可重入锁指自己可以再次获得自己的内部锁，例如一个线程获取的某个对象的锁，还没有释放的时候，可以再次获取这个对象的锁，锁的计数器加1。如果不是可重入的，会产生死锁。

**synchronized依赖JVM，ReentrantLock依赖API：**

**ReentrantLock增加了高级功能：**

**·** 等待可中断：等待锁的线程可以被中断等待，去处理其他事情。

**·**实现公平锁：公平锁是指先等待的线程先获取锁。ReentrantLock默认非公平锁。

**·**实现选择性通知：通过Condition对象实现选择通知（jdk1.5）。在一个锁对象中可以创建多个condition（锁监视器），线程对象可以注册在不同的condition中，调用condition的signalAll()方法，只会通知该condition下注册的线程。

synchronized相当于Lock中只有一个condition，调用notify()方法会通知所有等待状态的线程。

**·**实现可重入：nonfairTryAcquire()方法来获取锁，首先判断当前线程是否是获取锁的线程，如果是则同步状态值加一。

##### 6.synchronized为什么不公平

收到锁请求的线程首先自旋，自旋也没有获取锁才会进入队列等待，这样对于已经进入队列的线程不公平。

##### 7.synchronized优化策略

四个状态：无锁、偏向锁、轻量级锁和重量级锁。

**自旋锁：**获取不到锁时不进行线程切换，再次尝试获取锁。优点是避免额外的线程切换造成的开销，缺点是会占用cpu。默认10次。

**自适应自旋锁：**自旋时间不固定，由之前自旋时间和锁拥有者的状态决定。在同一个锁上，如果上一次自旋很成功，则认为此次也能成功，允许自旋；如果很少成功，可能直接忽略自旋，避免浪费cpu资源。

**锁销除：**编译器对检测到的不可能存在共享竞争的锁进行消除。

**锁粗化：**一个线程频繁请求一个资源，会多次获得锁释放锁，这时可以把多次请求合并为一个请求。

**偏向锁：**为了在没有竞争的情况下减少锁的开销，锁会偏向于第一个获得它的进程，如果没有被其他线程获取，则这个线程不需要再获得锁。

### 13.volatile

##### 1.为什么用

jdk1.2之前，java内存模型直接使用主存读取变量，但在之后的java内存模型下，线程可以把变量保存到本地内存中，而不是直接写入共享内存，这就会造成一个线程在主存中修改了变量的值，另一个线程还在使用本地内存中变量的值，造成数据不一致问题。

把变量声明为volatile，告诉JVM这个变量是共享并且不稳定的，每次使用都要去主存中读取，每次修改都要对主存中的变量进行修改。

volatile除了防止JVM的指令重排，还一个作用就是保证变量的可见性。

##### 2.并发编程的三个重要特性

**原子性：**一个操作要么全部做，要么全部做。

**可见性：**一个线程对变量进行了修改，其他线程要立刻看到修改后的值。

**有序性：**保证代码执行的先后顺序。

### 14.synchronized和volatile

volatile是线程同步的轻量级实现，所以volatile比synchronized性能好。

volatile只能用于变量，synchronized可以修饰方法和代码块。

volatile主要用来保证变量的可见性，不能保证原子性，synchronized两者都可以保证。

volatile主要解决变量在多个线程的可见性，synchronized主要解决多个线程之间访问资源的同步性。

### 15.ThreadLocal

通常创建的变量可以被任何一个线程访问，如果想实现每个线程有自己专属的本地变量，就要使用ThreadLocal，使每个线程都有自己的本地变量，让每个线程都绑定自己的值，访问ThreadLocal变量的线程都有这个变量的副本。

可以使用get()，set()方法来获取默认值或将值更改为当前线程所存的副本的值，避免线程安全问题。

本地变量放在ThreadLocalMap中，每个线程Thread都有一个ThreadLocalMap，key是ThreadLocal，value是存的对象

##### ThreadLocal的内存泄漏问题

ThreadLocal会发生内存泄漏问题，因为ThreadLocalMap的key是弱引用，value是强引用，如果ThreadLocal没有被外部强引用的话，垃圾回收后key会被清理，而value不会被清理掉。这样会出现key是null的数据，如果不处理，则value永远无法被回收。

解决方法：在调用set()，get()，remove()方法时，会清理掉key为null的记录。

##### 特性

synchronized通过线程等待解决线程安全，而ThreadLocal是为每个线程单独创建一个变量副本。

### 16.线程池

##### 1.线程池的好处

**降低资源消耗：**通过重复利用已创建的线程来降低创建线程和销毁线程的消耗。

**提高响应速度：**任务到达时，任务不需要等待线程创建就可以立即执行。

**提高可管理性：**线程无限制创建，会消耗系统资源，降低系统稳定性，通过线程池进行统一分配，调优和监控。

##### 2.Runnable接口、Callable接口

**Runnable接口：**jdk1.0就存在，不会返回结果和抛出异常。

**Callable接口：**jdk1.5，会返回结果和抛出异常。

如果任务无需返回结果或抛出异常，可以用Runnable接口；Executors工具类可以实现两者的转换。

##### 3.execute()、submit()

**execute()：**用于提交不需要返回值的任务，无法判断任务是否被线程池执行成功。

**submit()：**用于提交需要返回值的任务，线程池会返回一个Future类型的对象，调用get()方法来获取返回值，会阻塞线程直到任务完成。

##### 4.创建线程池方式

**（1）通过ThreadPoolExecutor构造方法实现**

**（2）通过Executor框架的工具类Executors来实现**

**Executors返回线程池对象的弊端：**FixedThreadPool和SingleThreadPool允许请求的队列长度是Integer.MAX_VALUE，可能堆积大量的请求，导致内存溢出；CachedThreadPool和ScheduledThreadPool允许创建的线程数量是Integer.MAX_VALUE，可能堆积大量线程，导致内存溢出。

##### 5.ThreadPoolExecutor构造函数参数

corePoolSize：最小同时运行的线程数。

maximumPoolSize：当队列中的请求任务达到最大值时，可同时运行的最大线程数。

workQueue：当有新任务的时候，会判断线程数是否达到核心线程数，达到的话，任务请求存放在队列中。

keepAliveTime：当线程数大于核心线程数，如果没有新任务提交，会在超过keepAliveTime后销毁核心线程外的线程。

unit：keepAliveTime的单位。

threadFactory

handler：饱和策略。

##### 6.ThreadPoolExecutor的饱和策略

AbortPolicy：抛出异常拒绝新任务的处理。（默认）

CallerRunsPolicy：调用执行自己的线程运行任务，直接在调用excute()的方法中运行任务。

DiscardPolicy：直接丢弃。

DiscardOldestPolicy：丢弃最早未处理的请求。

##### 7.原理分析

使用ThreadPoolExecutor创建一个对象executor，调用方法executor.execute()将任务提交到线程池中

如果当前线程数小于核心线程数，则通过addWorker()创建一个线程并将任务添加到此线程中执行；

如果当前线程数大于等于核心线程数，判断线程池状态，RUNNING并且队列可以加入任务，则将任务添加进队列，之后在判断线程池状态，如果是RUNNING则创建线程执行，如果不是RUNNING则从队列中移除任务；

入队失败，尝试通过addWorker()创建一个线程并执行。

### 17.Atomic原子类

Atomic指一个操作不可中断，多个线程一起执行时，一旦操作开始，不会被其他线程干扰。

JUC包下的原子类都在atomic下

![image-20210729171155117](C:\Users\Herion\AppData\Roaming\Typora\typora-user-images\image-20210729171155117.png)

##### 1.JUC包中的原子类

**基本类型**

AtomicInteger

AtomicLong

AtomicBoolean

**数组类型**

AtomicIntegerArray

AtomicLongArray

AtomicReferenceArray

**引用类型**

AtomicReference

AtomicStampedReference

AtomicMarkableReference

**对象的属性修改类型**

AtomicIntegerFieldUpdater

AtomicLongFieldUpdater

AtomicReferenceFieldUpdater

### 18.AQS

全程AbstractQueueSynchronizer，这个类在java.util.concurrent.locks下。是用来构建锁和同步器的框架。

##### 1.AQS原理

AQS的思想是，请求一个空闲的共享资源，就将请求资源的线程设为工作线程，并且将共享资源加锁；如果共享资源被占用，需要有一个线程堵塞等待和分配锁的机制，AQS用CLH队列锁实现，将暂时获取不到资源的线程加入到队列中。

##### 2.AQS共享方式

**独占：**只有一个线程能执行，可分为公平锁、不公平锁。

**共享：**多个线程可同时执行。

##### 3.自定义同步器

自定义同步器只需要实现共享资源state的获取与释放即可。

**模版方法模式：**

1.使用者继承AbstractQueuedSynchronizer，并重写指定方法。

2.将AQS组合在使用者的实现中，调用模版方法，模版方法会调用重写的方法。

isHeldExclusively()：该线程是否正在独占资源。

tryAcquire(int)：独占方式，尝试获取资源。

tryRelease(int)：独占方式，尝试释放资源。

tryAcquireShared(int)：共享方式，尝试获取资源。

tryReleaseShared(int)：共享方式，尝试释放资源。

以ReentrantLock为例：初始状态state=0，当A线程lock()时，调用tryAcquire()方法将state加1，之后其他线程获取锁都会失败，直到A线程unlock()，state=0，其他资源才可以获得锁。因为是可重入锁，state可以累加，但获取几次就要释放几次。

##### 4.AQS组件

**Semaphore信号量：**允许多个线程同时访问。构造方法传入int数表示最大并发量，使用acquire()方法获得一个许可，release()方法归还许可，tryAcquire()方法尝试获取一个许可。

**CountDownLatch倒计时器：**允许count个 线程阻塞在同一个地方，协调多个线程的同步。构造方法传入int数作为计数器，每调用一次countDown()方法计数器减一，调用await()方法来进行等待，直到计数器为0时被唤醒。

### 19.java多线程实现方法

##### 1.继承Thread类，重写run()方法

```java
static class MyThread extends Thread {
    private int i;
    @Override
    public void run() {
        for (i = 0; i < 10; i++){
            System.out.println(Thread.currentThread().getName() + " " + i);
        }
    }
}
public static void main(String[] args) {
    for (int i = 0; i < 10; i++){
        System.out.println(Thread.currentThread().getName() + " " + i);
        if (i == 5){
            MyThread myThread1 = new MyThread();
            MyThread myThread2 = new MyThread();
            myThread1.start();
            myThread2.start();
        }
    }
}
```



##### 2.实现Runnable()接口，重写run()方法，实现接口的类的实例作为Thread构造函数的target

```java
static class MyRunnable implements Runnable{
    private int i = 0;
    @Override
    public void run() {
        for (i = 0; i < 10; i++){
            System.out.println(Thread.currentThread().getName() + " " + i);
        }
    }
}
public static void main(String[] args) {
    for (int i = 0; i < 10; i++){
        System.out.println(Thread.currentThread().getName() + " " + i);
        if (i == 5){
            Runnable myRunnable = new MyRunnable();
            Thread thread1 = new Thread(myRunnable);
            Thread thread2 = new Thread(myRunnable);
            thread1.start();
            thread2.start();
        }
    }
}
```



##### 3.通过Callable和FutureTask创建线程

创建Callable接口的实现类，重写call()方法

创建实现类对象，使用FutureTask包装Callable对象

使用FutureTask对象作为Thread的target

调用FutureTask的get()方法获取返回值

```java
static class MyCallable implements Callable<Integer> {
    private int i = 0;
    @Override
    public Integer call() throws Exception {
        int sum = 0;
        for (i = 0; i < 10; i++){
            System.out.println(Thread.currentThread().getName() + " " + i);
            sum += i;
        }
        return sum;
    }
}
public static void main(String[] args) {
    Callable<Integer> myCallable = new MyCallable();
    FutureTask<Integer> futureTask = new FutureTask<>(myCallable);
    for (int i = 0; i < 10; i++){
        System.out.println(Thread.currentThread().getName() +" "+ i);
        if (i == 5){
            Thread thread1 = new Thread(futureTask);
            thread1.start();
        }
    }
    System.out.println("=============");
    try {
        int sum = futureTask.get();
        System.out.println("sum = " + sum);
    } catch (InterruptedException e) {
        e.printStackTrace();
    } catch (ExecutionException e) {
        e.printStackTrace();
    }
}
```



##### 4.通过线程池创建线程

```java
private static int POOL_NUM = 10;

static class MyRunnable implements Runnable{
    @Override
    public void run() {
        System.out.println("通过线程池方式创建的线程：" + Thread.currentThread().getName() + " ");
    }
}

public static void main(String[] args) {
    ExecutorService executorService = Executors.newFixedThreadPool(5);
    for (int i = 0; i < POOL_NUM; i++){
        MyRunnable thread = new MyRunnable();
        executorService.execute(thread);
    }
    executorService.shutdown();
}
```

### 20.CAS

compare and swap比较并交换，是个乐观锁。

CAS需要三个操作数，内存值，旧的预期值和准备修改的新值。当CAS指令执行时，会比较内存中的值和旧的预期值是否相同，相同的话使用准备修改的新值进行修改；不相同的话操作失败，进行自选操作，重新获取预期值并计算准备修改的新值，再次尝试。

缺点：如果失败会一直自旋，耗费CPU资源；只能保证一个变量的原子性，不能保证代码块的原子性，如果需要多个变量进行原子性更新，只能使用synchronized；**ABA问题：**假设第二个线程将内存中的值修改成其他又修改为预期值（将V中A修改为B又修改为A），当前线程的CAS无法判断V中的值是否变化，也就是说CAS只判断是否相等，不能判断是否修改过。

### 21.JMM

JMM：java内存模型，用于处理线程间数据的通信。

JMM规定所有变量都储存在主存中，但每个线程有自己的工作内存，线程操作一个变量，需要先把主存中的变量加载到工作内存中创建一个变量副本，线程对变量的操作都是对工作内存中变量副本的操作。

**8种原子操作：**

**主内存：**lock、unlock、read、write

**工作内存：**load、user、assgin、store

### 22.as-if-serial和happens-before

##### 1.as-if-serial

解释器和编译器可以优化执行顺序，即指令重排，但无论怎样重排序，执行结果不能改变。

为了遵循as-if-serial，编译器和解释器不会对有数据依赖的操作进行指令重排。

##### 2.happens-before

先行发生原则，是指前一个操作的结果可以被后续的操作获取。

JMM将happens-before禁止的重排序按是否改变结果分为两类：对于会改变执行结果的重排序必须禁止，对于不会改变执行重排序的操作不作要求。

##### 3.区别

as-if-serial保证单线程程序执行结果不变；happens-before保证多线程程序执行结果不变。

两者都是为了在不改变执行结果的前提下提高程序的并行程度。

### 23.指令重排

为了提高性能，编译器和解释器会对指令进行重排序。

### 24.原子性、可见性、有序性

##### 1.原子性

操作要么全成功，要么全失败。除了long和double两个64位的数据类型，其他基本类型都具备原子性。

##### 2.可见性

可见性是指一个线程修改了某个变量，其他线程立即能得知修改。

volatile保证线程在工作内存修改变量副本后立即将改变刷入主存；获取变量每次都要从主存中获取。

保证可见性的关键字：volatile、synchronized、final。

##### 3.有序性

本线程内的所有操作都是有序的，观察其他线程内的操作都是无序的。

保证有序性的关键词：volatile、synchronized。

### 25.线程间通信方式

##### 1.volatile

对变量的读需从主存中获取，对变量的写需立刻写会主存。

##### 2.synchronized

保证线程对变量访问的可见性，原子性，有序性。

##### 3.等待通知机制

##### 4.管道I/O流

用于线程间数据传输

##### 5.ThreadLocal
