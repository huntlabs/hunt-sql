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
module hunt.sql.dialect.mysql.ast.statement.MySqlShowCharacterSetStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;

import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.sql.dialect.mysql.ast.statement.MySqlShowStatement;


import hunt.container;

public class MySqlShowCharacterSetStatement : MySqlStatementImpl , MySqlShowStatement {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private SQLExpr where;
    private SQLExpr pattern;

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, where);
            acceptChild(visitor, pattern);
        }
        visitor.endVisit(this);
    }

    public SQLExpr getWhere() {
        return where;
    }

    public void setWhere(SQLExpr where) {
        this.where = where;
    }

    public SQLExpr getPattern() {
        return pattern;
    }

    public void setPattern(SQLExpr pattern) {
        this.pattern = pattern;
    }

    override
    public List!(SQLObject) getChildren() {
        // return Arrays.!(SQLObject)asList(this.where, pattern);
        List!SQLObject ls = new ArrayList!SQLObject();
        ls.add(this.where);
        ls.add(pattern);
        return ls;
    }

}
