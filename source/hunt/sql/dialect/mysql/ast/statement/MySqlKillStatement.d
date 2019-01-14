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
module hunt.sql.dialect.mysql.ast.statement.MySqlKillStatement;



import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

public class MySqlKillStatement : MySqlStatementImpl {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private Type          type;
    private List!(SQLExpr) threadIds;

    public static enum Type {
                             CONNECTION, QUERY
    }

    this()
    {
        threadIds = new ArrayList!(SQLExpr)();
    }

    public Type getType() {
        return type;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public SQLExpr getThreadId() {
        return threadIds.get(0);
    }

    public void setThreadId(SQLExpr threadId) {
        this.threadIds.set(0, threadId);
    }
    
    public List!(SQLExpr) getThreadIds() {
        return threadIds;
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, cast(List!(SQLObject))threadIds);
        }
        visitor.endVisit(this);
    }

    override
    public List!(SQLObject) getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
