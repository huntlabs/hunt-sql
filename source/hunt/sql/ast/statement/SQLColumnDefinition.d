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
module hunt.sql.ast.statement.SQLColumnDefinition;

import hunt.container;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.ast.statement.SQLColumnConstraint;
import hunt.lang;
import hunt.sql.ast.statement.SQLNotNullConstraint;
import hunt.sql.ast.statement.SQLColumnPrimaryKey;
import hunt.sql.ast.statement.SQLCreateTableStatement;

public class SQLColumnDefinition : SQLObjectImpl , SQLTableElement, SQLObjectWithDataType, SQLReplaceable {
    protected string                          dbType;

    protected SQLName                         name;
    protected SQLDataType                     dataType;
    protected SQLExpr                         defaultExpr;
    protected  List!SQLColumnConstraint constraints;
    protected SQLExpr                         comment;

    protected Boolean                         enable;
    protected Boolean                         validate;
    protected Boolean                         rely;

    // for mysql
    protected bool                         autoIncrement = false;
    protected SQLExpr                         onUpdate;
    protected SQLExpr                         storage;
    protected SQLExpr                         charsetExpr;
    protected SQLExpr                         asExpr;
    protected bool                         sorted        = false;
    protected bool                         virtual       = false;

    protected Identity                        identity;
    protected SQLExpr                         generatedAlawsAs;

    public this(){
        constraints   = new ArrayList!SQLColumnConstraint(0);
    }

    public Identity getIdentity() {
        return identity;
    }

    // for sqlserver
    public void setIdentity(Identity x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.identity = x;
    }

    public SQLExpr getGeneratedAlawsAs() {
        return generatedAlawsAs;
    }

    public void setGeneratedAlawsAs(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.generatedAlawsAs = x;
    }

    public Boolean getEnable() {
        return enable;
    }

    public void setEnable(Boolean enable) {
        this.enable = enable;
    }

    public Boolean getValidate() {
        return validate;
    }

    public void setValidate(Boolean validate) {
        this.validate = validate;
    }

    public Boolean getRely() {
        return rely;
    }

    public void setRely(Boolean rely) {
        this.rely = rely;
    }

    public SQLName getName() {
        return name;
    }

    public long nameHashCode64() {
        if (name is null) {
            return 0;
        }

        return name.hashCode64();
    }

    public string getNameAsString() {
        if (name is null) {
            return null;
        }

        return (cast(Object)(name)).toString();
    }

    public void setName(SQLName name) {
        this.name = name;
    }

    public void setName(string name) {
        this.setName(new SQLIdentifierExpr(name));
    }

    public SQLDataType getDataType() {
        return dataType;
    }

    public void setDataType(SQLDataType dataType) {
        if (dataType !is null) {
            dataType.setParent(this);
        }
        this.dataType = dataType;
    }

    public SQLExpr getDefaultExpr() {
        return defaultExpr;
    }

    public void setDefaultExpr(SQLExpr defaultExpr) {
        if (defaultExpr !is null) {
            defaultExpr.setParent(this);
        }
        this.defaultExpr = defaultExpr;
    }

    public List!SQLColumnConstraint getConstraints() {
        return constraints;
    }
    
    public void addConstraint(SQLColumnConstraint constraint) {
        if (constraint !is null) {
            constraint.setParent(this);
        }
        this.constraints.add(constraint);
    }

