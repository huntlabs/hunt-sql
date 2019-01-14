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
module hunt.sql.ast.statement.SQLDropIndexStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLExprTableSource;
import hunt.sql.ast.statement.SQLDropStatement;


import hunt.collection;

public class SQLDropIndexStatement : SQLStatementImpl , SQLDropStatement {

    private SQLName            indexName;
    private SQLExprTableSource tableName;

    private SQLExpr            algorithm;
    private SQLExpr            lockOption;
    
    public this() {
        
    }
    
    public this(string dbType) {
        super (dbType);
    }

    public SQLName getIndexName() {
        return indexName;
    }

    public void setIndexName(SQLName indexName) {
        this.indexName = indexName;
    }

    public SQLExprTableSource getTableName() {
        return tableName;
    }

    public void setTableName(SQLName tableName) {
        this.setTableName(new SQLExprTableSource(tableName));
    }

    public void setTableName(SQLExprTableSource tableName) {
        this.tableName = tableName;
    }

    public SQLExpr getAlgorithm() {
        return algorithm;
    }

    public void setAlgorithm(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.algorithm = x;
    }

    public SQLExpr getLockOption() {
        return lockOption;
    }

    public void setLockOption(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.lockOption = x;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, indexName);
            acceptChild(visitor, tableName);
            acceptChild(visitor, algorithm);
            acceptChild(visitor, lockOption);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (indexName !is null) {
            children.add(indexName);
        }
        if (tableName !is null) {
            children.add(tableName);
        }
        return children;
    }
}
