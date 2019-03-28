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
module hunt.sql.visitor.functions.Locate;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;

import hunt.Integer;
import hunt.Number;

import hunt.String;
import hunt.String;
import hunt.collection;
import std.conv;
import std.uni;
import std.string;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;

public class Locate : Function {

    public  static Locate instance;

    // static this()
    // {
    //     instance = new Locate();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        List!(SQLExpr) params = x.getParameters();
        int paramSize = params.size();
        if (paramSize != 2 && paramSize != 3) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr param0 = params.get(0);
        SQLExpr param1 = params.get(1);
        SQLExpr param2 = null;

        param0.accept(visitor);
        param1.accept(visitor);
        if (paramSize == 3) {
            param2 = params.get(2);
            param2.accept(visitor);
        }

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        Object param1Value = param1.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (param0Value is null || param1Value is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        string strValue0 = param0Value.toString();
        string strValue1 = param1Value.toString();

        if (paramSize == 2) {
            int result = cast(int)(strValue1.indexOf(strValue0) + 1);
            return new Integer(result);
        }
        
        Object param2Value = param2.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        int start = (cast(Number) param2Value).intValue();
        
        int result = cast(int)(strValue1.indexOf(strValue0, start + 1) + 1);
        return new Integer(result);
    }
}
