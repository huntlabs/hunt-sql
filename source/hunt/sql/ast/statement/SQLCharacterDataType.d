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
module hunt.sql.ast.statement.SQLCharacterDataType;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLCommentHint;
import hunt.sql.ast.SQLDataTypeImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLIntegerExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;

import hunt.collection;

public class SQLCharacterDataType : SQLDataTypeImpl {

    private string             charSetName;
    private string             collate;

    private string             charType;
    private bool            hasBinary;

    public List!SQLCommentHint hints;

    public  static string CHAR_TYPE_BYTE = "BYTE";
    public  static string CHAR_TYPE_CHAR = "CHAR";

    public this(string name){
        super(name);
    }

    public this(string name, int precision){
        super(name, precision);
    }

    public string getCharSetName() {
        return charSetName;
    }

    public void setCharSetName(string charSetName) {
        this.charSetName = charSetName;
    }
    
    public bool isHasBinary() {
        return hasBinary;
    }

    public void setHasBinary(bool hasBinary) {
        this.hasBinary = hasBinary;
    }

    public string getCollate() {
        return collate;
    }

    public void setCollate(string collate) {
        this.collate = collate;
    }

    public string getCharType() {
        return charType;
    }

    public void setCharType(string charType) {
        this.charType = charType;
    }

    public List!SQLCommentHint getHints() {
        return hints;
    }

    public void setHints(List!SQLCommentHint hints) {
        this.hints = hints;
    }

    public int getLength() {
        if (this.arguments.size() == 1) {
            SQLExpr arg = this.arguments.get(0);
            if (cast(SQLIntegerExpr)(arg) !is null ) {
                return (cast(SQLIntegerExpr) arg).getNumber().intValue();
            }
        }

        return -1;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLExpr(visitor, this.arguments);
        }

        visitor.endVisit(this);
    }


    override public SQLCharacterDataType clone() {
        SQLCharacterDataType x = new SQLCharacterDataType(getName());

        super.cloneTo(x);

        x.charSetName = charSetName;
        x.collate = collate;
        x.charType = charType;
        x.hasBinary = hasBinary;

        return x;
    }

    override
    public string toString() {
        return SQLUtils.toSQLString(this);
    }
}
