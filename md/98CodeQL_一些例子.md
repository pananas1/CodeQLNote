### 1.查询某个类的某个方法
```sql
import java

from Method method
where method.hasName("[method name]") and 
method.getDeclaringType().hasQualifiedName("[package name]", "[class name]")
select method
```
### 2.查询某个类的所有子类的某个方法（不包括某个类）
```sql
import java

from Method method
where method.hasName("[method name]") and 
method.getDeclaringType().getASupertype().hasQualifiedName("[package name]", "[class name]")
select method
```
### 3.查询某个类的所有子类的某个方法（包括某个类）
```sql
import java

from Method method
where method.hasName("[method name]") and 
method.getDeclaringType().getAnAncestor().hasQualifiedName("[package name]", "[class name]")
select method
```
### 4.查询哪里调用了某个方法
```sql
import java

from MethodAccess call, Method method
where method.hasName("[method name]") and 
method.getDeclaringType().getAnAncestor().hasQualifiedName("[package name]", "[class name]") and 
call.getMethod() = method
select call, call.getAnArgument(), call.getArgument(0)
```