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
module hunt.sql.dialect.postgresql.ast.stmt.PGInsertStatement;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLInsertStatement;
import hunt.sql.ast.statement.SQLUpdateSetItem;
import hunt.sql.ast.statement.SQLWithSubqueryClause;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.dialect.postgresql.ast.stmt.PGSQLStatement;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLObject;


public class PGInsertStatement : SQLInsertStatement , PGSQLStatement {

    alias cloneTo = SQLInsertStatement.cloneTo;
    
    private List!(ValuesClause)     valuesList;
    private SQLExpr                returning;
    private bool			       defaultValues = false;

    private List!(SQLExpr)          onConflictTarget;
    private SQLName                onConflictConstraint;
    private SQLExpr                onConflictWhere;
    private bool                onConflictDoNothing;
    private List!(SQLUpdateSetItem) onConflictUpdateSetItems;


    public this() {
        valuesList = new ArrayList!(ValuesClause)();
        dbType = DBType.POSTGRESQL.name;
    }

    public void cloneTo(PGInsertStatement x) {
        super.cloneTo(x);
        foreach(ValuesClause v ; valuesList) {
            ValuesClause v2 = v.clone();
            v2.setParent(x);
            x.valuesList.add(v2);
        }
        if (returning !is null) {
            x.setReturning(returning.clone());
        }
        x.defaultValues = defaultValues;
    }

    public SQLExpr getReturning() {
        return returning;
    }

    public void setReturning(SQLExpr returning) {
        this.returning = returning;
    }


    override public ValuesClause getValues() {
        if (valuesList.size() == 0) {
            return null;
        }
        return valuesList.get(0);
    }

    override public void setValues(ValuesClause values) {
        if (valuesList.size() == 0) {
            valuesList.add(values);
        } else {
            valuesList.set(0, values);
        }
    }

    override public List!(ValuesClause) getValuesList() {
        return valuesList;
    }

    override public void addValueCause(ValuesClause valueClause) {
        valueClause.setParent(this);
        valuesList.add(valueClause);
    }

    public bool isDefaultValues() {
		return defaultValues;
	}

	public void setDefaultValues(bool defaultValues) {
		this.defaultValues = defaultValues;
	}

	override  protected void accept0(SQLASTVisitor visitor) {
        accept0(cast(PGASTVisitor) visitor);
    }

    override
    public void accept0(PGASTVisitor visitor) {
        if (visitor.visit(this)) {
            this.acceptChild(visitor, _with);
            this.acceptChild(visitor, tableSource);
            this.acceptChild!SQLExpr(visitor, columns);
            this.acceptChild!ValuesClause(visitor, valuesList);
            this.acceptChild(visitor, query);
            this.acceptChild(visitor, returning);
        }

        visitor.endVisit(this);
    }

    override public PGInsertStatement clone() {
        PGInsertStatement x = new PGInsertStatement();
        cloneTo(x);
        return x;
    }

    public List!(SQLExpr) getOnConflictTarget() {
        return onConflictTarget;
    }

    public void setOnConflictTarget(List!(SQLExpr) onConflictTarget) {
        this.onConflictTarget = onConflictTarget;
    }

    public bool isOnConflictDoNothing() {
        return onConflictDoNothing;
    }

    public void setOnConflictDoNothing(bool onConflictDoNothing) {
        this.onConflictDoNothing = onConflictDoNothing;
    }

    public List!(SQLUpdateSetItem) getOnConflictUpdateSetItems() {
        return onConflictUpdateSetItems;
    }

    public void addConflicUpdateItem(SQLUpdateSetItem item) {
        if (onConflictUpdateSetItems is null) {
            onConflictUpdateSetItems = new ArrayList!(SQLUpdateSetItem)();
        }

        item.setParent(this);
        onConflictUpdateSetItems.add(item);
    }

    public SQLName getOnConflictConstraint() {
        return onConflictConstraint;
    }

    public void setOnConflictConstraint(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.onConflictConstraint = x;
    }

    public SQLExpr getOnConflictWhere() {
        return onConflictWhere;
    }

    public void setOnConflictWhere(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.onConflictWhere = x;
    }
}
