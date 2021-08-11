# JUC集合

## ConcurrentHashMap
### 1.7
由一个个Segment组成，ConcurrentHashMap是一个Segment数组。每个Segment类似于HashMap结构
默认Segment是16，Segment个数被初始化后不能被更改，可以理解为并发级别为Segment的个数
#### 初始化
1. 必要的参数校验
2. 检验并发级别的大小
3. 。。。
4. 初始化segment[0]，默认大小为2，负载因子为0.75，扩容阈值为2 * 0.75 = 1.5， 插入第二个值才开始扩容

#### put()
1. 必要的参数校验。
2. 计算`key`的hash值，然后定位key在Segment数组中的位置。
3. 如果对应位置的Segment没有初始化，调用`ensureSegment()`，初始化Segment。
4. 调用`put(K key, int hash, V value, boolean onlyIfAbsent)`。

#### put(K key, int hash, V value, boolean onlyIfAbsent)
1. 使用ReentrantLock来获取锁，获取不到的话调用`scanAndLockForPut()`来获取。
2. 计算在`HashEntry`数组中要put的位置，也就是找到`K`在`HashEntry`数组的第几个位置上，使用了在HashMap中查找数组位置的方法。
3. CAS获取对应数组位置上的`HashEntry`，并对`HashEntry`进行遍历。
4. 在遍历过程中，判断`key`是否存在，如果存在则替换链表中的节点。遍历完链表后没有找到`key`相同的节点，则进行插入操作。如果当前需要插入的节点已经被初始化，直接进行头插法。如果没有被初始化，进行初始化并头插法。
5. 如果插入后需要扩容，则调用`rehash()`，来进行数组的扩容。不需要扩容的化直接将当前整个链表插入数组位置上。
6. 如果插入节点之前存在，替换后则返回旧值，否则返回null。

#### ensureSegment()
1. 计算`key`在Segment数组中的位置，判断对应位置的Segment是否已经被初始化。
2. 如果没有被初始化，记录第一个Segment的初始长度，负载因子，扩容阈值，创建一个对应的`HashEntry`。
3. 再次判断对应位置的Segment是否已经被初始化。
4. 使用创建的`HashEntry`来初始化这个Segment。
5. 自旋判断计算得到的指定位置的Segment是否为null，使用CAS在这个位置上为Segment赋值。

#### scanAndLockForPut()
- 做的操作是不断地自旋`tryLock()`获取锁，当自旋次数大于指定次数时，使用`lock()`阻塞获取锁。在自旋时一直获取`hash`位置下的`HashEntry`。

#### rehash()
- 扩容
1. 计算新的表的容量、阈值，创建新的数组。
2. 遍历老的数组，计算新的位置，新的位置只能是老的位置或者老的位置加上老的容量。
3. 如果当前位置不是链表，只有一个节点，直接赋值。
4. 否则，for循环寻找后面的元素都是相同的节点，将这段节点直接赋给新的链表。
5. 再次for循环，遍历剩余元素，头插到k位置。
6. 然后将新的节点头插到数组中。

#### get()
```java
public V get(Object key) {
    Segment<K,V> s; // manually integrate access methods to reduce overhead
    HashEntry<K,V>[] tab;
    // 1. hash 值
    int h = hash(key);
    long u = (((h >>> segmentShift) & segmentMask) << SSHIFT) + SBASE;
    // 2. 根据 hash 找到对应的 segment
    if ((s = (Segment<K,V>)UNSAFE.getObjectVolatile(segments, u)) != null &&
        (tab = s.table) != null) {
        // 3. 找到segment 内部数组相应位置的链表，遍历
        for (HashEntry<K,V> e = (HashEntry<K,V>) UNSAFE.getObjectVolatile
                 (tab, ((long)(((tab.length - 1) & h)) << TSHIFT) + TBASE);
             e != null; e = e.next) {
            K k;
            if ((k = e.key) == key || (e.hash == h && key.equals(k)))
                return e.value;
        }
    }
    return null;
}
```
### 1.8
- 采用了数组+节点+链表的数据结构
#### 初始化
- 关键字：sizeCtl：（1）-1 表示正在进行初始化，（2）-N说明有`N-1`个线程正在扩容，（3）如果table没有初始化，表示table的初始化大小，（4）如果table已经初始化，表示table容量

