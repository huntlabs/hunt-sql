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
module hunt.sql.ast.statement.SQLAlterTableRenamePartition;

import hunt.collection;

import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;
import hunt.sql.ast.statement.SQLAssignItem;
import hunt.sql.ast.SQLObject;

public class SQLAlterTableRenamePartition : SQLObjectImpl , SQLAlterTableItem {

    private bool ifNotExists = false;

    private  List!SQLAssignItem partition;
    private  List!SQLAssignItem to;

    this()
    {
        partition = new ArrayList!SQLAssignItem(4);
        to        = new ArrayList!SQLAssignItem(4);
    }

    public List!SQLAssignItem getPartition() {
        return partition;
    }

    public bool isIfNotExists() {
        return ifNotExists;
    }

    public void setIfNotExists(bool ifNotExists) {
        this.ifNotExists = ifNotExists;
    }

    public List!SQLAssignItem getTo() {
        return to;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLAssignItem(visitor, partition);
            acceptChild!SQLAssignItem(visitor, to);
        }
        visitor.endVisit(this);
    }
}
