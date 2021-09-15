[TOC]

A-Z的ASCII码:65-90   a-z：65+32-90+32 -->

### 1.int与Integer的基本使用对比

Integer是int的包装类；int是基本数据类型；
Integer变量必须实例化后才能使用；int变量不需要；
Integer实际是对象的引用，指向此new的Integer对象；int是直接存储数据值 ；
Integer的默认值是null；int的默认值是0。

### 2.String不可变的原因、好处

原因：Java9之后使用byte数组存储字符串，被声明为final，这意味着 value 数组初始化之后就不能再引用其它数组。并且 String 内部没有改变 value 数组的方法，因此可以保证 String 不可变。

好处：

##### 1.可以缓存hash值

String的hash值被经常使用（例如用作Hashmap的key），保证不变hash值不会改变，只需要计算一次。

##### 2.String Pool

String对象创建过，会到StringPool中引用。（StringPoll：创建字符串时，如果存在池中，则返回现有字符串的引用，不创建新对象）。

##### 3.安全

String经常作为参数，不可改变保证参数不便。（例如网络连接参数）

##### 4.线程安全

不可变，天生线程安全，不用考虑同步问题。

### 3.StringBuilder、StringBuffer

StringBuffer是线程安全的，类中的方法都添加了**synchronized关键字**，也就是给这个方法添加了一个锁，用来保证线程安全。，而StringBuilder则没有实现线程安全功能，所以性能略高。

### 4.new String("abc")

使用这种方式创建两个对象（StringPool中没有）。

1.“abc”是字符串字面量，编译时会在StringPool中创建一个对象，指向字面量。

2.使用new的方式会在堆中创建一个字符串对象。

### 5.final

##### 1.数据

基本类型：值不能改变。

引用类型：不能在引用其他对象，对象本身可以修改。

##### 2.方法

不能被子类重写

private声明的方法隐形被指定为final，若子类中定义的方法与基类private方法名相同，不是重写，而是重新定义了一个方法。

##### 3.类

不能被继承。

### 6.Object等价与相等

==：判断两个变量是否引用同一个对象。

.equals()：判断引用的对象是否等价。

### 7.散列

Hashmap通过键值对保存信息，如果键没有按照一定顺序排列，则只能线性查找，非常慢。散列是将键保存在数组中，用数组表示键的信息，因为数组长度不可变，所以用键生成一个对象作为下标，这个值就是散列码。

### 8.浅拷贝与深拷贝

##### 1.浅拷贝

基本类型拷贝值，引用类型拷贝内存地址，所以其中一个对象改变，会影响另一个对象。

实现：需要实现Coloneable接口，并重写clone()方法。

##### 2.深拷贝

基本类型拷贝值，引用类型重新创建新的对象空间，拷贝内容。

实现：对于有多层对象的，每个对象都要实现Cloneable接口，并重写clone()方法。

##### 3.替代方案

拷贝构造函数或拷贝工厂。

##### 4.深拷贝方法

1.构造函数

调用构造函数进行深拷贝，基本类型直接赋值，对象则重新new一个。

缺点：新增成员变量需要新增新的拷贝构造函数

2.实现Cloneable接口

类及所有成员变量的类都要实现接口，并重写clone()方法，并且需要拷贝的类的clone()方法内，调用成员变量的clone()方法。

3.序列化

Jackson、Gson、Apache Commons Lang包。先序列化对象，再反序列化生成拷贝对象。

需要实现Serializable接口。

### 9.抽象类与接口

抽象类不能被实例化，只能被继承。

接口在java8之前相当于完全抽象的类，不能实现任何方法，java8之后可以有自己方法的实现；接口的字段、方法默认public，不能是private、protected，java9之后可以是private，可以定义某些复用代码而不把方法暴露出去。

##### 区别

一个类可以实现多个接口，但只能继承一个抽象类。

接口的字段是static、final的，抽象类没限制。

接口的成员是public的，抽象类的成员可以有多种访问权限。

使用接口：不同的类实现同样的方法；使用抽象类：相同的类共享代码。接口优于抽象类，比较灵活。java8之后可以有自己方法实现，方便维护。

