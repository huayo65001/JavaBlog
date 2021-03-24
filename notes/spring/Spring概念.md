# Spring概念

- Spring框架概述
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
<br>

- Spring框架中用到了哪些设计模式？
    - 工厂设计模式：Spring使用工厂模式通过BeanFactory、ApplicationContext创建bean对象
    - 代理设计模式：Spring AOP功能的实现
    - 单例设计模式：Spring中的Bean默认都是单例的
    - 包装器设计模式：我们的项目需要连接多个数据库，而且不同的客户在每次访问中根据需要访问不同的数据库，这种模式会让我们根据客户的需求能够动态切换不同的数据源。
    - 观察者模式：Spring事件驱动模型
    - 适配器模式：Spring AOP的增强或通知使用到了适配器模式，Spring MVC中也使用到了适配器模式适配Controller