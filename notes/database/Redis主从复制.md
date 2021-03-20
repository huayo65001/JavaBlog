# Redis主从复制

- 主从复制实现原理
    - 完整过程如下：
    1. 开启主从复制
        - 命令：replicaof \<masterip> \<masterport> 或者 配置文件 replicaof \<masterip> \<masterport>
    2. 建立套接字连接
        - slave根据ip和端口向master发送套接字连接，master在接受套接字连接后，创建相应的客户端状态。
    3. 发送PING命令
        - slave发送ping命令，以检查套接字的读写状态是否正常。
    4. 身份验证
        - 如果master和slave都设置密码，则验证，都没有设置密码则不需要验证，一个设置一个不设置返回错误。
    5. 发送端口信息
        - slave向master发送自己的监听端口，master收到后记录在slave所对应的客户端状态的slave_listening_port属性中。
    6. 发送IP地址
        - slave向master发送slave_announce_ip配置的ip地址，master收到记录后记录在slave所对应的客户端状态的slave_ip属性。
    7. 发送CAPA
        - slave发送capa告诉master自己的同步复制能力，master收到后记录在slave对应的客户端状态的slave_capa属性。
    8. 数据同步
        - slave向master发送PSYNC命令，master收到该命令后判断是进行部分重同步还是完整重同步，然后根据策略进行数据的同步。
        - slave如果是第一次执行复制，会发送PSYNC ？ -1，master返回+FULLRESYNC \<replid> \<offset>执行完整重同步。
        - 如果不是第一次执行，slave则发送PSYNC replid offset，其中replid是master的复制ID，offset是slave当前的复制偏移量。master根据replid和offset来判断应该执行哪种同步操作。如果是完整重同步，返回+FULLRESYNC \<replid> \<offset>；如果是部分重同步，则返回+CONTINUE \<replid>，此时slave只需要等待master将自己缺少的数据发送过来就可以了。
    9. 命令传播
        - 当完成了同步之后，就进入命令传播阶段，master会将自己执行的写命令一直发送给slave，slave负责一直接收命令。这样就能保证master和slave的一致性了。
        - 在命令传播阶段，slave默认每秒一次的频率向master发送命令：REPLCONF ACK \<reploff>。
        - 发送REPLCONF有三个作用：1. 检测master与slave之间的网络状态。2. 汇报自己的偏移量，检测命令丢失。3. 辅助实现min-slaves配置，用于防止master在不安全的情况下执行命令。

<br>

- 旧版同步：SYNC
    - Redis2.8之前的数据同步通过SYNC命令来实现
    - slave向master发送SYNC命令，master收到命令后执行BGSAVE命令，fork子进程生成RDB方法，同时会有一个缓冲区记录当前开始所有的写命令。当BGSAVE执行完成后，master将生成的RDB文件发送给slave，slave接收RDB文件并载入到内存，将数据库状态更新到master执行BGSAVE之前的状态。当master进行命令传播时，将缓冲区中的写命令发送给slave，还会同时写进复制积压缓冲区。当slave重连上master时，会将自己的复制偏移量通过PYSNC发送给master，master通过与复制积压缓冲区进行比较，如果发现部分未同步的命令还在复制积压缓冲区，则将这部分命令进行部分同步，如果重连时间太久，这部分命令已经不在复制积压缓冲区，则将进行全同步。

<br>

- 运行ID(runid)
    - 每个Redis Server都会有自己的运行ID，当slave初次复制master时，master会将自己的runid发送给slave进行保存，之后slave再次进行复制的时候就会讲该runid发送给master，master通过比较runid来判断是不是同一个master。
    - 引入runid后，数据同步过程变为slave通过PSYNC runid offset命令，将正在复制的runid和offset发送给master，master判断runid与自己的runid是否相等，如果相等，并且offset还在复制积压缓冲区，进行部分重同步。否则，如果runid不想等或者offset已经不在复制积压缓冲区，执行完全重同步。

<br>

- PSYNC存在的问题
    - slave重启，runid和offset都会丢失，需要进行完全重同步。
    - redis发生故障切换，故障切换后master runid发生了变化，slave需要进行完全重同步。

<br>

