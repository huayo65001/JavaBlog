# Kafka

<!--ts-->
- [Kafka](#kafka)
    - [Kafka的简介](#kafka的简介)
    - [使用消息队列的好处](#使用消息队列的好处)
    - [消息队列的两种模式](#消息队列的两种模式)
    - [Kafka架构](#kafka架构)
    - [Kafka的特点](#kafka的特点)
    - [Kafka和其他消息队列的区别](#kafka和其他消息队列的区别)
    - [Kafka中Zookeeper的作用](#kafka中zookeeper的作用)
      - [为什么Kafka的offset放到了Kafka的名为__consumer_offsets 的Topic中?](#为什么kafka的offset放到了kafka的名为__consumer_offsets-的topic中)
    - [Kafka分区的目的](#kafka分区的目的)
    - [Kafka分区的partition个数设置为多少合适？](#kafka分区的partition个数设置为多少合适)
    - [Kafka如何做到消息的有序性？](#kafka如何做到消息的有序性)
    - [Kafka中leader分区的选举机制](#kafka中leader分区的选举机制)
    - [OffSet的作用](#offset的作用)
    - [Kafka的高可靠性是怎么保证的？](#kafka的高可靠性是怎么保证的)
    - [Kafka的数据一致性原理](#kafka的数据一致性原理)
    - [Kafka在什么情况下会出现消息丢失？](#kafka在什么情况下会出现消息丢失)
    - [Kafka数据传输的事务有几种？](#kafka数据传输的事务有几种)
      - [事务的详细解释](#事务的详细解释)
    - [Kakfa高效文件存储设计特点](#kakfa高效文件存储设计特点)
    - [Kafka的rebalance](#kafka的rebalance)
    - [Kafka为什么这么快？（高吞吐量）](#kafka为什么这么快高吞吐量)

<!-- Added by: hanzhigang, at: 2021年 8月17日 星期二 13时51分36秒 CST -->

<!--te-->

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
- 发布/订阅模式：推/拉 Kafka基于拉取的发布/订阅模式，消费者的消费速度可以根据自己来决定。一直维护着长轮询，可能会造成资源的浪费。
### Kafka架构
- Topic：Producer将消息发送到特定的Topic，consumer通过订阅这个Topic来消费消息。
- Partition：Partition是Topic的一部分，一个Topic可以有多个Partition，同一Topic下的Partition可以分布在不同的Broker中。
- Producer：消费消息的一方
- Consumer：生产消息的一方
- ConsumerGroup：一个partition只能被消费者组里的一个消费者消费。
- Broker：可以看做是一个kafka实例，多个kafka broker组成一个kafka cluster。
- Offset：记录Consumer对Partition中消息的消费进度。

### Kafka的特点
1. 高吞吐量、低延迟：kafka每秒可以处理几十万条消息，它的延迟最低只有几毫秒，每个主题可以 分多个分区, 消费组对分区进行消费操作；
2. 可扩展性：kafka集群支持热扩展；
3. 持久性、可靠性：消息被持久化到本地磁盘，并且支持数据备份防止数据丢失；
4. 容错性：允许集群中节点失败（若副本数量为n,则允许n-1个节点失败）；
5. 高并发：支持数千个客户端同时读写；


### Kafka和其他消息队列的区别


### Kafka中Zookeeper的作用
主要为Kafka提供元数据的管理功能。
1. Broker注册：Kafka会将该Broker信息存入其中，Broker在Zookeeper中创建的是临时节点，一旦Broker故障下线，Zookeeper就会将该节点删除。同时可以基于Watcher机制监听该节点，当节点删除后做出相应反应。
2. Topic注册：所有Broker和Topic的对应关系都由Zookeeper来维护。`/brokers/topics/{topicname}`。还完成Topic中leader的选举。
3. Consumer的注册和负载均衡：①Consumer Group的注册`/consumers/{group_id}`。在其目录下有三个子目录。ids：一个Consumer Group有多个Consumer，ids用来记录这些Consumer。owners：记录该用户组可消费的Topic信息。offsets：记录owners中每个Topic的所有Partition的所有OffSet。②Consumer的注册：注册的是临时节点(`/consumers/{group_id}/ids/{consumer_id}`)。③负载均衡：一个Consumer Group下有多个Consumer，怎么去均匀的消费订阅消息。由Zookeeper来维护。
4. Producer的负载均衡：
5. 维护Partition和Consumer的关系：同一个Consumer Group订阅的任一个Partition都只能分配给一个Consumer，Partition和Consumer的对应关系路径：`/consumer/{group_id}/owners/{topic}/{broker_id-partition_id}`，该路径下的内容是该消息分区消费者的Consumer ID。这个路径也是一个临时节点，在Rebalance时会被删除。
6. 记录消息消费的进度：在2.0版本中不再记录在Zookeeper中，而是记录在Kafka的Topic中。
#### 为什么Kafka的offset放到了Kafka的名为__consumer_offsets 的Topic中?
Kafka其实存在一个比较大的隐患，就是利用Zookeeper来存储记录每个消费者/消费者组的消费进度，虽然在使用过程中JVM帮助我们完成了一些优化，但是消费者需要频繁的去与Zookeeper进行交互，而ZKClient的API操作Zookeeper频繁的Write其本身是一个比较低效的action，对于后期水平扩展也是一个比较头疼的问题。如果期间Zookeeper集群发生了变化，那Kafka集群的吞吐量也跟着受影响。

### Kafka分区的目的
实现负载均衡，分区对于消费者来说，可以提高并发度，提高效率
### Kafka分区的partition个数设置为多少合适？ 
### Kafka如何做到消息的有序性？
kafka中每个partition的写入是有序的，而且单个partition只能由一个消费者消费，可以保证里面的消息的顺序性，但是分区之间的消息是不保证有序的。
### Kafka中leader分区的选举机制
- kafka在所有broker中选出一个controller，所有partition的leader的选举都由controller决定。controller会将leader的改变直接通过rpc的方式通知需要为此做出反应的broker。同时controller也负责增删topic以及replica的重新分配。
1. controller在zookeeper注册watch，一旦有broker宕机，在zk中的节点会被删除。controller读取最新的幸存的broker。
2. controller决定set_p，该集合包含了宕机的broker上的所有partition。
3. 对set_p中的每一个partition，读取该partition当前的ISR。决定该partition的新leader。如果当前ISR中有至少一个Replica还幸存，则选择其中一个作为新的leader，新的ISR包含当前ISR中所有幸存的Replica。否则选择该partition中任意一个幸存的replica作为新的leader以及ISR。如果该partition的所有replica都宕机了，则将新的leader设置为-1。
4. 将新的leader，ISR和新的leader_epoch以及controller_epoch写入目录下。
5. 直接通过RPC向set_p相关的broker发送leaderandisrrequest命令。controller可以在一个rpc操作中发送多个命令从而提升效率。

- leaderandisrrequest响应过程：①若请求中的controller epoch小于最新的controller epoch，则直接返回stalecontrollerepochcode。②对于请求中partitionStateInfos中的每一个元素，若partitionStateInfo的leader epoch小于当前replicmanager中存储的leader epoch，返回staleleaderepochcode。否则如果当前brokerid在partitionstateinfo中，则将该partition及partition存入一个名为partitionState的Map中。③筛选出partitionState中leader与当前broker id相等的所有记录存入partitionsTobeleader中，其他记录存入partitionstobefollower中。④如果partitiontobeleader不为空，对其执行makeleaders方法。⑤如果partitiontobefollower不为空，对其执行makefollowers方法。⑥若高水位线程还未启动，将其启动，并将hwThreadInitialized设为true。⑦关闭所有idle状态的fetcher。

### OffSet的作用
kafka是顺序读写，具备很好的吞吐量。实现原理是
- 每次生产消息时，都是往对应partition的文件中追加写入，而消息的被读取状态是由consumer来维护的。所以每个partition中offset一般都是连续递增的（如果开启了压缩，因为对旧数据的merge会导致不连续）
- 被读取的消息并不会删除，所以每次都是追加写入顺序读写，具备很好的吞吐量。
- 实现过程是 consumer在消费消息后，向broker中有个专门维护每个consumer的offset的topic生产一条消息，记录自己当前已读的消息的offset+1的值作为新的offset的消息。当然在旧版本的实现是在zookeeper上有个节点存放这个offset，当时后面考虑性能问题，kafka改到了topic里，同时可以自由配置使用zookeeper还是使用topic。


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
- 因为网络原因，副本的复制速度可能有所不同，所以kafka只支持读取HW之上的所有数据。
### Kafka在什么情况下会出现消息丢失？
如果leader崩溃，另一个副本称为新的leader，那么leader新写的那些消息就可能丢失了。如果我们允许消费者去读取这些消息，可能就破坏了消息的一致性。试想：一个消费者从当前leader读取并处理了message4，这个时候leader挂掉了，选举了新的leader，这个时候另一个消费者在新的leader读取消息，发现这个消息其实并不存在，就造成了数据不一致性。
### Kafka数据传输的事务有几种？
- 最多一次：消息不会被重复发送，最多被传输一次，但也有可能一次不传输
- 最少一次：消息不会被漏发送，消息至少被传输一次，但也有可能被重复发送。
- 精确一次：不会被漏发送也不会被重复发送，消息正好被传输一次。
#### 事务的详细解释
1. 至少一次：(重试，消息可能会被重复被消费)分两种情况：①如果生产者的acks设置为-1或all，并且生产者在发送消息最后也收到了ack，这就意味着消息已经被精确一次写入了Kafka的topic。②如果生产者接收ack超时或者收到了错误，它就会认为消息没有写入Kafka的topic，然后会尝试重新发送消息。③如果broker恰好在消息已经成功写入Kafka的topic，但是在发送ack前发送了故障，那么生产者的重试机制就会导致这条消息被写入Kafka两次。
2. 至多一次：如果生产者在ack超时或返回错误的时候不重试发送消息。那么消息有可能最终并没有写入Kafka的topic中。这样就可能出现消息并没有被消费者消费的消息。
3. 精确一次：生产者有重试机制，且发送的消息只会被消费一次。即时生产者重试发送消息，也只会让消息被发送给消费者一次。
### Kakfa高效文件存储设计特点
- Kafka把topic中一个partition大文件分成多个小文件，通过多个小文件段，就容易定期清除或删除已经消费完文件，减少磁盘占用
- 通过索引信息可以快速定位message和确定response大小
- 通过index元数据全部映射到memory，可以避免segment file的io操作。
- 通过索引文件稀疏存储，可以大幅度降低index文件元数据占用空间大小。
### Kafka的rebalance
在kafka中，当有新的消费者加入或者订阅的topic数发生变化，会触发rebalance。重新均衡消费者消费。
1. 所有成员向coordinator发送请求，请求入组。一旦所有成员都发送了请求，coordinator会从中选择一个作为leader，并把组成员信息和订阅信息发给leader。
2. leader开始分配消费方案，指定哪个consumer负责消费哪些topic的partition。一旦分配完成，leader将这个方案发送给coordinator。coordinator收到方案后，发送给每个consumer，这样组内每个消费者都能知道自己消费哪个topic的哪个分区了。
### Kafka为什么这么快？（高吞吐量）
1. 顺序写入：不断追加到文件中，这个特性可以让kafka充分利用磁盘的顺序读写性能。顺序读写不需要硬盘磁头的寻道时间，只需要很少的磁盘旋转时间，所以速度远快于随机读写。
2. Memory Mapped Files：直接利用操作系统的page来完成文件到物理内存的映射，完成之后对物理内存的操作会直接同步到磁盘。通过内存映射的方式会大大提高IO效率，省去了用户空间到内核空间的复制。
3. 零拷贝sendfile
4. 分区：kafka中的topic中的内容可以被分为多个partition，每个partition又分为多个segment，每次操作都是对一小部分做操作，很轻便，同时增加了并行操作的能力。
5. 批量发送：producer发送消息的时候，可以将消息缓存到本地，等到固定条件发送到kafka中。
6. 数据压缩：减少传输的数据量，减轻对网络传输的压力。
7. 高效的网络模型，Reactor。
