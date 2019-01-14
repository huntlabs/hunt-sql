/*
 * Copyright 2015-2018 HuntLabs.cn
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance _with the License.
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
module hunt.sql.ast.statement.SQLInsertStatement;


import hunt.collection;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLStatement;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLWithSubqueryClause;
import hunt.sql.ast.statement.SQLInsertInto;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLSelect;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLSelectQuery;



public class SQLInsertStatement : SQLInsertInto , SQLStatement {

    alias cloneTo = SQLInsertInto.cloneTo;

    protected SQLWithSubqueryClause _with;

    protected string dbType;

    protected bool upsert = false; // for phoenix

    private bool afterSemi;

    public this(){

    }

    public void cloneTo(SQLInsertStatement x) {
        super.cloneTo(x);
        x.dbType = dbType;
        x.upsert = upsert;
        x.afterSemi = afterSemi;

        if (_with !is null) {
            x.setWith(_with.clone());
        }
    }

    override public SQLInsertStatement clone() {
        SQLInsertStatement x = new SQLInsertStatement();
        cloneTo(x);
        return x;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            this.acceptChild(visitor, tableSource);
            this.acceptChild!SQLExpr(visitor, columns);
            this.acceptChild!ValuesClause(visitor, valuesList);
            this.acceptChild(visitor, query);
        }

        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();

        children.add(tableSource);
        children.addAll(cast(List!SQLObject)(this.columns));
        children.addAll(cast(List!SQLObject)(this.valuesList));
        if (query !is null) {
            children.add(query);
        }

        return children;
    }

    public bool isUpsert() {
        return upsert;
    }

    public void setUpsert(bool upsert) {
        this.upsert = upsert;
    }

    // public static class ValuesClause : SQLObjectImpl {

    //     private      List!SQLExpr values;
    //     private  string        originalString;
    //     private  int           replaceCount;

    //     public this(){
    //         this(new ArrayList!SQLExpr());
    //     }

    //     override public ValuesClause clone() {
    //         ValuesClause x = new ValuesClause(new ArrayList!SQLExpr(this.values.size()));
    //         foreach (SQLExpr v ; values) {
    //             x.addValue(v);
    //         }
    //         return x;
    //     }

    //     public this(List!SQLExpr values){
    //         this.values = values;
    //         for (int i = 0; i < values.size(); ++i) {
    //             values.get(i).setParent(this);
    //         }
    //     }

    //     public void addValue(SQLExpr value) {
    //         value.setParent(this);
    //         values.add(value);
    //     }

    //     public List!SQLExpr getValues() {
    //         return values;
    //     }

    //     override public void output(StringBuffer buf) {
    //         buf.append(" VALUES (");
    //         for (int i = 0, size = values.size(); i < size; ++i) {
    //             if (i != 0) {
    //                 buf.append(", ");
    //             }
    //             values.get(i).output(buf);
    //         }
    //         buf.append(")");
    //     }

        
    //     override  protected void accept0(SQLASTVisitor visitor) {
    //         if (visitor.visit(this)) {
    //             this.acceptChild(visitor, values);
    //         }

    //         visitor.endVisit(this);
    //     }

    //     public string getOriginalString() {
    //         return originalString;
    //     }

    //     public void setOriginalString(string originalString) {
    //         this.originalString = originalString;
    //     }

    //     public int getReplaceCount() {
    //         return replaceCount;
    //     }

    //     public void incrementReplaceCount() {
    //         this.replaceCount++;
    //     }
    // }

    override
    public string getDbType() {
        return dbType;
    }
    
    public void setDbType(string dbType) {
        this.dbType = dbType;
    }

    override
    public bool isAfterSemi() {
        return afterSemi;
    }

    override
    public void setAfterSemi(bool afterSemi) {
        this.afterSemi = afterSemi;
    }


    public SQLWithSubqueryClause getWith() {
        return _with;
    }

    public void setWith(SQLWithSubqueryClause _with) {
        if (_with !is null) {
            _with.setParent(this);
        }
        this._with = _with;
    }

    override public string toString() {
        return SQLUtils.toSQLString(this, dbType);
    }

    public string toLowerCaseString() {
        return SQLUtils.toSQLString(this, dbType, SQLUtils.DEFAULT_LCASE_FORMAT_OPTION);
    }
}
