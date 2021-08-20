# ThreadLocal

### ThreadLocal简介
- ThreadLocal是一个将在多线程中为每一个线程创建单独的变量副本的类；当使用ThreadLocal来维护变量副本的时候，ThreadLocal会为每个线程创建单独的变量副本，避免因为多线程操作共享变量导致数据不一致的情况。

每个线程Thread都维护了自己的threadLocals变量，所以在每个线程创建ThreadLocal的时候，实际上数据是存在自己的线程Thread的threadLocals变量里面的，别人是拿不到的，从而实现了线程隔离。

### ThreadLocal的数据结构
```java
static class ThreadLocalMap {

	static class Entry extends WeakReference<ThreadLocal<?>> {
		/** The value associated with this ThreadLocal. */
		Object value;

		Entry(ThreadLocal<?> k, Object v) {
			super(k);
			value = v;
		}
	}
}    
```
开发过程中一个线程可以有多个ThreadLocal来存放不同类型的对象的，但是他们都将放到你当前线程的ThreadLocalMap里，要用数组来存。
### GC之后key是否为null
如果key有被强引用类型引用，那么GC之后key不为null，如果没有被强引用类型引用，那么GC之后为key为null
### ThreadLocl的replaceStaleEntry
- 替换过期数据
1. 当在插入数据的向后遍历的过程中，如果遇到了key为null的Entry，说明key被回收掉了，此时位置为staleSlot，触发替换过期数据的逻辑。
2. 在当前位置开始，向前寻找其他的过期数据，直到碰到Entry为null结束。这样的操作是为了更新探测清理过期数据的起始下标(slotToExpunge)。
3. 在当前位置开始，向后寻找key相等的Entry元素，(1)找到后更新Entry的值，并交换staleSlot元素的位置，更新Entry数据，然后开始过期Entry的清理工作。(2)如果没有找到key相等的Entry，直到Entry为null才停止寻找，此时table中没有相等的Entry，在null位置创建Entry，并与staleSlot元素的位置交换，然后开始过期Entry的清理工作。
### ThreadLocal的探测式清理(expungeStaleEntry)
1. 在探测清理过期数据的起始下标slotToExpunge位置开始，如果碰到key为null的Entry，将Entry置为空，如果碰到正常的Entry，rehash当前Entry，如果rehash后的位置上有Entry，则放到后面最近的位置。
2. 直到碰到空的slot，停止探测。
### ThreadLocal的启发式清理(cleanSomeSlots)

### ThreadLocal的hash冲突

### ThreadLocal的扩容机制
- 先探测式清理，如果清理后的大小大于等于阈值的3/4，进行扩容操作。
### ThreadLocal的set()

### ThreadLocal的get()

### ThreadLocal的InteritableThreadLocal
```java
private void test() {    
final ThreadLocal threadLocal = new InheritableThreadLocal();       
threadLocal.set("帅得一匹");    
Thread t = new Thread() {        
    @Override        
    public void run() {            
      super.run();            
      Log.i( "张三帅么 =" + threadLocal.get());        
    }    
  };          
  t.start(); 
}
```
在父线程中设置InheritableThreadLocal，子线程也可以访问到值
子线程在初始化的时候会先读取父线程的InheritableThreadLocal，将里面的值存在自己的ThreadLocal中。
### 为什么ThreadLocal会造成内存泄露? 如何解决

### ThreadLocal的应用场景
1. 每个线程维护一个序列号
2. Session的管理