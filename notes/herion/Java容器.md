[TOC]

### 1.list、set、map区别

list：有序，可重复。

set：无序，不可重复。

map：使用键值对存储，key无序，不可重复，value无序，可重复。每个key最多映射到一个value。

### 2.选用集合

1.需要用键值获取元素值就用map，需要排序用TreeMap，不需要用HashMap，需要保证线程安全用ConcurrentHashMap。

2.只需要存元素值就用实现Collection接口的集合，保证元素唯一就用HashSet，TreeSet，不需要唯一就用List下的ArrryList，LinkedList。

### 3.为何使用集合

当需要存储相同类型的数据时，需要使用一个容器，就是数组。但是数组有些缺点：有序可重复，特点单一，一旦声明长度不可变。

集合长度可变，根据有无序，可否重复选择合适的集合，提高存储数据的灵活性。

### 4.ArrayList、Vector、LinkedList

##### 1.ArrayList

List接口的主要实现类，底层实现是Object数组，线程不安全，支持快速随机访问。添加删除时间复杂度O(1),在指定位置添加删除时间复杂度O(n-i)。

**扩容：**默认大小为10。扩容后大小为默认大小的1.5倍（10 + 10 >> 1(10 / 2)）

##### 2.LinkedList

底层实现是双向链表，不支持高效的快速随机访问。添加删除时间复杂度O(1),在指定位置添加删除时间复杂度O(n)。线程不安全。内存占用大，需要存储前驱、后继、数据。

##### 3.Vector

List接口的古老实现类，线程安全，底层是Object数组。

### 5.RandomAccess接口

接口内没有任何实现，作为一个标识，表示实现这个接口的类具有随机访问功能。

### 6.HashSet、LinkedHashSet、TreeSet

##### 1.HashSet

set接口的主要实现类，底层实现是HashMap，线程不安全，可以存储null。

##### 2.LinkedHashMap

HashSet的子类，可以按添加的顺序遍历，增加了双向链表。

##### 3.TreeSet

底层实现是红黑树，可以按添加的顺序遍历。

### 7.HashMap、Hashtable

##### 1.线程安全

HashMap线程不安全，Hashtable线程安全，内部方法用Synchronized修饰。

##### 2.效率

因为Hashtable线程安全，效率不如HashMap高。

##### 3.null

HashMap的key、value支持null，null作为key只能有一个，value可以有多个，Hashtable不支持null。

##### 4.初始容量及扩充

Hashtable初始容量为11，扩充后大小为2n+1；HashMap初始容量为16，扩充后为两倍。

给定初始值，Hashtable大小为给定值，HashMap大小为2的幂次方。

HashMap：当链表程度大于阈值（链表长度为8）时，如果数组长度小于64，则会扩容数组；如果大于64，则将链表转变为红黑树，减少搜索时间。

**为何是2的幂次方：**hash值范围很大，大约40亿的映射空间，内存存不下，需要对数组的长度取模计算。使用&运算比%运算效率高，所以计算公式是（n-1）&hash，当n是2的幂次方时，（n-1）&hash与（n-1）%hash等价。

##### 5.底层结构

jdk1.7时，HashMap底层结构式分段数组+链表，jdk1.8后底层结构为数组+链表/红黑树。当链表程度大于阈值（链表长度为8）时，如果数组长度小于64，则会扩容数组；如果大于64，则将链表转变为红黑树，减少搜索时间。Hashtable没有这种机制。

### 8.HashMap、HashSet

HashSet底层是HashMap实现的。

HashMap实现了Map接口，HashSet实现了Set接口。

HashMap存储键值对，HashSet存储值。

HashMap用put方法添加键值对，HashSet用add方法添加值。

HashMap使用key计算hashcode，HashSet使用成员对象计算hashcode，两个对象的hashcode可能相等，使用equals方法判断两个对象是否相同。

### 9.TreeMap

继承自AbstractMap，还实现了NavigableMap、SortedMap接口。

NavigableMap接口让TreeMap有集合内元素的搜索能力。

SortedMap接口实现按键排序的功能，默认按key升序排序。

### 10.HashSet检查重复

当加入对象时，先计算hashcode，与已加入对象的hashcode比较，如果不相等，则假设没有重复；如果相等，再调用equals方法来判断是否真的相等，如果相等，则不会加入成功。

两个对象相等，则hashcode一定相同。

两个对象相等，对两个对象equals也返回true。

如果hashcode相同，对象不一定相等。

所以equals重写过，则hashcode必须重写。

### 11.HashMap的7种遍历方式

大体分四类：迭代器（Iterator）遍历、for each遍历、lambda遍历、streams API遍历。

1.迭代器的entrySet遍历方式

2.迭代器的keySet遍历方式

3.for each的entrySet遍历方式

4.for each的keySet遍历方式

5.lambda的遍历方式

6.streams API的单线程遍历方式

7.streams API的多线程遍历方式

keySet在循环时调用了get(key)方法，又遍历了一边map；entrySet将key，value存在了Entry对象里，无需再遍历map，所以性能提高了一倍。

### 12.ConcurrentHashMap

##### 1.jdk1.7及以前

Segment+HashEntry+链表。Segment是可重入锁，大小为16，HshEntry用来保存键值对，链表用来解决冲突。一个ConcurrentHashMap中有一个Segment数组，一个元素包含一个HashEntry数组，每个元素是个链表。每个Segment元素守护一个HashEntry数组，需要修改元素时，需要先获得Segment的锁。

**初始化segment**

检查计算得到的位置的segment是否为null

为null继续初始化，使用segment[0]的容量和负载因子创建一个HashEntry数组

再次检查指定位置的segment是否为null

使用创建的HashEntry数组初始化这个segment

自旋判断计算得到的指定位置的segment是否为null，使用CAS在这个位置赋值。

##### 2.jdk1.8

底层跟HashMap相似，Node数组+链表+红黑树，并发控制用syhchronized+CAS来控制。syhchronized只锁当前链表或红黑树的头结点，只要不冲突，就不会并发。

### 13.HashMap构造方法

1.无参数构造方法

2.包含另一个Map的构造方法

3.指定容量大小的构造方法

4.指定容量大小和加载因子的构造方法

### 14.PriorityQueue

优先队列，默认小顶堆。



自定义排序方式，构造方法内 指定容量 并 new 一个Comparator，并重写compare(o1, o2)方法，o1是当前结点，o2是父结点。当返回-1时，o1要向上移动。

修改成大顶堆：

```java
PriorityQueue<Integer> queue = new PriorityQueue<>(size, new Comparator<Integer>() {
   @Override
    public int compare(Integer o1, Integer o2) {
        if (o1 > o2) return -1;
        else if (o1 == o2) return 0;
        else return 1;
    }
});
```

