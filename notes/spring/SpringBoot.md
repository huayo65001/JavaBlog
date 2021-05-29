# SpringBoot
## 自动装配原理
- pom.xml
  - spring-boot-dependencies:核心依赖在父工程中
  - 写或者引入springboot依赖的时候，不需要指定版本，因为有这些版本仓库
- 启动器
- 注解
  - SpringBootConfiguration：启动器
  - EnableAutoConfiguration:自动配置
### SpringBoot自动装配的原理
1. SpringBoot启动会加载大量的自动配置类
2. 看我们需要的功能有没有在SpringBoot默认写好的自动配置类中
3. 我们再来看这个自动配置类中到底配置了哪些组件。（只要我们要用到的组件存在其中，就不需要再手动配置）
4. 给容器中自动配置类添加组件时，会从properties类中获取某些属性。我们只要在配置文件中指定这些属性的值即可。xxxAutoConfiguration: 自动配置类，给容器中添加组件。xxxProperties：封装配置文件中相关属性。
## 微服务架构

## yaml
- yaml 可以直接给实体类赋值