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
module hunt.sql.dialect.mysql.ast.expr.MySqlCharExpr;

import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.dialect.mysql.visitor.MySqlASTVisitor;
import hunt.sql.visitor.SQLASTVisitor;
import hunt.sql.dialect.mysql.ast.expr.MySqlExpr;
import hunt.container;
import hunt.sql.util.String;

public class MySqlCharExpr : SQLCharExpr , MySqlExpr {

    alias output = SQLCharExpr.output;

    private string charset;
    private string collate;

    public this(){

    }

    public this(string text){
        super(text);
    }

     public this(String text){
        super(text);
    }

    public string getCharset() {
        return charset;
    }

    public void setCharset(string charset) {
        this.charset = charset;
    }

    public string getCollate() {
        return collate;
    }

    public void setCollate(string collate) {
        this.collate = collate;
    }

    override public void output(StringBuffer buf) {
        if (charset !is null) {
            buf.append(charset);
            buf.append(' ');
        }
        if (super.text !is null){
            super.output(buf);
        }

        if (collate !is null) {
            buf.append(" COLLATE ");
            buf.append(collate);
        }
    }

    
    override  protected void accept0(SQLASTVisitor visitor) {
        if (cast(MySqlASTVisitor)(visitor) !is null) {
            accept0(cast(MySqlASTVisitor) visitor);
        } else {
            visitor.visit(this);
            visitor.endVisit(this);
        }
    }

    public void accept0(MySqlASTVisitor visitor) {
        visitor.visit(this);
        visitor.endVisit(this);
    }
    
    override public string toString() {
        StringBuffer buf = new StringBuffer();
        output(buf);
        return buf.toString();
    }
    
    override public MySqlCharExpr clone() {
    	MySqlCharExpr x = new MySqlCharExpr(text);
        x.setCharset(charset);
        x.setCollate(collate);
        return x;
    }
}
