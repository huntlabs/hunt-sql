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
module hunt.sql.dialect.mysql.ast.statement.MySqlExecuteStatement;



import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

public class MySqlExecuteStatement : MySqlStatementImpl {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private SQLName             statementName;
    private  List!(SQLExpr) parameters;

    this()
    {
        parameters = new ArrayList!(SQLExpr)();
    }

    public SQLName getStatementName() {
        return statementName;
    }

    public void setStatementName(SQLName statementName) {
        this.statementName = statementName;
    }

    public List!(SQLExpr) getParameters() {
        return parameters;
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, statementName);
            acceptChild!SQLExpr(visitor, parameters);
        }
        visitor.endVisit(this);
    }

    override
    public List!(SQLObject) getChildren() {
        List!(SQLObject) children = new ArrayList!(SQLObject)();
        if (statementName !is null) {
            children.add(statementName);
        }
        children.addAll(cast(List!SQLObject)(this.parameters));
        return children;
    }
}
