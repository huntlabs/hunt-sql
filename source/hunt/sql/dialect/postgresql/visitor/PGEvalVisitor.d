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
module hunt.sql.dialect.postgresql.visitor.PGEvalVisitor;



import hunt.collection;


import hunt.sql.ast.expr.SQLBinaryExpr;
import hunt.sql.ast.expr.SQLBinaryOpExpr;
import hunt.sql.ast.expr.SQLCaseExpr;
import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLInListExpr;
import hunt.sql.ast.expr.SQLIntegerExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.ast.expr.SQLNullExpr;
import hunt.sql.ast.expr.SQLNumberExpr;
import hunt.sql.ast.expr.SQLQueryExpr;
import hunt.sql.ast.expr.SQLUnaryExpr;
import hunt.sql.ast.expr.SQLVariantRefExpr;
import hunt.sql.visitor.SQLEvalVisitor;
import hunt.sql.visitor.SQLEvalVisitorUtils;
import hunt.sql.visitor.functions.Function;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitorAdapter;

public class PGEvalVisitor : PGASTVisitorAdapter , SQLEvalVisitor {

    alias endVisit = PGASTVisitorAdapter.endVisit;
    alias visit = PGASTVisitorAdapter.visit; 

    private Map!(string, Function) functions;
    private List!(Object)          parameters;

    private int                   variantIndex     = -1;

    private bool               markVariantIndex = true;

    public this(){
        this(new ArrayList!(Object)(1));
    }

    public this(List!(Object) parameters){
        functions        = new HashMap!(string, Function)();
        parameters       = new ArrayList!(Object)();
        this.parameters = parameters;
    }

    public List!(Object) getParameters() {
        return parameters;
    }

    public void setParameters(List!(Object) parameters) {
        this.parameters = parameters;
    }

    override public bool visit(SQLCharExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    public int incrementAndGetVariantIndex() {
        return ++variantIndex;
    }

    public int getVariantIndex() {
        return variantIndex;
    }

    override public bool visit(SQLVariantRefExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    override public bool visit(SQLBinaryOpExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    override public bool visit(SQLUnaryExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    override public bool visit(SQLIntegerExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    override public bool visit(SQLNumberExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    override
    public bool visit(SQLCaseExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    override
    public bool visit(SQLInListExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    override
    public bool visit(SQLNullExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    override
    public bool visit(SQLMethodInvokeExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    override
    public bool visit(SQLQueryExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }

    public bool isMarkVariantIndex() {
        return markVariantIndex;
    }

    public void setMarkVariantIndex(bool markVariantIndex) {
        this.markVariantIndex = markVariantIndex;
    }

    override
    public Function getFunction(string funcName) {
        return functions.get(funcName);
    }

    override
    public void registerFunction(string funcName, Function function_p) {
        functions.put(funcName, function_p);
    }
    
    override
    public void unregisterFunction(string funcName) {
        functions.remove(funcName);
    }

    override public bool visit(SQLIdentifierExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }
    
    override
    public bool visit(SQLBinaryExpr x) {
        return SQLEvalVisitorUtils.visit(this, x);
    }
}
