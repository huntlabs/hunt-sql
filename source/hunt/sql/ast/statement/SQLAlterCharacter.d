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
module hunt.sql.ast.statement.SQLAlterCharacter;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.ast.statement.SQLAlterTableItem;
// import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;//@gxc
// import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;//@gxc
import hunt.sql.visitor.SQLASTVisitor;

public class SQLAlterCharacter : SQLObjectImpl , SQLAlterTableItem {

    private SQLExpr characterSet;
    private SQLExpr collate;

    override public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, characterSet);
            acceptChild(visitor, collate);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getCharacterSet() {
        return characterSet;
    }

    public void setCharacterSet(SQLExpr characterSet) {
        this.characterSet = characterSet;
    }

    public SQLExpr getCollate() {
        return collate;
    }

    public void setCollate(SQLExpr collate) {
        this.collate = collate;
    }

}
