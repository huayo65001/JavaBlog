# Spring

<!--ts-->
* [Spring](#spring)
      * [Spring框架概述](#spring框架概述)
      * [IOC是什么](#ioc是什么)
      * [IOC容器初始化过程](#ioc容器初始化过程)
      * [依赖注入的实现方式有哪些](#依赖注入的实现方式有哪些)
      * [依赖注入的相关注解有哪些](#依赖注入的相关注解有哪些)
      * [依赖注入的过程](#依赖注入的过程)
      * [Bean的生命周期](#bean的生命周期)
      * [Spring Bean的生命周期](#spring-bean的生命周期)
      * [Bean的作用范围](#bean的作用范围)
      * [如何通过XML创建Bean](#如何通过xml创建bean)
      * [如何通过注解创建Bean](#如何通过注解创建bean)
      * [如何通过注解配置文件](#如何通过注解配置文件)
      * [BeanFactory，FactoryBean和ApplicationContext的区别](#beanfactoryfactorybean和applicationcontext的区别)
      * [Spring 扩展接口](#spring-扩展接口)
      * [循环依赖](#循环依赖)
         * [Spring是如何解决循环依赖的？](#spring是如何解决循环依赖的)
         * [为什么要使用三级缓存呢？二级缓存能解决循环依赖吗？](#为什么要使用三级缓存呢二级缓存能解决循环依赖吗)
      * [什么是AOP](#什么是aop)
      * [AOP的相关注解有哪些](#aop的相关注解有哪些)
      * [AOP的相关术语](#aop的相关术语)
      * [AOP的过程](#aop的过程)
      * [什么是事务？](#什么是事务)
      * [Spring支持两种方式的事务管理](#spring支持两种方式的事务管理)
      * [PlatFormTransactionManager](#platformtransactionmanager)
      * [TransactionDefinition](#transactiondefinition)
      * [TransactionStatus](#transactionstatus)
      * [@Tranactional注解](#tranactional注解)
      * [Spring框架中用到了哪些设计模式？](#spring框架中用到了哪些设计模式)
      * [Spring涉及到的几种设计模式](#spring涉及到的几种设计模式)
      * [MyBatis](#mybatis)
      * [#{} 和 ${} 的区别](#-和--的区别)
      * [一级缓存是什么](#一级缓存是什么)
      * [二级缓存是什么](#二级缓存是什么)
      * [SpringMVC](#springmvc)
      * [SpringMVC的处理流程](#springmvc的处理流程)
      * [DispatcherServlet的作用](#dispatcherservlet的作用)
      * [DispatcherServlet初始化顺序](#dispatcherservlet初始化顺序)
      * [ContextLoaderListener初始化的上下文和DispatcherServlet初始化的上下的关系](#contextloaderlistener初始化的上下文和dispatcherservlet初始化的上下的关系)
      * [SpringMVC有哪些组件](#springmvc有哪些组件)
      * [SpringMVC有哪些注解](#springmvc有哪些注解)
      * [处理器拦截器](#处理器拦截器)
      * [SpringBoot](#springboot)
      * [Springboot的优点](#springboot的优点)
      * [Springboot的自动配置原理](#springboot的自动配置原理)
      * [什么是CSRF攻击](#什么是csrf攻击)
      * [什么是WebSockets](#什么是websockets)
      * [SpringBoot达成的jar和普通的jar有什么区别?](#springboot达成的jar和普通的jar有什么区别)

<!-- Added by: hanzhigang, at: 2021年 8月17日 星期二 13时52分54秒 CST -->

<!--te-->

### Spring框架概述
- Spring框架是一个轻量级的、开放源代码的J2EE应用程序框架。
- Spring有两个核心部分：IOC和Aop
1. IOC：控制反转，把创建对象的过程交给Spring进行管理。
2. Aop：面向切面，不修改源代码的情况下，进行功能的增加和增强。
- Spring框架的相关的特点
1. 方便解耦，简化开发。
2. Aop编程支持
3. 方便程序的测试
4. 方便整合各种优秀框架
5. 降低Java EE API的使用难度
6. 方便进行事务操作
---
### IOC是什么
IOC控制反转，实现两种方式，依赖查找和依赖注入，主要实现方式是依赖注入。之前创建对象需要new，现在将创建对象的权限交给IOC容器来完成。当容器创建对象的时候主动将它需要的依赖注入给它。
### IOC容器初始化过程
- 基于XML的初始化方法
1. ClassPathXmlApplicationContext初始化父类，调用父类方法初始化资源加载器。通过setConfigLocation方法加载相应的xml配置文件。
2. refresh方法规定了IOC容器初始化的过程，如果之前存在IOC容器则销毁IOC容器，保证每次创建的IOC容器都是新的。
3. 容器创建后通过loadBeanDefinition方法加载Bean的配置信息。主要做两件事：调用资源加载的方法加载相应的资源。通过XmlBeanDefinitonReader方法加载真正的bean的信息，并将xml文件中的信息转换成对应的文件对象。按照Spring Bean的规则对文档对象进行解析。
4. IOC容器中解析的Bean会放到一个HashMap中，key是string，value是BeanDefinition。注册过程中需要使用Synchronized来保证线程安全。当配置信息中配置的Bean被加载到IOC容器后，初始化就算完成了。Bean的定义信息已经可以被定位和检索，IOC容器的作用就是为Bean定义信息进行处理和维护，注册的Bean的定义信息是控制反转和依赖注入的基础。
- 基于注解的初始化方法
1. 直接将所有的注解Bean注册到容器中，可以在容器初始化时进行注册，也可以在容器初始化完成后进行注册，注册完成之后刷新容器，让容器对Bean的注册信息进行处理和维护。
2. 通过扫描指定的包和子包加载所有的类，在初始化注解容器时，指定要扫描的路径。
### 依赖注入的实现方式有哪些
1. setter
2. 构造函数
3. 接口
### 依赖注入的相关注解有哪些
1. @AutoWired 先按照类型，类型相同按照Bean的id
2. @Qualifier 按照类型，Bean的id进行注入
3. @Resource 按照Bean的id进行注入，只能注入Bean类型
4. @Value 只能注入基本数据类型和String类型
### 依赖注入的过程
1. 当IOC容器被初始化完之后，调用doGetBean方法来实现依赖注入。具体方法是通过BeanFactory的createBean完成，通过触发createBeanInstance方法来创建对象实例和populateBean对其Bean属性依赖进行注入。
2. 依赖注入的过程就是将创建的Bean对象实例设置到所依赖的Bean对象的属性上。真正的依赖注入通过setPropertyValues方法实现的。
3. BeanWrapperImpl方法实现对初始化的Bean对象进行依赖注入，对于非集合类型属性，通过JDK反射，通过属性的setter方法设置所需要的值。对于集合类型的属性，将属性值解析为目标类型的集合后直接赋值给属性。
### Bean的生命周期
1. 当完成Bean对象的初始化和依赖注入后，通过调用后置处理器BeanPostProcessor的PostProcessBeforeInitialization方法，在调用初始化方法init-method之前添加我们的实现逻辑，调用init-method方法，之后调用BeanPostProcessor的PostProcessAfterInitialization方法，添加我们的实现逻辑。当Bean调用完成之后，调用destory-method方法，销毁bean。

### Spring Bean的生命周期
- 实例化BeanFactoryPostProcessor实现类
- 执行BeanFactoryPostProcessor的postProcessBeanFactory方法
- 实例化BeanPostProcessor实现类
- 实例化InstantiationAwareBeanPostProcessor实现类
- 执行InstantiationAwareBeanPostProcessor的postProcessBeforeInstantiation方法
- **执行Bean的构造器**
- 执行InstantiationAwareBeanPostProcessor的postProcessPropertyValues方法
- **为Bean注入属性**
- 调用BeanNameAware的setBeanName方法
- 调用BeanFactoryAware的setBeanFactory方法
- 执行BeanPostProcessor的postProcessBeforeInitialization方法
- 调用InitializingBean的afterPropertiesSet方法
- **调用\<bean>的init-method属性指定的初始化方法**
- 执行BeanPostProcessor的postProcessAfterInitialization方法
- 执行InstantiationAwareBeanPostProcessor的postProcessAfterInstantiation方法
- 容器初始化成功，执行正常调用后，下面销毁容器
- 调用DisposibleBean的destory方法
- 调用\<bean>的destroy-method属性指定的初始化方法
  
### Bean的作用范围
1. Singleton
2. Prototype
3. Session
4. global Session
5. request
### 如何通过XML创建Bean

### 如何通过注解创建Bean
1. @Component
2. @Controller
3. @Service
4. @Repository
5. @Bean 被Bean注解的方法返回值是一个对象，将会被实例化，配置和初始化一个对象返回，这个对象只能由Spring IOC容器来管理。
### 如何通过注解配置文件

### BeanFactory，FactoryBean和ApplicationContext的区别
- BeanFactory是一个Bean工厂，使用了简单工厂模式，是Spring IOC容器的顶级接口，可以理解为含有Bean集合的工厂类，负责Bean的实例化，依赖注入，BeanFactory实例化后并不会实例化这些Bean，只有当用到的时候才去实例化，采用懒汉式，适合多例模式。
- FactoryBean是一个工厂Bean，使用了工厂方法模式，作用是生产其他的Bean实例，通过实现接口，通过一个工厂方法来实现自定义实例化Bean的逻辑。
- ApplicationContext是BeanFactory的子接口，扩展了BeanFactory的功能。在容器初始化时对Bean进行预实例化，容器初始化时，配置依赖关系就已经完成，属于立即加载，饿汉式，适合单例模式。
### Spring 扩展接口
- BeanFactoryPostProcessor：Spring允许在Bean创建之前，读取Bean的元属性，并根据自己的需求对元属性进行修改，比如将Bean的scope从singleton改为prototype
- BeanPostProcessor：在每个bean初始化前后做操作
- InstantiationAwareBeanPostProcessor：在bean实例化前做操作
- BeanNameAware、ApplicationContextAware和BeanFactoryAware：针对bean工厂，可以获取上下文，可以获取当前bean的id
- InitialingBean：在属性设置完毕后做一些自定义操作
- DisposibleBean：在关闭容器之前做一些操作
### 循环依赖
- 缓存分为三级：1. `singletonObjects`，一级缓存，存储的是所有创建好了的单例Bean。2. `earlySingletonObjects`，完成实例化，但是还未进行属性注入及初始化对象。3. `singletonFactories`，提前暴露的一个单例工厂，二级缓存中存储的就是这个从工厂中获取的对象。
- 每个缓存的作用：1. 一级缓存中存放的是已经完全创建好的单例Bean。2. 三级缓存中存放的是在完成Bean的实例化后，属性注入之前Spring将Bean包装成一个工厂。
#### Spring是如何解决循环依赖的？
Spring通过三级缓存解决了循环依赖，其中一级缓存为单例池`singletonObjects`，二级缓存为早期曝光对象`earlySingletonObjects`，三级缓存为早期曝光对象工厂`singletonFactories`。

当A、B两个类发生循环引用时，在A完成实例化后，就使用实例化后的对象去创建一个对象工厂，并添加到三级缓存中，如果A被AOP代理，那么通过这个工厂获取到的就是A代理后的对象，如果A没有被AOP代理，那么这个工厂获取到的就是A实例化后的对象。

当A进行属性注入时，会去创建B，同时B又依赖了A，所以创建B的同时又会去调用getBean(a)来获取需要的依赖，此时的getBean(a)会从缓存中获取：

第一步，先获取到三级缓存中的工厂；

第二步，调用对象工厂的getObject方法来获取到对应的对象，得到这个对象后将其注入到B中。紧接着B会走完它的生命周期，包括初始化、后置处理器等。

当B创建完后，会将B再注入到A中，此时A再完成它的整个生命周期。至此，循环依赖结束。

#### 为什么要使用三级缓存呢？二级缓存能解决循环依赖吗？

如果要使用二级缓存来解决循环依赖，意味着所有Bean在实例化后就要完成AOP代理，这样违背了Spring设计的原则，Spring在设计之初就是通过`AnnotationAwareAspectJAutoProxyCreator`这个后置处理器来在Bean生命周期的最后一步来完成AOP代理，而不是在实例化后就立马进行AOP代理。

---
### 什么是AOP
### AOP的相关注解有哪些
1. @Aspect：声明被注解的类是一个切面Bean
2. @Before：前置通知。指在某个连接点之前执行的通知。
3. @After：后置通知：在某个连接点退出时执行的通知(不论正常返回还是异常退出)
4. @AfterReturning：返回后通知。
5. @AfterThrowing：异常通知，方法抛出异常导致退出时执行的通知。

### AOP的相关术语
1. Aspect：切面，一个关注点的模块化，这个关注点可能会横切多个对象。
2. Joinpoint：连接点，程序执行过程中的某一行为，即业务层中的所有方法。
3. Advice：通知，指切面对于某个连接点所产生的的动作，包括前置通知，后置通知，返回后通知，异常通知和环绕通知。
4. Pointcut：切入点，指被拦截的连接点，切入点一定是连接点，但连接点不一定是切入点。
5. Proxy：代理
6. Target：代理的目标对象，指一个或多个切面所通知的对象。
7. Weaving：织入，指把增强应用到目标对象来创建代理对象的过程。

### AOP的过程
1. AOP是从BeanPostProcessor后置处理器开始，后置处理器可以监听容器触发的Bean生命周期时间，向容器注册后置处理器以后，容器中管理的Bean就具备了接收IOC容器回调事件的能力。
2. BeanPostProcessor的调用发生在SpringIOC容器完成Bean实例对象的创建和属性的依赖注入后，为Bean对象添加后置处理器的入口是initialization方法。
3. Spring中JDK动态代理通过JdkDynamicAopProxy调用Proxy的newInstance方法来生成代理类，JdkDynamicAopProxy也实现了InvocationHandler接口，invoke方法的具体逻辑是先获取应用到此方法上的执行器链，如果有执行器则创建MethodInvocation并调用proceed方法，否则直接反射调用目标方法。因此Spring AOP对目标对象的增强是通过拦截器实现的。
--- 
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

### Spring框架中用到了哪些设计模式？
- 工厂设计模式：Spring使用工厂模式通过BeanFactory、ApplicationContext创建bean对象
- 代理设计模式：Spring AOP功能的实现
- 单例设计模式：Spring中的Bean默认都是单例的
- 包装器设计模式：我们的项目需要连接多个数据库，而且不同的客户在每次访问中根据需要访问不同的数据库，这种模式会让我们根据客户的需求能够动态切换不同的数据源。
- 观察者模式：Spring事件驱动模型
- 适配器模式：Spring AOP的增强或通知使用到了适配器模式，Spring MVC中也使用到了适配器模式适配Controller


### Spring涉及到的几种设计模式

---

### MyBatis
### #{} 和 ${} 的区别
${} 相当于使用字符串拼接，存在SQL注入风险。
\#{} 相当于使用占位符，可以防止SQL注入，动态参数。

### 一级缓存是什么
- 是SqlSession级别的，操作数据库时需要创建SqlSession对象，对象中有一个HashMap存储缓存数据，不同的SqlSession之间缓存数据区域互不影响。在同一个SqlSession中执行两次相同的SQL语句，第一次执行完毕会将结果保存到缓存中，第二次查询时直接从缓存中获取。
- 如果SqlSession执行了DML操作(IUD)，MyBatis必须将缓存清空保证数据有效性。
### 二级缓存是什么
二级缓存是Mapper级别的，默认关闭。多个SqlSession可以共用二级缓存，作用域是Mapper的同一个namespace。

---
### SpringMVC
### SpringMVC的处理流程
1. Web容器启动时，会通知Spring初始化容器，加载Bean的定义信息并初始化所有单例Bean，然后遍历容器中的Bean，获取每一个Controller中的所有方法访问的URL，将URL和对应的Controller放到一个Map中。
2. 所有请求都发给DispatcherServelet前端处理器处理，DispatcherServelet会请求HandlerMapping寻找被Controller注解修饰的Bean和被RequestMapping修饰的方法和类。生成Handler和HandlerInterceptor，并以HandlerExecutionChain这样一个执行器链的形式返回。
3. DispatcherServlet使用Handler寻找对应的HandlerAdapter，HandlerAdapter执行相应的Handler方法，并把请求参数绑定到方法形参上，执行方法获得ModelAndView。
4. DispatcherServelet将ModelAndView讲给ViewResolver进行解析，得到View的物理视图，然后对视图进行渲染，将数据填充到视图中返回给客户端。

### DispatcherServlet的作用
- DispatcherServlet是前端控制器设计模式的实现，提供SpringWebMVC的集中访问点，而且负责职责的分派，而且与SpringIoC容器无缝集成，从而可以获得Spring的所有好处。DispatcherServlet主要用作职责调度工作，本身主要用于流程控制
1. 文件上传解析，如果请求类型是multipart将通过MultipartResolver进行文件上传解析。
2. 通过HandlerMapping，将请求映射到处理器(返回一个HandlerExecutionChain，它包含一个处理器、多个HandlerInterceptor拦截器)。
3. 通过HandlerAdapter支持多种类型的处理器(HandlerExecutionChain处理器)。
4. 通过ViewResolver解析逻辑视图名到具体视图实现。
5. 本地化渲染。
6. 渲染具体的视图等。
7. 如果执行过程中遇到异常交给HandlerExceptionResolver来解析。
### DispatcherServlet初始化顺序
- HttpServletBean继承HttpServlet，在Web容器启动时将调用它的init方法，(1)该初始化方法的主要作用是将Servlet初始化参数设置(init-param)到该组件上(如contextAttribute、contextClass、namespace、contextConfigLocation)，将通过BeanWrapper简化设值过程，方便后续使用。(2) 提供子类初始化扩展点，initServletBean()，该方法由FrameServlet覆盖。
- FrameServlet继承HttpServletBean，通过initServletBean()进行Web进行上下文初始化，该方法主要覆盖两件事情，初始化Web上下文，提供给子类初始化扩展点。
- DispatcherServlet继承FrameworkServlet，并实现了onRefresh()方法提供一些前端控制器的相关配置。
**综上，DispatcherServlet初始化主要做了两件事**
- 初始化SpringWebMVC使用的Web上下文，并且可能指定父容器为ContextLoaderListener。
- 初始化DispatcherServlet使用的策略，如HandlerMapping、HandlerAdapter等
### ContextLoaderListener初始化的上下文和DispatcherServlet初始化的上下的关系
 - ContextLoaderListener初始化的上下文加载的Bean是对于整个应用程序共享的，一般是DAO层，Service层Bean。
 - DispatcherServlet初始化上下文加载的Bean是只对SpringWebMVC有效的Bean，如Controller、HandlerMapping、HandlerAdapter等，该初始化上下文应该只是加载Web相关组件
### SpringMVC有哪些组件

### SpringMVC有哪些注解

### 处理器拦截器
- 常见应用场景：日志记录，权限检查，性能监控，通用行

---
### SpringBoot

### Springboot的优点
1. 独立运行：SpringBoot内嵌了各种servlet容器，Tomcat等，现在不需要达成war包部署到容器中，SpringBoot只需要达成一个jar包就能独立运行，所有的依赖包都在一个jar包中。
2. 简化配置：spring-boot-starter-web启动器自动依赖其他组件，减少了很多maven的配置。
3. 自动配置：springboot能够根据当前类路径下的类，jar包来自动配置bean，如添加一个spring-boot-starter-web启动器就能拥有web的功能，无需其他配置。
4. 无代码生成和xml配置
5. 避免大量的mave导入和各种版本冲突。
6. 应用监控。
### Springboot的自动配置原理
1. SpringBoot启动时会加载大量的自动配置类
2. 从类路径的META-INF/spring.factories中获取EnableAutoConfiguration指定的值。将这些值作为自动配置类导入到容器中，自动配置类就生效，帮我们进行自动配置工作。
3. 我们看我们需要的功能有没有在SpringBoot默认写好的配置类中。
4. 再来看这个自动配置类配置了哪些组件
5. 给容器中自动配置类添加组件的时候，会从properties类中获取某个属性，只需要在配置文件中指定这些属性的值即可。xxxAutoConfiguration：自动配置类，xxxProperties：封装配置文件中的相关属性。

### 什么是CSRF攻击

### 什么是WebSockets

### SpringBoot达成的jar和普通的jar有什么区别?
