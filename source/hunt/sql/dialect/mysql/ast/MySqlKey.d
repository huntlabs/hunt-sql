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
module hunt.sql.dialect.mysql.ast.MySqlKey;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLSelectOrderByItem;
import hunt.sql.ast.statement.SQLTableConstraint;
import hunt.sql.ast.statement.SQLUnique;
import hunt.sql.ast.statement.SQLUniqueConstraint;
import hunt.sql.dialect.mysql.ast.statement.MySqlAlterTableChangeColumn;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.sql.ast.SQLObject;
import hunt.collection;

public class MySqlKey : SQLUnique /* , SQLUniqueConstraint */, SQLTableConstraint {

    alias cloneTo = SQLUnique.cloneTo;

    private string  indexType;

    private bool hasConstaint;

    private SQLExpr keyBlockSize;

    public this(){
        dbType = DBType.MYSQL.name;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
        }
    }

    protected void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.getName());
            acceptChild!SQLSelectOrderByItem(visitor, this.getColumns());
            acceptChild(visitor, name);
        }
        visitor.endVisit(this);
    }

    public string getIndexType() {
        return indexType;
    }

    public void setIndexType(string indexType) {
        this.indexType = indexType;
    }

    public bool isHasConstaint() {
        return hasConstaint;
    }

    public void setHasConstaint(bool hasConstaint) {
        this.hasConstaint = hasConstaint;
    }

    public void cloneTo(MySqlKey x) {
        super.cloneTo(x);
        x.indexType = indexType;
        x.hasConstaint = hasConstaint;
        if (keyBlockSize !is null) {
            this.setKeyBlockSize(keyBlockSize.clone());
        }
    }

    override public MySqlKey clone() {
        MySqlKey x = new MySqlKey();
        cloneTo(x);
        return x;
    }

    public SQLExpr getKeyBlockSize() {
        return keyBlockSize;
    }

    public void setKeyBlockSize(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.keyBlockSize = x;
    }
}
