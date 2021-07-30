# IO

## IO模型简介

### IO分类
- 磁盘操作：file
- 字节操作：InputStream和OutputStream
- 字符操作：Reader和Writer
- 对象操作：Serializable
- 网络操作：Socket

### 五种IO模型
- 阻塞式IO(BIO)
- 非阻塞式IO(NIO)
- IO复用(select和poll)
- 信号驱动式IO
- 异步IO(AIO)

### 输入操作两个阶段
- 等待数据准备好
- 从内核向进程复制数据

### 套接字输入操作
- 等待数据从网络中达到，当所等待分组到达时，它被复制到内核中的某个缓冲区。
- 把数据从内核缓冲区复制到进程缓冲区。

### BIO
- 同步阻塞IO模式，数据的读取写入必须阻塞在一个线程内等待完成。应用程序被阻塞，直到数据复制到应用程序缓冲区中才返回。
- 这里阻塞过程中，其他程序还可以继续执行。
- 对于十万甚至百万级连接时，传统的BIO模型是无能为力的。
- 一请求一应答通信模型

### NIO
- 同步非阻塞IO模式，在java1.4中引入了NIO框架，对于java.nio包，提供了Channel、Selector、Buffer等抽象。
- 支持面向缓冲区，基于通道的I/O操作方法。
- 提供了`SocketChannel`和`ServerSocketChannel`两种不同的套接字通道实现，也支持阻塞模式，相对于BIO中的`Socket`和`ServerSocket`。
- 非阻塞模式对于低负载、低并发的应用程序，可以使用同步阻塞I/O来提升开发效率和更好的维护性。对于高负载和高并发的应用，使用NIO的非阻塞模式来开发。
#### NIO的特性、NIO与IO的区别
IO流是阻塞的，NIO是非阻塞的
1. 单线程中从通道读取数据到buffer，同时可以继续做别的事情，当在通道中读取到buffer的时候，线程再继续处理数据。
2. 非阻塞写，一个线程写一些数据到通道中，不需要等待它完全写入，就可以去做别的事情。
Buffer(缓冲区)
1. IO是面向流的，NIO是面向缓冲区的
2. Buffer是一个对象，它包含一些要写入或读出的数据。NIO引入了Buffer这个对象，这是和IO一个重要的区别。
3. IO是Stream oriented，虽然Stream也有Buffer开头的扩展类，但是只是流的包装类，最终还是从流到缓冲区。
4. Buffer是直接将数据读到缓冲区中进行处理的。
Channel(通道)
1. 通道是双向的，可读可写，但流的读写是单向的。无论读写，通道都是和Buffer交互。因为Buffer，通道可以异步的读写。
Selector(选择器)
1. NIO有选择器，IO没有选择器
2. 选择器用于单线程处理多个通道。对于操作系统来说，线程之间的切换是比较昂贵的，所以需要使用较少的线程来处理多个通道，所以使用选择器对于提高操作系统的效率是比较有用的。

### AIO
- 异步非阻塞的I/O模型，基于事件和回调机制实现的。

### 阻塞/非阻塞 异步/同步

## NIO
### 基础详解

### 流与块

### 通道与缓冲区

- **通道**

- **缓冲区**
- 缓冲区状态变量

### 选择器

## 多路IO复用
### Reactor模型

## 零拷贝
1. mmap + write
mmap()系统调用函数会直接把内核缓冲区里的数据`映射`到用户空间，这样，操作系统内核与用户空间就不需要再进行任何的数据拷贝操作。
具体过程如下：
- 应用程序调用了mmap()后，DMA会把磁盘的数据拷贝到内核的缓冲区里。接着，应用程序和操作系统`共享`这个缓冲区。
- 应用程序再调用write()，操作系统直接把内核缓冲区的数据拷贝到socket缓冲区中，这一切都发生在内核态，由CPU来搬运数据。
- 最后把内核的socket缓冲区里的数据，拷贝到网卡的缓冲区里，这个过程是由DMA搬运的。

仍需要通过CPU把内核缓冲区的数据拷贝到socket缓冲区里，仍然需要4次上下文切换，因为系统调用还是2次。

2. sendfile
```c++
#include <sys/socket.h>
ssize_t sendfile(int out_fd, int in_fd, off_t *offset, size_t count);
```
前两个参数是目的端和源端的文件描述符，后两个参数是源端的偏移量和复制数据的长度，返回值是实际复制数据的长度。

它可以替代前面的read()和write()这两个系统调用，这样就可以减少一次系统调用，也就减少了两次上下文切换的开销。