1. 循环判断`自旋`，对于数组为空并且数组长度为0，进行初始化。
2. 如果sizeCtl小于0，说明其他线程执行`CAS`成功，正在进行初始化。
3. 否则，`CAS`获取，获取成功后，再次判断数组是否为空并且数组长度为0。
4. 初始化数组，并重新设置sizeCtl。

```java
private final Node<K,V>[] initTable() {
    Node<K,V>[] tab; int sc;
    while ((tab = table) == null || tab.length == 0) {
        // 初始化的"功劳"被其他线程"抢去"了
        if ((sc = sizeCtl) < 0)
            Thread.yield(); // lost initialization race; just spin
        // CAS 一下，将 sizeCtl 设置为 -1，代表抢到了锁
        else if (U.compareAndSwapInt(this, SIZECTL, sc, -1)) {
            try {
                if ((tab = table) == null || tab.length == 0) {
                    // DEFAULT_CAPACITY 默认初始容量是 16
                    int n = (sc > 0) ? sc : DEFAULT_CAPACITY;
                    // 初始化数组，长度为 16 或初始化时提供的长度
                    Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n];
                    // 将这个数组赋值给 table，table 是 volatile 的
                    table = tab = nt;
                    // 如果 n 为 16 的话，那么这里 sc = 12
                    // 其实就是 0.75 * n
                    sc = n - (n >>> 2);
                }
            } finally {
                // 设置 sizeCtl 为 sc，我们就当是 12 吧
                sizeCtl = sc;
            }
            break;
        }
    }
    return tab;
}
```

#### putVal()
```java
public V put(K key, V value) {
    return putVal(key, value, false);
}
final V putVal(K key, V value, boolean onlyIfAbsent) {
    if (key == null || value == null) throw new NullPointerException();
    // 得到 hash 值
    int hash = spread(key.hashCode());
    // 用于记录相应链表的长度
    int binCount = 0;
    for (Node<K,V>[] tab = table;;) {
        Node<K,V> f; int n, i, fh;
        // 如果数组"空"，进行数组初始化
        if (tab == null || (n = tab.length) == 0)
            // 初始化数组，后面会详细介绍
            tab = initTable();

        // 找该 hash 值对应的数组下标，得到第一个节点 f
        else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {
            // 如果数组该位置为空，
            //    用一次 CAS 操作将这个新值放入其中即可，这个 put 操作差不多就结束了，可以拉到最后面了
            //          如果 CAS 失败，那就是有并发操作，进到下一个循环就好了
            if (casTabAt(tab, i, null,
                         new Node<K,V>(hash, key, value, null)))
                break;                   // no lock when adding to empty bin
        }
        // hash 居然可以等于 MOVED，这个需要到后面才能看明白，不过从名字上也能猜到，肯定是因为在扩容
        else if ((fh = f.hash) == MOVED)
            // 帮助数据迁移，这个等到看完数据迁移部分的介绍后，再理解这个就很简单了
            tab = helpTransfer(tab, f);

        else { // 到这里就是说，f 是该位置的头结点，而且不为空

            V oldVal = null;
            // 获取数组该位置的头结点的监视器锁
            synchronized (f) {
                if (tabAt(tab, i) == f) {
                    if (fh >= 0) { // 头结点的 hash 值大于 0，说明是链表
                        // 用于累加，记录链表的长度
                        binCount = 1;
                        // 遍历链表
                        for (Node<K,V> e = f;; ++binCount) {
                            K ek;
                            // 如果发现了"相等"的 key，判断是否要进行值覆盖，然后也就可以 break 了
                            if (e.hash == hash &&
                                ((ek = e.key) == key ||
                                 (ek != null && key.equals(ek)))) {
                                oldVal = e.val;
                                if (!onlyIfAbsent)
                                    e.val = value;
                                break;
                            }
                            // 到了链表的最末端，将这个新值放到链表的最后面
                            Node<K,V> pred = e;
                            if ((e = e.next) == null) {
                                pred.next = new Node<K,V>(hash, key,
                                                          value, null);
                                break;
                            }
                        }
                    }
                    else if (f instanceof TreeBin) { // 红黑树
                        Node<K,V> p;
                        binCount = 2;
                        // 调用红黑树的插值方法插入新节点
                        if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                       value)) != null) {
                            oldVal = p.val;
                            if (!onlyIfAbsent)
                                p.val = value;
                        }
                    }
                }
            }

            if (binCount != 0) {
                // 判断是否要将链表转换为红黑树，临界值和 HashMap 一样，也是 8
                if (binCount >= TREEIFY_THRESHOLD)
                    // 这个方法和 HashMap 中稍微有一点点不同，那就是它不是一定会进行红黑树转换，
                    // 如果当前数组的长度小于 64，那么会选择进行数组扩容，而不是转换为红黑树
                    //    具体源码我们就不看了，扩容部分后面说
                    treeifyBin(tab, i);
                if (oldVal != null)
                    return oldVal;
                break;
            }
        }
    }
    // 
    addCount(1L, binCount);
    return null;
}
```

