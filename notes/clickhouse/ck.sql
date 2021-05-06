create database if not exists doit20;
use doit20;
create table tb_1(id Int32,name String,age UInt8,gender String)engine=Memory();
insert into tb_1 values(1,'zss',23,'M'),(2,'db',11,'F');
create table test_array(
    name String,
    hobby Array(String)
) engine=Log;

insert into test_array values
('于谦',['抽烟','喝酒','烫头']),
('班长',['抽烟','于谦']),
('小',['吃','喝','睡']);

select arrayMap(e->concat(e,'abc'),hobby) from test_array;

-- 枚举数据类型Enum

create table test_enum(
    id UInt8,
    color Enum('RED'=1,'BLUE'=2,'YELLOW'=3)
)engine=Log;

insert into test_enum values(1,'RED'),('3','BLUE');
-- 没有声明的值不能插入
-- insert into test_enum values(2,'PINK');
insert into test_enum values(2,2);
-- 节省存储空间 提升处理效率 底层存储Int类型，占用空间最小
select id, toInt32(color) from test_enum;

-- tuple数组，可以存储任意的数据类型
select tuple(1,2,3,'hello') as x , toTypeName(x);

-- Nested 嵌套表
create table test_nested(
    uid Int8,
    name String,
    hobby Nested(
        id Int8,
        hname String,
        hname1 String
    )
)engine=Memory;

insert into test_nested values(1,'zss',[1,2,3],['吃','喝','睡'],['a','b','c']);

select uid, name, hobby.id, hobby.hname, hobby.hname1 from test_nested;

-- Domain
-- IPv4

create table test_domain(
    id Int8,
    ip IPv4
)engine=Memory;

insert into test_domain values(1,'192.168.1.1');
insert into test_domain values(1,'192.168.1');
