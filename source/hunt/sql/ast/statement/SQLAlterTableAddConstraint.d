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
module hunt.sql.ast.statement.SQLAlterTableAddConstraint;

import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLConstraint;


public class SQLAlterTableAddConstraint : SQLObjectImpl , SQLAlterTableItem {

    private SQLConstraint constraint;
    private bool      withNoCheck = false;

    public this(){

    }

    public this(SQLConstraint constraint){
        this.setConstraint(constraint);
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, constraint);
        }
        visitor.endVisit(this);
    }

    public SQLConstraint getConstraint() {
        return constraint;
    }

    public void setConstraint(SQLConstraint constraint) {
        if (constraint !is null) {
            constraint.setParent(this);
        }
        this.constraint = constraint;
    }

    public bool isWithNoCheck() {
        return withNoCheck;
    }

    public void setWithNoCheck(bool withNoCheck) {
        this.withNoCheck = withNoCheck;
    }

}
