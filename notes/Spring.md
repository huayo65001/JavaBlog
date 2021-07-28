# Spring

## IOC

## AOP

## 事务管理
### 什么是事务？

### Spring支持两种方式的事务管理
声明式事务管理和编程式事务管理
### PlatFormTransactionManager
事务管理器，Spring事务策略的核心
Spring并不直接管理事务，而是提供了多种事务管理器。Spring事务管理器的接口是PlatFormTransactionManager
### TransactionDefinition
事务定义信息(事务隔离级别、传播行为、超时、只读、回滚规则)
```java
public interface TransactionDefinition {

	// ------------  事务传播行为 -----------
    int PROPAGATION_REQUIRED = 0; // 默认的，如果当前存在事务，就加入该事务，如果当前没有事务，则创建一个新的事务。
    int PROPAGATION_SUPPORTS = 1; // 如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。
    int PROPAGATION_MANDATORY = 2; // 如果当前存在事务，则加入该事务；如果当前没有事务，则抛出异常。（mandatory：强制性）
    int PROPAGATION_REQUIRES_NEW = 3; // 创建一个新的事务，如果当前存在事务，则把当前事务刮起。也就是说不管外部方法是否开启事务，修饰的内部方法会新开启自己的事务，且开启的事务互相独立，互不干扰。
    int PROPAGATION_NOT_SUPPORTED = 4; // 以非事务方式运行，如果当前存在事务，则把当前事务挂起。
    int PROPAGATION_NEVER = 5; // 以非事务方式运行，如果当前存在事务，则抛出异常。
    int PROPAGATION_NESTED = 6; // 如果当前存在事务，则创建一个事务作为当前事务的嵌套事务来运行；如果当前没有事务，则该取值等价于TransactionDefinition.PROPAGATION_REQUIRED。也就是说：
	// 1. 在外部方法未开启事务的情况下Propagation.NESTED和Propagation.REQUIRED作用相同，修饰的内部方法都会新开启自己的事务，且开启的事务相互独立，互不干扰。
	// 2. 如果外部方法开启事务的话，Propagation.NESTED修饰的内部方法属于外部事务的子事务，外部主事务回滚的话，子事务也会回滚，而内部子事务可以单独回滚而不影响外部主事务和其他子事务。

	// -------------  事务隔离级别  ----------
    int ISOLATION_DEFAULT = -1;
    int ISOLATION_READ_UNCOMMITTED = 1;
    int ISOLATION_READ_COMMITTED = 2;
    int ISOLATION_REPEATABLE_READ = 4;
    int ISOLATION_SERIALIZABLE = 8;
    int TIMEOUT_DEFAULT = -1;
    // 返回事务的传播行为，默认值为 REQUIRED。
    int getPropagationBehavior();
    //返回事务的隔离级别，默认值是 DEFAULT
    int getIsolationLevel();
    // 返回事务的超时时间，默认值为-1。如果超过该时间限制但事务还没有完成，则自动回滚事务。
    int getTimeout();
    // 返回是否为只读事务，默认值为 false
    boolean isReadOnly();

    @Nullable
    String getName();
}
```
- 事务传播行为是为了解决业务层方法之间互相调用的事务问题。当事务方法被另一事务方法调用时，必须指定事务应该如何传播。例如：方法可能继续在现有事务中运行，也可能开启一个新事务，并在自己的事务中运行。
### TransactionStatus
事务运行状态
### @Tranactional注解

## SpringMVC

## SpringBoot

### Springboot的优点

### Springboot的自动配置原理