#### tryPreSize

```java
// 首先要说明的是，方法参数 size 传进来的时候就已经翻了倍了
private final void tryPresize(int size) {
    // c: size 的 1.5 倍，再加 1，再往上取最近的 2 的 n 次方。
    int c = (size >= (MAXIMUM_CAPACITY >>> 1)) ? MAXIMUM_CAPACITY :
        tableSizeFor(size + (size >>> 1) + 1);
    int sc;
    while ((sc = sizeCtl) >= 0) {
        Node<K,V>[] tab = table; int n;

        // 这个 if 分支和之前说的初始化数组的代码基本上是一样的，在这里，我们可以不用管这块代码
        if (tab == null || (n = tab.length) == 0) {
            n = (sc > c) ? sc : c;
            if (U.compareAndSwapInt(this, SIZECTL, sc, -1)) {
                try {
                    if (table == tab) {
                        @SuppressWarnings("unchecked")
                        Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n];
                        table = nt;
                        sc = n - (n >>> 2); // 0.75 * n
                    }
                } finally {
                    sizeCtl = sc;
                }
            }
        }
        else if (c <= sc || n >= MAXIMUM_CAPACITY)
            break;
        else if (tab == table) {
            // 我没看懂 rs 的真正含义是什么，不过也关系不大
            int rs = resizeStamp(n);

            if (sc < 0) {
                Node<K,V>[] nt;
                if ((sc >>> RESIZE_STAMP_SHIFT) != rs || sc == rs + 1 ||
                    sc == rs + MAX_RESIZERS || (nt = nextTable) == null ||
                    transferIndex <= 0)
                    break;
                // 2. 用 CAS 将 sizeCtl 加 1，然后执行 transfer 方法
                //    此时 nextTab 不为 null
                if (U.compareAndSwapInt(this, SIZECTL, sc, sc + 1))
                    transfer(tab, nt);
            }
            // 1. 将 sizeCtl 设置为 (rs << RESIZE_STAMP_SHIFT) + 2)
            //     我是没看懂这个值真正的意义是什么? 不过可以计算出来的是，结果是一个比较大的负数
            //  调用 transfer 方法，此时 nextTab 参数为 null
            else if (U.compareAndSwapInt(this, SIZECTL, sc,
                                         (rs << RESIZE_STAMP_SHIFT) + 2))
                transfer(tab, null);
        }
    }
}
```

#### transfer
<details>
    <summary>transfer源代码</summary>

