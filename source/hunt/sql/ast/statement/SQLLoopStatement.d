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
module hunt.sql.ast.statement.SQLLoopStatement;


import hunt.collection;

import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLLoopStatement : SQLStatementImpl {

    private string             labelName;

    private  List!SQLStatement statements;

    this()
    {
        statements = new ArrayList!SQLStatement();
    }

    override
    public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLStatement(visitor, statements);
        }
        visitor.endVisit(this);
    }

    public List!SQLStatement getStatements() {
        return statements;
    }

    public string getLabelName() {
        return labelName;
    }

    public void setLabelName(string labelName) {
        this.labelName = labelName;
    }

    public void addStatement(SQLStatement stmt) {
        if (stmt !is null) {
            stmt.setParent(this);
        }
        statements.add(stmt);
    }

    override
    public List!SQLObject getChildren() {
        return cast(List!SQLObject)statements;
    }
}
