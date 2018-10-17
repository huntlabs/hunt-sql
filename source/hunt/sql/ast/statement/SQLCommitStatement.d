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
module hunt.sql.ast.statement.SQLCommitStatement;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLStatementImpl;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.lang;

public class SQLCommitStatement : SQLStatementImpl {

    // oracle
    private bool write;
    private Boolean wait;
    private Boolean immediate;

    // mysql
    private bool work = false;
    private Boolean chain;
    private Boolean release;

    // sql server
    private SQLExpr transactionName;
    private SQLExpr delayedDurability;

    public this() {

    }

    override public SQLCommitStatement clone() {
        SQLCommitStatement x = new SQLCommitStatement();
        x.write = write;
        x.wait = wait;
        x.immediate = immediate;
        x.work = work;
        x.chain = chain;
        x.release = release;

        if(transactionName !is null) {
            x.setTransactionName(transactionName.clone());
        }
        if (delayedDurability !is null) {
            x.setDelayedDurability(delayedDurability.clone());
        }
        return x;
    }

    override public void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, transactionName);
            acceptChild(visitor, delayedDurability);
        }
        visitor.endVisit(this);
    }

    // oracle
    public bool isWrite() {
        return write;
    }

    public void setWrite(bool write) {
        this.write = write;
    }

    public Boolean getWait() {
        return wait;
    }

    public void setWait(Boolean wait) {
        this.wait = wait;
    }

    public Boolean getImmediate() {
        return immediate;
    }

    public void setImmediate(Boolean immediate) {
        this.immediate = immediate;
    }

    // mysql
    public Boolean getChain() {
        return chain;
    }

    public void setChain(Boolean chain) {
        this.chain = chain;
    }

    public Boolean getRelease() {
        return release;
    }

    public void setRelease(Boolean release) {
        this.release = release;
    }

    public bool isWork() {
        return work;
    }

    public void setWork(bool work) {
        this.work = work;
    }

    // sql server
    public SQLExpr getTransactionName() {
        return transactionName;
    }

    public void setTransactionName(SQLExpr transactionName) {
        if (transactionName !is null) {
            transactionName.setParent(this);
        }
        this.transactionName = transactionName;
    }

    public SQLExpr getDelayedDurability() {
        return delayedDurability;
    }

    public void setDelayedDurability(SQLExpr delayedDurability) {
        if (delayedDurability !is null) {
            delayedDurability.setParent(this);
        }
        this.delayedDurability = delayedDurability;
    }
}
