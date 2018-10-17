/*
 * Copyright 2015-2018 HuntLabs.cn.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
module hunt.sql.builder.impl.SQLBuilderImpl;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLBooleanExpr;
import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.ast.expr.SQLIntegerExpr;
import hunt.sql.ast.expr.SQLNullExpr;
import hunt.sql.ast.expr.SQLNumberExpr;
import hunt.sql.builder.SQLBuilder;
import hunt.sql.util.String;
import hunt.lang;

public class SQLBuilderImpl : SQLBuilder {
    public static SQLExpr toSQLExpr(Object obj, string dbType) {
        if (obj is null) {
            return new SQLNullExpr();
        }
        
        if (cast(Integer)(obj) !is null) {
            return new SQLIntegerExpr(cast(Integer) obj);
        }
        
        if (cast(Number)(obj) !is null) {
            return new SQLNumberExpr(cast(Number) obj);
        }
        
        if (cast(String)(obj) !is null) {
            return new SQLCharExpr(cast(String) obj);
        }
        
        if (cast(Boolean)(obj) !is null) {
            return new SQLBooleanExpr((cast(Boolean) obj).booleanValue);
        }
        
        throw new Exception("IllegalArgument not support : " ~ typeof(obj).stringof);
    }
}
