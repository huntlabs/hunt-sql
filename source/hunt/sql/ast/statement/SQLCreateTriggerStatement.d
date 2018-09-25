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
module hunt.sql.ast.statement.SQLCreateTriggerStatement;


import hunt.container;

import hunt.sql.ast;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLCreateStatement;

public class SQLCreateTriggerStatement : SQLStatementImpl , SQLCreateStatement {

    private SQLName                  name;
    private bool                  orReplace      = false;
    private TriggerType              triggerType;

    private SQLName                  definer;

    private bool                  update;
    private bool                  _delete;
    private bool                  insert;

    private SQLExprTableSource       on;

    private bool                  forEachRow     = false;

    private List!SQLName            updateOfColumns;

    private SQLExpr                  when;
    private SQLStatement             body;
    
    public this() {
         updateOfColumns = new ArrayList!SQLName();
    }
    
    public this(string dbType) {
        updateOfColumns = new ArrayList!SQLName();
        super (dbType);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild!SQLName(visitor, updateOfColumns);
            acceptChild(visitor, on);
            acceptChild(visitor, when);
            acceptChild(visitor, body);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (name !is null) {
            children.add(name);
        }
        children.addAll(cast(List!SQLObject)(updateOfColumns));
        if (on !is null) {
            children.add(on);
        }
        if (when !is null) {
            children.add(when);
        }
        if (body !is null) {
            children.add(body);
        }
        return children;
    }

    public SQLExprTableSource getOn() {
        return on;
    }

    public void setOn(SQLName on) {
        this.setOn(new SQLExprTableSource(on));
    }

    public void setOn(SQLExprTableSource on) {
        if (on !is null) {
            on.setParent(this);
        }
        this.on = on;
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }

    public SQLStatement getBody() {
        return body;
    }

    public void setBody(SQLStatement body) {
        if (body !is null) {
            body.setParent(this);
        }
        this.body = body;
    }

    public bool isOrReplace() {
        return orReplace;
    }

    public void setOrReplace(bool orReplace) {
        this.orReplace = orReplace;
    }

    public TriggerType getTriggerType() {
        return triggerType;
    }

    public void setTriggerType(TriggerType triggerType) {
        this.triggerType = triggerType;
    }

    public List!TriggerEvent getTriggerEvents() {
        return null;
    }

    public bool isForEachRow() {
        return forEachRow;
    }

    public void setForEachRow(bool forEachRow) {
        this.forEachRow = forEachRow;
    }

    public List!SQLName getUpdateOfColumns() {
        return updateOfColumns;
    }

    public SQLExpr getWhen() {
        return when;
    }

    public void setWhen(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.when = x;
    }

    public bool isUpdate() {
        return update;
    }

    public void setUpdate(bool update) {
        this.update = update;
    }

    public bool isDelete() {
        return _delete;
    }

    public void setDelete(bool _delete) {
        this._delete = _delete;
    }

    public bool isInsert() {
        return insert;
    }

    public void setInsert(bool insert) {
        this.insert = insert;
    }

    public SQLName getDefiner() {
        return definer;
    }

    public void setDefiner(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.definer = x;
    }

    public static struct TriggerType {
        enum TriggerType BEFORE = TriggerType("BEFORE");
        enum TriggerType AFTER = TriggerType("AFTER");
        enum TriggerType INSTEAD_OF = TriggerType("INSTEAD_OF");

        private string _name;

        this(string name)
        {
            _name = name;
        }

        @property string name()
        {
            return _name;
        }

        bool opEquals(const TriggerType h) nothrow {
            return _name == h._name ;
        } 

        bool opEquals(ref const TriggerType h) nothrow {
            return _name == h._name ;
        } 
    }

    public static struct TriggerEvent {
        enum TriggerEvent INSERT = TriggerEvent("INSERT");
        enum TriggerEvent UPDATE = TriggerEvent("UPDATE");
        enum TriggerEvent DELETE = TriggerEvent("DELETE");

        private string _name;

        this(string name)
        {
            _name = name;
        }

        @property string name()
        {
            return _name;
        }

        bool opEquals(const TriggerType h) nothrow {
            return _name == h._name ;
        } 

        bool opEquals(ref const TriggerType h) nothrow {
            return _name == h._name ;
        } 
    }
}