### 10.重写、重载

##### 重写 Override

继承体系中，子类实现一个与父类方法声明上完全相同的方法。

@Override注解作用：检查里氏替换原则

1.子类方法的访问权限需大于等于父类方法。

2.子类方法的返回值类型需是父类方法返回值类型或子类型。

3.子类方法抛出的异常类型需是父类方法异常类型或子类型。

##### 重载Overload

同一个类中，一个方法与已经存在的方法名相同，但参数的类型、个数、顺序有一个不相同。返回值不同，其他相同不是重载（会报错）。

### 11.异常

java通过面向对象的方法处理异常，每个异常都是一个对象，是Throwable及其子类的实例化。当一个方法出现异常便抛出一个异常对象，对象中包含异常信息，调用方法可以捕获异常并对其进行处理。

java异常通过5个关键字实现：try，catch，finally，throw，throws。

try：用来指定一块需要预防异常的程序。

catch：用来捕获指定异常类型的异常。

finally：确保不管发生什么异常都会执行的代码块。

throw：用来抛出指定异常。

throws：用来声明一个方法可能抛出的各类异常。

常见的异常类型：算术异常，空指针异常，数组越界异常，非法参数异常，找不到类异常等等。

**finally不执行的情况：**1.System.exit在finally前面；2.cpu关闭；3.线程死亡。

### 12.泛型

泛型就是参数化类型，将数据类型指定为一个参数，通过泛型指定的类型来控制具体限制的类型，编译时检查。

泛型通过类型擦除来实现，在编译时擦除了所有类型的相关信息，在运行时不存在任何类型的信息。擦除后泛型有两种转换形式：如果没有设置类型上界，转化为Object类型，如果设置了类型上界，则转化为类型上界。

限定通配符：<? extend T>：设置类型上界，类型是类型T的子类；<? super T>：设置类型下界，类型是类型T的父类。

Array不能用泛型。

### 13.Java C++

java面向对象，C++面向对象也面向过程。

java使用虚拟机实现跨平台，C++特定平台。

java没有指针，C++跟C一样有指针。

java没有多重继承，通过接口实现，C++有多重继承。

java支持自动垃圾回收，C++手动回收。

java的goto是保留字，C++可以使用goto。goto本质是流程控制，流程三种：子流程，循环，条件。函数调用，for，if等流程控制符可以控制所有流程，goto没必要用。

### 14.JVM、JRE、JDK

JVM:Java虚拟机(Java Virtual Machine)

JRE:Java运行环境(Java Runtime Enviroment)，JVM+核心类库

JDK:Java开发工具包(Java Development Kit)，JRE+Java开发工具

Java11之后JRE、JDK统一，没有JRE了。

javac.exe:编译器，将.java文件编译为字节码文件.class。

java.exe:运行字节码文件.class，由JVM对字节码进行解释和运行。

### 15.JIT 及时编译

JIT编译器在将字节码编译过一次后的机器码保存下来，下次可以直接使用。

java程序通过解释器进行解释执行，当某些方法或代码块频繁被执行，则被认为是热点代码，通过JIT（即时编译器）将字节码转换成机器码。

##### 为什么解释器与编译器并存？

当程序需要快速启动和执行的时候，使用解释器解释执行，省去编译的时间。当程序运行一段时间后，编译器发挥作用，将热点代码编译为机器码，可以获得更高的执行效率。当程序运行环境内存资源限制大时，用解释器节省内存空间；反之用编译器JIT提升效率。

### 16.静态方法调用非静态成员非法

静态成员属于类，可以直接用类名访问，在类加载的时候就分配内存；而非静态成员属于实例对象，只有对象实例化后才存在，再通过类的实例化对象去访问。所以非静态成员不存在的时候静态成员就存在了。

静态方法只允许访问静态成员。

### 17.成员变量、局部变量

1.成员变量属于类，局部变量属于代码块或方法。成员变量可以被public、private、static、final修饰，局部变量只能被final修饰。