该系统调用可以直接把内核缓冲区里的数据拷贝到socket缓冲区里，不再拷贝到用户态，这样就只有2次上下文切换和3次数据拷贝。

如果网卡支持SG-DMA技术，可以进一步减少通过CPU把内核缓冲区里的数据拷贝到socket缓冲区的过程。

在linux内核2.4版本开始，对于支持网卡支持SG—DMA技术的情况下，sendfile()系统调用的过程具体如下：
- 第一步：通过DMA将磁盘上的数据拷贝到内核缓冲区里。
- 第二步：缓冲区描述符和数据长度传到socket缓冲区，这样网卡的SG-DMA控制器就可以直接将内核缓冲中的数据拷贝到网卡的缓冲区里，此过程不需要将数据从操作系统内核缓冲区拷贝到socket缓冲区中，这样就减少了一次数据拷贝。

3. 大文件使用异步 + 直接IO，不使用零拷贝，因为零拷贝会用到PageCache，PageCache主要用来就IO的数据进行合并以及预读。将大文件放到PageCache中会造成大文件很快填满PageCache，造成很多小的热点文件不能被读到。


## Netty
- Netty是什么？
    - Netty成功找到了一种在不妥协可维护性和性能的情况下实现易于开发，性能，稳定性和灵活性的方法。
    1. Netty是一个基于NIO的CS(客户端-服务端)框架，使用它可以快速简单的开发网络应用框架。
    2. 它极大地简化并优化了TCP和UDP套接字服务器等网络编程，并且性能以及安全性等很多方面甚至都要更好。
    3. 支持多种协议，如FTP、SMTP、HTTP以及各种二进制和基于文本的传统协议。

<br>

- 为什么要用Netty？
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


<br>

- Netty应用场景
    - 主要用作网络通信
    - 作为RPC框架的网络通信工具
    - 实现一个自己的HTTP服务器
    - 实现一个即时通讯系统
    - 实现一个消息推送系统


<br>

- Netty核心组件有哪些？分别有什么作用？
    - Channel
        - Channel接口是Netty对网络操作抽象类。
        - 比较常用的Channel接口实现类是NioServerSocketChannel(服务端)和NioSocketChannel(客户端)
    - EventLoop
        - 负责监听网络事件中并调用事件处理器进行相关的I/O操作。
        - Channel为Netty网络操作抽象类，EventLoop负责处理注册到上面的Channel处理I/O操作，两者配合参与I/O操作。
    - ChannelFuture
        - Netty是异步非阻塞的，所有操作都是异步的。因此我们不能立刻知道操作是否执行成功，我们可以通过ChannelFuture接口的addListener方法注册一个ChannelFutureListener，当操作成功或失败时，监听会自动出发并返回结果。
    - ChannelHandler、ChannelPipeline
        - ChannelHandler是消息的具体处理器，负责读写操作、客户端连接等事情。
        - ChannelPipline是ChannelHandler的链，提供一个容器并定义了用于沿着链传播入站和出站事件流的API。
        - 一个数据或事件可能会被多个Handler处理，当一个ChannelHander处理完后就将数据交给写一个Handler。

<br>

- EventloopGroup了解么？和EventLoop啥关系？
    - EventGroup包含多个EventGroup，BossEventGroup用于接收连接，WorkerEventGroup用于具体的处理(消息的读写以及其他逻辑处理)。
    - bossGroup处理客户端连接，当客户端处理完成后，会将这个连接提交给workGroup来处理，然后workGroup负责处理其IO相关操作。

<br>

- Bootstrap和ServerBootstrap了解么？
    - Bootstrap是客户端的启动引导类/辅助类
    - ServerBootstrap是服务端的启动引导类/辅助类
    - Bootstrap通常使用connect()方法连接到远程的主机和端口，作为一个Netty TCP协议中通信的客户端。另外Bootstrap也可以绑定一个本地端口作为UDP协议通信中的一端。
    - ServerBootstrap通常使用绑定本地端口，等待客户端的连接。
    - Bootstrap只需要配置一个EventGroup，而ServerBootstrap需要配置两个EventstrapGroup，一个用于接收连接，一个用于具体的处理。


<br>

- NioEventLoopGroup默认的构造函数会起多少线程？
    - CPU核心数 * 2


<br>

