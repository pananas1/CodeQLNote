主要讲Variable类和它的子类。

# Variable类
>A variable is a field, a local variable or a parameter.

变量包括字段、局部变量和方法参数。
## 常用谓词
#### 获取变量类型
```java
Type getType() {}
```
#### 获取对变量的调用
```java
VarAccess getAnAccess()
```
#### 获取变量右边的表达式
```java
Expr getAnAssignedValue()
```
#### 获取变量初始化的表达式
```java
Expr getInitializer() {}
```
#### 获取变量及其类型的字符串形式
```java
string pp()
```
# Variable类的子类
## LocalScopeVariable 局部作用域的变量
局部作用域的变量，即局部变量或参数。 
### 谓词
#### 获取声明此变量的可调用对象
```java
Callable getCallable()
```
Callable包括方法和构造函数，该谓词返回接受该参数的方法或者是在方法中声明了局部变量的方法。

## LocalVariableDecl 局部变量
局部变量，是LocalScopeVariable类的子类
### 谓词
#### 获取声明此变量的表达式
```java
LocalVariableDeclExpr getDeclExpr() 
```

## Parameter 参数
方法的形参，LocalScopeVariable的子类
### 谓词
#### 判断方法体内是否给形参赋值
```java
predicate isEffectivelyFinal()
```
#### 获取形参的索引
```java
int getPosition()
```
#### 获取此形参的源声明
```java
Parameter getSourceDeclaration()
```
#### 判断形参是否与其源声明相同
```java
predicate isSourceDeclaration()
```
#### 判断是否是可变形参
```java
predicate isVarargs()
```
#### 不懂
>/** Holds if this formal parameter is a parameter representing the dispatch receiver in an extension method. */
```java
predicate isExtensionParameter()
```

## Field
字段，Variable的子类
### 谓词
#### 获取声明此字段的类型
```java
override RefType getDeclaringType()
```
#### 获取声明此字段的字段声明。
```java
FieldDeclaration getDeclaration()
```
#### 判断字段的访问权限
public or private...