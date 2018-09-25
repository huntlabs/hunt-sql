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
module hunt.sql.ast.statement.SQLAlterTableAddIndex;

import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.dialect.mysql.ast.MySqlKey;
import hunt.sql.dialect.mysql.ast.MySqlUnique;
import hunt.sql.dialect.mysql.ast.statement.MySqlTableIndex;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.SQLObject;


public class SQLAlterTableAddIndex : SQLObjectImpl , SQLAlterTableItem {

    private bool                          unique;

    private SQLName                          name;

    private  List!SQLSelectOrderByItem items;

    private string                           type;

    private string                           using;
    
    private bool                          key = false;

    protected SQLExpr                        comment;

    this()
    {
        items = new ArrayList!SQLSelectOrderByItem();
    }
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, getName());
            acceptChild!SQLSelectOrderByItem(visitor, getItems());
        }
        visitor.endVisit(this);
    }

    public bool isUnique() {
        return unique;
    }

    public void setUnique(bool unique) {
        this.unique = unique;
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

    public bool isKey() {
        return key;
    }

    public void setKey(bool key) {
        this.key = key;
    }

    public void cloneTo(MySqlTableIndex x) {
        if (name !is null) {
            x.setName(name.clone());
        }
        foreach (SQLSelectOrderByItem item ; items) {
            SQLSelectOrderByItem item2 = item.clone();
            item2.setParent(x);
            x.getColumns().add(item);
        }
        x.setIndexType(type);
    }

    public void cloneTo(MySqlKey x) {
        if (name !is null) {
            x.setName(name.clone());
        }
        foreach (SQLSelectOrderByItem item ; items) {
            SQLSelectOrderByItem item2 = item.clone();
            item2.setParent(x);
            x.getColumns().add(item);
        }
        x.setIndexType(type);
    }

    public SQLExpr getComment() {
        return comment;
    }

    public void setComment(SQLExpr comment) {
        if (comment !is null) {
            comment.setParent(this);
        }
        this.comment = comment;
    }
}
