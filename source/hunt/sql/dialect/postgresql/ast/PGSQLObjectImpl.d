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
module hunt.sql.dialect.postgresql.ast.PGSQLObjectImpl;

import hunt.sql.ast.SQLObjectImpl;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.dialect.postgresql.ast.PGSQLObject;

public abstract class PGSQLObjectImpl : SQLObjectImpl , PGSQLObject {

    public this(){

    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        this.accept0(cast(PGASTVisitor) visitor);
    }

    public abstract void accept0(PGASTVisitor visitor);
}
