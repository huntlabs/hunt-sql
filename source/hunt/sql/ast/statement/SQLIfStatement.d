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
module hunt.sql.ast.statement.SQLIfStatement;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;

public class SQLIfStatement : SQLStatementImpl {

    private SQLExpr            condition;
    private List!SQLStatement statements;
    private List!ElseIf       elseIfList;
    private Else               elseItem;

    this()
    {
        statements = new ArrayList!SQLStatement();
        elseIfList = new ArrayList!ElseIf();
    }

    override public SQLIfStatement clone() {
        SQLIfStatement x = new SQLIfStatement();

        foreach (SQLStatement stmt ; statements) {
            SQLStatement stmt2 = stmt.clone();
            stmt2.setParent(x);
            x.statements.add(stmt2);
        }
        foreach (ElseIf o ; elseIfList) {
            ElseIf o2 = o.clone();
            o2.setParent(x);
            x.elseIfList.add(o2);
        }
        if (elseItem !is null) {
            x.setElseItem(elseItem.clone());
        }

        return x;
    }

    override
    public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, condition);
            acceptChild!SQLStatement(visitor, statements);
            acceptChild!(SQLIfStatement.ElseIf)(visitor, elseIfList);
            acceptChild(visitor, elseItem);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getCondition() {
        return condition;
    }

    public void setCondition(SQLExpr condition) {
        if (condition !is null) {
            condition.setParent(this);
        }
        this.condition = condition;
    }

    public List!SQLStatement getStatements() {
        return statements;
    }

    public void addStatement(SQLStatement statement) {
        if (statement !is null) {
            statement.setParent(this);
        }
        this.statements.add(statement);
    }

    public List!ElseIf getElseIfList() {
        return elseIfList;
    }

    public Else getElseItem() {
        return elseItem;
    }

    public void setElseItem(Else elseItem) {
        if (elseItem !is null) {
            elseItem.setParent(this);
        }
        this.elseItem = elseItem;
    }

    public static class ElseIf : SQLObjectImpl {

        private SQLExpr            condition;
        private List!SQLStatement statements;
        this()
        {
            statements = new ArrayList!SQLStatement();
        }

        override
        public void accept0(SQLASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild(visitor, condition);
                acceptChild!SQLStatement(visitor, statements);
            }
            visitor.endVisit(this);
        }

        public List!SQLStatement getStatements() {
            return statements;
        }

        public void setStatements(List!SQLStatement statements) {
            this.statements = statements;
        }

        public SQLExpr getCondition() {
            return condition;
        }

        public void setCondition(SQLExpr condition) {
            if (condition !is null) {
                condition.setParent(this);
            }
            this.condition = condition;
        }

        override public ElseIf clone() {
            ElseIf x = new ElseIf();

            if (condition !is null) {
                x.setCondition(condition.clone());
            }
            foreach (SQLStatement stmt ; statements) {
                SQLStatement stmt2 = stmt.clone();
                stmt2.setParent(x);
                x.statements.add(stmt2);
            }

            return x;
        }
    }

    public static class Else : SQLObjectImpl {

        private List!SQLStatement statements;

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

        public void setStatements(List!SQLStatement statements) {
            this.statements = statements;
        }

        override public Else clone() {
            Else x = new Else();
            foreach (SQLStatement stmt ; statements) {
                SQLStatement stmt2 = stmt.clone();
                stmt2.setParent(x);
                x.statements.add(stmt2);
            }
            return x;
        }
    }
}
