[TOC]

### 1.Spring介绍

Spring是一个轻量级开发框架，是很多模块的集合，主要模块包括核心容器，web，数据访问/继承，AOP，Aspects，工具，消息，测试模块。

AOP：面向切面编程

Web：为创建web应用程序提供支持

core：Spring的核心；为IOC和依赖注入提供支持

JDBC：数据库连接

JMS：java消息服务

Aspects：提供与AspectJ的集成

### 2.@RestController、Controller

##### 1.Controller

controller返回一个页面

##### 2.RestController

RestController返回JSON或XML数据。

只返回对象，对象以JSON或XML形式写入HTTP相应（Response）中。

##### 3.Controller + ResponseBody

@Controller + @ResponseBody = @RestController

### 3.Spring IOC

IOC：控制反转，是一种设计思想，是把创建对象的控制权交给spring框架来做。通过bean来注册对象，所有对象都在IOC容器中，IOC容器实际上是个Map。

想创建对象，只需要在xml里配置或使用注解即可，不需要考虑对象如何被创建。需要使用对象时，只需要从context取得对象。

### 4.AOP

AOP：面向切面编程，将与业务本身无关，但需要被业务调用的功能（事务处理，权限控制，日志管理等）封装起来，降低模块的耦合度，提高代码的复用率。在不改变业务代码的情况下增加新功能。

AOP是基于动态代理的。

##### 1.Spring AOP、AspectJ AOP

Spring AOP是运行时增强，AspectJ AOP是编译时增强。

Spring AOP基于动态代理，AspectJ AOP基于字节码操作。

Spring已经集成了AspectJ，当切面比较少两者差异不大，当切面太多，首选AspectJ AOP。

##### 2.动态代理

实现动态代理的类需要实现InvocationHandler接口，并重写invoke()方法。

调用Proxy.newProxyInstance(classloader, interface, handler)来创建一个代理，类型是主体对象实现的接口。

### 5.Spring bean

bean相当于对象，注册的bean实例会存放在IOC容器中，可以通过xml配置或注解自动配置bean，实现IOC和依赖注入。

##### 1.scope作用域

singleton：单例模式，创建的bean实例只有一个，spring中的bean默认是singleton。

prototype：原型模式，每次请求都会创建一个新的bean实例。

request：每一次HTTP请求会创建一个新的bean，该bean仅在当前HTTP request有效。

session：每一次HTTP请求会创建一个新的bean，该bean仅在当前HTTP session有效。

##### 2.单例bean的线程安全问题

单例bean会有线程安全问题，当多线程操作同一个对象时，这个对象的成员变量的写操作会存在线程安全问题。

解决办法：1.在类中定义一个ThreadLocal成员变量，把可变的成员变量放入ThreadLocal中。

2.将bean作用域scope设为原型prototype，每次请求都会创建一个新的bean，就不会有线程安全问题了。

3.常用的controller，service，dao的bean是无状态的，不保存数据，所以是线程安全的。

##### 3.@Bean和@Component

1.作用对象不同：@Component注解作用于类，@Bean注解作用于方法。

2.@Component通过扫描类的路径来检测和自动装配bean到IOC容器中。

@Bean在标有该注解的方法中定义产生这个bean，通过该方法产生一个bean放到IOC容器中，即这个方法的返回值是一个对象。

3.@Bean比@Component注解的自定义更强，很多地方只能通过@Bean来注册bean。

##### 4.将类声明为bean的注解有哪些

@Component 组件，通用的注解

@Controller Contriller层

@Service Service层

@Repository Dao层

@Configuration 配置

@Bean 注解作用于方法，方法的返回值是个对象

##### 5.bean的生命周期

bean容器找到配置文件中的bean定义

bean容器通过java反射机制创建bean实例

使用set()方法设置属性值

实现Aware接口，则调用对应set方法



销毁时，如果实现了DisposableBean接口，则执行destory()方法

销毁时，如果Bean在配置文件包含destory-method属性，执行对应方法

### 6.Spring中用到的设计模式

##### 1.工厂设计模式

Spring通过BeanFactory和ApplicationContext来创建Bean对象。

BeanFactory：延迟注入，只有使用某个bean才注入，占用更小的内存，程序启动更快。

ApplicationContext：Spring容器启动一次性把所有bean创建。

##### 2.单例设计模式

Spring Bean默认都是单例。

好处：对于频繁使用的对象，省略创建对象花费的时间；new次数减少，对系统内存的使用频率降低，减轻垃圾回收的压力。

Spring通过ConcurrentHashMap实现了单例注册表来实现单例模式。

##### 3.代理设计模式

Spring AOP是基于动态代理实现的。

##### 4.模版方法模式

Spring中以Template结尾的对数据库操作的类，使用到了模版方法模式。

一般情况下，通过继承抽象类来实现模版模式，但Spring使用Callback模式和模版模式结合。

##### 5.包装器设计模式

连接多个数据库，不同用户根据需要访问不用数据库，包装器设计模式可以让程序根据用户需求动态切换数据源。

