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
module hunt.sql.ast.statement.SQLTableSourceImpl;


import hunt.collection;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLHint;
import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.util.FnvHash;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.statement.SQLTableSource;

public abstract class SQLTableSourceImpl : SQLObjectImpl , SQLTableSource {
    protected string        _alias;
    protected List!SQLHint hints;
    protected SQLExpr       flashback;
    protected long          aliasHashCod64;

    public this(){

    }

    public this(string alias_p){
        this._alias = alias_p;
    }

    public string getAlias() {
        return this._alias;
    }

    public void setAlias(string alias_p) {
        this._alias = alias_p;
        this.aliasHashCod64 = 0L;
    }

    public int getHintsSize() {
        if (hints is null) {
            return 0;
        }

        return hints.size();
    }

    public List!SQLHint getHints() {
        if (hints is null) {
            hints = new ArrayList!SQLHint(2);
        }
        return hints;
    }

    public void setHints(List!SQLHint hints) {
        this.hints = hints;
    }

    override public SQLTableSource clone() {
        throw new Exception(typeof(this).stringof);
    }

    public string computeAlias() {
        return _alias;
    }

    public SQLExpr getFlashback() {
        return flashback;
    }

    public void setFlashback(SQLExpr flashback) {
        if (flashback !is null) {
            flashback.setParent(this);
        }
        this.flashback = flashback;
    }

    public bool containsAlias(string alias_p) {
        if (SQLUtils.nameEquals(this._alias, alias_p)) {
            return true;
        }

        return false;
    }

    public long aliasHashCode64() {
        if (aliasHashCod64 == 0
                && _alias !is null) {
            aliasHashCod64 = FnvHash.hashCode64(_alias);
        }
        return aliasHashCod64;
    }

    public SQLColumnDefinition findColumn(string columnName) {
        if (columnName is null) {
            return null;
        }

        long hash = FnvHash.hashCode64(_alias);
        return findColumn(hash);
    }

    public SQLColumnDefinition findColumn(long columnNameHash) {
        return null;
    }

    public SQLTableSource findTableSourceWithColumn(string columnName) {
        if (columnName is null) {
            return null;
        }

        long hash = FnvHash.hashCode64(_alias);
        return findTableSourceWithColumn(hash);
    }

    public SQLTableSource findTableSourceWithColumn(long columnNameHash) {
        return null;
    }

    public SQLTableSource findTableSource(string alias_p) {
        long hash = FnvHash.hashCode64(alias_p);
        return findTableSource(hash);
    }

    public SQLTableSource findTableSource(long alias_hash) {
        long hash = this.aliasHashCode64();
        if (hash != 0 && hash == alias_hash) {
            return this;
        }
        return null;
    }
}
