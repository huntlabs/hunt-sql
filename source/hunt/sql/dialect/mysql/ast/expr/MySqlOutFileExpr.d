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
module hunt.sql.dialect.mysql.ast.expr.MySqlOutFileExpr;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLObject;

import hunt.container;

public class MySqlOutFileExpr : MySqlObjectImpl , SQLExpr {

    alias accept0 = MySqlObjectImpl.accept0;
    alias computeDataType = MySqlObjectImpl.computeDataType;

    private SQLExpr        file;
    private string         charset;

    private SQLExpr        columnsTerminatedBy;
    private bool        columnsEnclosedOptionally = false;
    private SQLLiteralExpr columnsEnclosedBy;
    private SQLLiteralExpr columnsEscaped;

    private SQLLiteralExpr linesStartingBy;
    private SQLLiteralExpr linesTerminatedBy;

    private SQLExpr        ignoreLinesNumber;

    public this(){
    }

    public this(SQLExpr file){
        this.file = file;
    }

    override public SQLDataType computeDataType()
    {
        return super.computeDataType();
    }

    override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, file);
        }
        visitor.endVisit(this);
    }

    override
    public List!SQLObject getChildren() {
        return Collections.singletonList!SQLObject(file);
    }

    public SQLExpr getFile() {
        return file;
    }

    public void setFile(SQLExpr file) {
        this.file = file;
    }

    public string getCharset() {
        return charset;
    }

    public void setCharset(string charset) {
        this.charset = charset;
    }

    public SQLExpr getColumnsTerminatedBy() {
        return columnsTerminatedBy;
    }

    public void setColumnsTerminatedBy(SQLExpr columnsTerminatedBy) {
        this.columnsTerminatedBy = columnsTerminatedBy;
    }

    public bool isColumnsEnclosedOptionally() {
        return columnsEnclosedOptionally;
    }

    public void setColumnsEnclosedOptionally(bool columnsEnclosedOptionally) {
        this.columnsEnclosedOptionally = columnsEnclosedOptionally;
    }

    public SQLLiteralExpr getColumnsEnclosedBy() {
        return columnsEnclosedBy;
    }

    public void setColumnsEnclosedBy(SQLLiteralExpr columnsEnclosedBy) {
        this.columnsEnclosedBy = columnsEnclosedBy;
    }

    public SQLLiteralExpr getColumnsEscaped() {
        return columnsEscaped;
    }

    public void setColumnsEscaped(SQLLiteralExpr columnsEscaped) {
        this.columnsEscaped = columnsEscaped;
    }

    public SQLLiteralExpr getLinesStartingBy() {
        return linesStartingBy;
    }

    public void setLinesStartingBy(SQLLiteralExpr linesStartingBy) {
        this.linesStartingBy = linesStartingBy;
    }

    public SQLLiteralExpr getLinesTerminatedBy() {
        return linesTerminatedBy;
    }

    public void setLinesTerminatedBy(SQLLiteralExpr linesTerminatedBy) {
        this.linesTerminatedBy = linesTerminatedBy;
    }

    public SQLExpr getIgnoreLinesNumber() {
        return ignoreLinesNumber;
    }

    public void setIgnoreLinesNumber(SQLExpr ignoreLinesNumber) {
        this.ignoreLinesNumber = ignoreLinesNumber;
    }

    override public SQLExpr clone() {
        throw new Exception("unsuported operation");
    }

}
