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
module hunt.sql.ast.statement.SQLCreateDatabaseStatement;

import hunt.container;

import hunt.sql.ast.SQLCommentHint;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLCreateStatement;

public class SQLCreateDatabaseStatement : SQLStatementImpl , SQLCreateStatement {

    private SQLName              name;

    private string               characterSet;
    private string               collate;

    private List!SQLCommentHint hints;
    
    protected bool            ifNotExists = false;

    public this(){
    }
    
    public this(string dbType){
        super (dbType);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, name);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        List!SQLObject children = new ArrayList!SQLObject();
        if (name !is null) {
            children.add(name);
        }
        return children;
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        this.name = name;
    }

    public string getCharacterSet() {
        return characterSet;
    }

    public void setCharacterSet(string characterSet) {
        this.characterSet = characterSet;
    }

    public string getCollate() {
        return collate;
    }

    public void setCollate(string collate) {
        this.collate = collate;
    }

    public List!SQLCommentHint getHints() {
        return hints;
    }

    public void setHints(List!SQLCommentHint hints) {
        this.hints = hints;
    }
    
    public bool isIfNotExists() {
        return ifNotExists;
    }
    
    public void setIfNotExists(bool ifNotExists) {
        this.ifNotExists = ifNotExists;
    }

}
