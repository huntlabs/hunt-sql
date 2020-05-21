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
module hunt.sql.ast.statement.SQLUnionQuery;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLLimit;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.SQLOrderBy;
import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLSelectQuery;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.ast.statement.SQLUnionOperator;
import hunt.collection;
import hunt.util.StringBuilder;

public class SQLUnionQuery : SQLObjectImpl , SQLSelectQuery {

    private bool          bracket  = false;

    private SQLSelectQuery   left;
    private SQLSelectQuery   right;
    private SQLUnionOperator operator = SQLUnionOperator.UNION;
    private SQLOrderBy       orderBy;

    private SQLLimit         limit;
    private string           dbType;

    public SQLUnionOperator getOperator() {
        return operator;
    }

    public void setOperator(SQLUnionOperator operator) {
        this.operator = operator;
    }

    public this(){

    }

    public this(SQLSelectQuery left, SQLUnionOperator operator, SQLSelectQuery right){
        this.setLeft(left);
        this.operator = operator;
        this.setRight(right);
    }

    public SQLSelectQuery getLeft() {
        return left;
    }

    public void setLeft(SQLSelectQuery left) {
        if (left !is null) {
            left.setParent(this);
        }
        this.left = left;
    }

    public SQLSelectQuery getRight() {
        return right;
    }

    public void setRight(SQLSelectQuery right) {
        if (right !is null) {
            right.setParent(this);
        }
        this.right = right;
    }

    public SQLOrderBy getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(SQLOrderBy orderBy) {
        if (orderBy !is null) {
            orderBy.setParent(this);
        }
        this.orderBy = orderBy;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, left);
            acceptChild(visitor, right);
            acceptChild(visitor, orderBy);
            acceptChild(visitor, limit);
        }
        visitor.endVisit(this);
    }


    public SQLLimit getLimit() {
        return limit;
    }

    public void setLimit(SQLLimit limit) {
        if (limit !is null) {
            limit.setParent(this);
        }
        this.limit = limit;
    }

    public bool isBracket() {
        return bracket;
    }

    public void setBracket(bool bracket) {
        this.bracket = bracket;
    }

    override public SQLUnionQuery clone() {
        SQLUnionQuery x = new SQLUnionQuery();

        x.bracket = bracket;
        if (left !is null) {
            x.setLeft(left.clone());
        }
        if (right !is null) {
            x.setRight(right.clone());
        }
        x.operator = operator;

        if (orderBy !is null) {
            x.setOrderBy(orderBy.clone());
        }

        if (limit !is null) {
            x.setLimit(limit.clone());
        }

        x.dbType = dbType;

        return x;
    }

    public SQLSelectQueryBlock getFirstQueryBlock() {
        if (cast(SQLSelectQueryBlock)(left) !is null ) {
            return cast(SQLSelectQueryBlock) left;
        }

        if (cast(SQLUnionQuery)(left) !is null ) {
            return (cast(SQLUnionQuery) left).getFirstQueryBlock();
        }

        return null;
    }

    public string getDbType() {
        return dbType;
    }

    public void setDbType(string dbType) {
        this.dbType = dbType;
    }

    override public void output(StringBuilder buf) {
        SQLASTOutputVisitor visitor = SQLUtils.createOutputVisitor(buf, dbType);
        this.accept(visitor);
    }
}
