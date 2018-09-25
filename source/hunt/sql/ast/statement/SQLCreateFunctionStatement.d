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
module hunt.sql.ast.statement.SQLCreateFunctionStatement;

import hunt.sql.ast;
import hunt.sql.ast.expr.SQLPropertyExpr;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLCreateStatement;

import hunt.container;

/**
 * Created by wenshao on 23/05/2017.
 */
public class SQLCreateFunctionStatement : SQLStatementImpl , SQLCreateStatement, SQLObjectWithDataType {
    private SQLName definer;

    private bool            create     = true;
    private bool            orReplace;
    private SQLName            name;
    private SQLStatement block;
    private List!SQLParameter parameters;

    // for oracle
    private string             javaCallSpec;

    private SQLName            authid;

    SQLDataType                returnDataType;

    // for mysql

    private string             comment;
    private bool            deterministic  = false;
    private bool            parallelEnable;
    private bool            aggregate;
    private SQLName            using;
    private bool            pipelined;
    private bool            resultCache;
    private string             wrappedSource;

    this()
    {
        parameters = new ArrayList!SQLParameter();
    }

    override public SQLCreateFunctionStatement clone() {
        SQLCreateFunctionStatement x = new SQLCreateFunctionStatement();

        if (definer !is null) {
            x.setDefiner(definer.clone());
        }
        x.create = create;
        x.orReplace = orReplace;
        if (name !is null) {
            x.setName(name.clone());
        }
        if (block !is null) {
            x.setBlock(block.clone());
        }
        foreach (SQLParameter p ; parameters) {
            SQLParameter p2 = p.clone();
            p2.setParent(x);
            x.parameters.add(p2);
        }
        x.javaCallSpec = javaCallSpec;
        if (authid !is null) {
            x.setAuthid(authid.clone());
        }
        if (returnDataType !is null) {
            x.setReturnDataType(returnDataType.clone());
        }
        x.comment = comment;
        x.deterministic = deterministic;
        x.pipelined = pipelined;

        return x;
    }

    override
    public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, definer);
            acceptChild(visitor, name);
            acceptChild!SQLParameter(visitor, parameters);
            acceptChild(visitor, returnDataType);
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

    public SQLDataType getReturnDataType() {
        return returnDataType;
    }

    public void setReturnDataType(SQLDataType returnDataType) {
        if (returnDataType !is null) {
            returnDataType.setParent(this);
        }
        this.returnDataType = returnDataType;
    }

    public string getComment() {
        return comment;
    }

    public void setComment(string comment) {
        this.comment = comment;
    }

    public bool isDeterministic() {
        return deterministic;
    }

    public void setDeterministic(bool deterministic) {
        this.deterministic = deterministic;
    }

    public string getSchema() {
        SQLName name = getName();
        if (name is null) {
            return null;
        }

        if (cast(SQLPropertyExpr)(name) !is null ) {
            return (cast(SQLPropertyExpr) name).getOwnernName();
        }

        return null;
    }

    override
    public SQLDataType getDataType() {
        return returnDataType;
    }

    override
    public void setDataType(SQLDataType dataType) {
        this.setReturnDataType(dataType);
    }


    public bool isParallelEnable() {
        return parallelEnable;
    }

    public void setParallelEnable(bool parallel_enable) {
        this.parallelEnable = parallel_enable;
    }

    public bool isAggregate() {
        return aggregate;
    }

    public void setAggregate(bool aggregate) {
        this.aggregate = aggregate;
    }

    public SQLName getUsing() {
        return using;
    }

    public void setUsing(SQLName using) {
        this.using = using;
    }

    public bool isPipelined() {
        return pipelined;
    }

    public void setPipelined(bool pipelined) {
        this.pipelined = pipelined;
    }

    public bool isResultCache() {
        return resultCache;
    }

    public void setResultCache(bool resultCache) {
        this.resultCache = resultCache;
    }

    public string getWrappedSource() {
        return wrappedSource;
    }

    public void setWrappedSource(string wrappedSource) {
        this.wrappedSource = wrappedSource;
    }
}
