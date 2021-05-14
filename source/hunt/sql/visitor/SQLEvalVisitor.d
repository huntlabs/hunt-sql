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
module hunt.sql.visitor.SQLEvalVisitor;

import hunt.collection;

import hunt.sql.visitor.functions.Function;
import hunt.sql.visitor.SQLASTVisitor;

import std.concurrency : initOnce;

interface SQLEvalVisitor : SQLASTVisitor {

    enum  string EVAL_VALUE       = "eval.value";
    enum  string EVAL_EXPR        = "eval.expr";

    static Object EVAL_ERROR() {
        __gshared Object inst;
        return initOnce!inst(new Object());
    }
    
    static Object EVAL_VALUE_COUNT() {
        __gshared Object inst;
        return initOnce!inst(new Object());
    }
    
    static Object EVAL_VALUE_NULL() {
        __gshared Object inst;
        return initOnce!inst(new Object());
    }

    Function getFunction(string funcName);

    void registerFunction(string funcName, Function function_p);

    void unregisterFunction(string funcName);

    List!(Object) getParameters();

    void setParameters(List!(Object) parameters);

    int incrementAndGetVariantIndex();

    bool isMarkVariantIndex();

    void setMarkVariantIndex(bool markVariantIndex);
}