- Netty线程模型了解么？
    - Reactor模式：基于事件驱动，采用多路复用将事件分发给相应的Handler处理，非常适合处理海量IO的场景。
    - 大部分网络框架基于Reactor模式设计开发。
    - Netty主要利用EventLoopGroup线程池来实现具体的线程模型的，实现服务端的时候一般会初始化两个线程池，bossGroup和workerGroup，bossGroup接收连接，workerGroup负责具体的处理，交由相应的Handler处理。
    1. 单线程模型
    2. 多线程模型：一个Acceptor线程负责客户端的连接，一个NIO线程组负责具体的处理。
    3. 主从多线程模型：从一个主线程组中选一个线程负责客户端的连接，其他的线程负责后续的接入认证工作。连接建立完成后，从NIO线程组负责具体的IO处理。

<br>

- Netty服务端和客户端的启动过程了解么？
    - 服务端：
        1. 创建两个NioEventLoopGroup实例，一个bossGroup、一个workerGroup
        2. 创建一个ServerBootstrap服务端启动引导类，这个类引导我们完成服务端的启动工作。
        3. .group()方法为这个引导类配置两个线程组，确定了线程模型。 
        4. 通过.channel()方法为这个引导类指定了IO模型为NIO
        5. 通过.childHandler()给引导类创建一个ChannelInitializer，然后指定了服务端消息的业务处理逻辑HelloServerHandler对象
        6. 调用ServerBootstrap类的bind()方法绑定端口

    - 客户端：
        1. 创建一个NioEventLoopGroup实例
        2. 创建一个Bootstrap启动引导类，这个类引导我们完成客户端的启动工作。
        3. .group()方法为这个引导类配置一个线程组
        4. 通过.channel()方法为这个引导类指定了IO模型为NIO
        5. 通过.childHandler()给引导类创建一个ChannelInitializer，然后指定了客户端消息的业务处理逻辑HelloClientHander对象
        6. 调用Bootstrap类的connect()方法进行连接，这个方法指定两个参数：inetHost：ip地址，inetPort：端口号

<br>

- 什么是TCP粘包/拆包？有什么解决方法呢？
    - 基于TCP发送数据的时候，多个字符串“粘”在了一起或者一个字符串被拆开的问题。
    - 使用Netty自带的解码器：LineBasedFrameDecoder：发送端发送数据包的时候，每个数据包之间以换行符作为分割。DelimiterFrameDecoder：可以自定义分割符解码器。FixedLengthFrameDecoder：固定长度解码器。
    - 自定义序列化编解码器

<br>

- Netty长链接、心跳机制了解么？
    - TCP在进行读写的时候，建立连接时会进行三次握手，断开时会进行四次挥手的操作，这个过程是比较消耗网络资源并且有时间延迟的。
    - 短连接：在进行完读写之后就会断开连接，如果下次再要相互发送消息，就重新建立连接。每一次的读写都要建立连接必然会带来大量网络资源的消耗，并且连接的建立也需要消耗时间。
    - 长连接：建立连接之后，完成一次读写不会主动关闭它们之间的连接，省去了较多的TCP建立和关闭的操作，降低对网络资源的依赖，节约时间。
    - 在保持长连接期间，网络异常出现的时候，client和server之间如果没有交互的话是不会知道对方已经掉线的，这时候需要引入心跳机制。
    - 在client与server之间在一段时间内没有数据交互的时候，会发送特殊的数据包给对方，当接收方收到这个数据报文后，也会回一个特殊的数据包给对方，这样就是一个PING-PONG交互。
    - TCP实际上有长连接选项，本身也有心跳包机制，但是TCP协议层面的长连接灵活性不够，一般都是需要在应用层协议上自定义心跳机制，也就是在Netty层面通过编码实现。

<br>

- Netty的零拷贝了解么？
    - 零拷贝(零复制)：计算机执行操作时，CPU不需要先将数据从某处内存复制到另一个特定的区域。这种技术通常用于通过网络传输文件时节省CPU周期和内存带宽。
    - 在OS层面的零拷贝一般指避免在用户态和内核态之间来回拷贝数据。而在Netty层面，零拷贝体现在对于数据操作的优化。
    - Netty的零拷贝体现在一下几个方面：
        1. 使用Netty提供的CompositeByteBuf类，可以将多个ByteBuf合并为一个逻辑上的ByteBuf，避免了多个ByteBuf之间的拷贝。
        2. ByteBuf支持slice操作，可以将一个ByteBuf分割成多个共享同一个存储区域的ByteBuf，避免了内存的拷贝。
        3. 通过FileRegion包装的FileChannel.tranferTo实现文件传输，可以直接将文件缓冲区的数据发送到目标Channel，避免了传统通过循环write方式导致内存拷贝的问题。