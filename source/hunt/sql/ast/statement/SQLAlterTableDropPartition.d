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
module hunt.sql.ast.statement.SQLAlterTableDropPartition;

import hunt.collection;

import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;

public class SQLAlterTableDropPartition : SQLObjectImpl , SQLAlterTableItem {

    private bool ifExists = false;

    private bool purge;

    private  List!SQLObject partitions;
    this()
    {
        partitions = new ArrayList!SQLObject(4);
    }

    public List!SQLObject getPartitions() {
        return partitions;
    }
    
    public void addPartition(SQLObject partition) {
        if (partition !is null) {
            partition.setParent(this);
        }
        this.partitions.add(partition);
    }

    public bool isIfExists() {
        return ifExists;
    }

    public void setIfExists(bool ifExists) {
        this.ifExists = ifExists;
    }

    public bool isPurge() {
        return purge;
    }

    public void setPurge(bool purge) {
        this.purge = purge;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, partitions);
        }
        visitor.endVisit(this);
    }
}