    override public void output(StringBuffer buf) {
        name.output(buf);
        buf.append(' ');
        this.dataType.output(buf);
        if (defaultExpr !is null) {
            buf.append(" DEFAULT ");
            this.defaultExpr.output(buf);
        }
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            this.acceptChild(visitor, name);
            this.acceptChild(visitor, dataType);
            this.acceptChild(visitor, defaultExpr);
            this.acceptChild!SQLColumnConstraint(visitor, constraints);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getComment() {
        return comment;
    }

    public void setComment(string comment) {
        this.setComment(new SQLCharExpr(comment));
    }

    public void setComment(SQLExpr comment) {
        if (comment !is null) {
            comment.setParent(this);
        }
        this.comment = comment;
    }

    public bool isVirtual() {
        return virtual;
    }

    public void setVirtual(bool virtual) {
        this.virtual = virtual;
    }

    public bool isSorted() {
        return sorted;
    }

    public void setSorted(bool sorted) {
        this.sorted = sorted;
    }

    public SQLExpr getCharsetExpr() {
        return charsetExpr;
    }

    public void setCharsetExpr(SQLExpr charsetExpr) {
        if (charsetExpr !is null) {
            charsetExpr.setParent(this);
        }
        this.charsetExpr = charsetExpr;
    }

    public SQLExpr getAsExpr() {
        return asExpr;
    }

    public void setAsExpr(SQLExpr asExpr) {
        if (charsetExpr !is null) {
            charsetExpr.setParent(this);
        }
        this.asExpr = asExpr;
    }

    public bool isAutoIncrement() {
        return autoIncrement;
    }

    public void setAutoIncrement(bool autoIncrement) {
        this.autoIncrement = autoIncrement;
    }

    public SQLExpr getOnUpdate() {
        return onUpdate;
    }

    public void setOnUpdate(SQLExpr onUpdate) {
        this.onUpdate = onUpdate;
    }

    public SQLExpr getStorage() {
        return storage;
    }

    public void setStorage(SQLExpr storage) {
        this.storage = storage;
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (defaultExpr == expr) {
            setDefaultExpr(target);
            return true;
        }

        if (name == expr) {
            setName(cast(SQLName) target);
            return true;
        }

        return false;
    }

    public static class Identity : SQLObjectImpl {

        private Integer seed;
        private Integer increment;

        private bool notForReplication;

        public this(){

        }

        public Integer getSeed() {
            return seed;
        }

        public void setSeed(Integer seed) {
            this.seed = seed;
        }

        public Integer getIncrement() {
            return increment;
        }

        public void setIncrement(Integer increment) {
            this.increment = increment;
        }

        public bool isNotForReplication() {
            return notForReplication;
        }

        public void setNotForReplication(bool notForReplication) {
            this.notForReplication = notForReplication;
        }

        override
        public void accept0(SQLASTVisitor visitor) {
            visitor.visit(this);
            visitor.endVisit(this);
        }

        override public Identity clone () {
            Identity x = new Identity();
            x.seed = seed;
            x.increment = increment;
            x.notForReplication = notForReplication;
            return x;
        }
    }

    public string computeAlias() {
        string alias_p = null;

        if (cast(SQLIdentifierExpr)(name) !is null) {
            alias_p = (cast(SQLIdentifierExpr) name).getName();
        } else if (cast(SQLPropertyExpr)(name) !is null ) {
            alias_p = (cast(SQLPropertyExpr) name).getName();
        }

        return SQLUtils.normalize(alias_p);
    }

    override public SQLColumnDefinition clone() {
        SQLColumnDefinition x = new SQLColumnDefinition();
        x.setDbType(dbType);

        if(name !is null) {
            x.setName(name.clone());
        }

        if (dataType !is null) {
            x.setDataType(dataType.clone());
        }

        if (defaultExpr !is null) {
            x.setDefaultExpr(defaultExpr.clone());
        }

        foreach (SQLColumnConstraint item ; constraints) {
            SQLColumnConstraint itemCloned = item.clone();
            itemCloned.setParent(x);
            x.constraints.add(itemCloned);
        }

        if (comment !is null) {
            x.setComment(comment.clone());
        }

        x.enable = enable;
        x.validate = validate;
        x.rely = rely;

        x.autoIncrement = autoIncrement;

        if (onUpdate !is null) {
            x.setOnUpdate(onUpdate.clone());
        }

        if (storage !is null) {
            x.setStorage(storage.clone());
        }

        if (charsetExpr !is null) {
            x.setCharsetExpr(charsetExpr.clone());
        }

        if (asExpr !is null) {
            x.setAsExpr(asExpr.clone());
        }

        x.sorted = sorted;
        x.virtual = virtual;

        if (identity !is null) {
            x.setIdentity(identity.clone());
        }

        return x;
    }

    public string getDbType() {
        return dbType;
    }

    public void setDbType(string dbType) {
        this.dbType = dbType;
    }

    public void simplify() {
        enable = false;
        validate = false;
        rely = false;


        if (cast(SQLIdentifierExpr)(this.name) !is null ) {
            SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) this.name;
            string columnName = identExpr.getName();
            string normalized = SQLUtils.normalize(columnName, dbType);
            if (normalized != columnName) {
                this.setName(normalized);
            }
        }
    }

    public bool containsNotNullConstaint() {
        foreach (SQLColumnConstraint constraint ; this.constraints) {
            if (cast(SQLNotNullConstraint)(constraint) !is null ) {
                return true;
            }
        }

        return false;
    }

    public bool isPrimaryKey() {
        foreach (SQLColumnConstraint constraint ; constraints) {
            if (cast(SQLColumnPrimaryKey)(constraint) !is null ) {
                return true;
            }
        }

        if (cast(SQLCreateTableStatement)(parent) !is null ) {
            return (cast(SQLCreateTableStatement) parent)
                    .isPrimaryColumn(nameHashCode64());
        }

        return false;
    }

    override public string toString() {
        return SQLUtils.toSQLString(this, dbType);
    }
}
