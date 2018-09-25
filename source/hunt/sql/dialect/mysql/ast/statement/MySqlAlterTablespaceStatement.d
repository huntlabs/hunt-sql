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
module hunt.sql.dialect.mysql.ast.statement.MySqlAlterTablespaceStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.statement.SQLAlterStatement;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

public class MySqlAlterTablespaceStatement : MySqlStatementImpl , SQLAlterStatement {
    alias accept0 = MySqlStatementImpl.accept0;
    
    private SQLName name;

    private SQLExpr addDataFile;
    private SQLExpr dropDataFile;
    private SQLExpr initialSize;
    private bool wait;
    private SQLExpr engine;

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
            acceptChild(visitor, addDataFile);
            acceptChild(visitor, initialSize);
            acceptChild(visitor, engine);
        }
        visitor.endVisit(this);
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

    public SQLExpr getAddDataFile() {
        return addDataFile;
    }

    public void setAddDataFile(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.addDataFile = addDataFile;
    }

    public SQLExpr getDropDataFile() {
        return dropDataFile;
    }

    public void setDropDataFile(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.dropDataFile = dropDataFile;
    }

    public SQLExpr getInitialSize() {
        return initialSize;
    }

    public void setInitialSize(SQLExpr x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.initialSize = x;
    }

    public bool isWait() {
        return wait;
    }

    public void setWait(bool wait) {
        this.wait = wait;
    }

    public SQLExpr getEngine() {
        return engine;
    }

    public void setEngine(SQLExpr engine) {
        if (engine !is null) {
            engine.setParent(this);
        }
        this.engine = engine;
    }
}