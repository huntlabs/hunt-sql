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
module hunt.sql.ast.statement.SQLUnionQueryTableSource;

import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.ast.statement.SQLTableSourceImpl;
import hunt.sql.ast.statement.SQLUnionQuery;
import hunt.collection;

public class SQLUnionQueryTableSource : SQLTableSourceImpl {

    private SQLUnionQuery _union;

    public this(){

    }

    public this(string _alias){
        super(_alias);
    }

    public this(SQLUnionQuery _union, string _alias){
        super(_alias);
        this.setUnion(_union);
    }

    public this(SQLUnionQuery _union){
        this.setUnion(_union);
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (visitor.visit(this)) {
            acceptChild(visitor, _union);
        }
        visitor.endVisit(this);
    }

    override public void output(StringBuffer buf) {
        buf.append("(");
        this._union.output(buf);
        buf.append(")");
    }

    public SQLUnionQuery getUnion() {
        return _union;
    }

    public void setUnion(SQLUnionQuery _union) {
        if (_union !is null) {
            _union.setParent(this);
        }
        this._union = _union;
    }
}