```java
private final void transfer(Node<K,V>[] tab, Node<K,V>[] nextTab) {
    int n = tab.length, stride;

    // stride 在单核下直接等于 n，多核模式下为 (n>>>3)/NCPU，最小值是 16
    // stride 可以理解为”步长“，有 n 个位置是需要进行迁移的，
    //   将这 n 个任务分为多个任务包，每个任务包有 stride 个任务
    if ((stride = (NCPU > 1) ? (n >>> 3) / NCPU : n) < MIN_TRANSFER_STRIDE)
        stride = MIN_TRANSFER_STRIDE; // subdivide range

    // 如果 nextTab 为 null，先进行一次初始化
    //    前面我们说了，外围会保证第一个发起迁移的线程调用此方法时，参数 nextTab 为 null
    //       之后参与迁移的线程调用此方法时，nextTab 不会为 null
    if (nextTab == null) {
        try {
            // 容量翻倍
            Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n << 1];
            nextTab = nt;
        } catch (Throwable ex) {      // try to cope with OOME
            sizeCtl = Integer.MAX_VALUE;
            return;
        }
        // nextTable 是 ConcurrentHashMap 中的属性
        nextTable = nextTab;
        // transferIndex 也是 ConcurrentHashMap 的属性，用于控制迁移的位置
        transferIndex = n;
    }

    int nextn = nextTab.length;

    // ForwardingNode 翻译过来就是正在被迁移的 Node
    // 这个构造方法会生成一个Node，key、value 和 next 都为 null，关键是 hash 为 MOVED
    // 后面我们会看到，原数组中位置 i 处的节点完成迁移工作后，
    //    就会将位置 i 处设置为这个 ForwardingNode，用来告诉其他线程该位置已经处理过了
    //    所以它其实相当于是一个标志。
    ForwardingNode<K,V> fwd = new ForwardingNode<K,V>(nextTab);


    // advance 指的是做完了一个位置的迁移工作，可以准备做下一个位置的了
    boolean advance = true;
    boolean finishing = false; // to ensure sweep before committing nextTab

    /*
     * 下面这个 for 循环，最难理解的在前面，而要看懂它们，应该先看懂后面的，然后再倒回来看
     * 
     */

    // i 是位置索引，bound 是边界，注意是从后往前
    for (int i = 0, bound = 0;;) {
        Node<K,V> f; int fh;

        // 下面这个 while 真的是不好理解
        // advance 为 true 表示可以进行下一个位置的迁移了
        //   简单理解结局: i 指向了 transferIndex，bound 指向了 transferIndex-stride
        while (advance) {
            int nextIndex, nextBound;
            if (--i >= bound || finishing)
                advance = false;

            // 将 transferIndex 值赋给 nextIndex
            // 这里 transferIndex 一旦小于等于 0，说明原数组的所有位置都有相应的线程去处理了
            else if ((nextIndex = transferIndex) <= 0) {
                i = -1;
                advance = false;
            }
            else if (U.compareAndSwapInt
                     (this, TRANSFERINDEX, nextIndex,
                      nextBound = (nextIndex > stride ?
                                   nextIndex - stride : 0))) {
                // 看括号中的代码，nextBound 是这次迁移任务的边界，注意，是从后往前
                bound = nextBound;
                i = nextIndex - 1;
                advance = false;
            }
        }
        if (i < 0 || i >= n || i + n >= nextn) {
            int sc;
            if (finishing) {
                // 所有的迁移操作已经完成
                nextTable = null;
                // 将新的 nextTab 赋值给 table 属性，完成迁移
                table = nextTab;
                // 重新计算 sizeCtl: n 是原数组长度，所以 sizeCtl 得出的值将是新数组长度的 0.75 倍
                sizeCtl = (n << 1) - (n >>> 1);
                return;
            }

            // 之前我们说过，sizeCtl 在迁移前会设置为 (rs << RESIZE_STAMP_SHIFT) + 2
            // 然后，每有一个线程参与迁移就会将 sizeCtl 加 1，
            // 这里使用 CAS 操作对 sizeCtl 进行减 1，代表做完了属于自己的任务
            if (U.compareAndSwapInt(this, SIZECTL, sc = sizeCtl, sc - 1)) {
                // 任务结束，方法退出
                if ((sc - 2) != resizeStamp(n) << RESIZE_STAMP_SHIFT)
                    return;

                // 到这里，说明 (sc - 2) == resizeStamp(n) << RESIZE_STAMP_SHIFT，
                // 也就是说，所有的迁移任务都做完了，也就会进入到上面的 if(finishing){} 分支了
                finishing = advance = true;
                i = n; // recheck before commit
            }
        }
        // 如果位置 i 处是空的，没有任何节点，那么放入刚刚初始化的 ForwardingNode ”空节点“
        else if ((f = tabAt(tab, i)) == null)
            advance = casTabAt(tab, i, null, fwd);
        // 该位置处是一个 ForwardingNode，代表该位置已经迁移过了
        else if ((fh = f.hash) == MOVED)
            advance = true; // already processed
        else {
            // 对数组该位置处的结点加锁，开始处理数组该位置处的迁移工作
            synchronized (f) {
                if (tabAt(tab, i) == f) {
                    Node<K,V> ln, hn;
                    // 头结点的 hash 大于 0，说明是链表的 Node 节点
                    if (fh >= 0) {
                        // 下面这一块和 Java7 中的 ConcurrentHashMap 迁移是差不多的，
                        // 需要将链表一分为二，
                        //   找到原链表中的 lastRun，然后 lastRun 及其之后的节点是一起进行迁移的
                        //   lastRun 之前的节点需要进行克隆，然后分到两个链表中
                        int runBit = fh & n;
                        Node<K,V> lastRun = f;
                        for (Node<K,V> p = f.next; p != null; p = p.next) {
                            int b = p.hash & n;
                            if (b != runBit) {
                                runBit = b;
                                lastRun = p;
                            }
                        }
                        if (runBit == 0) {
                            ln = lastRun;
                            hn = null;
                        }
                        else {
                            hn = lastRun;
                            ln = null;
                        }
                        for (Node<K,V> p = f; p != lastRun; p = p.next) {
                            int ph = p.hash; K pk = p.key; V pv = p.val;
                            if ((ph & n) == 0)
                                ln = new Node<K,V>(ph, pk, pv, ln);
                            else
                                hn = new Node<K,V>(ph, pk, pv, hn);
                        }
                        // 其中的一个链表放在新数组的位置 i
                        setTabAt(nextTab, i, ln);
                        // 另一个链表放在新数组的位置 i+n
                        setTabAt(nextTab, i + n, hn);
                        // 将原数组该位置处设置为 fwd，代表该位置已经处理完毕，
                        //    其他线程一旦看到该位置的 hash 值为 MOVED，就不会进行迁移了
                        setTabAt(tab, i, fwd);
                        // advance 设置为 true，代表该位置已经迁移完毕
                        advance = true;
                    }
                    else if (f instanceof TreeBin) {
                        // 红黑树的迁移
                        TreeBin<K,V> t = (TreeBin<K,V>)f;
                        TreeNode<K,V> lo = null, loTail = null;
                        TreeNode<K,V> hi = null, hiTail = null;
                        int lc = 0, hc = 0;
                        for (Node<K,V> e = t.first; e != null; e = e.next) {
                            int h = e.hash;
                            TreeNode<K,V> p = new TreeNode<K,V>
                                (h, e.key, e.val, null, null);
                            if ((h & n) == 0) {
                                if ((p.prev = loTail) == null)
                                    lo = p;
                                else
                                    loTail.next = p;
                                loTail = p;
                                ++lc;
                            }
                            else {
                                if ((p.prev = hiTail) == null)
                                    hi = p;
                                else
                                    hiTail.next = p;
                                hiTail = p;
                                ++hc;
                            }
                        }
                        // 如果一分为二后，节点数少于 8，那么将红黑树转换回链表
                        ln = (lc <= UNTREEIFY_THRESHOLD) ? untreeify(lo) :
                            (hc != 0) ? new TreeBin<K,V>(lo) : t;
                        hn = (hc <= UNTREEIFY_THRESHOLD) ? untreeify(hi) :
                            (lc != 0) ? new TreeBin<K,V>(hi) : t;

                        // 将 ln 放置在新数组的位置 i
                        setTabAt(nextTab, i, ln);
                        // 将 hn 放置在新数组的位置 i+n
                        setTabAt(nextTab, i + n, hn);
                        // 将原数组该位置处设置为 fwd，代表该位置已经处理完毕，
                        //    其他线程一旦看到该位置的 hash 值为 MOVED，就不会进行迁移了
                        setTabAt(tab, i, fwd);
                        // advance 设置为 true，代表该位置已经迁移完毕
                        advance = true;
                    }
                }
            }
        }
    }
}
```
</details>