2.内存存储方式来看，静态成员变量属于类，不加static的变量属于实例对象，存在堆内存中；而局部变量存在虚拟机栈中的局部变量表里。

3.生存时间来看，成员变量随对象创建而创建，局部变量在方法调用创建，执行结束死亡。

4.成员变量初始化会赋默认值，局部变量不赋默认值。

### 18.构造方法

类的构造方法是为了类对象的初始化。

不写构造方法会调用无参数的构造方法，定义了构造方法new的时候不能不传参数了。

构造方法名与类名相同，没有返回值且不能void声明，生成对象时自动执行，无需调用。

构造方法不可以override，但可以overload，可以有多个构造方法。

### 19.Java三大特性

1.封装：把一个对象的状态信息隐藏在内部，不允许外部直接访问内部的信息。但是可以提供一些外部可以调用的方法来操作属性。

2.继承：使用已存在的类的定义来创建新的类技术。

3.多态：一个对象具有多种状态，具体表现为父类引用指向子类对象。实现方式：重写、接口、抽象类。

### 20.序列化、反序列化

序列化：将对象或数据结构转换成二进制字节流。

反序列化：将序列化生成的二进制字节流转换成对应的对象或数据结构。

目的：通过网络传输对象或将对象存储在文件、数据库中。

transient关键字：修饰的变量不会被序列化。

##### 序列化方式

1.Java原生序列化

实现Serializable接口，会保存对象的元数据及对象数据。

2.Hessian序列化

可以跨语言的序列化方式。

3.JSON序列化

将对象数据转换为json字符串，抛弃了类型信息，在反序列化时需要制定类型信息。可读性较好。

### 21.键盘输入方式

##### 1.Scanner

```java
Scanner input = new Scanner(System.in);
String s = input.nextLine();
input.close();
```

##### 2.BufferedReader

```java
BufferedReader input = new BufferedReader(new InputStreamReader(System.in));
String s = input.readLine();
```

### 22.将数组转换为ArrayList

##### 1.手动转换

##### 2.new一个ArrayList

```java
//不支持基本数据类型
//使用后数组跟列表连接起来，一个更新，另一个也改变
List list = new ArrayList<>(Arrays.asList(array));
```

##### 3.Java8的Arrays.stream

```java
//包装类
Integer[] myArray = {1, 2, 3};
List myList = Arrays.stream(myArray).collect(Collectors.toList());
//基本类型
int[] myArray = {1, 2, 3};
List myList = Arrays.stream(myArray).boxed().collect(Collectors.toList());
```

##### 4.Java9的List.of()

```java
//不支持基本类型
Integer[] myArray = {1, 2, 3};
List myList = List.of(myArray);
```

### 23.查看大小

length：数组

length()：字符串

size()：泛型集合

### 24.I/O

##### 1.I/O

同步、异步是通信机制，阻塞、非阻塞是调用状态。

同步I/O：线程发起I/O请求会进行等待或轮询，I/O操作完成后再执行。

异步I/O：线程发起I/O请求后可以继续执行。

阻塞I/O：I/O操作要彻底完成后才能返回用户空间。

非阻塞I/O：I/O操作开始后立即返回一个状态值，无需等待彻底完成。

##### 2.BIO

同步阻塞I/O

##### 3.NIO

同步非阻塞I/O

##### 4.AIO

异步非阻塞I/O

##### 5.既然有了字节流,为什么还要有字符流?

字符流是由 Java 虚拟机将字节转换得到的，问题就出在这个过程还算是非常耗时，并且，如果我们不知道编码类型就很容易出现乱码问题。所以， I/O 流就干脆提供了一个直接操作字符的接口，方便我们平时对字符进行流操作。如果音频文件、图片等媒体文件用字节流比较好，如果涉及到字符的话使用字符流比较好。

### 25.反射

reflect

反射是在运行时才知道要操作的类是什么，并且在运行时获得类的完整构造，并可以调用其方法。

