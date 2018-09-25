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
module hunt.sql.ast.statement.SQLForeignKeyImpl;


import hunt.container;

import hunt.sql.ast.SQLName;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLConstraintImpl;
import hunt.sql.ast.statement.SQLForeignKeyConstraint;
import hunt.sql.ast.statement.SQLExprTableSource;
import std.uni;
import hunt.sql.ast.SQLObject;

public class SQLForeignKeyImpl : SQLConstraintImpl , SQLForeignKeyConstraint {

    alias cloneTo = SQLConstraintImpl.cloneTo;

    private SQLExprTableSource referencedTable;
    private List!SQLName      referencingColumns ;
    private List!SQLName      referencedColumns ;
    private bool            onDeleteCascade    = false;
    private bool            onDeleteSetNull    = false;

    public this(){
        referencingColumns = new ArrayList!SQLName();
        referencedColumns  = new ArrayList!SQLName();
    }

    override
    public List!SQLName getReferencingColumns() {
        return referencingColumns;
    }

    override
    public SQLExprTableSource getReferencedTable() {
        return referencedTable;
    }

    override
    public SQLName getReferencedTableName() {
        if (referencedTable is null) {
            return null;
        }
        return referencedTable.getName();
    }

    override
    public void setReferencedTableName(SQLName value) {
        if (value is null) {
            this.referencedTable = null;
            return;
        }
        this.setReferencedTable(new SQLExprTableSource(value));
    }

    public void setReferencedTable(SQLExprTableSource x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.referencedTable = x;
    }

    override
    public List!SQLName getReferencedColumns() {
        return referencedColumns;
    }

    public bool isOnDeleteCascade() {
        return onDeleteCascade;
    }

    public void setOnDeleteCascade(bool onDeleteCascade) {
        this.onDeleteCascade = onDeleteCascade;
    }

    public bool isOnDeleteSetNull() {
        return onDeleteSetNull;
    }

    public void setOnDeleteSetNull(bool onDeleteSetNull) {
        this.onDeleteSetNull = onDeleteSetNull;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.getName());
            acceptChild(visitor, this.getReferencedTableName());
            acceptChild!SQLName(visitor, this.getReferencingColumns());
            acceptChild!SQLName(visitor, this.getReferencedColumns());
        }
        visitor.endVisit(this);        
    }

    public void cloneTo(SQLForeignKeyImpl x) {
        super.cloneTo(x);

        if (referencedTable !is null) {
            x.setReferencedTable(referencedTable.clone());
        }

        foreach (SQLName column ; referencingColumns) {
            SQLName columnClone = column.clone();
            columnClone.setParent(x);
            x.getReferencingColumns().add(columnClone);
        }

        foreach (SQLName column ; referencedColumns) {
            SQLName columnClone = column.clone();
            columnClone.setParent(x);
            x.getReferencedColumns().add(columnClone);
        }
    }

    override public SQLForeignKeyImpl clone() {
        SQLForeignKeyImpl x = new SQLForeignKeyImpl();
        cloneTo(x);
        return x;
    }

    public static struct Match {
        enum Match FULL = Match("FULL");
        enum Match PARTIAL = Match("PARTIAL");
        enum Match SIMPLE = Match("SIMPLE");

        public  string name;
        public  string name_lcase;

        this(string name){
            this.name = name;
            this.name_lcase = toLower(name);
        }

        bool opEquals(const Match h) nothrow {
            return name == h.name ;
        } 

        bool opEquals(ref const Match h) nothrow {
            return name == h.name ;
        }
    }

    public static struct On {
        enum On DELETE = On("DELETE"); //
        enum On UPDATE = On("UPDATE");

        public  string name;
        public  string name_lcase;

        this(string name){
            this.name = name;
            this.name_lcase = toLower(name);
        }

        bool opEquals(const On h) nothrow {
            return name == h.name ;
        } 

        bool opEquals(ref const On h) nothrow {
            return name == h.name ;
        }
    }

    public static struct Option {

        enum Option RESTRICT = Option("RESTRICT");
        enum Option CASCADE = Option("CASCADE");
        enum Option SET_NULL = Option("SET NULL");
        enum Option NO_ACTION = Option("NO ACTION");

        public  string name;
        public  string name_lcase;

        this(string name){
            this.name = name;
            this.name_lcase = toLower(name);
        }

        bool opEquals(const Option h) nothrow {
            return name == h.name ;
        } 

        bool opEquals(ref const Option h) nothrow {
            return name == h.name ;
        }

        public string getText() {
            return name;
        }

    }
}
