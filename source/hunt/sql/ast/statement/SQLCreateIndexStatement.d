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
module hunt.sql.ast.statement.SQLCreateIndexStatement;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLCreateStatement;

public class SQLCreateIndexStatement : SQLStatementImpl , SQLCreateStatement {

    private SQLName                    name;

    private SQLTableSource             table;

    private List!SQLSelectOrderByItem items;

    private string                     type;
    
    // for mysql
    private string                     using;

    private SQLExpr                    comment;

    public this(){
        items = new ArrayList!SQLSelectOrderByItem();
    }
    
    public this(string dbType){
        items = new ArrayList!SQLSelectOrderByItem();
        super (dbType);
    }

    public SQLTableSource getTable() {
        return table;
    }

    public void setTable(SQLName table) {
        this.setTable(new SQLExprTableSource(table));
    }

    public void setTable(SQLTableSource table) {
        this.table = table;
    }

    public string getTableName() {
        if (cast(SQLExprTableSource)(table) !is null ) {
            SQLExpr expr = (cast(SQLExprTableSource) table).getExpr();
            if (cast(SQLIdentifierExpr)(expr) !is null ) {
                return (cast(SQLIdentifierExpr) expr).getName();
            } else if (cast(SQLPropertyExpr)(expr) !is null ) {
                return (cast(SQLPropertyExpr) expr).getName();
            }
        }

        return null;
    }

    public List!SQLSelectOrderByItem getItems() {
        return items;
    }

    public void addItem(SQLSelectOrderByItem item) {
        if (item !is null) {
            item.setParent(this);
        }
        this.items.add(item);
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        this.name = name;
    }

    public string getType() {
        return type;
    }

    public void setType(string type) {
        this.type = type;
    }
    
    public string getUsing() {
        return using;
    }

    public void setUsing(string using) {
        this.using = using;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild(visitor, table);
            acceptChild!SQLSelectOrderByItem(visitor, items);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (name !is null) {
            children.add(name);
        }

        if (table !is null) {
            children.add(table);
        }

        children.addAll(cast(List!SQLObject)(this.items));
        return children;
    }

    public string getSchema() {
        SQLName name = null;
        if (cast(SQLExprTableSource)(table) !is null ) {
            SQLExpr expr = (cast(SQLExprTableSource) table).getExpr();
            if (cast(SQLName)(expr) !is null ) {
                name = cast(SQLName) expr;
            }
        }

        if (name is null) {
            return null;
        }

        if (cast(SQLPropertyExpr)(name) !is null ) {
            return (cast(SQLPropertyExpr) name).getOwnernName();
        }

        return null;
    }


    override public SQLCreateIndexStatement clone() {
        SQLCreateIndexStatement x = new SQLCreateIndexStatement();
        if (name !is null) {
            x.setName(name.clone());
        }
        if (table !is null) {
            x.setTable(table.clone());
        }
        foreach (SQLSelectOrderByItem item ; items) {
            SQLSelectOrderByItem item2 = item.clone();
            item2.setParent(x);
            x.items.add(item2);
        }
        x.type = type;
        x.using = using;
        if (comment !is null) {
            x.setComment(comment.clone());
        }
        return x;
    }

    public SQLExpr getComment() {
        return comment;
    }

    public void setComment(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.comment = x;
    }
}
