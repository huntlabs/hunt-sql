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
module hunt.sql.visitor.functions.Elt;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
import hunt.Number;
import hunt.String;
import hunt.String;
import hunt.collection;

import std.concurrency : initOnce;

public class Elt : Function {

    static Elt instance() {
        __gshared Elt inst;
        return initOnce!inst(new Elt());
    }    

    // public  static Elt instance;

    // static this()
    // {
    //     instance = new Elt();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() <= 1) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        SQLExpr param0 = x.getParameters().get(0);
        param0.accept(visitor);

        Object param0Value = param0.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        int param0IntValue;
        if (!(cast(Number)(param0Value) !is null)) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }
        param0IntValue = (cast(Number) param0Value).intValue();

        if (param0IntValue >= x.getParameters().size()) {
            return null;
        }

        SQLExpr item = x.getParameters().get(param0IntValue);
        item.accept(visitor);

        Object itemValue = item.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        return itemValue;
    }
}