### CopyOnWriteArrayList

#### 请先说说非并发集合中Fail-fast机制? 
- `fail-fast`机制是集合中的错误检测机制，通常出现在遍历集合元素的过程中。
- 在进行遍历的时候，会把实时修改次数`modCount`赋给`expectedModCount`。在遍历过程中，如果有其他线程对集合中的元素进行增、删、改操作时，`modCount`会增加，此时`modCount`与`expectedModCount`不一致，就会抛出异常。
- `fail-fast`不会保证遍历过程中真的出现错误，只是尽可能的去抛出异常。
#### 再为什么说ArrayList查询快而增删慢? 
- 数组的查询是对引用地址的访问，不需要遍历。而增加和删除，需要向前或向后移动元素。增加时还可能遇到扩容操作，创建一个新数组，增加length，再把元素放进去。
#### 对比ArrayList说说CopyOnWriteArrayList的增删改查实现原理? COW基于拷贝 
- 增：获取锁，复制当前CopyOnWriteArrayList的快照数组，存放元素，设置数组。释放锁
- 查：复制当前CopyOnWriteArrayList的快照数组，定义为final，在遍历过程中不会出现冲突，遍历。
- 删：获取锁，复制当前CopyOnWriteArrayList的快照数组。如果删除的位置为最后一个，复制除最后一个元素外的数组，设置数组。否则先复制开始到删除位置的数组，再复制删除位置到最后位置的数组，设置数组。释放锁
- 改：获取锁，获得CopyOnWriteArrayList的快照数组，如果更新某个位置的元素与快照数组中某个位置的元素相同，直接设置数组。否则复制数组，更新相应位置的元素，设置数组。
#### 再说下弱一致性的迭代器原理是怎么样的? COWIterator<E>
- final Object[] 数组作为当前CopyOnWriteList数组的快照，对当前数组状态的引用。此数组在迭代器的生存期内不会更改，因此不可能发生冲突，不会抛出多线程修改异常。
#### CopyOnWriteArrayList为什么并发安全且性能比Vector好? 

