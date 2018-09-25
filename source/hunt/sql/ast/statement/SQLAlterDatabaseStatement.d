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
module hunt.sql.ast.statement.SQLAlterDatabaseStatement;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterStatement;
import hunt.sql.ast.statement.SQLAlterCharacter;

import hunt.container;

public class SQLAlterDatabaseStatement : SQLStatementImpl , SQLAlterStatement {

    private SQLName name;

    private bool upgradeDataDirectoryName;

    private SQLAlterCharacter character;
    
    public this() {
        
    }
    
    public this(string dbType) {
        this.setDbType(dbType);
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }

    public SQLAlterCharacter getCharacter() {
        return character;
    }

    public void setCharacter(SQLAlterCharacter character) {
        if (character !is null) {
            character.setParent(this);
        }
        this.character = character;
    }

    public bool isUpgradeDataDirectoryName() {
        return upgradeDataDirectoryName;
    }

    public void setUpgradeDataDirectoryName(bool upgradeDataDirectoryName) {
        this.upgradeDataDirectoryName = upgradeDataDirectoryName;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(name);
    }
}
