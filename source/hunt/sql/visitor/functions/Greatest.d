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
module hunt.sql.visitor.functions.Greatest;

// import hunt.sql.visitor.SQLEvalVisitor.EVAL_VALUE;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.SQLEvalVisitorUtils;
import hunt.sql.visitor.functions.Function;

public class Greatest : Function {

    public  static Greatest instance;

    // static this()
    // {
    //     instance = new Greatest();
    // }

    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        Object result = null;
        foreach(SQLExpr item ; x.getParameters()) {
            item.accept(visitor);

            Object itemValue = item.getAttributes().get(SQLEvalVisitor.EVAL_VALUE);
            if (result is null) {
                result = itemValue;
            } else {
                if (SQLEvalVisitorUtils.gt(itemValue, result)) {
                    result = itemValue;
                }
            }
        }

        return result;
    }
}
