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
module hunt.sql.ast.statement.SQLBlockStatement;

import hunt.container;

import hunt.sql.ast.SQLParameter;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.SQLObject;

public class SQLBlockStatement : SQLStatementImpl {
    private string             labelName;
    private string             endLabel;
    private List!SQLParameter parameters;
    private List!SQLStatement statementList;
    public SQLStatement        exception;
    private bool            endOfCommit;

    public this() {
        parameters    = new ArrayList!SQLParameter();
        statementList = new ArrayList!SQLStatement();
    }

    public List!SQLStatement getStatementList() {
        return statementList;
    }

    public void setStatementList(List!SQLStatement statementList) {
        this.statementList = statementList;
    }
    
    public string getLabelName() {
        return labelName;
    }

    public void setLabelName(string labelName) {
        this.labelName = labelName;
    }

    override
    public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLParameter(visitor, parameters);
            acceptChild!SQLStatement(visitor, statementList);
            acceptChild(visitor, exception);
        }
        visitor.endVisit(this);
    }

    public List!SQLParameter getParameters() {
        return parameters;
    }

    public void setParameters(List!SQLParameter parameters) {
        this.parameters = parameters;
    }

    public SQLStatement getException() {
        return exception;
    }

    public void setException(SQLStatement exception) {
        if (exception !is null) {
            exception.setParent(this);
        }
        this.exception = exception;
    }

    public string getEndLabel() {
        return endLabel;
    }

    public void setEndLabel(string endLabel) {
        this.endLabel = endLabel;
    }

    override public SQLBlockStatement clone() {
        SQLBlockStatement x = new SQLBlockStatement();
        x.labelName = labelName;
        x.endLabel = endLabel;

        foreach (SQLParameter p ; parameters) {
            SQLParameter p2 = p.clone();
            p2.setParent(x);
            x.parameters.add(p2);
        }

        foreach (SQLStatement stmt ; statementList) {
            SQLStatement stmt2 = stmt.clone();
            stmt2.setParent(x);
            x.statementList.add(stmt2);
        }

        if (exception !is null) {
            x.setException(exception.clone());
        }

        return x;
    }

    public SQLParameter findParameter(long hash) {
        foreach (SQLParameter param ; this.parameters) {
            if (param.getName().nameHashCode64() == hash) {
                return param;
            }
        }

        return null;
    }

    public bool isEndOfCommit() {
        return endOfCommit;
    }

    public void setEndOfCommit(bool value) {
        this.endOfCommit = value;
    }
}
