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
module hunt.sql.ast.statement.SQLMergeStatement;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLHint;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLTableSource;
import hunt.sql.ast.statement.SQLErrorLoggingClause;
import hunt.sql.ast.statement.SQLUpdateSetItem;
import hunt.sql.ast.SQLObject;

public class SQLMergeStatement : SQLStatementImpl {

    private  List!SQLHint      hints;

    private SQLTableSource           into;
    private string                   _alias;
    private SQLTableSource           using;
    private SQLExpr                  on;
    private MergeUpdateClause        updateClause;
    private MergeInsertClause        insertClause;
    private SQLErrorLoggingClause errorLoggingClause;

    this()
    {
        hints = new ArrayList!SQLHint();
    }

    override public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, into);
            acceptChild(visitor, using);
            acceptChild(visitor, on);
            acceptChild(visitor, updateClause);
            acceptChild(visitor, insertClause);
            acceptChild(visitor, errorLoggingClause);
        }
        visitor.endVisit(this);
    }

    public string getAlias() {
        return into.getAlias();
    }

    public SQLTableSource getInto() {
        return into;
    }
    
    public void setInto(SQLName into) {
        this.setInto(new SQLExprTableSource(into));
    }

    public void setInto(SQLTableSource into) {
        if (into !is null) {
            into.setParent(this);
        }
        this.into = into;
    }

    public SQLTableSource getUsing() {
        return using;
    }

    public void setUsing(SQLTableSource using) {
        this.using = using;
    }

    public SQLExpr getOn() {
        return on;
    }

    public void setOn(SQLExpr on) {
        this.on = on;
    }

    public MergeUpdateClause getUpdateClause() {
        return updateClause;
    }

    public void setUpdateClause(MergeUpdateClause updateClause) {
        this.updateClause = updateClause;
    }

    public MergeInsertClause getInsertClause() {
        return insertClause;
    }

    public void setInsertClause(MergeInsertClause insertClause) {
        this.insertClause = insertClause;
    }

    public SQLErrorLoggingClause getErrorLoggingClause() {
        return errorLoggingClause;
    }

    public void setErrorLoggingClause(SQLErrorLoggingClause errorLoggingClause) {
        this.errorLoggingClause = errorLoggingClause;
    }

    public List!SQLHint getHints() {
        return hints;
    }

    public static class MergeUpdateClause : SQLObjectImpl {

        private List!SQLUpdateSetItem items;
        private SQLExpr                where;
        private SQLExpr                deleteWhere;

        this()
        {
            items = new ArrayList!SQLUpdateSetItem();
        }

        public List!SQLUpdateSetItem getItems() {
            return items;
        }

        public void addItem(SQLUpdateSetItem item) {
            if (item !is null) {
                item.setParent(this);
            }
            this.items.add(item);
        }

        public SQLExpr getWhere() {
            return where;
        }

        public void setWhere(SQLExpr where) {
            this.where = where;
        }

        public SQLExpr getDeleteWhere() {
            return deleteWhere;
        }

        public void setDeleteWhere(SQLExpr deleteWhere) {
            this.deleteWhere = deleteWhere;
        }

        override
        public void accept0(SQLASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild!SQLUpdateSetItem(visitor, items);
                acceptChild(visitor, where);
                acceptChild(visitor, deleteWhere);
            }
            visitor.endVisit(this);
        }

    }

    public static class MergeInsertClause : SQLObjectImpl {

        private List!SQLExpr columns;
        private List!SQLExpr values;
        private SQLExpr       where;

        this()
        {
            columns = new ArrayList!SQLExpr();
            values  = new ArrayList!SQLExpr();
        }

        override
        public void accept0(SQLASTVisitor visitor) {
            if (visitor.visit(this)) {
                acceptChild!SQLExpr(visitor, columns);
                acceptChild!SQLExpr(visitor, values);
                acceptChild(visitor, where);
            }
            visitor.endVisit(this);
        }

        public List!SQLExpr getColumns() {
            return columns;
        }

        public void setColumns(List!SQLExpr columns) {
            this.columns = columns;
        }

        public List!SQLExpr getValues() {
            return values;
        }

        public void setValues(List!SQLExpr values) {
            this.values = values;
        }

        public SQLExpr getWhere() {
            return where;
        }

        public void setWhere(SQLExpr where) {
            this.where = where;
        }

    }
}

// public  class MergeUpdateClause : SQLObjectImpl {

//         private List!SQLUpdateSetItem items;
//         private SQLExpr                where;
//         private SQLExpr                deleteWhere;

//         this()
//         {
//             items = new ArrayList!SQLUpdateSetItem();
//         }

//         public List!SQLUpdateSetItem getItems() {
//             return items;
//         }

//         public void addItem(SQLUpdateSetItem item) {
//             if (item !is null) {
//                 item.setParent(this);
//             }
//             this.items.add(item);
//         }

//         public SQLExpr getWhere() {
//             return where;
//         }

//         public void setWhere(SQLExpr where) {
//             this.where = where;
//         }

//         public SQLExpr getDeleteWhere() {
//             return deleteWhere;
//         }

//         public void setDeleteWhere(SQLExpr deleteWhere) {
//             this.deleteWhere = deleteWhere;
//         }

//         override
//         public void accept0(SQLASTVisitor visitor) {
//             if (visitor.visit(this)) {
//                 acceptChild(visitor, cast(List!SQLObject)items);
//                 acceptChild(visitor, where);
//                 acceptChild(visitor, deleteWhere);
//             }
//             visitor.endVisit(this);
//         }

//     }

//     public  class MergeInsertClause : SQLObjectImpl {

//         private List!SQLExpr columns;
//         private List!SQLExpr values;
//         private SQLExpr       where;

//         this()
//         {
//             columns = new ArrayList!SQLExpr();
//             values  = new ArrayList!SQLExpr();
//         }

//         override
//         public void accept0(SQLASTVisitor visitor) {
//             if (visitor.visit(this)) {
//                 acceptChild(visitor, cast(List!SQLObject)columns);
//                 acceptChild(visitor, cast(List!SQLObject)values);
//                 acceptChild(visitor, where);
//             }
//             visitor.endVisit(this);
//         }

//         public List!SQLExpr getColumns() {
//             return columns;
//         }

//         public void setColumns(List!SQLExpr columns) {
//             this.columns = columns;
//         }

//         public List!SQLExpr getValues() {
//             return values;
//         }

//         public void setValues(List!SQLExpr values) {
//             this.values = values;
//         }

//         public SQLExpr getWhere() {
//             return where;
//         }

//         public void setWhere(SQLExpr where) {
//             this.where = where;
//         }

//     }