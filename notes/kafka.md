# Kafka
### Kafka的简介
- Kafka是一个分布式的基于发布/订阅模式的消息队列，主要应用于大数据的实时处理领域。
### 使用消息队列的好处
- 解耦
- 可恢复性
- 缓冲
- 灵活性和峰值处理能力
- 异步通信
### 消息队列的两种模式
- 点对点模式
- 发布/订阅模式 Kafka基于拉取的发布/订阅模式，消费者的消费速度可以根据自己来决定。一直维护着长轮询，可能会造成资源的浪费。
### Kafka架构
- Topic
- Partition
- Producer
- Consumer
- ConsumerGroup
- Broker
- Offset

### Kafka分区的目的
实现负载均衡，分区对于消费者来说，可以提高并发度，提高效率
### Kafka如何做到消息的有序性？
kafka中每个partition的写入是有序的，而且单个partition只能由一个消费者消费，可以保证里面的消息的顺序性，但是分区之间的消息是不保证有序的。
### Kafka的高可靠性是怎么保证的？
- Topic分区副本
Kafka可以保证单个分区的消息是有序的，分区可以分为在线和离线，众多的分区中只有一个是leader，其他的是follower。所有的读写操作都是通过leader进行的，同时follower会定期去leader上复制数据。当leader挂了之后，follower称为leader。通过分区副本，引入了数据冗余，同时提供了Kafka的数据可靠性。
- Producer向Broker发送消息
为了让用户设置数据可靠性，Kafka在Producer中提供了消息确认机制，可以通过配置来决定消息发送到对应分区的几个副本才算发送成功。三个级别：发送出去就算成功。发送给leader，并把它写入分区数据文件，返回确认或失败。发送出去，并等到同步副本都收到消息才算成功。
### Kafka的数据一致性原理
- ISR：副本能够跟的上leader的进度
- OSR：副本没有跟上leader的进度
- AR：所有的副本
- LEO：当前日志文件的下一条
- HW：高水位
- LSE：对未完成的事务而言，LSO的值等于事务中第一条消息的位置
- 因为网络原因，副本的复制速度可能有所不同，所以afka只支持读取HW只上的所有数据。
### Kafka在什么情况下会出现消息丢失？
如果leader崩溃，另一个副本称为新的leader，那么leader新写的那些消息就可能丢失了。如果我们允许消费者去读取这些消息，可能就破坏了消息的一致性。试想：一个消费者从当前leader读取并处理了message4，这个时候leader挂掉了，选举了新的leader，这个时候另一个消费者在新的leader读取消息，发现这个消息其实并不存在，就造成了数据不一致性。
### Kafka数据传输的事务有几种？
- 最多一次
- 最少一次
- 精确一次
### Kakfa高效文件存储设计特点
- Kafka把topic中一个partition大文件分成多个小文件，通过多个小文件段，就容易定期清除或删除已经消费完文件，减少磁盘占用
- 通过索引信息可以快速定位message和确定response大小
- 通过index元数据全部映射到memory，可以避免segment file的io操作。
- 通过索引文件稀疏存储，可以大幅度降低index文件元数据占用空间大小。
### Kafka的rebalance
在kafka中，当有新的消费者加入或者订阅的topic数发生变化，会触发rebalance。重新均衡消费者消费。
1. 所有成员向coordinator发送请求，请求入组。一旦所有成员都发送了请求，coordinator会从中选择一个作为leader，并把组成员信息和订阅信息发给leader。
2. leader开始分配消费方案，指定哪个consumer负责消费哪些topic的partition。一旦分配完成，leader将这个方案发送给coordinator。coordinator收到方案后，发送给每个consumer，这样组内每个消费者都能直到自己消费哪个topic的哪个分区了。
### Kafka为什么这么快？（高吞吐量）
1. 顺序写入：不断追加到文件中，这个特性可以让kafka充分利用磁盘的顺序读写性能。顺序读写不需要硬盘磁头的寻道时间，只需要很少的磁盘旋转时间，所以速度远快于随机读写。
2. Memory Mapped Files
3. 零拷贝sendfile
4. 分区：kafka中的topic中的内容可以被分为多个partition，每个partition又分为多个segment，每次操作都是对一小部分做操作，很轻便，同时增加了并行操作的能力。
5. 批量发送：producer发送消息的时候，可以将消息缓存到本地，等到固定条件发送到kafka中。
6. 数据压缩：减少传输的数据量，减轻对网络传输的压力。