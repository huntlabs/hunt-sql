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
module hunt.sql.dialect.mysql.ast.statement.MySqlSubPartitionByKey;


import hunt.collection;
import hunt.sql.ast.SQLObject;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLSubPartitionBy;
import hunt.sql.dialect.mysql.ast.MySqlObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;

public class MySqlSubPartitionByKey : SQLSubPartitionBy , MySqlObject {
    alias cloneTo = SQLSubPartitionBy.cloneTo;
    private List!(SQLName) columns;
    private short algorithm = 2;

    this()
    {
        columns = new ArrayList!(SQLName)();
    }

    public short getAlgorithm() {
        return algorithm;
    }

    public void setAlgorithm(short algorithm) {
        this.algorithm = algorithm;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
        } else {
            throw new Exception("not support visitor type : " ~ typeof(visitor).stringof);
        }
    }
    
    override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLName(visitor, columns);
            acceptChild(visitor, subPartitionsCount);
        }
        visitor.endVisit(this);
    }

    public List!(SQLName) getColumns() {
        return columns;
    }

    public void addColumn(SQLName column) {
        if (column !is null) {
            column.setParent(this);
        }
        this.columns.add(column);
    }

    public void cloneTo(MySqlSubPartitionByKey x) {
        super.cloneTo(x);
        foreach(SQLName column ; columns) {
            SQLName c2 = column.clone();
            c2.setParent(x);
            x.columns.add(c2);
        }
	    x.setAlgorithm(algorithm);
    }

    override public MySqlSubPartitionByKey clone() {
        MySqlSubPartitionByKey x = new MySqlSubPartitionByKey();
        cloneTo(x);
        return x;
    }
}
