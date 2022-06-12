介绍QL语言相关知识，如谓词、类型、表达式等概念。

QL是一种声明性的、面向对象的查询语言。官方文档[关于QL语言](https://codeql.github.com/docs/ql-language-reference/about-the-ql-language/#about-the-ql-language)

仅对QL中常用的语法结构做简单的介绍，深入理解可查阅官方文档。

# 谓词
官方文档[谓词](https://codeql.github.com/docs/ql-language-reference/predicates/)

QL中的谓词用于描述构成QL程序的逻辑关系，可以简单理解为函数，但不完全一样。
## 谓词分类
### 1.根据返回值分类
按照返回结果可分为`有返回值谓词`和`无返回值谓词`。
#### 1）没有返回值的谓词
使用`predicate`声明的谓词没有返回值，类似Java中的void关键字。这类谓词的名称绝大多数以is开头，用于逻辑判断。比如QL内置类型`Method`用于表示代码中的方法，`isPrivate()`就是该类提供的谓词之一，用于判断方法是否是私有方法。我们通过如下语句，即可查询代码中所有的私有方法：
```sql
from Method m
where m.isPrivate()
select m
```
#### 2）有返回值的谓词
有返回值的谓词需要以返回值类型声明，谓词名称绝大多数以get开头，例如在`Method`类中，想要获取方法名称可以使用`getName()`谓词，如下查询语句，返回了符合条件的方法名称：
```sql
from Method m
where m.isPrivate()
select m.getName()
```
### 2.根据谓词功能分类
官方文档中将谓词分为三种，即`非成员谓词`、`成员谓词`和`特征谓词`，与Java中的非成员方法、成员方法、构造方法相对应。但要注意，它们的功能并不相同。

# 类型
官方文档[类型](https://codeql.github.com/docs/ql-language-reference/types/)

QL是一种静态类型语言，每个变量都必须有一个声明的类型，类似Java中的类型。
QL中的类型有`基本类型`、`类`、 `字符类型`、`类域类型`、 `代数数据类型`、`类型联合`和`数据库类型`。这里只对基本类型和类类型做介绍。
## 基本类型
不常用，不多介绍<br>
`boolean`、`float`、`int`、`string`、`date`
## 类
### 1.类的定义
QL中的类与Java中的类不同，它不能用于创建对象，仅仅表示一个逻辑属性。一个类的定义如下：
```java
class OneTwoThree extends int {
  OneTwoThree() { // characteristic predicate
    this = 1 or this = 2 or this = 3
  }

  string getAString() { // member predicate
    result = "One, two or three: " + this.toString()
  }

  predicate isEven() { // member predicate
    this = 2
  }
}
```
1. 类定义格式：`class [ClassName] extends [Class]{}`
   <br>其中类名首字母需要大写，并且必须继承一个已知的类型；
2. 特征谓词：`[ClassName]() {}`
   <br>谓词名称要与类名相同，方法体中使用this变量限制类中可能值的逻辑属性，上面的例子中表示OneTwoThree类型的值范围为1、2、3。可以理解成Java中的构造方法；
3. 例子中的`getAString()`、`predicate isEven()`分别表示有返回值的成员谓词和无返回值的成员谓词。可以理解成Java中的类成员方法。对谓词的调用也类似与Java中对类方法的调用，例如通过`(OneTwoThree).getAString()`调用`getAString()`，返回1、2、3的字符串。
### 2.抽象类
QL中可以使用`abstract`定义抽象类，下面通过举一个简单的应用场景来理解。<br>
例如在编写SQL注入的查询语句时，不同数据库的sink点是不一样的，当需求不断增加时，势必修改原先的查询语句，并且多种类型的数据库写在一个查询语句中，也不易维护。抽象类用于解决此类问题，实际上在CodeQL内置的查询规则中，有大量的地方使用了抽象类。

我们定义一个抽象类`QueryInjectionSink`，用于表示SQL注入的sink点，类体中为空。
```java
abstract class QueryInjectionSink extends DataFlow::Node { }
```
当我们想要查询Mysql数据库的sql注入的sink点时，我们可以继承`QueryInjectionSink`类，在类体中写与Mysql相关的sink点逻辑。
```java
class MysqlInjectionSink extends QueryInjectionSink {
    // 具体逻辑
}
```
此时`QueryInjectionSink`类型中就包含了`MysqlInjectionSink`类型。当我们需要增加Oracle相关的查询逻辑时，只需要再编写一个类，并继承`QueryInjectionSink`即可。
```java
class OracleInjectionSink extends QueryInjectionSink {
    // 具体逻辑
}
```
此时`QueryInjectionSink`类型中就包含了`MysqlInjectionSink`类型和`OracleInjectionSink`类型，可见QL语言的抽象类与Java中的抽象类不同，QL中的父类（抽象类）为其子类的并集。
### 3.继承
QL中子类可以重写父类的谓词，但与Java中的方法重写有很大的区别。建议通过官方文档[覆盖成员谓词](https://codeql.github.com/docs/ql-language-reference/types/)中的例子理解。<br>
另外QL中的类支持多重继承，如果A继承自B、C，则A的值范围为A、B、C类值范围的交集。
### 4.类型强转
QL中的类型支持强转，例子如下：
```java
// 该类型值范围为1 2 3
class OneTwoThree extends int {
    OneTwoThree() {
      this = 1 or this = 2 or this = 3
    }
}

// 该类型值为1 2
class OneTwo extends int {
    OneTwo() {
      this = 1 or this = 2
    }

}

// 查询OneTwoThree中的值，但是强转为OneTwo类型，查询结果为1 2 
from OneTwoThree ot
select ot.(OneTwo)
```
可见，QL中的强转更像是一个过滤器。
# 表达式
官方文档[表达式](https://codeql.github.com/docs/ql-language-reference/expressions/)

这部分内容很多，这里主要介绍我在查询规则的时候经常遇到的表达式，其它表达式可查阅官方文档。
## any表达式
语法结构：<br>
`any(<变量声明> | <公式> | <表达式>)`
<br>any()表达式表示具有特定形式并满足特定条件的任何值，作用：
1. 引入临时变量；
2. 通过公式限制值；（可选）
3. 通过表达式对值做一些额外的处理。（可选）

例如如下代码，使用any表达式限制类型的值范围，此时类型的值被限制在0、1、4、9：
```java
class AnyDemo extends int {
    AnyDemo() {
      this = any(int i | i = [0 .. 3] | i * i)	
    }
}
```
在编写一些复杂的逻辑关系时，常常用到any表达式，比如在一个谓词中表示多种类型的值:
```java
/** Declarations used by source code. */
class UsedInSource extends GeneratedDeclaration {
  UsedInSource() {
    (
      this = any(Variable v | v.fromSource()).getType()
      or
      this = any(Expr e | e.getEnclosingCallable().fromSource()).getType()
      or
      this = any(RefType t | t.fromSource())
      or
      this = any(TypeAccess ta | ta.fromSource())
    )
  }
}
```
## exists
`exists(<变量声明> | <公式> | <表达式>)`

变量声明满足公式则返回true，否则false