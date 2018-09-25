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
module hunt.sql.dialect.mysql.ast.MySqlIndexHintImpl;


import hunt.container;

import hunt.sql.ast.SQLName;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.dialect.mysql.ast.MySqlObject;
import hunt.sql.dialect.mysql.ast.MySqlObjectImpl;
import hunt.sql.dialect.mysql.ast.MySqlIndexHint;


public abstract class MySqlIndexHintImpl : MySqlObjectImpl , MySqlIndexHint {

    alias accept0 = MySqlObjectImpl.accept0;

    private MySqlIndexHint.Option option;

    private List!(SQLName)         indexList;

    this()
    {
        indexList = new ArrayList!(SQLName)();
    }

    override
    public abstract void accept0(MySqlASTVisitor visitor);

    public MySqlIndexHint.Option getOption() {
        return option;
    }

    public void setOption(MySqlIndexHint.Option option) {
        this.option = option;
    }

    public List!(SQLName) getIndexList() {
        return indexList;
    }

    public void setIndexList(List!(SQLName) indexList) {
        this.indexList = indexList;
    }

    public abstract override MySqlIndexHintImpl clone();

    public void cloneTo(MySqlIndexHintImpl x) {
        x.option = option;
        foreach(SQLName name ; indexList) {
            SQLName name2 = name.clone();
            name2.setParent(x);
            x.indexList.add(name2);
        }
    }
}
