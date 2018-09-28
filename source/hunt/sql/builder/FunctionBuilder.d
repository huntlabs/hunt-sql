/*
 * Copyright 2015-2018 HuntLabs.cn.
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
module hunt.sql.builder.FunctionBuilder;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.util.DBType;

/**
 * Created by wenshao on 09/07/2017.
 */
public class FunctionBuilder {
    private  string dbType;

    public this(string dbType) {
        this.dbType = dbType;
    }

    // for character function
    public SQLMethodInvokeExpr length(SQLExpr expr) {
        return new SQLMethodInvokeExpr("length", null, expr);
    }

    public SQLMethodInvokeExpr lower(SQLExpr expr) {
        return new SQLMethodInvokeExpr("lower", null, expr);
    }

    public SQLMethodInvokeExpr upper(SQLExpr expr) {
        return new SQLMethodInvokeExpr("upper", null, expr);
    }

    public SQLMethodInvokeExpr substr(SQLExpr expr) {
        return new SQLMethodInvokeExpr("substr", null, expr);
    }

    public SQLMethodInvokeExpr ltrim(SQLExpr expr) {
        return new SQLMethodInvokeExpr("ltrim", null, expr);
    }

    public SQLMethodInvokeExpr rtrim(SQLExpr expr) {
        return new SQLMethodInvokeExpr("rtrim", null, expr);
    }

    public SQLMethodInvokeExpr trim(SQLExpr expr) {
        return new SQLMethodInvokeExpr("trim", null, expr);
    }

    public SQLMethodInvokeExpr ifnull(SQLExpr expr1, SQLExpr expr2) {
        if (DBType.ALIYUN_ADS.name == dbType
                || DBType.PRESTO.name == dbType
                || DBType.ODPS.name == dbType) {
            return new SQLMethodInvokeExpr("coalesce", null, expr1, expr2);
        }

        if (DBType.ORACLE.name == dbType) {
            return new SQLMethodInvokeExpr("nvl", null, expr1, expr2);
        }

        if (DBType.SQL_SERVER.name == dbType) {
            return new SQLMethodInvokeExpr("isnull", null, expr1, expr2);
        }

        return new SQLMethodInvokeExpr("ifnull", null, expr1, expr2);
    }
}
