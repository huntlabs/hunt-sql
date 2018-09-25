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
module hunt.sql.visitor.functions.Reverse;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
import hunt.math;
import hunt.sql.util.String;
import hunt.util.string;
import hunt.container;
import std.conv;
import std.uni;

public class Reverse : Function {
    public  static Reverse instance;

    // static this()
    // {
    //     instance = new Reverse();
    // }
    
    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() != 1) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr param0 = x.getParameters().get(0);
        param0.accept(visitor);

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (param0Value is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        string strValue = param0Value.toString();

        StringBuilder buf = new StringBuilder();
        for (int i = cast(int)(strValue.length) - 1; i >= 0; --i) {
            buf.append(charAt(strValue, i));
        }
        string result = buf.toString();
        return new String(result);
    }
}
