# Netty

## Netty是什么？
- Netty成功找到了一种在不妥协可维护性和性能的情况下实现易于开发，性能，稳定性和灵活性的方法。
1. Netty是一个基于NIO的CS(客户端-服务端)框架，使用它可以快速简单的开发网络应用框架。
2. 它极大地简化并优化了TCP和UDP套接字服务器等网络编程，并且性能以及安全性等很多方面甚至都要更好。
3. 支持多种协议，如FTP、SMTP、HTTP以及各种二进制和基于文本的传统协议。
## 为什么要用Netty？
- 相比较于直接使用JDK自带的NIO相关的API来说，更加易用，具有下面这些优点：
1. 统一的API，支持多种传输协议，阻塞和非阻塞的
2. 简单且强大的线程模式
3. 自带编码器解决TCP粘包/拆包问题
4. 自带各种协议栈
5. 真正的无连接数据包套接字支持
6. 比直接使用Java核心API有更高的吞吐量、更低的延迟、更低的资源消耗和更少的内存复制。
7. 安全性不错，有完整的SSL/TLS和StartTLS支持。
8. 社区活跃
9. 成熟稳定，经历了大项目的使用和考验，而且很多开源项目都使用到了Netty。

## Netty应用场景
- 主要用作网络通信
- 作为RPC框架的网络通信工具
- 实现一个自己的HTTP服务器
- 实现一个即时通讯系统
- 实现一个消息推送系统
## Netty核心组件有哪些？分别有什么作用？
### Channel
- Channel接口是Netty对网络操作抽象类。
- 比较常用的Channel接口实现类是NioServerSocketChannel(服务端)和NioSocketChannel(客户端)
### EventLoop
- 负责监听网络事件中并调用事件处理器进行相关的I/O操作。
- Channel为Netty网络操作抽象类，EventLoop负责处理注册到上面的Channel处理I/O操作，两者配合参与I/O操作。
### ChannelFuture
- Netty是异步非阻塞的，所有操作都是异步的。因此我们不能立刻知道操作是否执行成功，我们可以通过ChannelFuture接口的addListener方法注册一个ChannelFutureListener，当操作成功或失败时，监听会自动触发并返回结果。
### ChannelHandler、ChannelPipeline
- ChannelHandler是消息的具体处理器，负责读写操作、客户端连接等事情。
- ChannelPipline是ChannelHandler的链，提供一个容器并定义了用于沿着链传播入站和出站事件流的API。
- 一个数据或事件可能会被多个Handler处理，当一个ChannelHander处理完后就将数据交给写一个Handler。
## EventLoopGroup了解么？和EventLoop啥关系？
- EventLoopGroup包含多个EventLoop，BossEventGroup用于接收连接，WorkerEventGroup用于具体的处理(消息的读写以及其他逻辑处理)。
- bossGroup处理客户端连接，当客户端处理完成后，会将这个连接提交给workGroup来处理，然后workGroup负责处理其IO相关操作。


## Bootstrap和ServerBootstrap了解么？
- Bootstrap是客户端的启动引导类/辅助类
- ServerBootstrap是服务端的启动引导类/辅助类
- Bootstrap通常使用connect()方法连接到远程的主机和端口，作为一个Netty TCP协议中通信的客户端。另外Bootstrap也可以绑定一个本地端口作为UDP协议通信中的一端。
- ServerBootstrap通常使用绑定本地端口，等待客户端的连接。
- Bootstrap只需要配置一个EventGroup，而ServerBootstrap需要配置两个EventstrapGroup，一个用于接收连接，一个用于具体的处理。
## NioEventLoopGroup默认的构造函数会起多少线程？
- CPU核心数 * 2

## Netty线程模型了解么？
- Reactor模式：基于事件驱动，采用多路复用将事件分发给相应的Handler处理，非常适合处理海量IO的场景。
- 大部分网络框架基于Reactor模式设计开发。
- Netty主要利用EventLoopGroup线程池来实现具体的线程模型的，实现服务端的时候一般会初始化两个线程池，bossGroup和workerGroup，bossGroup接收连接，workerGroup负责具体的处理，交由相应的Handler处理。
1. 单线程模型
2. 多线程模型：一个Acceptor线程负责客户端的连接，一个NIO线程组负责具体的处理。
3. 主从多线程模型：从一个主线程组中选一个线程负责客户端的连接，其他的线程负责后续的接入认证工作。连接建立完成后，从NIO线程组负责具体的IO处理。

