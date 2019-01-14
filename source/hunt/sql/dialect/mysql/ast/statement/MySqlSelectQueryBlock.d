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
module hunt.sql.dialect.mysql.ast.statement.MySqlSelectQueryBlock;

import hunt.Boolean;
import hunt.collection;
import hunt.sql.ast.SQLObject;

import hunt.sql.SQLUtils;
import hunt.sql.ast;
import hunt.sql.ast.statement.SQLSelectItem;
import hunt.sql.ast.statement.SQLSelectQueryBlock;
import hunt.sql.dialect.mysql.ast.MySqlObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
// import hunt.sql.dialect.oracle.ast.stmt.OracleSelectQueryBlock;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.util.DBType;

public class MySqlSelectQueryBlock : SQLSelectQueryBlock , MySqlObject {
    private bool              hignPriority;
    private bool              straightJoin;
    private bool              smallResult;
    private bool              bigResult;
    private bool              bufferResult;
    private Boolean              cache;
    private bool              calcFoundRows;
    private SQLName              procedureName;
    private List!(SQLExpr)        procedureArgumentList;
    private bool              lockInShareMode;
    private SQLName              forcePartition; // for petadata

    public this(){
        dbType = DBType.MYSQL.name;
    }

    override public MySqlSelectQueryBlock clone() {
        MySqlSelectQueryBlock x = new MySqlSelectQueryBlock();
        cloneTo(x);

        x.hignPriority = hignPriority;
        x.straightJoin = straightJoin;

        x.smallResult = smallResult;
        x.bigResult = bigResult;
        x.bufferResult = bufferResult;
        x.cache = cache;
        x.calcFoundRows = calcFoundRows;

        if (procedureName !is null) {
            x.setProcedureName(procedureName.clone());
        }
        if (procedureArgumentList !is null) {
            foreach(SQLExpr arg ; procedureArgumentList) {
                SQLExpr arg_cloned = arg.clone();
                arg_cloned.setParent(this);
                x.procedureArgumentList.add(arg_cloned);
            }
        }
        x.lockInShareMode = lockInShareMode;

        return x;
    }

    public bool isLockInShareMode() {
        return lockInShareMode;
    }

    public void setLockInShareMode(bool lockInShareMode) {
        this.lockInShareMode = lockInShareMode;
    }

    public SQLName getProcedureName() {
        return procedureName;
    }

    public void setProcedureName(SQLName procedureName) {
        this.procedureName = procedureName;
    }

    public List!(SQLExpr) getProcedureArgumentList() {
        if (procedureArgumentList is null) {
            procedureArgumentList = new ArrayList!(SQLExpr)(2);
        }
        return procedureArgumentList;
    }

    public bool isHignPriority() {
        return hignPriority;
    }

    public void setHignPriority(bool hignPriority) {
        this.hignPriority = hignPriority;
    }

    public bool isStraightJoin() {
        return straightJoin;
    }

    public void setStraightJoin(bool straightJoin) {
        this.straightJoin = straightJoin;
    }

    public bool isSmallResult() {
        return smallResult;
    }

    public void setSmallResult(bool smallResult) {
        this.smallResult = smallResult;
    }

    public bool isBigResult() {
        return bigResult;
    }

    public void setBigResult(bool bigResult) {
        this.bigResult = bigResult;
    }

    public bool isBufferResult() {
        return bufferResult;
    }

    public void setBufferResult(bool bufferResult) {
        this.bufferResult = bufferResult;
    }

    public Boolean getCache() {
        return cache;
    }

    public void setCache(Boolean cache) {
        this.cache = cache;
    }

    public bool isCalcFoundRows() {
        return calcFoundRows;
    }

    public void setCalcFoundRows(bool calcFoundRows) {
        this.calcFoundRows = calcFoundRows;
    }

    override
    public size_t toHash() @trusted nothrow {
         int prime = 31;
        size_t result = 1;
        result = prime * result + (bigResult ? 1231 : 1237);
        result = prime * result + (bufferResult ? 1231 : 1237);
        result = prime * result + hashOf(cache);
        result = prime * result + (calcFoundRows ? 1231 : 1237);
        result = prime * result + (forUpdate ? 1231 : 1237);
        result = prime * result + (hignPriority ? 1231 : 1237);
        result = prime * result + ((hints is null) ? 0 : (cast(Object)hints).toHash());
        result = prime * result + ((_limit is null) ? 0 : (cast(Object)_limit).toHash());
        result = prime * result + (lockInShareMode ? 1231 : 1237);
        result = prime * result + ((orderBy is null) ? 0 : (cast(Object)orderBy).toHash());
        result = prime * result + ((procedureArgumentList is null) ? 0 : (cast(Object)procedureArgumentList).toHash());
        result = prime * result + ((procedureName is null) ? 0 : (cast(Object)procedureName).toHash());
        result = prime * result + (smallResult ? 1231 : 1237);
        result = prime * result + (straightJoin ? 1231 : 1237);
        return result;
    }

    override
    public bool opEquals(Object obj) {
        if (this == obj) return true;
        if (obj is null) return false;
        if ( typeid(this) != typeid(obj)) return false;
        MySqlSelectQueryBlock other = cast(MySqlSelectQueryBlock) obj;
        if (bigResult != other.bigResult) return false;
        if (bufferResult != other.bufferResult) return false;
        if (cache is null) {
            if (other.cache !is null) return false;
        } else if (!(cache == other.cache)) return false;
        if (calcFoundRows != other.calcFoundRows) return false;
        if (forUpdate != other.forUpdate) return false;
        if (hignPriority != other.hignPriority) return false;
        if (hints is null) {
            if (other.hints !is null) return false;
        } else if (!(cast(Object)(hints)).opEquals(cast(Object)(other.hints))) return false;
        if (_limit is null) {
            if (other._limit !is null) return false;
        } else if (!(_limit == other._limit)) return false;
        if (lockInShareMode != other.lockInShareMode) return false;
        if (orderBy is null) {
            if (other.orderBy !is null) return false;
        } else if (!(cast(Object)(orderBy)).opEquals(cast(Object)(other.orderBy))) return false;
        if (procedureArgumentList is null) {
            if (other.procedureArgumentList !is null) return false;
        } else if (!(cast(Object)(procedureArgumentList)).opEquals(cast(Object)(other.procedureArgumentList))) return false;
        if (procedureName is null) {
            if (other.procedureName !is null) return false;
        } else if (!(cast(Object)(procedureName)).opEquals(cast(Object)(other.procedureName))) return false;
        if (smallResult != other.smallResult) return false;
        if (straightJoin != other.straightJoin) return false;
        return true;
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
            return;
        }

        super.accept0(visitor);
    }

    override
    public void accept0(MySqlASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild!SQLSelectItem(visitor, this.selectList);
            acceptChild(visitor, this.forcePartition);
            acceptChild(visitor, this.from);
            acceptChild(visitor, this.where);
            acceptChild(visitor, this.groupBy);
            acceptChild(visitor, this.orderBy);
            acceptChild(visitor, this._limit);
            acceptChild(visitor, this.procedureName);
            acceptChild!SQLExpr(visitor, this.procedureArgumentList);
            acceptChild(visitor, this.into);
        }

        visitor.endVisit(this);
    }

    public SQLName getForcePartition() {
        return forcePartition;
    }

    public void setForcePartition(SQLName x) {
        if (x !is null) {
            x.setParent(this);
        }
        this.forcePartition = x;
    }

    override public string toString() {
        return SQLUtils.toMySqlString(this);
    }
}