```java
//获取类的对象实例
Class studentClass = Class.forName("com.zhou.pojo.Student");

//根据对象获取构造器对象
//class.newInstance()默认无参构造
Object student = studentClass.newInstance();

//使用构造器可以进行有参构造
Constructor studentConstructor = studentClass.getConstructor();
//根据构造器对象获取反射类对象
Object student = studentConstructor.newInstance();

//根据对象获取方法对象
Method setStudentName = studentClass.getMethod("setName", String.class);
//使用invoke()方法调用方法
setStudentName.invoke("Eric");

//获取类的属性
//getFields()获取不到private属性
Field[] fields = studentClass.getFields();
for (Field field :fields){
    System.out.println(field.getName());
}
//getDeclaredFields()可以获取private属性
Field[] fields = studentClass.getDeclaredFields();
```

**MethodAccessor:**

Method的invoke()方法调用MethodAccessor类的invoke()方法进行处理。

MethodAccessor有两个版本，一个是native版本，一个是Java版本。

native版本的MethodAccessor启动速度快，但随运行时间变长速度变慢；java版本的MethodAccessor启动速度慢，但随运行时间变长速度变快。

在第一次调用invoke()时，使用NativeMethodAccessorImpl实现，在反射调用超过15次之后，使用MethodAccessorGenerator生成的MethonAccessor。

### 26.equals

##### 1.为什么重写equals必须重写hashCode

如果两个对象相等，则hashCode一定相同。

如果两个对象相等，调用equals()方法都返回true。

两个对象hashCode相同，对象不一定相等。

如果让对象充当HashMap的key时，如果不重写hashCode方法，那两个内容相同的对象因为hashCode值不同，都会存在map中，这样一个key存了两遍，所以必须重写hashCode()。

### 27.BigDecimal

用来操作浮点数

### 28.子类初始化顺序

1.父类静态变量和静态方法

2.子类静态变量和静态方法

3.父类普通变量和普通方法

4.父类构造方法

5.子类普通变量和普通方法

6.子类构造方法

### 29.java按值调用

按值调用：方法接收的是参数的值。

引用调用：方法接受的是参数的地址。

java总是按值调用，对于基本类型，在方法中改变参数的值，不会改变实参的值；对于引用类型，在方法中改变引用的内容，实参也改变，但不能改变实参的引用。

### 30.Class类

程序运行时，会为每一个对象维护一个运行时的类型标识，获取类的各种信息，包括类名、属性、方法、构造等等，保存这个信息的类就是Class类。

##### 获取Class对象：

1.对象.getClass()

2.类名.class

3.Class.forName(类的全限定名（包名+类名）)

获取Class对象后可以调用newInstance()方法创建对象，默认调用无参构造。

### 31.CSRF

Cross-site Request Forgery跨站请求伪造。攻击者通过伪造浏览器的请求，向一个用户曾经认证访问过的网站发送请求，使目标网站接收并误以为用户的真实操作。

常用于盗号、转账、发送虚假信息。

##### 如何避免：

1.服务器验证HTTP请求头的Referer字段，Referer字段保存请求的来源地址。

2.在页面添加验证码，服务器验证验证码。

3.请求地址添加token，服务器解码token验证。

4.在HTTP请求头中自定义属性。通过XMLHttpRequest类为所有该类请求添加请求头属性，将token放在其中，这样token不需要添加在url中。

### 32.AutoCloseable

java.lang包下的一个接口，主要用于管理资源，准确的说是释放资源。

资源类实现AutoCloseable接口，需要重写close()方法。

数据库连接类Connection，io类InputStream和OutputStream使用到了此接口。

try-with-resources语法糖

```java
public class Resource implements AutoCloseable{
    public void read() {
        System.out.println("do something");
    }
 
    @Override
    public void close() throws Exception {
        System.out.println("closed");
    }
}
public static void f2(){
    try(Resource resource = new Resource()) {
        resource.read();
    } catch (Exception e) {
    }
}
```



1.使用try-with-resources语法，无论是否抛出异常，在执行完后都会调用close()方法。

2.使用try-with-resources语法创建多个资源，close()方法的执行顺序和创建资源顺序相反。

3.使用try-with-resources语法，抛出异常后先执行所有资源的close()方法，再执行catch里面的代码，最后执行finally里的代码。
