# AQS

### 锁核心类AQS详解
- 什么是AQS ? 为什么它是核心 ?
- AQS的核心思想是什么 ? 它是怎么实现的 ? 底层数据结构等
- AQS有哪些核心的方法 ?
- AQS定义什么样的资源获取方式 ? AQS定义了两种资源获取方式：独占(只有一个线程能访问执行，又根据是否按队列的顺序分为公平锁和非公平锁，如ReentrantLock)和共享(多个线程可同时访问执行，如Semaphore、CountDownLatch、 CyclicBarrier)。ReentrantReadWriteLock可以看成是组合式，允许多个线程同时对某一资源进行读。
- AQS底层使用了什么样的设计模式 ? 模板
- AQS的应用示例 ?

### AQS的核心思想是什么
如果请求的共享资源空闲，那么将请求资源的线程设置为有效工作线程，并将资源设定为锁定状态，如果请求的共享资源被占用，那么设置一套线程阻塞等待以及被唤醒时锁分配的机制，这个机制AQS是基于CLH队列锁实现的，即将暂时获得不到的锁的线程加入到队列中。
> CLH队列是一个虚拟双向队列，即不存在队列实例，仅存在节点之间的关联关系。

### AQS核心方法

#### state
- 使用volatile修饰，保证线程可见性

#### acquire
- 以独占模式获取资源，忽略中断
```java
public final void acquire(int arg) {
    if (!tryAcquire(arg) && acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}

```

#### tryAcquire
- 以独占模式获取资源

#### addWaiter
- 向同步队列添加一个节点
```java
// 添加等待者
private Node addWaiter(Node node) {
    // 新生成一个结点，默认为独占模式
    Node node = new Node(Thread.currentThread(), node);
    // Try the fast path of enq; backup to full enq on failure
    // 保存尾结点
    Node pred = tail;
    if (pred != null) { // 尾结点不为空，即已经被初始化
        // 将node结点的prev域连接到尾结点
        node.prev = pred;
        if (compareAndSetTail(pred, node)) {
            pred.next = node;
            return node;
        }
    }
    enq(node); // 当队列还没有初始化  或者  当compareAndSetTail时，前面有节点在进行操作，导致失败
    return node;
}

```

#### enq
- 如果sync队列还没有初始化，或者在加入尾节点时有节点在操作，则会使用enq插入队列中
```java
private Node enq(final Node node) {
    for (;;) { // 无限循环，确保结点能够成功入队列
        // 保存尾结点
        Node t = tail;
        if (t == null) { // 尾结点为空，即还没被初始化
            if (compareAndSetHead(new Node())) // 头结点为空，并设置头结点为新生成的结点
                tail = head; // 头结点与尾结点都指向同一个新生结点
        } else { // 尾结点不为空，即已经被初始化过
            // 将node结点的prev域连接到尾结点
            node.prev = t;
            if (compareAndSetTail(t, node)) { // 比较结点t是否为尾结点，若是则将尾结点设置为node
                // 设置尾结点的next域为node
                t.next = node;
                return t; // 返回尾结点
            }
        }
    }
}
```

#### acquireQueued
- sync队列中的结点在独占且忽略中断的模式下获取资源， **从后向前找**
```java
// sync队列中的结点在独占且忽略中断的模式下获取(资源)
final boolean acquireQueued(final Node node, int arg) {
    // 标志
    boolean failed = true;
    try {
        // 中断标志
        boolean interrupted = false;
        for (;;) { // 无限循环
            // 获取node节点的前驱结点
            final Node p = node.predecessor();
            // node为刚加入的节点，判断是否可以申请到资源。
            // 如果可以，将当前节点置为头节点，虚节点，当前节点的线程已经获取到资源，不需要在队列中了。
            // interrupted 为false，线程在处于执行状态，为true的话表示线程处于等待状态
            if (p == head && tryAcquire(arg)) {
                setHead(node); // 设置头结点
                p.next = null; // help GC
                failed = false; // 设置标志
                return interrupted;
            }
            // 如果加入的节点前面还有节点或者没有获取到资源
            // 判断在获取失败后是否需要挂起
            if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                interrupted = true;
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}
```

