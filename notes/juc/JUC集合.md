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
Object key;
int h = hash(key);
long u = (((h >>> segmentShift) & segmentMask) << SSHFIT) + SBASE;
if((s = (Segment<k,v>) UNSAFE.getObjectVolatile(segment, u)) != null && (tab = s.table != null)){
    for(HashEntry<k,v> e = (HashEntry<k,v>) UNSAFE.getObjectVolatile(tab, ((long)(((tab.length - 1) & h)) << TSHFIT) + TBASE); 
    e != null; e = e.next){
        K k;
        if((k = e.key) == key || (e.hash == h && key.equals(k))){
            return e.value;
        }
    }
}
return null;
```
### 1.8
- 采用了数组+节点+链表的数据结构
#### 初始化
- 关键字：sizeCtl：（1）-1 表示正在进行初始化，（2）-N说明有`N-1`个线程正在扩容，（3）如果table没有初始化，表示table的初始化大小，（4）如果table已经初始化，表示table容量

1. 循环判断`自旋`，对于数组为空并且数组长度为0，进行初始化。
2. 如果sizeCtl小于0，说明其他线程执行`CAS`成功，正在进行初始化。
3. 否则，`CAS`获取，获取成功后，再次判断数组是否为空并且数组长度为0。
4. 初始化数组，并重新设置sizeCtl。

#### put()

#### ensureSegment()
#### scanAndLockForPut()
#### rehash()
#### get()

### CopyOnWriteArrayList


### ConcurrentLinkedQueue


### BlockingQueue
