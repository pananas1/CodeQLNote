/**
 * @name seninfoprint
 * @description 日志敏感信息打印
 * @kind path-problem
 * @id java/seninfo
 */

import java
import semmle.code.java.StringFormat
import semmle.code.java.dataflow.TaintTracking
import DataFlow::PathGraph

/**
 * 定义敏感信息关键字正则表达式
 */
string getSeninfoRegexString() {
    result = "pass|email|password|phone|userEmail"
}

/**
 * 敏感变量类
 * 包括敏感字段，敏感局部变量和敏感参数
 */
class SeninfoVar extends Variable {
    SeninfoVar() {
        this.getName().regexpMatch(getSeninfoRegexString()) and
        this.getCompilationUnit().fromSource()
    }
}

// class SeninfoFieldDeclaration extends FieldDeclaration {
//     SeninfoFieldDeclaration() {
//         this.getAField().getName().regexpMatch(getSeninfoRegexString())
//     }
// }

class SeninfoConfiguration extends TaintTracking::Configuration {
    SeninfoConfiguration() {
        this = "SeninfoConfiguration"
    }
    override predicate isSource(DataFlow::Node source){
        source.asExpr() = any(SeninfoVar sv).getAnAccess()
        //source.asExpr() = any(SeninfoFieldDeclaration sfd).getAField().getAnAccess()
    }
    override predicate isSink(DataFlow::Node sink){
        sink.asExpr() = any(LoggerFormatMethod lfm).getAReference().getAnArgument()
    }
    override predicate isSanitizer(DataFlow::Node sanitizer){
        none()
    }
}

from SeninfoConfiguration config, DataFlow::PathNode source, DataFlow::PathNode sink, SeninfoVar f
where config.hasFlowPath(source, sink) and
    source.getNode().asExpr() = f.getAnAccess()
select sink, source, sink, "sensitive information $@ is written to here", f, f.getName()


