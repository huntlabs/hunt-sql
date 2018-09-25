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
module hunt.sql.ast.statement.SQLCallStatement;

import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.ast.expr.SQLVariantRefExpr;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLCallStatement : SQLStatementImpl {

    private bool             brace      = false;

    private SQLVariantRefExpr   outParameter;

    private SQLName             procedureName;

    private  List!SQLExpr parameters;
    
    public this() {
        parameters = new ArrayList!SQLExpr();
    }
    
    public this(string dbType) {
        super (dbType);
    }

    public SQLVariantRefExpr getOutParameter() {
        return outParameter;
    }

    public void setOutParameter(SQLVariantRefExpr outParameter) {
        this.outParameter = outParameter;
    }

    public SQLName getProcedureName() {
        return procedureName;
    }

    public void setProcedureName(SQLName procedureName) {
        this.procedureName = procedureName;
    }

    public List!SQLExpr getParameters() {
        return parameters;
    }

    public bool isBrace() {
        return brace;
    }

    public void setBrace(bool brace) {
        this.brace = brace;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.outParameter);
            acceptChild(visitor, this.procedureName);
            acceptChild!SQLExpr(visitor, this.parameters);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        children.add(outParameter);
        children.add(procedureName);
        children.addAll(cast(List!SQLObject)(parameters));
        return null;
    }
}
