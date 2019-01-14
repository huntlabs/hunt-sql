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
module hunt.sql.ast.statement.SQLAssignItem;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLReplaceable;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.collection;

public class SQLAssignItem : SQLObjectImpl , SQLReplaceable {

    private SQLExpr target;
    private SQLExpr value;

    public this(){
    }

    public this(SQLExpr target, SQLExpr value){
        setTarget(target);
        setValue(value);
    }

    override public SQLAssignItem clone() {
        SQLAssignItem x = new SQLAssignItem();
        if (target !is null) {
            x.setTarget(target.clone());
        }
        if (value !is null) {
            x.setValue(value.clone());
        }
        return x;
    }

    public SQLExpr getTarget() {
        return target;
    }

    public void setTarget(SQLExpr target) {
        if (target !is null) {
            target.setParent(this);
        }
        this.target = target;
    }

    public SQLExpr getValue() {
        return value;
    }

    public void setValue(SQLExpr value) {
        if (value !is null) {
            value.setParent(this);
        }
        this.value = value;
    }

    override public void output(StringBuffer buf) {
        target.output(buf);
        buf.append(" = ");
        value.output(buf);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.target);
            acceptChild(visitor, this.value);
        }
        visitor.endVisit(this);
    }

    override
    public bool replace(SQLExpr expr, SQLExpr target) {
        if (this.target == expr) {
            setTarget(target);
            return true;
        }

        if (this.value == expr) {
            setValue(target);
            return true;
        }
        return false;
    }
}
