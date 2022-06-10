通过一个简单的查询介绍CoedQL查询语句的结构。

例如现在有一个需求，查询if冗余语句，比如如下代码：
```java
if (error) { }
```
则可以编写如下查询语句：
```sql
import java

from IfStmt ifstmt, Block block
where ifstmt.getThen() = block and
  block.getNumStmt() = 0
select ifstmt, "This 'if' statement is redundant."
```
查询语句的结构为：
```
/**
 *
 * Query metadata
 *
 */

import /* ... CodeQL libraries or modules ... */

/* ... Optional, define CodeQL classes and predicates ... */

from /* ... variable declarations ... */
where /* ... logical formula ... */
select /* ... expressions ... */
```
其中：
1. `Query metadata`部分表示查询元数据，它为用户提供有关查询的信息，并告诉CodeQL CLI如何处理查询结果。比如`@description`、`@id`、`@kind`等。更多元数据描述参考官方文档[关于查询元数据](https://codeql.github.com/docs/writing-codeql-queries/metadata-for-codeql-queries/)；
2. `import`类似java中的import，声明导入的lib；
3. `from`语句后跟变量的声明，格式为`<type> <variable name>`，例如上面查询语句中的`IfStmt ifstmt`，这里的`IfStmt`是CodeQL内置的类型，表示Java代码中的if语句，因此可以直接使用，当然我们可以自定义类型。
4. `where`后面跟逻辑条件，一般由聚合函数、谓词、逻辑公式组成，用于限制查询条件，CodeQL内置了大量的聚合函数和谓词，我们可以直接使用，当然也可以自定义。
   比如上面查询语句中`ifstmt.getThen() = block and block.getNumStmt() = 0`中的`getThen()`和`getNumStmt()`就分别为`IfStmt`和`Block`类型的谓词，`ifstmt.getThen()`表示获取if语句的then分支，`block.getNumStmt() = 0`表示语句块中子句的数量为0，整个条件就表示if语句的then分支为空。
5. `select`后跟要查询的内容，比如`select ifstmt, "This 'if' statement is redundant."`语句，查询的就是满足条件的if语句，后面的字符串为自定义的告警消息。

参考链接：
1. [关于 CodeQL 查询](https://codeql.github.com/docs/writing-codeql-queries/about-codeql-queries/)