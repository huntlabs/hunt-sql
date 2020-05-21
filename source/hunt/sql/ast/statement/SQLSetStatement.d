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
module hunt.sql.ast.statement.SQLSetStatement;


import hunt.collection;

import hunt.sql.ast;
import hunt.sql.ast.expr.SQLBinaryOpExpr;
import hunt.sql.ast.expr.SQLBinaryOperator;
import hunt.sql.ast.expr.SQLIntegerExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAssignItem;
import hunt.util.StringBuilder;

public class  SQLSetStatement: SQLStatementImpl {
    private Option option;

    private List!SQLAssignItem items ;
    
    private List!SQLCommentHint hints;

    public this(){
        items = new ArrayList!SQLAssignItem();
    }
    
    public this(string dbType){
        items = new ArrayList!SQLAssignItem();
        super (dbType);
    }
    
    public this(SQLExpr target, SQLExpr value){
        this(target, value, null);
    }

    public this(SQLExpr target, SQLExpr value, string dbType){
        items = new ArrayList!SQLAssignItem();
        super (dbType);
        SQLAssignItem item = new SQLAssignItem(target, value);
        item.setParent(this);
        this.items.add(item);
    }

    public static SQLSetStatement plus(SQLName target) {
        SQLExpr value = new SQLBinaryOpExpr(target.clone(), SQLBinaryOperator.Add, new SQLIntegerExpr(1));
        return new SQLSetStatement(target, value);
    }

    public List!SQLAssignItem getItems() {
        return items;
    }

    public void setItems(List!SQLAssignItem items) {
        this.items = items;
    }

    public List!SQLCommentHint getHints() {
        return hints;
    }

    public void setHints(List!SQLCommentHint hints) {
        this.hints = hints;
    }

    public Option getOption() {
        return option;
    }

    public void setOption(Option option) {
        this.option = option;
    }

    public void set(SQLExpr target, SQLExpr value) {
        SQLAssignItem assignItem = new SQLAssignItem(target, value);
        assignItem.setParent(this);
        this.items.add(assignItem);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLAssignItem(visitor, this.items);
            acceptChild!SQLCommentHint(visitor, this.hints);
        }
        visitor.endVisit(this);
    }

    override public void output(StringBuilder buf) {
        buf.append("SET ");

        for (int i = 0; i < items.size(); ++i) {
            if (i != 0) {
                buf.append(", ");
            }

            SQLAssignItem item = items.get(i);
            item.output(buf);
        }
    }

    override public SQLSetStatement clone() {
        SQLSetStatement x = new SQLSetStatement();
        foreach (SQLAssignItem item ; items) {
            SQLAssignItem item2 = item.clone();
            item2.setParent(x);
            x.items.add(item2);
        }
        if (hints !is null) {
            foreach (SQLCommentHint hint ; hints) {
                SQLCommentHint h2 = hint.clone();
                h2.setParent(x);
                x.hints.add(h2);
            }
        }
        return x;
    }

    override public List!SQLObject getChildren() {
        return cast(List!SQLObject)(this.items);
    }

    public static struct Option {
        enum Option IDENTITY_INSERT = Option("IDENTITY_INSERT");
        enum Option PASSWORD = Option("PASSWORD"); // mysql
        enum Option GLOBAL = Option("GLOBAL");
        enum Option SESSION = Option("SESSION");
        enum Option LOCAL = Option("LOCAL");

        private string _name;

        @property string name()
        {
            return _name;
        }

        this(string name)
        {
            _name = name;
        }

        bool opEquals(const Option h) nothrow {
            return _name == h._name ;
        } 

        bool opEquals(ref const Option h) nothrow {
            return _name == h._name ;
        }
    }

}
