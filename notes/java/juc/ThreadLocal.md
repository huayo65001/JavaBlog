# ThreadLocal

### ThreadLocal简介
- ThreadLocal是一个将在多线程中为每一个线程创建单独的变量副本的类；当使用ThreadLocal来维护变量副本的时候，ThreadLocal会为每个线程创建单独的变量副本，避免因为多线程操作共享变量导致数据不一致的情况。

### ThreadLocal的数据结构

### GC之后key是否为null

### ThreadLocl的replaceStaleEntry

### ThreadLocal的探测式清理(expungeStaleEntry)

### ThreadLocal的启发式清理(cleanSomeSlots)

### ThreadLocal的hash冲突

### ThreadLocal的扩容机制

### ThreadLocal的set()

### ThreadLocal的get()

### ThreadLocal的InteritableThreadLocal

### 为什么ThreadLocal会造成内存泄露? 如何解决

### ThreadLocal的应用场景