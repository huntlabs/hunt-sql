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
module hunt.sql.visitor.functions.Char;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;


import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
import hunt.Number;
import hunt.String;
import hunt.String;
import hunt.collection;
import hunt.math;
import hunt.text;
import std.concurrency : initOnce;

public class Char : Function {

    static Char instance() {
        __gshared Char inst;
        return initOnce!inst(new Char());
    }    
    // public  static Char instance;

    // static this()
    // {
    //     instance = new Char();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() == 0) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }

        StringBuilder buf = new StringBuilder(x.getParameters().size());
        foreach(SQLExpr param ; x.getParameters()) {
            param.accept(visitor);

            Object paramValue = param.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);

            if (cast(Number)(paramValue) !is null) {
                int charCode = (cast(Number) paramValue).intValue();
                buf.append(cast(char) charCode);
            } else if (cast(String)(paramValue) !is null) {
                try {
                    int charCode = new BigDecimal((cast(String) paramValue).value()).intValue();
                    buf.append(cast(char) charCode);
                } catch (Exception e) {
                }
            } else {
                return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
            }
        }

        return new String(buf.toString());
    }
}