#### CopyOnWriteArrayList有何缺陷，说说其应用场景?
- 因为是基于对数组的复制，在写操作的时候，复制数组，会消耗内存，内容多的话可能会导致`young gc`或`full gc`。
- 不能用于实时读的情况。虽然是保证最终一致性，但是在读的过程中，对数组的增、改、删是没有感知的，可能读到的数据还是旧的。
- 可以用于读多写少的情况。但是慎用，消耗内存。
### ConcurrentLinkedQueue


### BlockingQueue

#### 什么是BlockingDeque? 
- BlockingDeque 是一个双端队列。当不能够插入元素时，它将阻塞试图插入对象的线程，当不能够读取对象时，它将阻塞试图读取对象的线程。
#### BlockingQueue大家族有哪些? 
- ArrayBlockingQueue, DelayQueue, LinkedBlockingQueue, SynchronousQueue... 
#### BlockingQueue适合用在什么样的场景? 
- BlockingQueue 通常用于一个线程产生对象，另一个线程消耗对象的场景。一个线程会持续的产生对象，并将其插入到队列尾部。当队列中元素满时，会阻塞当前线程，直到另一个线程在队列中取出数据时。另一个线程在队列头取对象，当队列为空时，会阻塞当前线程，直到另一个线程往队列中存放对象。
#### BlockingQueue常用的方法? 
#### BlockingQueue插入方法有哪些? 这些方法(add(o),offer(o),put(o),offer(o, timeout, timeunit))的区别是什么?
- add 如果试图执行的操作无法执行，抛出异常
- offer 如果试图执行的操作无法执行，返回一个特定的值
- put 如果试图执行的操作无法执行，则会发生阻塞，直到能够执行。
- offer 如果试图执行的操作无法执行，则会发生阻塞，直到能够执行。但是等待时间不会超过给定的时间，否则返回一个特定值。
#### BlockingDeque 与BlockingQueue有何关系，请对比下它们的方法? 
#### BlockingDeque适合用在什么样的场景? 
- 在线程既是一个队列的生产者，也是这个队列的消费者，
#### BlockingDeque 与 BlockingQueue实现例子?
- LinkedBlockingQueue
- SynchronousQueue
