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
        - 在bean标签中的属性
        id 属性 class 属性(类全路径)
        - 创建参数时，默认也是执行无参的构造方法。
    - 基于xml方式注入属性
        - DI：依赖注入
        - 通过设值注入的方式注入属性
        - 通过有参构造方式注入属性
        - xml注入其他类型属性
<br>
- IOC操作Bean管理(基于注解)