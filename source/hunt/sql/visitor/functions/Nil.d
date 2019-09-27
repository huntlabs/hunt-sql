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
module hunt.sql.visitor.functions.Nil;

import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.functions.Function;
//import hunt.lang;
import hunt.String;
import hunt.String;
import hunt.collection;
import std.conv;
import std.uni;

import std.concurrency : initOnce;

public class Nil : Function {

    static Nil instance() {
        __gshared Nil inst;
        return initOnce!inst(new Nil());
    } 

    // public  static Nil instance;

    // static this()
    // {
    //     instance = new Nil();
    // }

    override
    public Object eval(SQLEvalVisitor visitor, SQLMethodInvokeExpr x) {
        return null;
    }

}
