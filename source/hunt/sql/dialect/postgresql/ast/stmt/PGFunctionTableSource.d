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
module hunt.sql.dialect.postgresql.ast.stmt.PGFunctionTableSource;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLParameter;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.dialect.postgresql.ast.PGSQLObject;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;

public class PGFunctionTableSource : SQLExprTableSource , PGSQLObject {

    private  List!(SQLParameter) parameters;

    public this(){
        parameters = new ArrayList!(SQLParameter)();
    }

    public this(SQLExpr expr){
        this();
        this.expr = expr;
    }

    public List!(SQLParameter) getParameters() {
        return parameters;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        this.accept0(cast(PGASTVisitor) visitor);
    }

    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.expr);
            acceptChild!SQLParameter(visitor, this.parameters);
        }
        visitor.endVisit(this);
    }
}
