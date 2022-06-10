主要介绍CodeQL的工作流程和安装配置
# 一、CodeQL工作流程
CodeQL 的整体思路是把源代码转化成一个可查询的数据库，通过 Extractor 模块对源代码工程进行关键信息分析提取，构成一个关系型数据库。CodeQL 的数据库并没有使用现有的数据库技术，而是一套基于文件的自己的实现。

对于编译型语言，Extractor 会监控编译过程，编译器每处理一个源代码文件，它都会收集源代码的相关信息，如：语法信息（AST 抽象语法树）、语义信息（名称绑定、类型信息、运算操作等），控制流、数据流等，同时也会复制一份源代码文件。而对于解释性语言，Extractor 则直接分析源代码，得到类似的相关信息。

关键信息提取完成后，所有分析所需的数据都会导入一个文件夹，这个就是 CodeQL database, 其中包括了源代码文件、关系数据、语言相关的 database schema（schema 定义了数据之间的相互关系）。

接下来就可以对数据库进行查询了，CodeQL 自己定义实现了一套名为 QL 的查询语言，并提供了相应的支持库和运行环境。

最终将查询结果展示给用户，方便用户进行进一步的人工审计分析。
# 二、COdeQL安装配置
1. codeql-cli：https://github.com/github/codeql-cli-binaries/releases
2. sdk：https://github.com/github/codeql
3. vscode安装codeql插件
4. 配置codeql二进制文件的环境变量，方便后续命令的使用（可选）
# 三、VSCode工作区配置
## 1.创建CodeQL database
在代码根目录下执行：<br>
`codeql database create [database-name] -l java`
如果报错，使用完整命令：<br>
`codeql database create [生成的数据库的路径] --language=java  --command="mvn clean install --file pom.xml -Dmaven.test.skip=true" --source-root=[源码路径]`
## 2.创建QL包
本地新建一个文件夹，用于存放QL脚本，在文件夹下创建文件`qlpack.yml`，内容为：
```yml
name: codeql-myquery
version: 0.0.0
libraryPathDependencies: codeql-java
```
## 3.将QL的sdk添加到VSCode工作区
## 4.添加CodeQL数据库

# 四、其它命令
## 编译生成database
`codeql database create [生成的数据库的路径] --language=java  --command="mvn clean install --file pom.xml -Dmaven.test.skip=true" --source-root=[源码路径]`<br>
其中--command参数可选
## 批量执行ql文件，并输出报告
`codeql database analyze /CodeQL/databases/micro-service-seclab /CodeQL/ql/java/ql/examples/demo --format=csv --output=/CodeQL/Result/micro-service-seclab.csv --rerun`
## 批量指定SDK中内置的规则
`codeql database analyze source_database_name qllib/java/ql/src/codeql-suites/java-security-extended.qls --format=csv --output=java-results.csv`
