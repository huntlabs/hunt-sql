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
module hunt.sql.dialect.mysql.ast.expr.MySqlUserName;

import hunt.sql.ast.SQLName;
import hunt.sql.ast.SQLObject;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.util.FnvHash;
import hunt.sql.dialect.mysql.ast.expr.MySqlExprImpl;
// //import hunt.lang.common;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.util.Common;


import hunt.collection;

public class MySqlUserName : MySqlExprImpl , SQLName, Cloneable {

    alias accept0 = MySqlObjectImpl.accept0;

    private string userName;
    private string host;
    private string identifiedBy;

    private long   userNameHashCod64;
    private long   _hashCode64;

    public string getUserName() {
        return userName;
    }

    public void setUserName(string userName) {
        this.userName = userName;

        this._hashCode64 = 0;
        this.userNameHashCod64 = 0;
    }

    public string getHost() {
        return host;
    }

    public void setHost(string host) {
        this.host = host;

        this._hashCode64 = 0;
        this.userNameHashCod64 = 0;
    }

    override
    public void accept0(MySqlASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }

    public string getSimpleName() {
        return userName ~ '@' ~ host;
    }

    public string getIdentifiedBy() {
        return identifiedBy;
    }

    public void setIdentifiedBy(string identifiedBy) {
        this.identifiedBy = identifiedBy;
    }

    override public string toString() {
        return getSimpleName();
    }

    override public MySqlUserName clone() {
        MySqlUserName x = new MySqlUserName();

        x.userName     = userName;
        x.host         = host;
        x.identifiedBy = identifiedBy;

        return x;
    }

    override
    public List!(SQLObject) getChildren() {
        return Collections.emptyList!(SQLObject)();
    }

    public long nameHashCode64() {
        if (userNameHashCod64 == 0
                && userName !is null) {
            userNameHashCod64 = FnvHash.hashCode64(userName);
        }
        return userNameHashCod64;
    }

    override
    public long hashCode64() {
        if (_hashCode64 == 0) {
            if (host !is null) {
                long hash = FnvHash.hashCode64(host);
                hash ^= '@';
                hash *= 0x100000001b3L;
                hash = FnvHash.hashCode64(hash, userName);

                _hashCode64 = hash;
            } else {
                _hashCode64 = nameHashCode64();
            }
        }

        return _hashCode64;
    }
}
