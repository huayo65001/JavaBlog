# JUC集合


## ConcurrentHashMap
### 1.7
由一个个Segment组成，ConcurrentHashMap是一个Segment数组。每个Segment类似于HashMap结构
默认Segment是16，Segment个数被初始化后不能被更改，可以理解为并发级别为Segment的个数
#### 初始化

#### put()



#### ensureSegment()
#### scanAndLockForPut()
#### rehash()
#### get()
### 1.8
#### 初始化
#### put()

#### ensureSegment()
#### scanAndLockForPut()
#### rehash()
#### get()

### CopyOnWriteArrayList


### ConcurrentLinkedQueue


### BlockingQueue