- PSYNC2
    - 引入两组replid和offset替换原来的runid和offset
    1. 第一组replid和offset，对于master来说，表示为自己的复制ID和复制偏移量，对于slave来说，表示为自己正在同步的master的复制ID和复制偏移量。
    2. 第二组replid和offset，对于master和slave来说，都表示为自己上一个master的复制ID来复制偏移量；主要用于切换时支持部分重同步。
    - slave也会开启复制积压缓冲区，主要用于故障切换后，slave代替master，该slave仍可以通过复制积压缓冲区来继续支持部分重同步，否则无法支持部分重同步。

    - PSYNC2优化场景
    1. slave重启后导致完整同步，原因是重启后复制ID和复制偏移量都丢失了，解决方法在关闭服务器之前将这两个变量存下来。
    2. master故障切换后导致完整重同步：原因是master发生故障后，出现了新的master，而新的master的复制ID也发生了变化，导致无法进行部分重同步。解决方法，将新的复制ID和复制偏移量与老的复制ID和复制偏移量串联起来。slave在晋升为master后，将自己保存的第一组复制ID和偏移量移动到第二组，第一组生成属于自己的复制ID。这样新master通过第二组id判断slave是否是自己之前的master，如果是尝试进行部分重同步。


<br>

- 主从复制会存在哪些问题
    - 一旦主节点宕机，从节点晋升为主节点，同时需要修改应用方的主节点地址，还需要命令所有从节点去复制新的主节点，整个过程需要人工干预。
    - 主节点的写能力/存储能力受到单机的限制。

- 哨兵
    - 主从复制存在的问题可以用哨兵机制来解决。使用Sentinel来完成节点选举工作。
    - 哨兵用于监控Redis集群中Master主服务器的工作状态，可以完成Master和Slave的主从转换。
    - 系统可以执行四个任务：
        1. 监控：不断检查主服务器和从服务器是否正常运行。
        2. 通知：当被监控的某个Redis服务器出现问题，Sentinel通过API脚本向管理员或其他应用发出通知。
        3. 自动故障转移：当主节点不能正常工作时，Sentinel会开始一次自动的故障转移。会将失效主节点的从节点中选择一个成为主节点，并将其他从节点指向新的主节点。
        4. 配置提供者：在Redis Sentinel模式下，客户端应用在初始化的时候是与Sentinel节点集合连接，从而获取主节点信息。
    - 工作原理：
        1. 每个Sentinel节点每秒一次的频率向它所知的主服务器，从服务器以及其他Sentinel节点发送PING命令
        2. 当一个实例距离有效恢复PING命令的有效时间超过down-after-milliseconds所指定的值时，该Sentinel节点标记为主观下线。
        3. 如果一个主服务器被标记为主观下线后，那么正在监视的其他Sentinel节点也要以每秒一次的频率确认主服务进入了主观下线状态。
        4. 这时有足够数量的Sentinel节点在指定的时间范围内确认该服务器处于主观下线状态，主服务器被标记为客观下线状态。
        5. 一般情况下每个Sentinel以每十秒一次的频率向主服务器和从服务器发送INFO命令，当一个主服务器被指定为客观下线时，频率会改为一秒一次。
        6. Sentinel协商客观下线的主节点的状态，如果处于SDOWN状态，则投票出新的主节点，并将从节点指向新的主节点进行数据复制。
        7. 如果没有足够数量的Sentinel同意主节点下线，则主节点的客观下线状态被移除。当主服务器重新向Sentinel命令有效回复时，主服务器的主观下线状态被移除。

<br>

- 缓存穿透
    - 大量请求的数据根本不在缓存中，导致大量请求不经过缓存，直接到了数据库。
    - 解决方案：
        1. 参数校验：一些不合法的请求直接抛出异常返回给服务器。
        2. 缓存无效key，当缓存和数据库都不存在该key的数据时，在Redis中写入该key，并设置一定的过期时间。这种方式适合变化不频繁的key的情况。如果key变化频繁会导致Redis中存在大量无效的key。
        3. 布隆过滤器：可以非常方便的判断一个给定的数据是否存在于海量数据中。具体做法是把所有可能存在的请求的值放到过滤器中，用户请求过来的事情，首先判断用户发来的请求的值是否存在于过滤器中，如果不存在直接返回异常结果给客户端。


<br>

- 缓存雪崩
    - 缓存在同一时间内大面积的失效，导致大量的用户请求直接到了数据库，造成数据库短时间内承受大量的请求。
    - 解决方案：
        - 针对Redis服务不可用的情况：(1)设置Redis集群，避免单机出现问题导致整个缓存服务都没办法使用。(2)限流，避免同时处理大量请求。
        - 针对热点缓存失效问题：(1)随机设置热点缓存失效时间.(2)缓存永不失效。