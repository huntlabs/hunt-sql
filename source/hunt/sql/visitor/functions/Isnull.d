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
 * See the License for the specific Booleanuage governing permissions and
 * limitations under the License.
 */
module hunt.sql.visitor.functions.Isnull;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_ERROR;
// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;
// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE_NULL;

import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
import hunt.Boolean;
import hunt.String;
import hunt.String;
import hunt.collection;
import std.conv;
import std.uni;

public class Isnull : Function {

    public static Isnull instance ;

    // static this()
    // {
    //     instance = new Isnull();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
         List!(SQLExpr) parameters = x.getParameters();
        if (parameters.size() == 0) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr condition = parameters.get(0);
        condition.accept(visitor);
        Object itemValue = condition.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (itemValue == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return Boolean.TRUE;
        } else if (itemValue is null) {
            return null;
        } else {
            return Boolean.FALSE;
        }
    }
}
