# java集合
<!--ts-->
- [java集合](#java集合)
  - [ArrayList、Vector、LinkedList](#arraylistvectorlinkedlist)
    - [ArrayList的扩容机制](#arraylist的扩容机制)
    - [ArrayList和LinkedList的区别](#arraylist和linkedlist的区别)
    - [ArrayList和Vector的区别，为什么要用ArrayList取代Vector？](#arraylist和vector的区别为什么要用arraylist取代vector)
  - [HashMap、TreeMap、HashTable、LinkHashMap](#hashmaptreemaphashtablelinkhashmap)
    - [HashMap底层实现](#hashmap底层实现)
    - [HashMap的长度为什么是2的幂次方](#hashmap的长度为什么是2的幂次方)
    - [负载因子为什么是0.75？](#负载因子为什么是075)
    - [HashMap和HashTable的区别](#hashmap和hashtable的区别)
    - [LinkHashMap](#linkhashmap)
    - [TreeMap](#treemap)
    - [ConcurrentHashMap 和 Hashtable 的区别](#concurrenthashmap-和-hashtable-的区别)
    - [comparable 和 Comparator的区别](#comparable-和-comparator的区别)
  - [TreeSet](#treeset)

<!-- Added by: hanzhigang, at: 2021年 8月28日 星期六 09时51分09秒 CST -->

<!--te-->
## ArrayList、Vector、LinkedList
### ArrayList的扩容机制
1. 有参构造方法，创建指定容量大小的数组。无参构造方法则是创建默认大小10的数组。
2. `ensureCapacity`，供外部使用，在进行插入的时候，如果每次只插入一个，那么频繁的插入就导致频繁的拷贝，降低性能，为了避免这种情况，在插入之前先调用这个方法，以减少增量重新分配的次数。
3. `ensureCapacityInternal`，得到最小扩容量，调用`ensureExplicitCapacity`来判断是否需要扩容。
4. `ensureExplicitCapacity`，如果最小扩容量比当前数组中的容量大小大，则调用`grow`进行扩容。
5. `grow`，每次扩容进行1.5倍的扩容操作。
6. 在进行第一次插入的时候会进行扩容，因为之前初始化的是一个空的数组，长度为0。
### ArrayList和LinkedList的区别
1. 是否保证线程安全： ArrayList 和 LinkedList 都是不同步的，也就是不保证线程安全；
2. 底层数据结构： Arraylist 底层使用的是 Object 数组；LinkedList 底层使用的是 双向链表 数据结构（JDK1.6之前为循环链表，JDK1.7取消了循环。注意双向链表和双向循环链表的区别.）
3. 插入和删除是否受元素位置的影响： ① ArrayList 采用数组存储，所以插入和删除元素的时间复杂度受元素位置的影响。 比如：执行add(E e)方法的时候， ArrayList 会默认在将指定的元素追加到此列表的末尾，这种情况时间复杂度就是O(1)。但是如果要在指定位置 i 插入和删除元素的话（add(int index, E element)）时间复杂度就为 O(n-i)。因为在进行上述操作的时候集合中第 i 和第 i 个元素之后的(n-i)个元素都要执行向后位/向前移一位的操作。 ② LinkedList 采用链表存储，所以对于add(E e)方法的插入，删除元素时间复杂度不受元素位置的影响，近似 O（1），如果是要在指定位置i插入和删除元素的话（(add(int index, E element)） 时间复杂度近似为o(n))因为需要先移动到指定位置再插入。
4. 是否支持快速随机访问： LinkedList 不支持高效的随机元素访问，而 ArrayList 支持。快速随机访问就是通过元素的序号快速获取元素对象(对应于get(int index)方法)。
5. 内存空间占用： ArrayList的空间浪费主要体现在在list列表的结尾会预留一定的容量空间，而LinkedList的空间花费则体现在它的每一个元素都需要消耗比ArrayList更多的空间（因为要存放直接后继和直接前驱以及数据）。

### ArrayList和Vector的区别，为什么要用ArrayList取代Vector？
1. Vector类的所有方法都是同步的。可以由两个线程安全地访问一个Vector对象、但是一个线程访问Vector的话代码要在同步操作上耗费大量的时间。
2. Arraylist不是同步的，所以在不需要保证线程安全时建议使用Arraylist。
## HashMap、TreeMap、HashTable、LinkHashMap
### HashMap底层实现
JDK1.8 之前HashMap底层是数组和链表 结合在一起使用也就是链表散列。1.8之后通过数组链表和红黑树的结合。HashMap通过key的hashCode 经过扰动函数处理过后得到hash值，然后通过 (n - 1) & hash 判断当前元素存放的位置（这里的 n 指的是数组的长度），如果当前位置存在元素的话，就判断该元素与要存入的元素的 hash 值以及 key 是否相同，如果相同的话，直接覆盖，不相同就通过拉链法解决冲突。
所谓扰动函数指的就是 HashMap 的 hash 方法。使用 hash 方法也就是扰动函数是为了防止一些实现比较差的 hashCode() 方法 扰动函数之后可以减少碰撞。
### HashMap的长度为什么是2的幂次方
取余(%)操作中如果除数是2的幂次则等价于与其除数减一的与(&)操作（也就是说hash%length==hash&(length-1)的前提是length是2的n次方；）。并且 采用二进制位操作&，相对于%能够提高运算效率，这就解释了HashMap的长度为什么是2的幂次方。
### 负载因子为什么是0.75？
负载因子是0.75的时候，空间利用率比较高，而且避免了相当多的Hash冲突，使得底层的链表或者是红黑树的高度比较低，提升了空间效率。
### HashMap和HashTable的区别
1. 线程是否安全： HashMap 是非线程安全的，HashTable 是线程安全的；HashTable 内部的方法基本都经过synchronized 修饰。
2. 效率： 因为线程安全的问题，HashMap 要比 HashTable 效率高一点。
3. 对Null key 和Null value的支持： HashMap 中，null 可以作为键，这样的键只有一个，可以有一个或多个键所对应的值为 null。但是在 HashTable 中 put 进的键值只要有一个 null，直接抛出 NullPointerException。hashmap在put空值时做了特殊处理。这是因为Hashtable使用的是安全失败机制（fail-safe），这种机制会使你此次读到的数据不一定是最新的数据。如果你使用null值，就会使得其无法判断对应的key是不存在还是为空，因为你无法再调用一次contain(key）来对key是否存在进行判断，ConcurrentHashMap同理。
4. 初始容量大小和每次扩充容量大小的不同 ： ①创建时如果不指定容量初始值，**Hashtable 默认的初始大小为11，之后每次扩充，容量变为原来的2n+1。HashMap 默认的初始化大小为16。之后每次扩充，容量变为原来的2倍。②创建时如果给定了容量初始值，那么 Hashtable 会直接使用你给定的大小，而 HashMap 会将其扩充为2的幂次方大小（HashMap 中的tableSizeFor()方法保证）**。也就是说 HashMap 总是使用2的幂作为哈希表的大小。
5. 底层数据结构： JDK1.8 以后的 HashMap 在解决哈希冲突时有了较大的变化，当链表长度大于阈值（默认为8）时，将链表转化为红黑树，以减少搜索时间。Hashtable 没有这样的机制
### LinkHashMap
LinkedHashMap拥有HashMap的所有特性，它比HashMap多维护了一个双向链表，因此可以按照插入的顺序从头部或者从尾部迭代，是有序的，不过因为比HashMap多维护了一个双向链表，它的内存相比而言要比 HashMap 大，并且性能会差一些。
### TreeMap
底层实现红黑树，继承Map接口，不允许出现重复的key，可以插入null键，null值，可以对元素进行排序。
### ConcurrentHashMap 和 Hashtable 的区别
1. 底层数据结构： JDK1.7的 ConcurrentHashMap 底层采用 分段的数组+链表 实现，JDK1.8 采用的数据结构跟HashMap1.8的结构一样，数组+链表/红黑二叉树。Hashtable 和 JDK1.8 之前的 HashMap 的底层数据结构类似都是采用 数组+链表 的形式，数组是 HashMap 的主体，链表则是主要为了解决哈希冲突而存在的；
2. 实现线程安全的方式（重要）： ① 在JDK1.7的时候，ConcurrentHashMap（分段锁） 对整个桶数组进行了分割分段(Segment)，每一把锁只锁容器其中一部分数据，多线程访问容器里不同数据段的数据，就不会存在锁竞争，提高并发访问率。 到了 JDK1.8 的时候已经摒弃了Segment的概念，而是直接用 Node 数组+链表+红黑树的数据结构来实现，并发控制使用 synchronized 和 CAS 来操作。② Hashtable(同一把锁) :使用 synchronized 来保证线程安全，效率非常低下。当一个线程访问同步方法时，其他线程也访问同步方法，可能会进入阻塞或轮询状态，如使用 put 添加元素，另一个线程不能使用 put 添加元素，也不能使用 get，竞争会越来越激烈效率越低。
### comparable 和 Comparator的区别
- comparable接口实际上是出自java.lang包 它有一个 compareTo(Object obj)方法用来排序。
- comparator接口实际上是出自 java.util 包它有一个compare(Object obj1, Object obj2)方法用来排序。
一般我们需要对一个集合使用自定义排序时，我们就要重写compareTo()方法或compare()方法，当我们需要对某一个集合实现两种排序方式，比如一个song对象中的歌名和歌手名分别采用一种排序方法的话，我们可以重写compareTo()方法和使用自制的Comparator方法或者以两个Comparator来实现歌名排序和歌星名排序，第二种代表我们只能使用两个参数版的 Collections.sort()。
## TreeSet
TreeSet对TreeMap做了一层包装，也就是说TreeSet里面有一个TreeMap(适配器模式)。
