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
module hunt.sql.dialect.mysql.ast.statement.MySqlSubPartitionByList;


import hunt.collection;
import hunt.sql.ast.SQLObject;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLSubPartitionBy;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.dialect.mysql.ast.MySqlObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;

public class MySqlSubPartitionByList : SQLSubPartitionBy , MySqlObject {
    alias cloneTo = SQLSubPartitionBy.cloneTo;
    private SQLExpr       expr;

    private List!(SQLColumnDefinition) columns;

    this()
    {
        columns = new ArrayList!(SQLColumnDefinition)();
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
        } else {
            throw new Exception("not support visitor type : " ~ typeof(visitor).stringof);
        }
    }
    
    override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, expr);
            acceptChild!SQLColumnDefinition(visitor, columns);
            acceptChild(visitor, subPartitionsCount);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getExpr() {
        return expr;
    }

    public void setExpr(SQLExpr expr) {
        if (expr !is null) {
            expr.setParent(this);
        }
        this.expr = expr;
    }

    public List!(SQLColumnDefinition) getColumns() {
        return columns;
    }

    public void addColumn(SQLColumnDefinition column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.columns.add(column);
    }

    public void cloneTo(MySqlSubPartitionByList x) {
        super.cloneTo(x);
        if (expr !is null) {
            x.setExpr(expr.clone());
        }
        foreach(SQLColumnDefinition column ; columns) {
            SQLColumnDefinition c2 = column.clone();
            c2.setParent(x);
            x.columns.add(c2);
        }
    }

    override public MySqlSubPartitionByList clone() {
        MySqlSubPartitionByList x = new MySqlSubPartitionByList();
        cloneTo(x);
        return x;
    }
}
