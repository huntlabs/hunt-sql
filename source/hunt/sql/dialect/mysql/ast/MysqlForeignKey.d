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
module hunt.sql.dialect.mysql.ast.MysqlForeignKey;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLForeignKeyImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;
import hunt.container;
import hunt.sql.ast.SQLObject;

public class MysqlForeignKey : SQLForeignKeyImpl {
    private SQLName  indexName;
    private bool  hasConstraint;
    private Match    referenceMatch;
    protected Option onUpdate;
    protected Option onDelete;

    public this() {
        dbType = DBType.MYSQL.name;
    }

    public SQLName getIndexName() {
        return indexName;
    }

    public void setIndexName(SQLName indexName) {
        this.indexName = indexName;
    }

    public bool isHasConstraint() {
        return hasConstraint;
    }

    public void setHasConstraint(bool hasConstraint) {
        this.hasConstraint = hasConstraint;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
        }
    }

    protected void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, this.getName());
            acceptChild(visitor, this.getReferencedTableName());
            acceptChild!SQLName(visitor, this.getReferencingColumns());
            acceptChild!SQLName(visitor, this.getReferencedColumns());

            acceptChild(visitor, indexName);
        }
        visitor.endVisit(this);
    }

    override public MysqlForeignKey clone() {
        MysqlForeignKey x = new MysqlForeignKey();
        cloneTo(x);

        x.referenceMatch = referenceMatch;
        x.onUpdate = onUpdate;
        x.onDelete = onDelete;

        return x;
    }

    public Match getReferenceMatch() {
        return referenceMatch;
    }

    public void setReferenceMatch(Match referenceMatch) {
        this.referenceMatch = referenceMatch;
    }

    public Option getOnUpdate() {
        return onUpdate;
    }

    public void setOnUpdate(Option onUpdate) {
        this.onUpdate = onUpdate;
    }

    public Option getOnDelete() {
        return onDelete;
    }

    public void setOnDelete(Option onDelete) {
        this.onDelete = onDelete;
    }

}
