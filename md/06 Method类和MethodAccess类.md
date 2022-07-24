主要讲Method类和MethodAccess类和它们的谓词。

`Mehtond`类和`MethodAccess`类是非常重要的两个类，前者表示方法，后者表示方法的调用。在污点分析中，source与sink往往是某个方法的参数，所以在定义source与sink时，经常可以看到Mehtond类和MethodAccess类的身影。

# Mehtond类
类的定义如下：
```java
class Method extends Callable, @method {}
```
`Method`继承自`Callable`，即它是可调用对象之一，也就是方法。

## 常用谓词
#### 1.重写相关
没咋用过
#### 2.获取方法的签名
```java
override string getSignature() {}
```
能够获取到一个方法完整的形式，包括方法名和参数以及参数的类型。比如
`commence(javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse,org.springframework.security.core.AuthenticationException)`
#### 3.判断两个方法是否有相同的形参
```java
predicate sameParamTypes(Method m) {}
```
#### 4.获取调用此方法时可能被调用的所有方法
对于类方法，包括方法本身和它的所有重写方法；对于接口方法，包括在实现类上定义或继承的方法。
>for interface methods this includes matching methods defined on or inherited by implementing classes.
```java
SrcMethod getAPossibleImplementation() {}
```
#### 5.获取调用方法的调用点
就是返回调用方法的地方，返回的是`MethodAccess`类型，使用频率很高。
```java
override MethodAccess getAReference() {}
```
#### 6.is开头的谓词
主要判断方法的类型，比如是不是重写方法，是不是私有方法，是不是静态方法等。

#### 7.获取声明此方法的类型
这个是`Member`类中的一个谓词，比较常用
```java
RefType getDeclaringType() {}
```

## Method类的子类
#### 1.SrcMethod
不太懂
#### 2.GetterMethod
具备如下条件的方法：
1. 无参；
2. 它的主体只包含一条返回字段值的语句。 
#### 3.SetterMethod
具备如下条件的方法：
1. 只有一个参数；
2. 它的主体只包含一条语句，将方法参数的值赋给与方法相同类型声明的字段。 
#### 4.FinalizeMethod
不太懂
>A finalizer method, with name `finalize`,return type `void` and no parameters.

# MethodAccess类
对带有参数列表的方法的调用，包括无参方法。
```java
class MethodAccess extends Expr, Call, @methodaccess {}
```
是`Expr`类和`Call`类的子类。
## 常用谓词
#### 1.获取方法调用的表达式
>Gets the qualifying expression of this method access, if any.
```java
override Expr getQualifier() {}
```
比如下面这个Java代码：
```java
request.getHeader("x-requested-with")
```
`request.getHeader("x-requested-with")`表示一个方法调用`MethodAccess`；
MethodAccess.getQualifier()返回的是`request`这个表达式。
#### 2.Holds if this method access has a qualifier.
不太理解什么是qualifier。
```java
predicate hasQualifier() {}
```
总之：
`request.getHeader("x-requested-with")`这样的表示有qualifier。
`getHeader("x-requested-with")`这样的表示没有qualifier。
#### 3.获取调用方法时传入的参数
返回的是一个表达式。
```java
override Expr getAnArgument() {}
```
另外一个是返回某个参数，序号从0开始。
```java
override Expr getArgument(int index) {}
```
#### 4.不懂
```java
  /** Gets a type argument supplied as part of this method access, if any. */
  Expr getATypeArgument() { result.getIndex() <= -2 and result.getParent() = this }

  /** Gets the type argument at the specified (zero-based) position in this method access, if any. */
  Expr getTypeArgument(int index) {
    result = this.getATypeArgument() and
    (-2 - result.getIndex()) = index
  }
```
#### 5.获取方法
```java
Method getMethod() {}
```
#### 5.获取包含这个MethodAccess的可调用对象
>Gets the immediately enclosing callable that contains this method access.

```java
override Callable getEnclosingCallable() {}
```
#### 6.获取包含这个MethodAccess的语句
> Gets the immediately enclosing statement that contains this method access.

```java
override Stmt getEnclosingStmt() {}
```
#### 7.获取调用这个方法的对象的类型
```java
RefType getReceiverType() {}
```
比如：
```java
request.getHeader("x-requested-with") 
```
request的类型是HttpServletRequest