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
module hunt.sql.visitor.ExportParameterizedOutputVisitor;

import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.visitor.ExportParameterVisitor;
import hunt.String;
import hunt.collection;
import hunt.util.Appendable;
import hunt.util.Common;
import hunt.text;

public class ExportParameterizedOutputVisitor : SQLASTOutputVisitor , ExportParameterVisitor {

    /**
     * true= if require parameterized sql output
     */
    private  bool requireParameterizedOutput;

    override public bool isParameterizedMergeInList()
    {
        return super.isParameterizedMergeInList();
    }
    override public void setParameterizedMergeInList(bool flag)
    {
        return super.setParameterizedMergeInList(flag);
    }

    public this( List!(Object) parameters, Appendable appender, bool wantParameterizedOutput){
        super(appender, true);
        this.parameters = parameters;
        this.requireParameterizedOutput = wantParameterizedOutput;
    }

    public this() {
        this(new ArrayList!(Object)());
    }

    public this( List!(Object) parameters){
        this(parameters,new StringBuilder(),false);
    }

    public this( Appendable appender) {
        this(new ArrayList!(Object)(), appender, true);
    }

    
    override public List!(Object) getParameters() {
        return parameters;
    }
}
