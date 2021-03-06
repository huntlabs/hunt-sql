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
module hunt.sql.ast.statement.SQLAlterTableConvertCharSet;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLAlterTableItem;

public class SQLAlterTableConvertCharSet : SQLObjectImpl , SQLAlterTableItem {

    private SQLExpr charset;
    private SQLExpr collate;
    
    public this() {
        
    }

    public SQLExpr getCharset() {
        return charset;
    }

    public void setCharset(SQLExpr charset) {
        if (charset !is null) {
            charset.setParent(this);
        }
        this.charset = charset;
    }

    public SQLExpr getCollate() {
        return collate;
    }

    public void setCollate(SQLExpr collate) {
        if (collate !is null) {
            collate.setParent(this);
        }
        this.collate = collate;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, charset);
            acceptChild(visitor, collate);
        }
        visitor.endVisit(this);
    }

}
