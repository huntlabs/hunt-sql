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
module hunt.sql.dialect.mysql.ast.statement.MySqlLoadDataInFileStatement;


import hunt.container;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.expr.SQLLiteralExpr;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.statement.MySqlStatementImpl;

public class MySqlLoadDataInFileStatement : MySqlStatementImpl {

    alias accept0 = MySqlStatementImpl.accept0;

    private bool             lowPriority               = false;
    private bool             concurrent                = false;
    private bool             local                     = false;

    private SQLLiteralExpr      fileName;

    private bool             replicate                 = false;
    private bool             ignore                    = false;

    private SQLName             tableName;

    private string              charset;

    private SQLLiteralExpr      columnsTerminatedBy;
    private bool             columnsEnclosedOptionally = false;
    private SQLLiteralExpr      columnsEnclosedBy;
    private SQLLiteralExpr      columnsEscaped;

    private SQLLiteralExpr      linesStartingBy;
    private SQLLiteralExpr      linesTerminatedBy;

    private SQLExpr             ignoreLinesNumber;

    private List!(SQLExpr)  setList;

    private List!(SQLExpr)  columns;

    this(){
        setList                   = new ArrayList!(SQLExpr)();
        columns                   = new ArrayList!(SQLExpr)();
    }

    public bool isLowPriority() {
        return lowPriority;
    }

    public void setLowPriority(bool lowPriority) {
        this.lowPriority = lowPriority;
    }

    public bool isConcurrent() {
        return concurrent;
    }

    public void setConcurrent(bool concurrent) {
        this.concurrent = concurrent;
    }

    public bool isLocal() {
        return local;
    }

    public void setLocal(bool local) {
        this.local = local;
    }

    public SQLLiteralExpr getFileName() {
        return fileName;
    }

    public void setFileName(SQLLiteralExpr fileName) {
        this.fileName = fileName;
    }

    public bool isReplicate() {
        return replicate;
    }

    public void setReplicate(bool replicate) {
        this.replicate = replicate;
    }

    public bool isIgnore() {
        return ignore;
    }

    public void setIgnore(bool ignore) {
        this.ignore = ignore;
    }

    public SQLName getTableName() {
        return tableName;
    }

    public void setTableName(SQLName tableName) {
        this.tableName = tableName;
    }

    public string getCharset() {
        return charset;
    }

    public void setCharset(string charset) {
        this.charset = charset;
    }

    public SQLLiteralExpr getColumnsTerminatedBy() {
        return columnsTerminatedBy;
    }

    public void setColumnsTerminatedBy(SQLLiteralExpr columnsTerminatedBy) {
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

    public List!(SQLExpr) getSetList() {
        return setList;
    }

    override public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, fileName);
            acceptChild(visitor, tableName);
            acceptChild(visitor, columnsTerminatedBy);
            acceptChild(visitor, columnsEnclosedBy);
            acceptChild(visitor, columnsEscaped);
            acceptChild(visitor, linesStartingBy);
            acceptChild(visitor, linesTerminatedBy);
            acceptChild(visitor, ignoreLinesNumber);
            acceptChild(visitor, cast(List!(SQLObject))setList);
        }
        visitor.endVisit(this);
    }

    override
    public List!(SQLObject) getChildren() {
        List!(SQLObject) children = new ArrayList!(SQLObject)();
        if (fileName !is null) {
            children.add(fileName);
        }
        if (tableName !is null) {
            children.add(tableName);
        }
        if (columnsTerminatedBy !is null) {
            children.add(columnsTerminatedBy);
        }
        if (columnsEnclosedBy !is null) {
            children.add(columnsEnclosedBy);
        }
        if (columnsEscaped !is null) {
            children.add(columnsEscaped);
        }
        if (linesStartingBy !is null) {
            children.add(linesStartingBy);
        }
        if (linesTerminatedBy !is null) {
            children.add(linesTerminatedBy);
        }
        if (ignoreLinesNumber !is null) {
            children.add(ignoreLinesNumber);
        }
        return children;
    }

    
    public List!(SQLExpr) getColumns() {
        return columns;
    }

    
    public void setColumns(List!(SQLExpr) columns) {
        this.columns = columns;
    }

    
    public void setSetList(List!(SQLExpr) setList) {
        this.setList = setList;
    }
}
