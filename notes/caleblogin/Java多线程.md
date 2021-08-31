# java多线程
<!--ts-->
- [java多线程](#java多线程)
  - [并发出现问题的根源：并发三要素](#并发出现问题的根源并发三要素)
  - [JAVA是怎么解决并发问题的](#java是怎么解决并发问题的)
  - [线程安全](#线程安全)
    - [线程安全的实现方法](#线程安全的实现方法)
  - [线程状态转换](#线程状态转换)
  - [线程使用方式](#线程使用方式)
  - [线程互斥同步](#线程互斥同步)
    - [Synchronized和Reentranlock的对比](#synchronized和reentranlock的对比)
  - [synchronized](#synchronized)
    - [加锁和释放锁的原理：](#加锁和释放锁的原理)
    - [锁升级过程](#锁升级过程)
    - [锁优化](#锁优化)
  - [volatile](#volatile)
    - [可见性](#可见性)
    - [MESI机制](#mesi机制)
      - [有了MESI为什么还需要Volatile](#有了mesi为什么还需要volatile)
    - [有序性](#有序性)
  - [final](#final)
    - [知识点](#知识点)
    - [有序性](#有序性-1)
  - [CAS，Unsafe和原子类](#casunsafe和原子类)
  - [LockSupport](#locksupport)
  - [AQS](#aqs)
  - [ReentrantLock](#reentrantlock)
  - [ReentrantReadWriteLock](#reentrantreadwritelock)
  - [CopyOnWriteArrayList](#copyonwritearraylist)
  - [ConcurrentHashMap](#concurrenthashmap)
    - [ConcurrentHashMap怎么实现线程安全](#concurrenthashmap怎么实现线程安全)
    - [1.7](#17)
    - [1.8](#18)
  - [BlockingQueue](#blockingqueue)
  - [JUC线程池ThreadPoolExecutor](#juc线程池threadpoolexecutor)
    - [核心方法](#核心方法)
    - [exectue方法中为什么double check线程池的状态](#exectue方法中为什么double-check线程池的状态)
    - [几种常见的线程池](#几种常见的线程池)
    - [关闭线程池](#关闭线程池)
  - [线程工具类，CountDownLatch，CyclicBarrier，Semaphore](#线程工具类countdownlatchcyclicbarriersemaphore)
  - [ThreadLocal](#threadlocal)

<!-- Added by: hanzhigang, at: 2021年 8月28日 星期六 09时48分55秒 CST -->

<!--te-->
## 并发出现问题的根源：并发三要素
1. 原子性：分时复用引起的，操作系统增加了进程、线程以分时复用CPU，进而均衡CPU与IO设备之间的速度差异。引出了原子性问题
2. 可见性：CPU缓存引起的，CPU增加了缓存，以均衡和内存之间的速度差异，引出了可见性的问题。
3. 有序性：执行重排序引起的，编译程序优化指令执行执行次序，使得缓存能够得到更合理的利用。引出了有序性的问题。编译器优化重排序，指令级并行重排序，内存系统重排序。
## JAVA是怎么解决并发问题的
1. volatile，synchronized，final三个关键字。
2. happen-before规则
①单一线程原则，在一个程序内，程序前面的操作先于发生程序后面的操作。
②管程锁定规则，一个unlock操作先行发生于后面对同一个锁的lock操作。
③volatile变量规则，对于一个volatile变量的写操作先行发生于后面对这个变量的读操作。
④线程启动规则，Thread对象的start发生先行发生于此线程的每一个动作。
⑤线程加入规则，Thread对象结束先行发生于join方法返回。
⑥线程中断规则，对线程interrupt方法的调用先行发生于被中断线程的代码检测到中断事件的发生。可以通过 interrupted() 方法检测到是否有中断发生。
⑦对象终结规则，一个对象的初始化先行发生于它的finalize方法的开始。
⑧传递性，如果操作A先行发生于操作B，操作B先行发生于操作C，那么操作A先行发生于操作C。
## 线程安全
不可变，绝对线程安全，相对线程安全，线程兼容，线程对立
### 线程安全的实现方法
1. 互斥同步：Synchronized，Reentrantlock
2. 非阻塞同步：CAS
3. 无同步方案：线程隔离ThreadLocal
## 线程状态转换
新建状态，就绪状态，运行状态，阻塞状态，结束状态
## 线程使用方式
1. 实现 Runnable 接口
2. 实现 Callable 接口
3. 继承 Thread 类
## 线程互斥同步
### Synchronized和Reentranlock的对比
1. 锁的实现 synchronized 是 JVM 实现的，而 ReentrantLock 是 JDK 实现的。
2. 性能 新版本 Java 对 synchronized 进行了很多优化，例如自旋锁等，synchronized 与 ReentrantLock 大致相同。
3. 等待可中断 当持有锁的线程长期不释放锁的时候，正在等待的线程可以选择放弃等待，改为处理其他事情。 ReentrantLock 可中断，而 synchronized 不行。
4. 公平锁 公平锁是指多个线程在等待同一个锁时，必须按照申请锁的时间顺序来依次获得锁。 synchronized 中的锁是非公平的，ReentrantLock 默认情况下也是非公平的，但是也可以是公平的。
5. 锁绑定多个条件 一个 ReentrantLock 可以同时绑定多个 Condition 对象。
## synchronized
1. 使用方法，对象锁，this，普通成员方法上。类锁，静态方法，当前类
### 加锁和释放锁的原理：
1. 使用synchronized之后，会在编译之后在同步的代码块前后加上monitorenter和monitorexit字节码指令，他依赖操作系统底层互斥锁实现。他的作用主要就是实现原子性操作和解决共享变量的内存可见性问题。执行monitorenter指令时会尝试获取对象锁，如果对象没有被锁定或者已经获得了锁，锁的计数器+1。此时其他竞争锁的线程则会进入等待队列中。执行monitorexit指令时则会把计数器-1，当计数器值为0时，则锁释放，处于等待队列中的线程再继续竞争锁。**从内存语义来说，加锁的过程会清除工作内存中的共享变量，再从主内存读取，而释放锁的过程则是将工作内存中的共享变量写回主内存**。
2. 深入底层源码：synchronized实际上有两个队列waitSet和entryList。当多个线程进入同步代码块时，首先进入entryList。有一个线程获取到monitor锁后，就赋值给当前线程，并且计数器+1。如果线程调用wait方法，将释放锁，当前线程置为null，计数器-1，同时进入waitSet等待被唤醒，调用notify或者notifyAll之后又会进入entryList竞争锁。如果线程执行完毕，同样释放锁，计数器-1，当前线程置为null。
### 锁升级过程
无锁，偏向锁，轻量级锁，重量级锁
### 锁优化
1. 自旋锁，自适应自旋锁，锁消除，锁粗化，偏向锁，轻量级锁
2. 自旋锁：由于大部分时间锁被占用的时间很短，共享变量的锁定时间也很短，没必要挂起线程，用户态和内核态的来回上下文切换严重影响性能。让线程执行一个忙循环，防止用户态进入内核态。默认10次。
3. 自适应自旋锁：自选的时间不是固定的，而是由前一次在同一个锁上的自选时间和锁持有者的状态决定的。
4. 锁消除：检测到一些同步代码块完全不存在数据竞争的场景，也就不需要加锁，就会进行锁消除。
5. 锁粗化：有很多操作都是对同一个对象加锁，就会把锁的同步范围扩展到整个操作序列之外。
6. 偏向锁：当线程访问同步块获取锁时，会在对象头和栈帧中的锁记录里面存储偏向锁的线程ID，之后这个线程再次进入代码块时，都不需要CAS来加锁和解锁了，偏向锁会永远偏向第一个获得锁的线程，如果后续没有线程去竞争这个锁，持有锁的线程永远不需要进行同步。反之当有其他线程竞争当前偏向锁时，持有偏向锁的线程就会释放当前偏向锁。
7. 轻量级锁：在线程栈帧中创建锁记录的空间用于存储当前锁对象markword的拷贝，JVM会使用CAS操作将markword拷贝到锁记录中，并将markword指向当前线程栈帧中的锁记录的指针。这个对象就拥有了当前对象的锁，并将markword中的锁标志位更新为00，表示此对象处于轻量级锁定状态。如果操作失败，jvm会检查当前markword是否已经指向了当前线程栈帧中的锁记录空间，如果已指向，可以直接调用，如果没有指向，那么就说明该锁被其他线程抢占了，如果有两条以上的线程竞争该锁，轻量级锁失效，直接膨胀为重量级锁。轻量级锁解锁时，会原子的使用CAS将线程栈帧中的markword拷贝替换回对象头中，如果失败，说明当前锁存在竞争关系，直接膨胀为重量级锁。
8. 偏向锁就是通过对象头的偏向线程ID来对比，甚至都不需要CAS了，而轻量级锁主要就是通过CAS修改对象头锁记录和自旋来实现，重量级锁则是除了拥有锁的线程其他全部阻塞。

## volatile
### 可见性
总线嗅探机制，CPU需要每时每刻监听总线上的一切活动，总线嗅探只是保证了某个CPU核心的Cache更新数据这个事件能被其他的CPU核心知道，但不能保证事务串行化。volatile修饰的变量会直接强制刷回主存，此时缓存中的该变量失效，读取时重新在主存中读取该变量。
### MESI机制
- 四个状态：已失效、独占、共享、已修改
#### 有了MESI为什么还需要Volatile
1. 不止操作系统做了指令的重排序，编译器和虚拟机都做了指令的重排序，所以需要volatile。
2. mesi只是保证多核cpu的独占cache之间的一致性，但是cpu的并不是直接把数据写入L1 cache的，中间可能还有store buffer，因此有mesi机制是远远不够的。
3. mesi协议最多只是保证了对于一个变量，在多个核上的读写顺序，对于多个变量而言是没有任何保证的。
4. mesi对于这种弱一致性的cpu来说，只会保证指令之间的有比如控制依赖，数据依赖，地址依赖等等依赖关系的指令间的提交的先后顺序，而对于完全没有依赖关系的指令，它们是不会保证执行提交的顺序的，除非你使用了volatile，java把volatile编译成arm和power能够识别的barrier指令，这时候才是按照顺序的。
### 有序性
内存屏障，storestore 禁止上面的普通写和下面的volatile写重排序。，storeload防止上面的 volatile 写与下面可能有的 volatile 读/写重排序。，loadload，loadstore禁止下面所有的普通读写操作和上面的 volatile 读重排序。
## final
### 知识点
1. final修饰的方法是可以被重载的
2. final不都是编译器常量，当修饰的变量指向一个随机数时，只有当前变量被初始化后无法被更改。
### 有序性
1. JMM禁止编译器把final域的写重排序到构造函数之外。
2. JMM禁止编译器把final域的读重排序到构造函数之外。
3. 在构造函数内对一个final修饰的对象的成员域的写入，与随后在构造函数之外把这个被构造的对象的引用赋给一个引用变量，这两个操作是不能被重排序的。
## CAS，Unsafe和原子类
1. CAS：CAS叫做CompareAndSwap，比较并交换，主要是通过处理器的指令来保证操作的原子性，它包含三个操作数：变量内存地址，V表示。旧的预期值，A表示。准备设置的新值，B表示。当执行CAS指令时，只有当V等于A时，才会用B去更新V的值，否则就不会执行更新操作。
2. 缺点：ABA问题。循环时间长。只能保证一个共享变量的原子操作：只对一个共享变量操作可以保证原子性，但是多个则不行，多个可以通过AtomicReference来处理或者使用锁synchronized实现。
3. Unsafe：compareAndSwapInt,compareAndSwapObject,compareAndSwapLong。
4. 原子类：AtomicInteger,AtomicBoolean,AtomicLong,AtomicIntegerArray,AtomicLongArray,AtomicReference, AtomicReference,AtomicStampedReference,AtomicMarkableReference,AtomicIntegerFieldUpdater,AtomicLongFieldUpdater,AtomicStampedFieldUpdater,AtomicReferenceFieldUpdater。
## LockSupport
1. LockSupport用来创建锁和其他同步类的基本线程阻塞原语。简而言之，当调用LockSupport.park时，表示当前线程将会等待，直至获得许可，当调用LockSupport.unpark时，必须把等待获得许可的线程作为参数进行传递，好让此线程继续运行。
2. Thread.sleep()和Object.wait()的区别：①释不释放锁资源。②必须传入时间，另一个可不传。③sleep唤醒后继续执行，对于wait不传时间的必须通过notify或notifyAll来唤醒，带时间的立刻获取锁或没有立刻获取锁，进入同步队列。
3. Thread.sleep()和Condition.await()的区别：Object.wait()和Condition.await()的原理是基本一致的，不同的是Condition.await()底层是调用LockSupport.park()来实现阻塞当前线程的。 实际上，它在阻塞当前线程之前还干了两件事，一是把当前线程添加到条件队列中，二是“完全”释放锁，也就是让state状态变量变为0，然后才是调用LockSupport.park()阻塞当前线程。
4. Thread.sleep()和LockSupport.park()的区别：①都是阻塞当前线程的执行，且不会释放当前线程所占用的锁资源。②Thread.sleep()无法从外部唤醒，只能自己醒过来，park可被unpark唤醒。③Thread.sleep()需要捕获异常，park不需要捕获异常。④Thread.sleep()是一个native方法，park调用底层的unsafe的native方法。
5. Object.wait和LockSupport.park的区别：①wait需要在同步代码块中执行，park可以在任意地方执行。②wait需要捕获异常，park不需要捕获异常。③wait不带超时的，必须由notify唤醒，不一定执行后面的操作，park不带超时的必须由unpark唤醒，一定执行后面的操作。④park和unpark可以换序执行。
6. LockSupprt.park不会释放当前锁资源，锁资源的释放是由Condition.await()中实现的。
## AQS
1. AQS的思想：如果被请求的共享资源空闲，则将当前请求资源的线程设置为有效的工作线程，并且将共享资源设定为锁定状态。如果被请求的共享资源被占用，那么就需要一套线程阻塞等待以及被唤醒时所分配的机制。这个机制AQS是用CLH队列锁实现的，即将暂时获取不到锁的线程加入到队列中。
2. AQS使用一个int成员变量来表示同步状态，通过内置的FIFO队列来完成获取资源线程的排队工作。AQS使用CAS对该同步状态进行原子操作实现对其值的修改。
3. AQS的模板方法`isHeldExclusively()//该线程是否正在独占资源。只有用到condition才需要去实现它。tryAcquire(int)//独占方式。尝试获取资源，成功则返回true，失败则返回false。tryRelease(int)//独占方式。尝试释放资源，成功则返回true，失败则返回false。tryAcquireShared(int)//共享方式。尝试获取资源。负数表示失败；0表示成功，但没有剩余可用资源；正数表示成功，且有剩余资源。tryReleaseShared(int)//共享方式。尝试释放资源，成功则返回true，失败则返回false。`
4. 内部类Node，ConditionObject
## ReentrantLock
1. ReentrantLock类内部总共存在Sync、NonfairSync、FairSync三个类，NonfairSync与FairSync类继承自Sync类，Sync类继承自AbstractQueuedSynchronizer抽象类。
2. AQS怎么实现的非公平锁，怎么实现的公平锁
## ReentrantReadWriteLock
1. Sync继承自AQS、NonfairSync继承自Sync类、FairSync继承自Sync类；ReadLock实现了Lock接口、WriteLock也实现了Lock接口。
2. 高16位为读锁，低16位为写锁
3. 锁升降级：锁降级指的是写锁降级成为读锁。如果当前线程拥有写锁，然后将其释放，最后再获取读锁，这种分段完成的过程不能称之为锁降级。锁降级是指把持住(当前拥有的)写锁，再获取到读锁，随后释放(先前拥有的)写锁的过程。
## CopyOnWriteArrayList

## ConcurrentHashMap
1.7使用Segment+HashEntry分段锁的方式实现，1.8则抛弃了Segment，改为使用CAS+synchronized+Node实现，同样也加入了红黑树，避免链表过长导致性能的问题。
### ConcurrentHashMap怎么实现线程安全

### 1.7
1. 1.7版本的ConcurrentHashMap采用分段锁机制，里面包含一个Segment数组，Segment继承与ReentrantLock，Segment则包含HashEntry的数组，HashEntry本身就是一个链表的结构，具有保存key、value的能力能指向下一个节点的指针。实际上就是相当于每个Segment都是一个HashMap，默认的Segment长度是16，也就是支持16个线程的并发写，Segment之间相互不会受到影响。
2. 初始的默认大小是2，当put第二个的时候，进行扩容。先扩容再添加元素。
3. put流程：①计算hash，定位到segment，segment如果是空就先初始化。②使用ReentrantLock加锁，如果获取锁失败则尝试自旋，自旋超过次数就阻塞获取，保证一定获取锁成功。③遍历HashEntry，就是和HashMap一样，数组中key和hash一样就直接替换，不存在就再插入链表，链表同样。
4. get流程：get也很简单，key通过hash定位到segment，再遍历链表定位到具体的元素上，需要注意的是value是volatile的，所以get是不需要加锁的。
5. get方法的安全性分析：（1）put 操作的线程安全性。初始化槽，这个我们之前就说过了，使用了 CAS 来初始化 Segment 中的数组。 添加节点到链表的操作是插入到表头的，所以，如果这个时候 get 操作在链表遍历的过程已经到了中间，是不会影响的。当然，另一个并发问题就是 get 操作在 put 之后，需要保证刚刚插入表头的节点被读取，这个依赖于 setEntryAt 方法中使用的 UNSAFE.putOrderedObject。 扩容。扩容是新创建了数组，然后进行迁移数据，最后面将 newTable 设置给属性 table。所以，如果 get 操作此时也在进行，那么也没关系，如果 get 先行，那么就是在旧的 table 上做查询操作；而 put 先行，那么 put 操作的可见性保证就是 table 使用了 volatile 关键字。 remove 操作的线程安全性。（2）remove 操作。get 操作需要遍历链表，但是 remove 操作会"破坏"链表。 如果 remove 破坏的节点 get 操作已经过去了，那么这里不存在任何问题。 如果 remove 先破坏了一个节点，分两种情况考虑。 1、如果此节点是头结点，那么需要将头结点的 next 设置为数组该位置的元素，table 虽然使用了 volatile 修饰，但是 volatile 并不能提供数组内部操作的可见性保证，所以源码中使用了 UNSAFE 来操作数组，请看方法 setEntryAt。2、如果要删除的节点不是头结点，它会将要删除节点的后继节点接到前驱节点中，这里的并发保证就是 next 属性是 volatile 的。
6. 扩容机制：从头结点开始向后遍历，找到当前链表的最后几个下标相同的连续的节点。从lastRun节点到尾结点的这部分就可以整体迁移到新数组的对应下标位置了，因为它们的下标都是相同的，可以这样统一处理。从头结点到 lastRun 之前的节点，无法统一处理，只能一个一个去复制了。且注意，这里不是直接迁移，而是复制节点到新的数组，旧的节点会在不久的将来，因为没有引用指向，被 JVM 垃圾回收处理掉。
7. size()：采用乐观的方式，认为在统计size的过程中没有发生put，remove等改变segment结构的操作。但是如果发生了就需要重试。如果重试两次都不成功，就只能强制把所有的Segment加锁后，再统计。
### 1.8
1. put流程：①首先计算hash，遍历node数组，如果node是空的话，就通过CAS+自旋的方式初始化。②如果当前数组位置是空则直接通过CAS自旋写入数据。③如果hash==MOVED，说明需要扩容，执行扩容。④如果都不满足，就使用synchronized写入数据，写入数据同样判断链表、红黑树，链表写入和HashMap的方式一样，key hash一样就覆盖，反之就尾插法，链表长度超过8就转换成红黑树。
2. get流程：通过key计算hash，如果key hash相同就返回，如果是红黑树按照红黑树获取，都不是就遍历链表获取。
3. 扩容机制：在元素迁移的时候，所有线程遵循从后向前推进的规则，在线程迁移过程中会确定一个范围，限定它此次迁移的数据范围。比如A线程第一个进来，只能迁移index=7 和 6 的数据，此时其他线程不能迁移这部分数据了，只能继续向前推进，寻找其他可以迁移的数据范围。且每次推进的步长都是固定值。线程B发现线程A正在迁移6 7的数据，只能向前寻找，迁移bound4和5的数据。维护了一个全局的transferIndex,来表示所有线程总共推进到元素下标的位置。比如当线程A第一次迁移成功后又向前推进，迁移2，3的数据，此时托没有其他线程在帮助迁移，则transferIndex为2。
4. 为什么到8才转成红黑树：因为通常情况下，链表长度很难达到8，但是特殊情况下链表长度为8，哈希表容量又很大，造成链表性能很差的时候，只能采用红黑树提高性能，这是一种应对策略。
## BlockingQueue
- ArrayBlockingQueue(数组阻塞队列，先进先出)，DelayQueue(延迟阻塞队列)，LinkedBlockingQueue(链阻塞队列，先进先出)，PriorityBlockingQueue(具有优先级的阻塞队列)，SynchronousQueue(同步队列)。
- 四组不同的行为方式：(add,remove,element) 抛出异常。(offer,poll,peek) 返回特定值。(put,take) 阻塞。(offer,poll) 超时。
- SynchronousQueue 是一个特殊的队列，它的内部同时只能够容纳单个元素。如果该队列已有一元素的话，试图向队列中插入一个新元素的线程将会阻塞，直到另一个线程将该元素从队列中抽走。同样，如果该队列为空，试图向队列中抽取一个元素的线程将会阻塞，直到另一个线程向队列中插入了一条新的元素。据此，把这个类称作一个队列显然是夸大其词了。它更多像是一个汇合点。
## JUC线程池ThreadPoolExecutor
1. 核心概念：核心线程池大小，最大线程池大小，存活时间单位，存活时间大小，阻塞队列，拒绝策略。
2. 当提交一个新任务到线程池时，具体的执行流程如下：当我们提交任务，线程池会根据corePoolSize大小创建若干任务数量线程执行任务。当任务的数量超过corePoolSize数量，后续的任务将会进入阻塞队列阻塞排队。当阻塞队列也满了之后，那么将会继续创建(maximumPoolSize-corePoolSize)个数量的线程来执行任务，如果任务处理完成，maximumPoolSize-corePoolSize额外创建的线程等待keepAliveTime之后被自动销毁。如果达到maximumPoolSize，阻塞队列还是满的状态，那么将根据不同的拒绝策略对应处理。
3. 拒绝执行策略：AbortPolicy：直接丢弃任务，抛出异常，这是默认策略。CallerRunsPolicy：只用调用者所在的线程来处理任务。DiscardOldestPolicy：丢弃等待队列中最旧的任务，并执行当前任务。DiscardPolicy：直接丢弃任务，也不抛出异常。
### 核心方法
线程池的工作线程通过Woker类实现，在ReentrantLock锁的保证下，把Woker实例插入到HashSet后，并启动Woker中的线程。
从Woker类的构造方法实现可以发现: 线程工厂在创建线程thread时，将Woker实例本身this作为参数传入，当执行start方法启动线程thread时，本质是执行了Worker的runWorker方法。
firstTask执行完成之后，通过getTask方法从阻塞队列中获取等待的任务，如果队列中没有任务，getTask方法会被阻塞并挂起，不会占用cpu资源
1. execute：（1）如果当前线程池中的线程数小于核心线程数，执行addWorker创建新线程执行command任务。（2）否则，当线程池处于Running状态，把提交的任务成功放入阻塞队列中时，double check线程池的状态，如果线程池没有running，成功从阻塞队列中删除任务，执行reject方法处理任务。如果当前线程池处于running状态但是没有线程，创建一个空的线程。（3）往线程池中创建新的线程失败，执行reject策略。
2. addWorker：addWorker主要负责创建新的线程并执行任务，线程池创建新线程执行任务时，需要获取全局锁。
3. runworker：线程启动之后，通过unlock方法释放锁，设置AQS的state为0，表示运行可中断； Worker执行firstTask或从workQueue中获取任务：(1)进行加锁操作，保证thread不被其他线程中断(除非线程池被中断) (2)检查线程池状态，倘若线程池处于中断状态，当前线程将中断。 (3)执行beforeExecute (4)执行任务的run方法 (5)执行afterExecute方法 (6)解锁操作。
### exectue方法中为什么double check线程池的状态
在多线程环境下，线程池的状态时刻在变化，而ctl.get()是非原子操作，很有可能刚获取了线程池状态后线程池状态就改变了。判断是否将command加入workque是线程池之前的状态。倘若没有double check，万一线程池处于非running状态(在多线程环境下很有可能发生)，那么command永远不会执行。
### 几种常见的线程池
- newFixedThreadPool
```java
public static ExecutorService newFixedThreadPool(int nThreads) {
    return new ThreadPoolExecutor(nThreads, nThreads,
                                0L, TimeUnit.MILLISECONDS,
                                new LinkedBlockingQueue<Runnable>());
}
```
线程池里的线程数量达到核心线程数后，即时线程池没有可执行任务，也不会释放线程。FixedThreadPool的工作队列为无界队列，线程池里的线程数量不会超过核心线程数，这导致最大线程数和存活时间是一个无用参数。饱和策略也失效。
- newSingleThreadExecutor:只会用一个线程来执行任务，保证任务的先进先出
```java
public static ExecutorService newSingleThreadExecutor() {
    return new FinalizableDelegatedExecutorService
        (new ThreadPoolExecutor(1, 1,
                                0L, TimeUnit.MILLISECONDS,
                                new LinkedBlockingQueue<Runnable>()));
}
```
初始化的线程池只有一个线程，该线程异常结束，会重新创建一个新的线程继续执行任务，唯一的线程可以保证所提交任务的顺序执行。由于使用无界队列，饱和策略失效。
- newCachedThreadPool：可灵活的回收线程，超过60秒就会自动回收。
```java
public static ExecutorService newCachedThreadPool() {
    return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                    60L, TimeUnit.SECONDS,
                                    new SynchronousQueue<Runnable>());
}
```
线程池的线程数可达到Integer.MAX_VALUE，即2147483647，内部使用SynchronousQueue作为阻塞队列。
### 关闭线程池
- shutdown()：中断所有没有正在执行任务的线程，线程池中的线程状态设置为SHUTDOWN状态。
- shutdownnow()：线程池里的线程状态设置为STOP状态，然后停止所有正在执行或暂停任务的线程。
## 线程工具类，CountDownLatch，CyclicBarrier，Semaphore
1. CountDownLatch 是一个线程等待其他线程， CyclicBarrier 是多个线程互相等待。
2. CountDownLatch 的计数是减 1 直到 0，CyclicBarrier 是加 1，直到指定值。
3. CountDownLatch 是一次性的， CyclicBarrier  可以循环利用。
4. CyclicBarrier 可以在最后一个线程达到屏障之前，选择先执行一个操作。
5. Semaphore ，需要拿到许可才能执行，并可以选择公平和非公平模式
## ThreadLocal
1. ThreadLocal可以理解为线程本地变量，他会在每个线程都创建一个副本，那么在线程之间访问内部副本变量就行了，做到了线程之间互相隔离，相比于synchronized的做法是用空间来换时间。**ThreadLocal有一个静态内部类ThreadLocalMap**，ThreadLocalMap又包含了一个Entry数组，Entry本身是一个弱引用，他的key是指向ThreadLocal的弱引用，Entry具备了保存key value键值对的能力。
2. 弱引用的目的是为了防止内存泄露，如果是强引用那么ThreadLocal对象除非线程结束否则始终无法被回收，弱引用则会在下一次GC的时候被回收。但是这样还是会存在内存泄露的问题，假如key和ThreadLocal对象被回收之后，entry中就存在key为null，但是value有值的entry对象，但是永远没办法被访问到，同样除非线程结束运行。但是只要ThreadLocal使用恰当，在使用完之后调用remove方法删除Entry对象，实际上是不会出现这个问题的。
3. 清理过期entry的方法，探测式清理和启发式清理。
- 应用场景：数据库管理，SimpleDateFormat，每个线程内保存类似于全局变量的信息，可以让不同方法直接使用，避免参数传递的麻烦，却不想被多线程共享。全局存储用户信息。
