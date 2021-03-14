# 初始化问题
```java
class Bowl {
    Bowl(int marker) {
        System.out.println("Bowl(" + marker + ")");
    }
}
class Tableware {
    static Bowl bowl7 = new Bowl(7);
    static {
        System.out.println("Tableware静态代码块");
    }
    Tableware() {
        System.out.println("Tableware构造方法");
    }
    Bowl bowl = new Bowl(6);
}
class Table extends Tableware {
    {
        System.out.println("Table非静态代码块_1");
    }
    Bowl bowl5 = new Bowl(5);
    {
        System.out.println("Table非静态代码块_2");
    }
    static Bowl bowl1 = new Bowl(1);
    static {
        System.out.println("Table静态代码块");
    }
    Table() {
        System.out.println("Table构造方法");
    }
    static Bowl bowl2 = new Bowl(2);
}
class Cupboard extends Tableware {
    Bowl bowl3 = new Bowl(3);
    static Bowl bowl4 = new Bowl(4);
    Cupboard() {
        System.out.println("Cupboard构造方法");
    }
    void otherMethod(int marker) {
        System.out.println("otherMethod(" + marker + ")");
    }
}
public class StaticInitialization {
    public static void main(String[] args) {
        System.out.println("main()");
        cupboard.otherMethod(1);

    }
    static Table table = new Table();
    static Cupboard cupboard = new Cupboard();
}
```
### 最终输出结果？

### 涉及的知识点：
1. 在类的内部，变量定义的先后顺序决定了初始化顺序。即使变量定义遍布在方法定义之间，它们仍旧会在任何方法(包括构造方法)被调用之前得到初始化。
2. 无论创建多少个对象，静态数据都只占用一份存储区域。static关键字不能应用于局部变量，因此它只能作用在域。如果一个域是静态的基本数据类型，且也没有对它进行初始化，那么它就会获得基本类型的标准初值；如果它是一个对象引用，那么它的默认初始化值就是null。
3. 静态初始化只能在必要时刻才进行，例如：类里面的静态变量，只有当类被调用时才会初始化，并且静态变量不会再次被初始化(执行)，即静态变量只会初始化(执行)一次。
4. 初始化的顺序是先静态对象，然后是非静态对象。
5. 当有父类时，完整的初始化顺序为：父类静态变量(静态代码块) -> 子类静态变量 -> 父类非静态变量 -> 父类构造器 -> 子类非静态变量 -> 子类构造器


### 在JVM角度谈初始化问题