/*
 * Copyright 2015-2018 HuntLabs.cn
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
module hunt.sql.visitor.functions.Lpad;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;
import hunt.Number;
import hunt.String;
import hunt.String;
import hunt.collection;
import std.conv;
import std.uni;
import hunt.text;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;

public class Lpad : Function {

    public  static Lpad instance;

    // static this()
    // {
    //     instance = new Lpad();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        List!(SQLExpr) params = x.getParameters();
        int paramSize = params.size();
        if (paramSize != 3) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr param0 = params.get(0);
        SQLExpr param1 = params.get(1);
        SQLExpr param2 = params.get(2);

        param0.accept(visitor);
        param1.accept(visitor);
        param2.accept(visitor);

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        Object param1Value = param1.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        Object param2Value = param2.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (param0Value is null || param1Value is null || param2Value is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        string strValue0 = param0Value.toString();
        int len = (cast(Number) param1Value).intValue();
        string strValue1 = param2Value.toString();
        
        string result = strValue0;
        if (result.length > len) {
            return new String(result.substring(0, len));
        }
        
        while (result.length < len) {
            result = strValue1 ~ result;
        }

        return new String(result);
    }
}
