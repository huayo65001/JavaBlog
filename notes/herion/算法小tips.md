# 算法小tips

### 算法中常用的东西

##### 1.数据结构

```java
//数组
List<Integer> list = new ArrayList<>();
//链表
List<Integer> list = new LinkedList<>();
//栈
Deque<Integer> stack = new LinkedList<>();
//队列
Deque<Integer> queue = new LinkedList<>();
//HashMap
Map<Integer, Integer> map = new HashMap<>();
//遍历有序的HashMap
Map<Integer, Integer> map = new LinkedHashMap<>();
//遍历
Iterator<Map.Entry<Integer, Integer>> iterator = map.entrySet().iterator();
while (iterator.hasNext()) {
    Map.Entry<Integer, Integer> entry = iterator.next();
}
//HashSet
Set<Integer> set = new HashSet<>();
//遍历有序的HashSet
Set<Integer> set = new LinkedHashSet<>();
//优先队列
PriorityQueue<Integer> queue = new PriorityQueue<>();
//优先队列修改比较方式
//匿名内部类
PriorityQueue<Integer> queue = new PriorityQueue<>(10, new Comparator<Integer>() {
    @Override
    //o1是当前插入的元素，o2是父结点
    public int compare(Integer o1, Integer o2) {
        return 0; //返回-1时o1向上交换
    }
});
PriorityQueue<Integer> queue = new PriorityQueue<>(10, ((o1, o2) -> o1 - o2));
```



### 1.找一个消失的数/成对数中的单独的数

异或运算，相同的数抵消，最后剩下一个单独的数。

### 2.topK问题

PriorityQueue；快速排序。

### 3.等差数列求和公式

$$
S=\frac{(首项+尾项)\times项数}{2}
$$

