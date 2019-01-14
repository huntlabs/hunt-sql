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
module hunt.sql.dialect.mysql.ast.statement.MySqlSetTransactionStatement;

import hunt.sql.ast.SQLObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;
import hunt.Boolean;

import hunt.collection;

public class MySqlSetTransactionStatement : MySqlStatementImpl {

    alias accept0 = MySqlStatementImpl.accept0;
    
    private Boolean global;

    private string  isolationLevel;

    private string  accessModel;

    private Boolean session;


    public Boolean getSession() {
        return session;
    }

    public void setSession(Boolean session) {
        this.session = session;
    }

    override public void accept0(MySqlASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    public Boolean getGlobal() {
        return global;
    }

    public void setGlobal(Boolean global) {
        this.global = global;
    }

    public string getIsolationLevel() {
        return isolationLevel;
    }

    public void setIsolationLevel(string isolationLevel) {
        this.isolationLevel = isolationLevel;
    }

    public string getAccessModel() {
        return accessModel;
    }

    public void setAccessModel(string accessModel) {
        this.accessModel = accessModel;
    }

    override
    public List!(SQLObject) getChildren() {
        return Collections.emptyList!(SQLObject)();
    }
}
