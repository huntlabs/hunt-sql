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
module hunt.sql.ast.statement.SQLStartTransactionStatement;

import hunt.collection;

import hunt.sql.ast;
// import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
// import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;

public class SQLStartTransactionStatement : SQLStatementImpl {

    private bool              consistentSnapshot = false;

    private bool              begin              = false;
    private bool              work               = false;
    private SQLExpr              name;

    private List!SQLCommentHint hints;

    public bool isConsistentSnapshot() {
        return consistentSnapshot;
    }

    public void setConsistentSnapshot(bool consistentSnapshot) {
        this.consistentSnapshot = consistentSnapshot;
    }

    public bool isBegin() {
        return begin;
    }

    public void setBegin(bool begin) {
        this.begin = begin;
    }

    public bool isWork() {
        return work;
    }

    public void setWork(bool work) {
        this.work = work;
    }

    override public void accept0(SQLASTVisitor visitor) {
        visitor.visit(this);

        visitor.endVisit(this);
    }

    public List!SQLCommentHint getHints() {
        return hints;
    }

    public void setHints(List!SQLCommentHint hints) {
        this.hints = hints;
    }

    public SQLExpr getName() {
        return name;
    }

    public void setName(SQLExpr name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }

    override
    public List!SQLObject getChildren() {
        if (name !is null) {
            return Collections.singletonList!SQLObject(name);
        }
        return Collections.emptyList!(SQLObject)();
    }
}
