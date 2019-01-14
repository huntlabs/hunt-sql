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
module hunt.sql.ast.statement.SQLDescribeStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLObjectType;


import hunt.collection;

public class SQLDescribeStatement : SQLStatementImpl {

    protected SQLName object;

    protected SQLName column;

    // for odps
    protected SQLObjectType objectType;
    protected List!SQLExpr partition;

    this()
    {
        partition = new ArrayList!SQLExpr();
    }

    public SQLName getObject() {
        return object;
    }

    public void setObject(SQLName object) {
        this.object = object;
    }

    public SQLName getColumn() {
        return column;
    }

    public void setColumn(SQLName column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.column = column;
    }

    public List!SQLExpr getPartition() {
        return partition;
    }

    public void setPartition(List!SQLExpr partition) {
        this.partition = partition;
    }

    public SQLObjectType getObjectType() {
        return objectType;
    }

    public void setObjectType(SQLObjectType objectType) {
        this.objectType = objectType;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, object);
            acceptChild(visitor, column);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        // return Arrays.asList(this.object, column);
        List!SQLObject ls = new ArrayList!SQLObject();
        ls.add(this.object);
        ls.add(column);
        return ls;
    }
}