## Netty服务端和客户端的启动过程了解么？
### 服务端：
1. 创建两个NioEventLoopGroup实例，一个bossGroup、一个workerGroup
2. 创建一个ServerBootstrap服务端启动引导类，这个类引导我们完成服务端的启动工作。
3. .group()方法为这个引导类配置两个线程组，确定了线程模型。 
4. 通过.channel()方法为这个引导类指定了IO模型为NIO
5. 通过.childHandler()给引导类创建一个ChannelInitializer，然后指定了服务端消息的业务处理逻辑HelloServerHandler对象
6. 调用ServerBootstrap类的bind()方法绑定端口

### 客户端：
1. 创建一个NioEventLoopGroup实例
2. 创建一个Bootstrap启动引导类，这个类引导我们完成客户端的启动工作。
3. .group()方法为这个引导类配置一个线程组
4. 通过.channel()方法为这个引导类指定了IO模型为NIO
5. 通过.childHandler()给引导类创建一个ChannelInitializer，然后指定了客户端消息的业务处理逻辑HelloClientHander对象
6. 调用Bootstrap类的connect()方法进行连接，这个方法指定两个参数：inetHost：ip地址，inetPort：端口号

## 什么是TCP粘包/拆包？有什么解决方法呢？
- 基于TCP发送数据的时候，多个字符串“粘”在了一起或者一个字符串被拆开的问题。
- 使用Netty自带的解码器：LineBasedFrameDecoder：发送端发送数据包的时候，每个数据包之间以换行符作为分割。DelimiterFrameDecoder：可以自定义分割符解码器。FixedLengthFrameDecoder：固定长度解码器。
- 自定义序列化编解码器
## Netty长链接、心跳机制了解么？
- TCP在进行读写的时候，建立连接时会进行三次握手，断开时会进行四次挥手的操作，这个过程是比较消耗网络资源并且有时间延迟的。
- 短连接：在进行完读写之后就会断开连接，如果下次再要相互发送消息，就重新建立连接。每一次的读写都要建立连接必然会带来大量网络资源的消耗，并且连接的建立也需要消耗时间。
- 长连接：建立连接之后，完成一次读写不会主动关闭它们之间的连接，省去了较多的TCP建立和关闭的操作，降低对网络资源的依赖，节约时间。
- 在保持长连接期间，网络异常出现的时候，client和server之间如果没有交互的话是不会知道对方已经掉线的，这时候需要引入心跳机制。
- 在client与server之间在一段时间内没有数据交互的时候，会发送特殊的数据包给对方，当接收方收到这个数据报文后，也会回一个特殊的数据包给对方，这样就是一个PING-PONG交互。
- TCP实际上有长连接选项，本身也有心跳包机制，但是TCP协议层面的长连接灵活性不够，一般都是需要在应用层协议上自定义心跳机制，也就是在Netty层面通过编码实现。

## Netty的零拷贝了解么？
- 零拷贝(零复制)：计算机执行操作时，CPU不需要先将数据从某处内存复制到另一个特定的区域。这种技术通常用于通过网络传输文件时节省CPU周期和内存带宽。
- 在OS层面的零拷贝一般指避免在用户态和内核态之间来回拷贝数据。而在Netty层面，零拷贝体现在对于数据操作的优化。
- Netty的零拷贝体现在一下几个方面：
1. 使用Netty提供的CompositeByteBuf类，可以将多个ByteBuf合并为一个逻辑上的ByteBuf，避免了多个ByteBuf之间的拷贝。
2. ByteBuf支持slice操作，可以将一个ByteBuf分割成多个共享同一个存储区域的ByteBuf，避免了内存的拷贝。
3. 通过FileRegion包装的FileChannel.tranferTo实现文件传输，可以直接将文件缓冲区的数据发送到目标Channel，避免了传统通过循环write方式导致内存拷贝的问题。