#### shouldParkAfterFailedAcquire
- 当获取资源失败后，检查并且更新结点状态，并将该节点挂起
```java
// 当获取(资源)失败后，检查并且更新结点状态
private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
    // 获取前驱结点的状态
    int ws = pred.waitStatus;
    if (ws == Node.SIGNAL) // 状态为SIGNAL，为-1
        /*
            * This node has already set status asking a release
            * to signal it, so it can safely park.
            */
        // 可以进行park操作
        return true;
    if (ws > 0) { // 表示状态为CANCELLED，为1
        /*
            * Predecessor was cancelled. Skip over predecessors and
            * indicate retry.
            */
        do {
            node.prev = pred = pred.prev;
        } while (pred.waitStatus > 0); // 找到pred结点前面最近的一个状态不为CANCELLED的结点
        // 赋值pred结点的next域
        pred.next = node;
    } else { // 为PROPAGATE -3 或者是0 表示无状态,(为CONDITION -2时，表示此节点在condition queue中)
        /*
            * waitStatus must be 0 or PROPAGATE.  Indicate that we
            * need a signal, but don't park yet.  Caller will need to
            * retry to make sure it cannot acquire before parking.
            */
        // 比较并设置前驱结点的状态为SIGNAL
        compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
    }
    // 不能进行park操作
    return false;
}

```

#### cancelAcquire
- 取消获取资源
```java
// 取消继续获取(资源)
private void cancelAcquire(Node node) {
    // Ignore if node doesn't exist
    // node为空，返回
    if (node == null)
        return;
    // 设置node结点的thread为空
    node.thread = null;

    // Skip cancelled predecessors
    // 保存node的前驱结点
    Node pred = node.prev;
    while (pred.waitStatus > 0) // 找到node前驱结点中第一个状态小于0的结点，即不为CANCELLED状态的结点
        node.prev = pred = pred.prev;

    // predNext is the apparent node to unsplice. CASes below will
    // fail if not, in which case, we lost race vs another cancel
    // or signal, so no further action is necessary.
    // 获取pred结点的下一个结点
    Node predNext = pred.next;

    // Can use unconditional write instead of CAS here.
    // After this atomic step, other Nodes can skip past us.
    // Before, we are free of interference from other threads.
    // 设置node结点的状态为CANCELLED
    node.waitStatus = Node.CANCELLED;

    // If we are the tail, remove ourselves.
    if (node == tail && compareAndSetTail(node, pred)) { // node结点为尾结点，则设置尾结点为pred结点
        // 比较并设置pred结点的next节点为null
        compareAndSetNext(pred, predNext, null); 
    } else { // node结点不为尾结点，或者比较设置不成功
        // If successor needs signal, try to set pred's next-link
        // so it will get one. Otherwise wake it up to propagate.
        int ws;
        if (pred != head &&
            ((ws = pred.waitStatus) == Node.SIGNAL ||
                (ws <= 0 && compareAndSetWaitStatus(pred, ws, Node.SIGNAL))) &&
            pred.thread != null) { // (pred结点不为头结点，并且pred结点的状态为SIGNAL)或者 
                                // pred结点状态小于等于0，并且比较并设置等待状态为SIGNAL成功，并且pred结点所封装的线程不为空
            // 保存结点的后继
            Node next = node.next;
            if (next != null && next.waitStatus <= 0) // 后继不为空并且后继的状态小于等于0
                compareAndSetNext(pred, predNext, next); // 比较并设置pred.next = next;
        } else {
            unparkSuccessor(node); // 释放node的前一个结点
        }

        node.next = node; // help GC
    }
}
```
#### unparkSuccessor
- 释放后继节点
```java
// 释放后继结点
private void unparkSuccessor(Node node) {
    /*
        * If status is negative (i.e., possibly needing signal) try
        * to clear in anticipation of signalling.  It is OK if this
        * fails or if status is changed by waiting thread.
        */
    // 获取node结点的等待状态
    int ws = node.waitStatus;
    if (ws < 0) // 状态值小于0，为SIGNAL -1 或 CONDITION -2 或 PROPAGATE -3
        // 比较并且设置结点等待状态，设置为0
        compareAndSetWaitStatus(node, ws, 0);

    /*
        * Thread to unpark is held in successor, which is normally
        * just the next node.  But if cancelled or apparently null,
        * traverse backwards from tail to find the actual
        * non-cancelled successor.
        */
    // 获取node节点的下一个结点
    Node s = node.next;
    if (s == null || s.waitStatus > 0) { // 下一个结点为空或者下一个节点的等待状态大于0，即为CANCELLED
        // s赋值为空
        s = null; 
        // 从尾结点开始从后往前开始遍历
        for (Node t = tail; t != null && t != node; t = t.prev)
            if (t.waitStatus <= 0) // 找到等待状态小于等于0的结点，找到最前的状态小于等于0的结点
                // 保存结点
                s = t;
    }
    if (s != null) // 该结点不为为空，释放许可
        LockSupport.unpark(s.thread);
}
```
#### release
```java
public final boolean release(int arg) {
    if (tryRelease(arg)) { // 释放成功
        // 保存头结点
        Node h = head;
        if (h != null && h.waitStatus != 0) // 头结点不为空并且头结点状态不为0
            unparkSuccessor(h); //释放头结点的后继结点
        return true;
    }
    return false;
}

```
