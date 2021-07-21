# Kafka
### Kafka的简介
- Kafka是一个分布式的基于发布/订阅模式的消息队列，主要应用于大数据的实时处理领域。
#### 使用消息队列的好处
- 解耦
- 可恢复性
- 缓冲
- 灵活性和峰值处理能力
- 异步通信
#### 消息队列的两种模式
- 点对点模式
- 发布/订阅模式 Kafka基于拉取的发布/订阅模式，消费者的消费速度可以根据自己来决定。一直维护着长轮询，可能会造成资源的浪费。
#### Kafka架构
- 一个消费组内的不同消费者只能消费相同topic的不同的partition。
- (1)zookeeper帮我们Kafka集群存储一些信息.(2)帮助消费者存储消费到的位置信息。0.9版本及之后offset存储到kafka本地磁盘，默认存168个小时。

####