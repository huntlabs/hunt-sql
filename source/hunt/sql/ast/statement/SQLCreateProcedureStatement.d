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
module hunt.sql.ast.statement.SQLCreateProcedureStatement;

import hunt.collection;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLParameter;
import hunt.sql.ast.SQLStatement;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLCreateStatement;
import hunt.sql.ast.SQLObject;


public class SQLCreateProcedureStatement : SQLStatementImpl , SQLCreateStatement {

    private SQLName            definer;

    private bool            create     = true;
    private bool            orReplace;
    private SQLName            name;
    private SQLStatement       block;
    private List!SQLParameter parameters;

    // for oracle
    private string             javaCallSpec;

    private SQLName            authid;

    // for mysql
    private bool            deterministic;
    private bool            containsSql;
    private bool            noSql;
    private bool            readSqlData;
    private bool            modifiesSqlData;

    private string             wrappedSource;

    this()
    {
        parameters = new ArrayList!SQLParameter();
    }

    override
    public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, definer);
            acceptChild(visitor, name);
            acceptChild!SQLParameter(visitor, parameters);
            acceptChild(visitor, block);
        }
        visitor.endVisit(this);
    }

    public List!SQLParameter getParameters() {
        return parameters;
    }

    public void setParameters(List!SQLParameter parameters) {
        this.parameters = parameters;
    }

    public SQLName getName() {
        return name;
    }

    public void setName(SQLName name) {
        this.name = name;
    }

    public SQLStatement getBlock() {
        return block;
    }

    public void setBlock(SQLStatement block) {
        if (block !is null) {
            block.setParent(this);
        }
        this.block = block;
    }

    public SQLName getAuthid() {
        return authid;
    }

    public void setAuthid(SQLName authid) {
        if (authid !is null) {
            authid.setParent(this);
        }
        this.authid = authid;
    }

    public bool isOrReplace() {
        return orReplace;
    }

    public void setOrReplace(bool orReplace) {
        this.orReplace = orReplace;
    }

    public SQLName getDefiner() {
        return definer;
    }
    
    public void setDefiner(SQLName definer) {
        this.definer = definer;
    }

    public bool isCreate() {
        return create;
    }

    public void setCreate(bool create) {
        this.create = create;
    }

    public string getJavaCallSpec() {
        return javaCallSpec;
    }

    public void setJavaCallSpec(string javaCallSpec) {
        this.javaCallSpec = javaCallSpec;
    }

    public bool isDeterministic() {
        return deterministic;
    }

    public void setDeterministic(bool deterministic) {
        this.deterministic = deterministic;
    }

    public bool isContainsSql() {
        return containsSql;
    }

    public void setContainsSql(bool containsSql) {
        this.containsSql = containsSql;
    }

    public bool isNoSql() {
        return noSql;
    }

    public void setNoSql(bool noSql) {
        this.noSql = noSql;
    }

    public bool isReadSqlData() {
        return readSqlData;
    }

    public void setReadSqlData(bool readSqlData) {
        this.readSqlData = readSqlData;
    }

    public bool isModifiesSqlData() {
        return modifiesSqlData;
    }

    public void setModifiesSqlData(bool modifiesSqlData) {
        this.modifiesSqlData = modifiesSqlData;
    }

    public SQLParameter findParameter(long hash) {
        foreach (SQLParameter param ; this.parameters) {
            if (param.getName().nameHashCode64() == hash) {
                return param;
            }
        }

        return null;
    }

    public string getWrappedSource() {
        return wrappedSource;
    }

    public void setWrappedSource(string wrappedSource) {
        this.wrappedSource = wrappedSource;
    }
}
