# SpringMVC

<br>
- DispatcherServlet的作用
    - DispatcherServlet是前端控制器设计模式的实现，提供SpringWebMVC的集中访问点，而且负责职责的分派，而且与SpringIoC容器无缝集成，从而可以获得Spring的所有好处。DispatcherServlet主要用作职责调度工作，本身主要用于流程控制
    1. 文件上传解析，如果请求类型是multipart将通过MultipartResolver进行文件上传解析。
    2. 通过HandlerMapping，将请求映射到处理器(返回一个HandlerExecutionChain，它包含一个处理器、多个HandlerInterceptor拦截器)。
    3. 通过HandlerAdapter支持多种类型的处理器(HandlerExecutionChain处理器)。
    4. 通过ViewResolver解析逻辑视图名到具体视图实现。
    5. 本地化渲染。
    6. 渲染具体的视图等。
    7. 如果执行过程中遇到异常交给HandlerExceptionResolver来解析。
<br>
- ContextLoaderListener初始化的上下文和DispatcherServlet初始化的上下的关系
    - ContextLoaderListener初始化的上下文加载的Bean是对于整个应用程序共享的，一般是DAO层，Service层Bean。
    - DispatcherServlet初始化上下文加载的Bean是只对SpringWebMVC有效的Bean，如Controller、HandlerMapping、HandlerAdapter等，该初始化上下文应该只是加载Web相关组件。
<br>
- DispatcherServlet初始化顺序
    - HttpServletBean继承HttpServlet，在Web容器启动时将调用它的init方法，(1)该初始化方法的主要作用是将Servlet初始化参数设置(init-param)到该组件上(如contextAttribute、contextClass、namespace、contextConfigLocation)，将通过BeanWrapper简化设值过程，方便后续使用。(2) 提供子类初始化扩展点，initServletBean()，该方法由FrameServlet覆盖。
    - FrameServlet继承HttpServletBean，通过initServletBean()进行Web进行上下文初始化，该方法主要覆盖两件事情，初始化Web上下文，提供给子类初始化扩展点。
    - DispatcherServlet继承FrameworkServlet，并实现了onRefresh()方法提供一些前端控制器的相关配置。
    **综上，DispatcherServlet初始化主要做了两件事**
    - 初始化SpringWebMVC使用的Web上下文，并且可能指定父容器为ContextLoaderListener。
    - 初始化DispatcherServlet使用的策略，如HandlerMapping、HandlerAdapter等。

### Controller
- MVC中的C包括控制逻辑和功能处理(DispatcherServlet+Controller)
- Controller控制器是MVC中部分的C，主要负责功能处理部分，主要用于收集、验证请求参数并绑定到命令对象。将命令对象交给业务对象，由业务对象返回并返回模型数据。返回ModelAndView。


### 处理器拦截器
- 常见应用场景：
    - 日志记录
    - 权限检查
    - 性能监控
    - 通用行为