##### 6.观察者模式

Spring事务驱动模型使用观察者模式。

##### 7.适配器模式

Spring AOP的增强或通知（advice）使用到适配器模式；Spring MVC中用适配器模式适配Controller。

### 7.Spring事务

##### 1.Spring管理事务的方式

1.编程式事务，在代码中硬编码

2.声明式事务，在配置文件中配置

声明式事务分为两种：基于XML的声明式事务、基于注解的声明式事务

##### 2.隔离级别

TransactionDefinition接口中定义了五个表示隔离级别的常量：

**ISOLATION_DEFAULT：**使用后端数据库默认的隔离级别，MySQL默认是可重复度。

**ISOLATION_READ_UNCOMMITTED：**未提交读，最低级的隔离级别，会出现幻读、不可重复读、脏读问题。

**ISOLATION_READ_COMMITTED：**已提交读，可以解决脏读问题，但不能解决幻读和不可重复读问题。

**ISOLATION_REPEATABLE_READ：**可重复读，可以解决脏读、不可重复读问题，但不能解决幻读问题。

**ISOLATION_SERIALIZABLE：**最高的隔离级别，完全服从ACID的隔离级别，事务按顺序执行，不会产生干扰，但严重影响性能。

##### 3.Spring事务哪几种事务传播行为

**支持当前事务的情况：**

**PROPAGATION_REQUIRED：**存在事务，则加入事务；不存在事务，则创建新事务。

**PROPAGATION_SUPPORTS：**存在事务，则加入事务；不存在事务，则以非事务方式运行。

**PROPAGATION_MANDATORY：**存在事务，则加入事务；不存在事务，则抛出异常。

**不支持当前事务的情况：**

**PROPAGATION_REQUIRES_NEW：**创建新的事务，如果当前存在事务，则把当前事务挂起。

**PROPAGATION_NOT_SUPPORTED：**以非事务方式运行，如果当前存在事务，则把当前事务挂起。

**PROPAGATION_NEVER：**以非事务方式运行，如果当前存在事务，则抛出异常。

##### 4.@Transactional注解

作用到类上时，该类所有public方法都具有该类型的事务属性；作用到方法上时，可以覆盖类级别的定义。方法抛出异常，就会回滚，数据库数据也回滚。

不配置属性rollbackFor，则事务只在遇到运行时异常时才回滚；rollbackFor=Exception.class可以在遇到非运行时异常也回滚。

### 8.JPA

##### 不持久化方法

1.static

2.final

3.transient

4.@Transient

### 9.spring mvc流程

web容器启动会通知spring初始化容器，加载Bean的定义信息并初始化Bean，之后遍历容器内的Bean，获取每个Controller对应的方法的url，将controller和url存在一个Map中。

所有请求都会让DispatcherServlet处理，首先DS请求HandlerMapping找出容器内被@Controller修饰的Bean和被@RequestMapping修饰的类和方法，生成Handler和HandlerInterceptor以一个HandlerExecutionChain（处理执行链）返回；之后DS将Handler传给HandlerAdapter，HandlerAdapter会让真正的处理器处理Handler，并返回一个ModelAndView，Model是数据，View是个逻辑上的View；DS将ModelAndView传给ViewResolver处理成真正的View，渲染View并将数据填充，返回客户端。

### 10.spring mvc组件

1.DispatcherServlet：前端控制器，请求都会在这里处理，是整个流程控制的核心。

2.Handler：处理器，完成具体的业务逻辑。

3.HandlerMapping：完成url到controller的映射，DispatcherServlet通过HandlerMapping将不同请求映射到不同Handler。

4.HandlerInterceptor：处理器拦截器。

5.HandlerExecutionChain：处理器执行链，包括Handler和HandlerInterceptor。

6.HandlerAdapter：处理器适配器，用来执行Handler。

7.ModelAndView：Handler的处理结果。

8.ViewResolver：视图解析器，将ModelAndView进行解析渲染和数据填充，返回给客户端。

### 11.spring mvc注解

1.@Controller：在类的定义处添加，将类作为Bean交给IOC容器处理。

2.@RequestMapping：将url和业务方法映射起来，可以在类和方法上添加。value属性指定url的地址，method属性限制请求方法，params属性限制必须提供的参数。

3.@RequestParam

### 12.依赖注入

##### 1.实现方法

1.构造器注入

IOC会检查被注入对象的构造方法，获取需要的依赖对象列表，将其注入。优点是构造完成后进入就绪状态，可以马上使用；缺点是不能继承，不能设置默认值。

2.setter方法注入

为对象设置setter方法，就可以通过setter方法将依赖对象注入。优点是可以被继承，能设置默认值；缺点是构造完成后不能马上进入就绪状态。

3.接口注入

实现某个接口，接口提供方法来进行注入。需要实现额外的接口，一般不用。

##### 2.相关注解

1.@Autowired：自动装配，byType。

2.@Qualifier：在byType基础上byName注入。

3.@Resource：byName注入。

4.@Value：用于注入基本类型和String类型。

