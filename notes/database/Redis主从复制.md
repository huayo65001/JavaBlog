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

<br>

- 运行ID(runid)

<br>

- PSYNC存在的问题

<br>

- PSYNC2

<br>

- 主从复制的演变
