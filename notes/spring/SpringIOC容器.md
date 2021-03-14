# IOC
- IOC底层原理
    - 什么是IOC
        Inversion of Control 控制反转，降低计算机代码之间的耦合度
        把对象的创建和对象之间调用的过程，交给Spring进行管理
    - IOC底层原理
    1. xml解析、工厂模式、反射
    通过xml解析获得在xml文件中的类路径，然后通过反射来创建该类的实例
- IOC接口(BeanFactory)
    - IOC思想基于IOC容器完成，IOC容器底层就是对象工厂。
    - Spring提供IOC容器两种实现方式：
    1. BeanFactory：IOC容器基本实现，是Spring内部的使用接口，不提供开发人员使用，加载配置文件不会创建对象，在获取对象才去创建对象。
    2. ApplicationContext：BeanFactory接口的子接口，提供更多强大的功能，一般由开发人员进行使用。加载配置文件时候就会把在配置文件对象进行创建。
    <div align="center"> <img src="https://github.com/Eric-Han0521/JavaBlog/blob/main/notes/spring/pic/ApplicationContextHierarchy.png"/> </div><br>

- IOC操作Bean管理(基于xml)
- IOC操作Bean管理(基于注解)