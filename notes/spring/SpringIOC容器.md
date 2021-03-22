# IOC
- IOC底层原理
    - 什么是IOC
        Inversion of Control 控制反转，降低计算机代码之间的耦合度
        把对象的创建和对象之间调用的过程，交给Spring进行管理
    - IOC底层原理
    1. xml解析、工厂模式、反射
    通过xml解析获得在xml文件中的类路径，然后通过反射来创建该类的实例
<br>
- IOC接口(BeanFactory)
    - IOC思想基于IOC容器完成，IOC容器底层就是对象工厂。
    - Spring提供IOC容器两种实现方式：
    1. BeanFactory：IOC容器基本实现，是Spring内部的使用接口，不提供开发人员使用，加载配置文件不会创建对象，在获取对象才去创建对象。
    2. ApplicationContext：BeanFactory接口的子接口，提供更多强大的功能，一般由开发人员进行使用。加载配置文件时候就会把在配置文件对象进行创建。
    <div align="center"> <img src="https://github.com/Eric-Han0521/JavaBlog/blob/main/notes/spring/pic/ApplicationContextHierarchy.png"/> </div><br>

- 什么是Bean管理
    Bean管理指两个操作，Spring创建对象，Spring注入属性
    - Bean管理操作有两种方式
    (1)基于xml配置文件方式
    (2)基于注解方法实现
<br>
- IOC操作Bean管理(基于xml)
    - 基于xml方式创建对象
        - 在Bean标签中的属性
        id 属性 class 属性(类全路径)
        - 创建参数时，默认也是执行无参的构造方法。
    - 基于xml方式注入属性
        - DI：依赖注入
        - 通过设值注入的方式注入属性
        - 通过有参构造方式注入属性
        - xml注入其他类型属性
    - FactoryBean
        - 普通Bean：在配置文件中定义Bean类型就是返回类型
        - 工厂Bean：在配置文件中定义Bean类型和返回类型不一样
    - Bean的作用域
        - 在Spring中可以设置创建的Bean实例是单实例还是多实例
        - 在Spring中在默认情况下，创建的Bean是单实例对象
    - Bean的生命周期
    - 外部属性文件
        - 直接配置数据库信息(配置数据库连接池)
        - 引入外部属性文件配置数据库连接池
            - 创建外部属性文件，properties格式文件，写数据库信息
            - 把外部properties属性文件引入到Spring配置文件中
<br>
- IOC操作Bean管理(基于注解)
    - 针对创建对象提供的注解
    @Component/@Service/@Controller/@Repository  四个注解它们的功能是一样的，都可以用来创建Bean的实例
    - 基于注解方式实现属性注入
    @AutoWired 根据属性类型进行自动装配
    @Qualifier 根据属性名称进行注入
    @Resource 可以根据类型注入，可以根据名称注入

<br>

- Spring Bean的生命周期
    - 实例化BeanFactoryPostProcessor实现类
    - 执行BeanFactoryPostProcessor的postProcessBeanFactory方法
    - 实例化BeanPostProcessor实现类
    - 实例化InstantiationAwareBeanPostProcessorAdapter实现类
    - 执行InstantiationAwareBeanPostProcessor的postProcessBeforeInstantiation方法
    - 执行Bean的构造器
    - 执行InstantiationAwareBeanPostProcessor的postProcessPropertyValues方法
    - 为Bean注入属性
    - 调用BeanNameAware的setBeanName方法
    - 调用BeanFactoryAware的setBeanFactory方法
    - 执行BeanPostProcessor的postProcessBeforeInitialization方法
    - 调用InitializingBean的afterPropertiesSet方法
    - 调用\<bean>的init-method属性指定的初始化方法
    - 执行BeanPostProcessor的postProcessAfterInitialization方法
    - 执行InstantiationAwareBeanPostProcessor的postProcessAfterInitialization方法
    - 容器初始化成功，执行正常调用后，下面销毁容器
    - 调用DisposibleBean的destory方法
    - 调用\<bean>的destroy-method属性指定的初始化方法


- Spring IOC有什么好处？
    