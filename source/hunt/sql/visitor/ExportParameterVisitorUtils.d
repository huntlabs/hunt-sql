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
module hunt.sql.visitor.ExportParameterVisitorUtils;


import hunt.collection;

import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.SQLObject;
import hunt.sql.ast.expr;
import hunt.sql.visitor.ExportParameterizedOutputVisitor;
import hunt.sql.dialect.mysql.visitor.MySqlExportParameterVisitor;
// import hunt.sql.dialect.oracle.visitor.OracleExportParameterVisitor;
import hunt.sql.dialect.postgresql.visitor.PGExportParameterVisitor;
// import hunt.sql.dialect.sqlserver.visitor.MSSQLServerExportParameterVisitor;
// import hunt.sql.util.DBType;
import hunt.sql.visitor.ExportParameterVisitor;
import hunt.sql.util.DBType;
import hunt.sql.util.MyString;
import hunt.util.Common;

public  class ExportParameterVisitorUtils {
    
    //private for util class not need new instance
    private this() {
        // super();
    }

    public static ExportParameterVisitor createExportParameterVisitor(  Appendable out_p , string dbType) {
        
        if (DBType.MYSQL.name == (dbType)) {
            return new MySqlExportParameterVisitor(out_p);
        }
        // if (DBType.ORACLE.name == (dbType) || DBType.ALI_ORACLE.name == (dbType)) {
        //     return new OracleExportParameterVisitor(out_p);
        // }
        // if (DBType.DB2.name == (dbType)) {
        //     return new DB2ExportParameterVisitor(out_p);
        // }
        
        if (DBType.MARIADB.name == (dbType)) {
            return new MySqlExportParameterVisitor(out_p);
        }
        
        // if (DBType.H2.name == (dbType)) {
        //     return new MySqlExportParameterVisitor(out_p);
        // }

        if (DBType.POSTGRESQL.name == (dbType)
                || DBType.ENTERPRISEDB.name == (dbType)) {
            return new PGExportParameterVisitor(out_p);
        }

        // if (DBType.SQL_SERVER.name == (dbType) || DBType.JTDS.name == (dbType)) {
        //     return new MSSQLServerExportParameterVisitor(out_p);
        // }
       return new ExportParameterizedOutputVisitor(out_p);
    }

    

    public static bool exportParamterAndAccept( List!(Object) parameters, List!(SQLExpr) list) {
        for (int i = 0, size = list.size(); i < size; ++i) {
            SQLExpr param = list.get(i);

            SQLExpr result = exportParameter(parameters, param);
            if (result != param) {
                list.set(i, result);
            }
        }

        return false;
    }

    public static SQLExpr exportParameter( List!(Object) parameters,  SQLExpr param) {
        Object value = null;
        bool replace = false;

        if (cast(SQLCharExpr)(param) !is null) {
            value = (cast(SQLCharExpr) param).getText();
            replace = true;
        } else if (cast(SQLBooleanExpr)(param) !is null) {
            value = (cast(SQLBooleanExpr) param).getBooleanValue();
            replace = true;
        } else if (cast(SQLNumericLiteralExpr)(param) !is null) {
            value = cast(Object)(cast(SQLNumericLiteralExpr) param).getNumber();
            replace = true;
        } else if (cast(SQLHexExpr)(param) !is null) {
            value = (cast(SQLHexExpr) param)/* .toBytes() */;
            replace = true;
        } else if (cast(SQLTimestampExpr)(param) !is null || cast(SQLDateExpr)(param) !is null) {
            value = (cast(SQLTimestampExpr) param).getValue();
            replace = true;
        } else if (cast(SQLListExpr)(param) !is null) {
            SQLListExpr list = (cast(SQLListExpr) param);

            List!(Object) listValues = new ArrayList!(Object)();
            for (int i = 0; i < list.getItems().size(); i++) {
                SQLExpr listItem = list.getItems().get(i);

                if (cast(SQLCharExpr)(listItem) !is null) {
                    Object listValue = (cast(SQLCharExpr) listItem).getText();
                    listValues.add(listValue);
                } else if (cast(SQLBooleanExpr)(listItem) !is null) {
                    Object listValue = (cast(SQLBooleanExpr) listItem).getBooleanValue();
                    listValues.add(listValue);
                } else if (cast(SQLNumericLiteralExpr)(listItem) !is null) {
                    Object listValue = cast(Object)(cast(SQLNumericLiteralExpr) listItem).getNumber();
                    listValues.add(listValue);
                } else if (cast(SQLHexExpr)(param) !is null) {
                    Object listValue = (cast(SQLHexExpr) listItem)/* .toBytes() */;//@gxc
                    listValues.add(listValue);
                }
            }

            if (listValues.size() == list.getItems().size()) {
                value = cast(Object)listValues;
                replace = true;
            }
        }

        if (replace) {
            SQLObject parent = param.getParent();
            if (parent !is null) {
                List!(SQLObject) mergedList = null;
                if (cast(SQLBinaryOpExpr)(parent) !is null) {
                    mergedList = (cast(SQLBinaryOpExpr) parent).getMergedList();
                }
                if (mergedList !is null) {
                    List!(Object) mergedListParams = new ArrayList!(Object)(mergedList.size() + 1);
                    for (int i = 0; i < mergedList.size(); ++i) {
                        SQLObject item = mergedList.get(i);
                        if (cast(SQLBinaryOpExpr)(item) !is null) {
                            SQLBinaryOpExpr binaryOpItem = cast(SQLBinaryOpExpr) item;
                            exportParameter(mergedListParams, binaryOpItem.getRight());
                        }
                    }
                    if (mergedListParams.size() > 0) {
                        mergedListParams.add(0, value);
                        value = cast(Object)mergedListParams;
                    }
                }
            }

            parameters.add(value);

            return new SQLVariantRefExpr("?");
        }

        return param;
    }

    public static void exportParameter( List!(Object) parameters, SQLBinaryOpExpr x) {
        if (cast(SQLLiteralExpr)x.getLeft() !is null
                && cast(SQLLiteralExpr)x.getRight() !is null
                && x.getOperator().isRelational()) {
            return;
        }

        {
            SQLExpr leftResult = ExportParameterVisitorUtils.exportParameter(parameters, x.getLeft());
            if (leftResult != x.getLeft()) {
                x.setLeft(leftResult);
            }
        }

        {
            SQLExpr rightResult = exportParameter(parameters, x.getRight());
            if (rightResult != x.getRight()) {
                x.setRight(rightResult);
            }
        }
    }

    public static void exportParameter( List!(Object) parameters, SQLBetweenExpr x) {
        {
            SQLExpr result = exportParameter(parameters, x.getBeginExpr());
            if (result != x.getBeginExpr()) {
                x.setBeginExpr(result);
            }
        }

        {
            SQLExpr result = exportParameter(parameters, x.getEndExpr());
            if (result != x.getBeginExpr()) {
                x.setEndExpr(result);
            }
        }

    }
}
