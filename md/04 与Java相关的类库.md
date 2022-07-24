主要介绍与Java相关的CodeQL库。本文只是做简单的介绍，会另起它文总结常用的Java相关的库类和谓词。

官方文档[Java的CodeQL库](https://codeql.github.com/docs/codeql-language-guides/codeql-library-for-java/)

CodeQL的sdk中'.qll'后缀的文件为ql语言的库文件（ library ），类似Java语言里的jar包。在`java.qll`中可以看到所有的默认类。

CodeQL标准Java库中主要包括五个类别：
1. 用于表示程序元素的类（例如类和方法）；
2. 表示AST节点的类（例如语句和表达式）；
3. 表示元数据的类（例如注释和注解）；
4. 计算度量的类（例如圈复杂度和耦合）；
5. 用于导航程序调用图的类。

## 一、程序元素类
程序元素类包括：包（Package）、编译单元（CompilationUnit）、类型（Type）、方法（Method）、构造函数（Constructor）和变量（Variable）。
### 1. 类型（Type）
`Type`类有许多子类来表示不同的类型，例如：

1）`PrimitiveType`类表示Java的基本类型，即boolean、byte、char、double、 float、int、long、short。除此之外，QL还将void和\<nulltype>也分类为基本类型。例如如下查询语句，可以查询Java代码中所有基本类型的变量：
```sql
from Variable v
where v.getType() instanceof PrimitiveType and v.fromSource()
select v
```

2）`RefType`类表示引用类型，该类又有如下几个子类：
1. `Class`，表示Java中的类；
2. `Interface`，表示Java中的接口；
3. `EnumType`，表示Java中的枚举类；
4. `Array`，表示Java中的数组；
5. `NestedType`，表示在类中声明的类；
6. `TopLevelType`，表示顶层声明的类；

还有的比如`TypeObject`表示Java中的`java.lang.Object`类，`TypeSerializable`表示Java中的`java.io.Serializable`接口，这些类型声明在`JDK.qll`包中，这个包里封装了大量的jdk相关的类的类型。这些类型的定义相对简单，用来入门CodeQL语法非常不错。

3）泛型 Java中的泛型还没怎么整明白，这块先放放

### 2. 变量（Variable）
`Variable`类表示Java中的变量，其中子类`Field`表示Java字段，`LocalVariableDecl`表示局部变量，`Parameter`表示方法或构造函数的参数。

### 3. 方法（Method）

## 二、抽象语法树(AST)
此类别中的类表示抽象语法树的节点，即语句（Stmt）和表达式（Expr）。
[语句与表达式的区别](https://blog.csdn.net/super_hong/article/details/84667784)：语句是可以单独执行的、能够产生实际效果的代码；而表达式则是包含在语句中，根据某种条件计算出一个值或得出某种结果，然后由语句去判断和处理的代码。

### 1.语句
1. `IfStmt`，表示if语句；
2. `WhileStmt`，表示while语句；
3. `DoStmt`，表示dowhile语句....等等等等

### 2.表达式
Expr有许多子类，例如`Literal`、`UnaryExpr`、`BinaryExpr`、`Assignment`等。
#### Literal
[Literal](https://codeql.github.com/codeql-standard-libraries/java/semmle/code/java/Expr.qll/type.Expr$Literal.html)表示字面常量，它又有如下子类：
1. BooleanLiteral，表示布尔类型boolean，true或false；
2. IntegerLiteral，表示整型Integer；
3. LongLiteral，表示长整型Long；
4. FloatingPointLiteral，表示单精度浮点型Float；
5. DoubleLiteral，表示Double；
6. CharacterLiteral，表示Char；
7. StringLiteral，表示String；
8. NullLiteral，表示Null。
#### UnaryExpr
[UnaryExpr](https://codeql.github.com/codeql-standard-libraries/java/semmle/code/java/Expr.qll/type.Expr$UnaryExpr.html)表示一元表达式，例如`a++`这样的Java表达式。
#### BinaryExpr
[BinaryExpr](https://codeql.github.com/codeql-standard-libraries/java/semmle/code/java/Expr.qll/type.Expr$BinaryExpr.html)表示二元表达式，例如`a+b`这样的Java表达式。
#### Assignment
[Assignment](https://codeql.github.com/codeql-standard-libraries/java/semmle/code/java/Expr.qll/type.Expr$Assignment.html)表示赋值表达式，例如`a=b`在这样的Java表达式。
#### Accesses
表示引用，有点抽象，不知道怎么解释。。
`VarAccess`类表示对字段、参数、局部变量的引用。例如：
```java
Map<String, String> map = new HashMap();
// 表示对map变量的引用
map.put("key","value");
```
```java
public ModelAndView lessonPage(HttpServletRequest request) {
    // 表示对request参数的引用
    String path = request.getRequestURL().toString();
}
```
```java
public class Test {
    private String name;
    public String getName() {
        // 表示对字段的引用
        return name;
    }
}
```
除了`VarAccess`类之外，还有`ThisAccess`、`SuperAccess`、`ArrayAccess`、`MethodAccess`、`TypeAccess`、`WildcardTypeAccess`和`FieldAccess`。
#### 其它
`CastExpr`类，表示强转表达式；
`InstanceOfExpr`类，表示instanceof表达式；
`ConditionalExpr`类，三目表达式；
`TypeLiteral`类，类型字面常量，比如String.class这样的代码；
`ClassInstanceExpr`类，类的实例化表达式；
`ArrayCreationExpr`类，创建数据的表达式；
`ArrayInit`类，数组初始化；
`Annotation`类，注解。

所有的语句和表达式相关的类可以查阅官方文档中的表格[抽象语法树相关的类](https://codeql.github.com/docs/codeql-language-guides/abstract-syntax-tree-classes-for-working-with-java-programs/)。

Expr和Stmt都提供了成员谓词，用于探索程序的抽象语法树，例如：
1. `Expr.getAChildExpr`，返回给定表达式的子表达式；
2. `Stmt.getAChild`，返回直接嵌套在给定语句中的语句或表达式；
3. `Expr.getParen`和`Stmt.getParent`，返回AST节点的父节点。

## 三、元数据
`Annotation`类表示注解，`Javadoc`类表示注释。
例如通过注解查询废弃的构造函数：
```sql
import java

from Constructor c, Annotation ann, AnnotationType anntp
where ann = c.getAnAnnotation() and
    anntp = ann.getType() and
    anntp.hasQualifiedName("java.lang", "Deprecated")
select ann
```
## 四、指标
不懂
## 五、调用图
我们可以使用谓词`Call.getCallee`来找出特定调用表达式所指的方法或构造函数。例如，以下查询查找对名为`println`的方法的所有调用：
```sql
import java

from Call c, Method m
where m = c.getCallee() and
    m.hasName("println")
select c
```
`Callable`表示可调用对象，一个方法或者一个构造函数。
`Call`类表示对可调用对象的调用。
`Method`是`Callable`的子类。
相反，谓词`Callable.getAReference`返回一个引用它的调用，比如我们想找`getName()`方法在哪些地方被调用了，可以使用如下查询语句：
```sql
import java

from Callable c
where c.fromSource() and
c.getName().matches("getName")
select c.getAReference()
```