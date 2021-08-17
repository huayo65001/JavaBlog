[TOC]

### 1.基本操作

```sql
-- start MySQL
net start mysql;
systemctl start mysqld;
```

### 2.数据库操作

```sql
-- 查看数据库
SELECT DATABASE();
-- 创建数据库
CREATE DATABASE database_name;
-- 删除数据库
DROP DATABASE database_name;
```

### 3.表的操作

```sql
-- 创建表
CREATE TABLE table_name (结构定义)[表选项];
```

**结构定义：**

字段名 数据类型

**表选项：**

引擎：ENGINE = InnoDB/MyISAM

自增：AUTO_INCREMENT = colum

```sql
-- 修改表
ALTER TABLE table_name [表选项];
-- 重命名
RENAME TABLE old_table_name TO new_table_name;
-- 修改字段
ALTER TABLE table_name 操作名;
-- 操作名
ADD colum_name
ADD PRIMARY KEY colum
ADD INDEX colum
ADD UNIQUE colum
DROP colum
```

### 4.数据操作

```sql
-- 增
INSERT INTO table_name
VALUES (value1,value2,...);
INSERT INTO table_name (colum1,colum2)
VALUE (value1,value2);
-- 查
SELECT colum1, colum2
FROM table_name
WHERE colum3 = '**' AND colum2 = '212';
-- 查 去重
SELECT DISTINCT ...
-- 删
DELECT FROM table_name
WHERE colum1 = '123';
-- 改
UPDATE table_name
SET colum1 = '123'
WHERE colum2 = '111';
```

### 5.数据类型

##### 1.数值

（1）整形

tinyint	1byte

smallint	2byte

mediumint	3byte

int	4byte

bigint	8byte

（2）浮点型

float	4byte

double	8byte

（3）定点数

decimal	可变长度

##### 2.字符串

char	定长字符串

varchar	变长字符串

blob	二进制字符串	tinyblob,blob,mediumblob,longblob

text	非二进制字符串	tinytext,text,mediumtext,longtext

binary	varbinay	二进制字符串，对应char,varchar

##### 3.日期时间

datetime	8byte	日期时间

date	3byte	日期	current_data当前日期

time	3byte	时间	current_time当前时间

year	1byte	年份

timestamp	4byte	时间戳

##### 4.枚举、集合

enum：最大数量65535，以smallint保存，表现为字符串类型。

set：最大64，以bigint保存，位运算。

### 6.列属性

##### 1.主键

PRIMARY KEY

##### 2.唯一索引

UNIQUE

##### 3.null约束

not null：不允许为空

##### 4.默认值

DEFAULT

##### 5.自增

AUTO_INCREMENT，必须为索引，只能一个字段

##### 6.注释

COMMENT '内容'

##### 7.外键

FOREIGN KEY

级联操作cascade：主表更新，从表也更新。

### 7.建表规范

##### 1.第一范式

确保原子性，字段不能再分。

##### 2.第二范式

满足第一范式前提下，除主键外的其他字段都依赖主键，即不能出现部分依赖。消除复合主键可避免部分依赖。

##### 3.第三范式

满足第二范式前提下，除主键外的其他字段都与主键直接相关，即不能出现传递依赖。

传递依赖：某个字段依赖主键，另一个字段依赖此字段。

### 8.SELECT子句

```sql
-- 分组
GROUP BY colum_name [ASC升序/DESC降序]
-- 合计函数，需搭配GROUP BY使用
count 非null值记录数 count(DISTINCT colum)去重
sum 求和
max 最大值
min 最小值
avg 平均值
-- HAVING
-- 与WHERE功能用法不同，时机不同
-- WHERE对原数据进行过滤，数据必须是数据表存在的，无法和合计函数一起用
-- HAVING对筛选出的数据再次过滤，数据必须是查询出来的，必须引用GROUP BY中的列或合计函数中的列

-- 排序
ORDER BY --ASC升序，DESC降序
-- 限制条数
LIMIT
```

### 9.子查询

##### 1.from

需要给子查询结果一个别名。

```sql
SELECT *
FROM (SELECT * FROM TB WHERE id>0) AS subform
WHERE id>1;
```

##### 2.where

不需要取别名。

```sql
SELECT *
FROM tb
WHERE money = (SELECT MAX(money) FROM tb);
```

### 10.连接查询

内连接：inner join

左外连接：left join 右表null填充

右外连接：right join 左表null填充

自然连接：natural join

### 11.TRUNCATE

清空数据，删除表并重建。

重置AUTO_INCREMENT的值。

##### TRUNCATE、DELETE

TRUNCATE删除表重建，DELETE逐条删除。

TRUNCATE重置AUTO_INCREMENT，DELETE不重置。

TRUNCATE不知道删除几条，DELETE知道。

当被用于带分区的表时，TRUNCATE保留分区。