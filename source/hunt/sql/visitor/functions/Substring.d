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
module hunt.sql.visitor.functions.Substring;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;

import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
import hunt.lang;
import hunt.sql.util.String;
import hunt.string;
import hunt.container;
import std.conv;
import std.uni;
public class Substring : Function {

    public  static Substring instance;

    // static this()
    // {
    //     instance = new Substring();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        List!(SQLExpr) params = x.getParameters();
        int paramSize = params.size();

        SQLExpr param0 = params.get(0);

        SQLExpr param1;
        if (paramSize == 1 && x.getFrom() !is null) {
            param1 = x.getFrom();
            paramSize = 2;
        } else if (paramSize != 2 && paramSize != 3) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        } else {
            param1 = params.get(1);
        }

        param0.accept(visitor);
        param1.accept(visitor);

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        Object param1Value = param1.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (param0Value is null || param1Value is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        string str = param0Value.toString();
        int index = (cast(Number) param1Value).intValue();

        if (paramSize == 2 && x.getFor() is null) {
            if (index <= 0) {
                int lastIndex = cast(int)(str.length) + index;
                return new String(str.substring(lastIndex));
            }

            return new String(str.substring(index - 1));
        }

        SQLExpr param2 = x.getFor();
        if (param2 is null && params.size() > 2) {
            param2 = params.get(2);
        }
        param2.accept(visitor);
        Object param2Value = param2.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (param2Value is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        int len = (cast(Number) param2Value).intValue();

        string result;
        if (index <= 0) {
            int lastIndex = cast(int)(str.length) + index;
            result = str.substring(lastIndex);
        } else {
            result = str.substring(index - 1);
        }

        if (len > result.length) {
            return new String(result);
        }
        return new String(result.substring(0, len));
    }
}
