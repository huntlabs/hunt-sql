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
module hunt.sql.ast.statement.SQLCommentStatement;

import hunt.sql.ast;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLExprTableSource;

import hunt.collection;

public class SQLCommentStatement : SQLStatementImpl {

    public static struct Type {
        enum Type TABLE = Type("TABLE");
        enum Type COLUMN = Type("COLUMN");

        private string _name;

        this(string name)
        {
            _name = name;
        }

        @property string name()
        {
            return _name;
        }

        bool opEquals(const Type h) nothrow {
            return _name == h._name ;
        } 

        bool opEquals(ref const Type h) nothrow {
            return _name == h._name ;
        } 
    }

    private SQLExprTableSource on;
    private Type               type;
    private SQLExpr            comment;

    public SQLExpr getComment() {
        return comment;
    }

    public void setComment(SQLExpr comment) {
        this.comment = comment;
    }

    public Type getType() {
        return type;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public SQLExprTableSource getOn() {
        return on;
    }

    public void setOn(SQLExprTableSource on) {
        if (on !is null) {
            on.setParent(this);
        }
        this.on = on;
    }

    public void setOn(SQLName on) {
        this.setOn(new SQLExprTableSource(on));
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, on);
            acceptChild(visitor, comment);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (on !is null) {
            children.add(on);
        }
        if (comment !is null) {
            children.add(comment);
        }
        return children;
    }
}
