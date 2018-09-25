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
module hunt.sql.ast.statement.SQLExplainStatement;


import hunt.container;

import hunt.sql.ast.SQLCommentHint;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLExplainStatement : SQLStatementImpl {
    private string type;
    protected SQLStatement       statement;
    private List!SQLCommentHint hints;
    
    public this() {
        
    }
    
    public this(string dbType) {
        super (dbType);
    }

    public SQLStatement getStatement() {
        return statement;
    }

    public void setStatement(SQLStatement statement) {
        if (statement !is null) {
            statement.setParent(this);
        }
        this.statement = statement;
    }

    public string getType() {
        return type;
    }

    public void setType(string type) {
        this.type = type;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, statement);
        }
        visitor.endVisit(this);
    }

    public List!SQLCommentHint getHints() {
        return hints;
    }

    public void setHints(List!SQLCommentHint hints) {
        this.hints = hints;
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (statement !is null) {
            children.add(statement);
        }
        return children;
    }
}
