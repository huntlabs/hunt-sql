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
module hunt.sql.visitor.functions.Instr;

// import hunt.sql.visitor.SQLEvalVisitor.SQLEvalVisitor.EVAL_VALUE;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
import std.string;
import hunt.string;
import hunt.sql.util.MyString;
import hunt.lang;

public class Instr : Function {
    public  static Instr instance;

    // static this()
    // {
    //     instance = new Instr();
    // }
    
    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() != 2) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr param0 = x.getParameters().get(0);
        SQLExpr param1 = x.getParameters().get(1);
        param0.accept(visitor);
        param1.accept(visitor);

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        Object param1Value = param1.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (param0Value is null || param1Value is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        string strValue0 = param0Value.toString();
        string strValue1 = param1Value.toString();

        int result = cast(int)(strValue0.indexOf(strValue1) + 1);
        return new Integer(result);
    }
}
