CodeQL可以识别调用其它代码的代码以及可以被其它地方调用的代码，这个能力由Callable和Call这两个抽象类实现，文本主要介绍这两个类即它们的谓词。
# Call类
`Call`类是`MethodAccess`类、`ClassInstanceExpression`类、`ThisConstructorInvocationStmt`类、`SuperConstructorInvocationStmt`类的父类。<br>
>a Call is something that invokes a Callable.

`Call`类表示对可调用对象的调用，包括对方法的调用，对构造函数和超级构造函数的调用以及通过类实例化调用的构造函数。例如如下的Java代码结构：
```java
public class AjaxAuthenticationEntryPoint extends LoginUrlAuthenticationEntryPoint {
    public AjaxAuthenticationEntryPoint(String loginFormUrl) {
        // 对超级构造函数的调用，作用是调用父类的构造函数
        super(loginFormUrl);
    }
}
```
```java
// 对getHeader()方法的调用
request.getHeader("x-requested-with")
```
```java
// 通过实例化类调用的构造函数
SpringTemplateEngine engine = new SpringTemplateEngine();
```
## Call类的谓词
### getCallee()
`getCallee()`返回此调用的可调用对象。
### getCaller()
`getCaller()`返回调用此调用的可调用对象。
例如如下Java代码：<br>
```java
public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException, ServletException {
    if(request.getHeader("x-requested-with") != null) {
        response.sendError(401, authException.getMessage());
    } else {
        super.commence(request, response, authException);
    }
}
```
`request.getHeader("x-requested-with")`是一个调用（Call）<br>
`getHeader`是一个可调用的方法（Callee）<br>
`commence`也是一个可调用的方法（Callee），同时它也是`getHeader`的Caller。

# Callable类
`Callable`类是`Method`类和`Constructor`类的父类。
>a Callable is something that can be invoked

其实就是Java代码中的方法和构造函数。
## Callable类的谓词
### calls(Callable target)
>Holds if this callable calls `target`.

表示如果这个可调用对象调用了某个可调用对象，则保留。
### polyCalls(Callable target)
>succeeds if this callable may call target at runtime; this is the case if it contains a call whose callee is either target or a method that target overrides.

（没咋懂这个）好像是说调用重写的方法这种情况也能解析到。范围比calls大？

# 一些例子
### 查找没有被调用过的方法
通过这个查询语句可以查询废弃代码
```java
from Callable callee
where not exists(Callable caller | caller.polyCalls(callee)) and
    // 排除掉依赖的jar包中的方法
    callee.getCompilationUnit().fromSource() and
    // 排除掉隐式调用的方法，比如类初始化
    not callee.hasName("<clinit>") and not callee.hasName("finalize") and
    // 排除掉public声明的方法，因为这些方法可能是供外部使用的API
    not callee.isPublic() and
    // 排除掉非public的无参构造器，因为在单例模式中，通常会使用将构造器私有化，防止类被实例化
    not callee.(Constructor).getNumberOfParameters() = 0 and
    // 排除掉测试类中定义的方法
    not callee.getDeclaringType() instanceof TestClass
select callee, "Not called."
```