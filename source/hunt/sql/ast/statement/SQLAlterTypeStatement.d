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
module hunt.sql.ast.statement.SQLAlterTypeStatement;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;

import hunt.collection;

public class SQLAlterTypeStatement : SQLStatementImpl {
    private SQLName name;

    private bool compile;
    private bool _debug;
    private bool body;
    private bool reuseSettings;

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        if (name !is null) {
            name.setParent(this);
        }
        this.name = name;
    }

    public bool isCompile() {
        return compile;
    }

    public void setCompile(bool compile) {
        this.compile = compile;
    }

    public bool isDebug() {
        return _debug;
    }

    public void setDebug(bool _debug) {
        this._debug = _debug;
    }

    public bool isBody() {
        return body;
    }

    public void setBody(bool body) {
        this.body = body;
    }

    public bool isReuseSettings() {
        return reuseSettings;
    }

    public void setReuseSettings(bool reuseSettings) {
        this.reuseSettings = reuseSettings;
    }

    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(this.name);
    }
}
