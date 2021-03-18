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

- 主从复制的演变

- 哨兵

**未完，继续写**https//zhuanlan.zhihu.com/p/134104400

