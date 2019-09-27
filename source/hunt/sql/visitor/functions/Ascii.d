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
module hunt.sql.visitor.functions.Ascii;

import  hunt.sql.visitor.SQLEvalVisitor;
// import  hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;
// import  hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE_NULL;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
import hunt.String;
import hunt.Integer;
import hunt.text;

import std.concurrency : initOnce;

public class Ascii : Function {

    static Ascii instance() {
        __gshared Ascii inst;
        return initOnce!inst(new Ascii());
    }    

    // public  static Ascii instance;

    // static this()
    // {
    //     instance = new Ascii();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        if (x.getParameters().size() == 0) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }
        SQLExpr param = x.getParameters().get(0);
        param.accept(visitor);
        
        Object paramValue = param.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
        if (paramValue is null) {
            return cast(Object)(SQLEvalVisitor.EVAL_ERROR);
        }
        
        if (paramValue == SQLEvalVisitor.EVAL_VALUE_NULL) {
            return cast(Object)(SQLEvalVisitor.EVAL_VALUE_NULL);
        }

        string strValue = paramValue.toString();
        if (strValue.length == 0) {
            return new Integer(0);
        }

        int ascii = charAt(strValue, 0);
        return new Integer(ascii);
    }
}
