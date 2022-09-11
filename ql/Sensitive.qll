import java
import semmle.code.java.Maps

/**
 * 配置关心的敏感字段的名称
 * 
 * NOTE: 需要根据实际情况进行配置
 */
string getSensitiveFieldName(){
    result = ["mobile", "telephone", "phone"]
}

/**
 * 配置映射URL的标注名
 * 
 * NOTE: 需要根据实际情况进行配置
 */
string getMappingAnno(){
    result = ["RequestMapping", "GetMapping", "PostMapping"]
}

/**
 * 配置关心的含有敏感字段的类名，用来作为备案，当敏感的类没有编译进CodeQL数据库时，可以使用这种方式
 * 
 * NOTE: 需要根据实际情况进行配置
 */
string getSensitiveClassName(){
    result = ["UserInfoDTO"]
}

/**
 * 定义完全不需要关心的类型
 */
class DontCaredType extends Type{
    DontCaredType(){
        this instanceof PrimitiveType
        or
        this instanceof BoxedType
        or
        this instanceof NumberType
    }
}

/**
 * 定义映射URL的方法
 */
class MappingMethod extends Method{
    MappingMethod(){
        this.getAnAnnotation().getType().getName() = getMappingAnno() and
        not this.getReturnType() instanceof DontCaredType
    }
}

/**
 * 定义敏感数据的字段
 */
class SensitiveField extends Field {
    SensitiveField(){
        this.getName() = getSensitiveFieldName()
        or
        this.getType() instanceof SensitiveClass
    }
}

/**
 * 定义包含了敏感数据字段的类
 */
class SensitiveClass extends Class {
    SensitiveClass(){
        // 对于有些DTO对象没有编译成功的情况
        // 没有编译进数据库的类，不认为来自源代码
        this.getName() = getSensitiveClassName()
        or
        (
            this.fromSource() and
            this.getAField() instanceof SensitiveField
        )
    }
}

/**
 * 获取泛型内嵌的类型，例如`List<UserDTO>`里面的`UserDTO`，使用`+`来支持嵌套的泛型
 */
Class getGenericInnerType(ParameterizedType generic){
    result = generic.getATypeArgument+()
}

/**
 * 在`Map`类型的变量中包含了敏感数据
 */
class SensitiveMapVar extends Variable{
    SensitiveMapVar(){
        exists(MapPutCall mapPut, MapType mapType|
                mapType = this.getType() and
                (
                    // 1) key是敏感字段时
                    mapPut.getQualifier() = this.getAnAccess() and
                    mapPut.getKey().(StringLiteral).getValue() = getSensitiveFieldName()
                    or
                    // 2) value类型是敏感的类型时
                    mapType.getValueType() instanceof SensitiveClass
                    or
                    // 3) value类型是泛型时
                    getGenericInnerType(mapType.getValueType()) instanceof SensitiveClass
                )
            )
    }
}

/**
 * 在`ReturnType`中发现包含了敏感数据
 */
class SensitiveReturnType extends RefType{
    SensitiveReturnType(){
        // 直接返回包含了敏感字段的类
        this instanceof SensitiveClass
        or
        // 返回的是一个泛型，内嵌了敏感的类
        getGenericInnerType(this) instanceof SensitiveClass
    }
}

/**
 * 在`ReturnStmt`语句中包含了敏感信息
 */
class SensitiveReturnStmt extends ReturnStmt{
    SensitiveReturnStmt(){
        exists(Expr returnResult|
            this.getResult() = returnResult and
            (
                // 1）直接返回包含敏感字段的类，这种情景在校验ReturnType中已经包含了，所以注销掉
                // returnResult.getType() instanceof SensitiveClass
                // or
                // 2）将敏感的类，放入应答类的方法中时，例如Result.success(UserDTO),返回的类型是Result,但是实际还是UserDTO对象,不过会有误报
                returnResult.getAChildExpr*().getType() instanceof SensitiveClass
                or
                // 3）返回值是Map类型的变量时
                exists(SensitiveMapVar sensitiveMapVar| returnResult = sensitiveMapVar.getAnAccess())
            )
            )
    }
}

/**
 * 定义返回了敏感信息的映射方法
 */
class SensitiveMappingMethod extends MappingMethod{
    SensitiveMappingMethod(){
        exists(SensitiveReturnStmt sensitiveReturnStmt, SensitiveReturnType sensitiveReturnType |
            this.getReturnType() = sensitiveReturnType
            or
            sensitiveReturnStmt.getEnclosingCallable() = this)
    }
}