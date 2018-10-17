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
module hunt.sql.SQLTransformUtils;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLDataTypeImpl;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
// import hunt.sql.dialect.oracle.ast.clause.OracleWithSubqueryEntry;
// import hunt.sql.dialect.oracle.ast.expr.OracleSysdateExpr;
// import hunt.sql.dialect.oracle.ast.stmt;
import hunt.sql.util.FnvHash;
import hunt.string;
import hunt.container;
import std.uni;

public class SQLTransformUtils {
    public static SQLExpr transformDecode(SQLMethodInvokeExpr x) {
        if (x is null) {
            return null;
        }
        
        if (!equalsIgnoreCase("decode",x.getMethodName())) {
            throw new Exception(x.getMethodName());
        }

        List!(SQLExpr) parameters = x.getParameters();
        SQLCaseExpr caseExpr = new SQLCaseExpr();
        caseExpr.setParent(x.getParent());
        caseExpr.setValueExpr(parameters.get(0));

        if (parameters.size() == 4) {
            SQLExpr param1 = parameters.get(1);

            x.setMethodName("if");

            SQLBinaryOpExpr condition;
            if (cast(SQLNullExpr)(param1) !is null) {
                condition = new SQLBinaryOpExpr(parameters.get(0), SQLBinaryOperator.Is, param1);
            } else {
                condition = new SQLBinaryOpExpr(parameters.get(0), SQLBinaryOperator.Equality, param1);
            }
            condition.setParent(x);
            parameters.set(0, condition);
            parameters.set(1, parameters.get(2));
            parameters.set(2, parameters.get(3));
            parameters.removeAt(3);
            return x;
        }

        for (int i = 1; i + 1 < parameters.size(); i += 2) {
            SQLCaseExpr.Item item = new SQLCaseExpr.Item();
            SQLExpr conditionExpr = parameters.get(i);

            item.setConditionExpr(conditionExpr);

            SQLExpr valueExpr = parameters.get(i + 1);

            if (cast(SQLMethodInvokeExpr)(valueExpr) !is null) {
                SQLMethodInvokeExpr methodInvokeExpr = cast(SQLMethodInvokeExpr) valueExpr;
                if (equalsIgnoreCase("decode",methodInvokeExpr.getMethodName())) {
                    valueExpr = transformDecode(methodInvokeExpr);
                }
            }

            item.setValueExpr(valueExpr);
            caseExpr.addItem(item);
        }

        if (parameters.size() % 2 == 0) {
            SQLExpr defaultExpr = parameters.get(parameters.size() - 1);

            if (cast(SQLMethodInvokeExpr)(defaultExpr) !is null) {
                SQLMethodInvokeExpr methodInvokeExpr = cast(SQLMethodInvokeExpr) defaultExpr;
                if (equalsIgnoreCase("decode",methodInvokeExpr.getMethodName())) {
                    defaultExpr = transformDecode(methodInvokeExpr);
                }
            }

            caseExpr.setElseExpr(defaultExpr);
        }

        caseExpr.setParent(x.getParent());

        return caseExpr;
    }

    public static SQLDataType transformOracleToMySql(SQLDataType x) {
         string name = x.getName();
         long nameHash = x.nameHashCode64();

        if (name is null) {
            return x;
        }
        List!(SQLExpr) argumentns = x.getArguments();

        SQLDataType dataType;

        if (nameHash == FnvHash.Constants.UROWID) {
            int len = 4000;
            if (argumentns.size() == 1) {
                SQLExpr arg0 = argumentns.get(0);
                if (cast(SQLIntegerExpr)(arg0) !is null) {
                    len = (cast(SQLIntegerExpr) arg0).getNumber().intValue();
                }
            }
            dataType = new SQLDataTypeImpl("varchar", len);
        } else if (nameHash == FnvHash.Constants.ROWID) {
            dataType = new SQLDataTypeImpl("char", 10);

        } else if (nameHash == FnvHash.Constants.BOOLEAN) {
            dataType = new SQLDataTypeImpl("tinyint");

        } else if (nameHash == FnvHash.Constants.INTEGER) {
            dataType = new SQLDataTypeImpl("int");

        } else if (nameHash == FnvHash.Constants.FLOAT
                || nameHash == FnvHash.Constants.BINARY_FLOAT) {
                dataType = new SQLDataTypeImpl("float");

        } else if (nameHash == FnvHash.Constants.REAL
                || nameHash == FnvHash.Constants.BINARY_DOUBLE
                || nameHash == FnvHash.Constants.DOUBLE_PRECISION) {
            dataType = new SQLDataTypeImpl("double");

        } else if (nameHash == FnvHash.Constants.NUMBER) {
            if (argumentns.size() == 0) {
                dataType = new SQLDataTypeImpl("decimal", 38);
            } else {
                SQLExpr arg0 = argumentns.get(0);

                int precision, scale = 0;
                if (cast(SQLAllColumnExpr)(arg0) !is null) {
                    precision = 9;
                } else {
                    precision = (cast(SQLIntegerExpr) arg0).getNumber().intValue();
                }

                if (argumentns.size() > 1) {
                    scale = (cast(SQLIntegerExpr) argumentns.get(1)).getNumber().intValue();
                }

                if (scale > precision) {
                    if (cast(SQLAllColumnExpr)(arg0) !is null) {
                        precision = 19;
                        if (scale > precision) {
                            precision = scale;
                        }
                    } else {
                        precision = scale;
                    }
                }

                if (scale == 0) {
                    if (precision < 3) {
                        dataType = new SQLDataTypeImpl("tinyint");
                    } else if (precision < 5) {
                        dataType = new SQLDataTypeImpl("smallint");
                    } else if (precision < 9) {
                        dataType = new SQLDataTypeImpl("int");
                    } else if (precision <= 20) {
                        dataType = new SQLDataTypeImpl("bigint");
                    } else {
                        dataType = new SQLDataTypeImpl("decimal", precision);
                    }
                } else {
                    dataType = new SQLDataTypeImpl("decimal", precision, scale);
                }
            }

        } else if (nameHash == FnvHash.Constants.DEC
                || nameHash == FnvHash.Constants.DECIMAL) {

            dataType = x.clone();
            dataType.setName("decimal");

            int precision = 0;
            if (argumentns.size() > 0) {
                precision = (cast(SQLIntegerExpr) argumentns.get(0)).getNumber().intValue();
            }

            int scale = 0;
            if (argumentns.size() > 1) {
                scale = (cast(SQLIntegerExpr) argumentns.get(1)).getNumber().intValue();
                if (precision < scale) {
                    (cast(SQLIntegerExpr) dataType.getArguments().get(1)).setNumber(precision);
                }
            }

//            if (precision == 38 && scale == 0 && x.getParent(cast(SQLCastExpr)()) !is null) {
//                dataType.getArguments().clear();
//                dataType.setName("int");
//            }
            /////////////////////////////////

        } else if (nameHash == FnvHash.Constants.RAW) {
            int len;

            if (argumentns.size() == 0) {
                len = -1;
            } else if (argumentns.size() == 1) {
                SQLExpr arg0 = argumentns.get(0);
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }
            } else {
                throw new Exception("SQLUtils.toOracleString(x)");
            }

            if (len == -1) {
                dataType = new SQLDataTypeImpl("binary");
            } else if (len <= 255) {
                dataType = new SQLDataTypeImpl("binary", len);
            } else {
                dataType = new SQLDataTypeImpl("varbinary", len);
            }
        } else if (nameHash == FnvHash.Constants.CHAR
                || nameHash == FnvHash.Constants.CHARACTER) {
            if (argumentns.size() == 1) {
                SQLExpr arg0 = argumentns.get(0);

                int len;
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }

                if (len <= 255) {
                    dataType = new SQLCharacterDataType("char", len);
                } else {
                    dataType = new SQLCharacterDataType("varchar", len);
                }
            } else if (argumentns.size() == 0) {
                dataType = new SQLCharacterDataType("char");
            } else {
                throw new Exception("SQLUtils.toOracleString(x)");
            }

        } else if (nameHash == FnvHash.Constants.NCHAR) {
            if (argumentns.size() == 1) {
                SQLExpr arg0 = argumentns.get(0);

                int len;
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }

                if (len <= 255) {
                    dataType = new SQLCharacterDataType("nchar", len);
                } else {
                    dataType = new SQLCharacterDataType("nvarchar", len);
                }
            } else if (argumentns.size() == 0) {
                dataType = new SQLCharacterDataType("nchar");
            } else {
                throw new Exception("SQLUtils.toOracleString(x)");
            }

        } else if (nameHash == FnvHash.Constants.VARCHAR2) {
            if (argumentns.size() > 0) {
                int len;
                SQLExpr arg0 = argumentns.get(0);
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }
                dataType = new SQLCharacterDataType("varchar", len);
            } else {
                dataType = new SQLCharacterDataType("varchar");
            }

        } else if (nameHash == FnvHash.Constants.NVARCHAR2) {
            if (argumentns.size() > 0) {
                int len;
                SQLExpr arg0 = argumentns.get(0);
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }
                dataType = new SQLCharacterDataType("nvarchar", len);
            } else {
                dataType = new SQLCharacterDataType("nvarchar");
            }

        } else if (nameHash == FnvHash.Constants.BFILE) {
            dataType = new SQLCharacterDataType("varchar", 255);

        } else if (nameHash == FnvHash.Constants.DATE
                || nameHash == FnvHash.Constants.TIMESTAMP) {
            int len = -1;
            if (argumentns.size() > 0) {
                SQLExpr arg0 = argumentns.get(0);
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }
            }

            if (len >= 0) {
                if (len > 6) {
                    len = 6;
                }
                dataType = new SQLDataTypeImpl("datetime", len);
            } else {
                dataType = new SQLDataTypeImpl("datetime");
            }
        } else if (nameHash == FnvHash.Constants.BLOB
                || nameHash == FnvHash.Constants.LONG_RAW) {
            argumentns.clear();
            dataType = new SQLDataTypeImpl("LONGBLOB");

        } else if (nameHash == FnvHash.Constants.CLOB
                || nameHash == FnvHash.Constants.NCLOB
                || nameHash == FnvHash.Constants.LONG
                || nameHash == FnvHash.Constants.XMLTYPE) {
            argumentns.clear();
            dataType = new SQLCharacterDataType("LONGTEXT");

        } else {
            dataType = x;
        }

        if (dataType != x) {
            dataType.setParent(x.getParent());
        }

        return dataType;
    }

    public static SQLDataType transformOracleToAliyunAds(SQLDataType x) {
         string dataTypeName = toLower(x.getName());
        SQLDataType dataType;

        if (dataTypeName == ("varchar2")
                || dataTypeName == ("varchar")
                || dataTypeName == ("char")
                || dataTypeName == ("nchar")
                || dataTypeName == ("nvarchar")
                || dataTypeName == ("nvarchar2")
                || dataTypeName == ("clob")
                || dataTypeName == ("nclob")
                || dataTypeName == ("blob")
                || dataTypeName == ("long")
                || dataTypeName == ("long raw")
                || dataTypeName == ("raw")
                ) {
            dataType = new SQLCharacterDataType("varchar");
        } else if (dataTypeName == ("number")
                || dataTypeName == ("decimal")
                || dataTypeName == ("dec")
                || dataTypeName == ("numeric")) {
            int scale = 0;
            if (x.getArguments().size() > 1) {
                scale = (cast(SQLIntegerExpr) x.getArguments().get(1)).getNumber().intValue();
            }
            if (scale == 0) {
                dataType = new SQLDataTypeImpl("bigint");
            } else {
                dataType = new SQLDataTypeImpl("double");
            }
        } else if (dataTypeName == ("date")
                || dataTypeName == ("datetime")
                || dataTypeName == ("timestamp")) {
            dataType = new SQLDataTypeImpl("timestamp");
        } else if (dataTypeName == ("float")
                || dataTypeName == ("binary_float")) {
            dataType = new SQLDataTypeImpl("float");
        } else if (dataTypeName == ("double")
                || dataTypeName == ("binary_double")) {
            dataType = new SQLDataTypeImpl("double");
        } else {
            dataType = x;
        }

        if (dataType != x) {
            dataType.setParent(x.getParent());
        }

        return dataType;
    }

    public static SQLDataType transformOracleToPostgresql(SQLDataType x) {
         string name = x.getName();
         long nameHash = x.nameHashCode64();

        if (name is null) {
            return x;
        }
        List!(SQLExpr) argumentns = x.getArguments();

        SQLDataType dataType;

        if (nameHash == FnvHash.Constants.UROWID) {
            int len = 4000;
            if (argumentns.size() == 1) {
                SQLExpr arg0 = argumentns.get(0);
                if (cast(SQLIntegerExpr)(arg0) !is null) {
                    len = (cast(SQLIntegerExpr) arg0).getNumber().intValue();
                }
            }
            dataType = new SQLDataTypeImpl(SQLDataType.Constants.VARCHAR, len);
        } else if (nameHash == FnvHash.Constants.ROWID) {
            dataType = new SQLDataTypeImpl(SQLDataType.Constants.CHAR, 10);

        } else if (nameHash == FnvHash.Constants.BOOLEAN || nameHash == FnvHash.Constants.SMALLINT) {
            dataType = new SQLDataTypeImpl(SQLDataType.Constants.SMALLINT);

        } else if (nameHash == FnvHash.Constants.INTEGER
                || nameHash == FnvHash.Constants.INT) {
            dataType = new SQLDataTypeImpl(SQLDataType.Constants.DECIMAL, 38);

        } else if (nameHash == FnvHash.Constants.BINARY_FLOAT) {
            dataType = new SQLDataTypeImpl(SQLDataType.Constants.REAL);

        } else if (nameHash == FnvHash.Constants.BINARY_DOUBLE
                || nameHash == FnvHash.Constants.FLOAT
                || nameHash == FnvHash.Constants.DOUBLE
                || nameHash == FnvHash.Constants.REAL
                || nameHash == FnvHash.Constants.DOUBLE_PRECISION) {
            dataType = new SQLDataTypeImpl(SQLDataType.Constants.DOUBLE_PRECISION);

        } else if (nameHash == FnvHash.Constants.NUMBER) {
            if (argumentns.size() == 0) {
                dataType = new SQLDataTypeImpl(SQLDataType.Constants.DECIMAL, 38);
            } else {
                SQLExpr arg0 = argumentns.get(0);

                int precision, scale = 0;
                if (cast(SQLAllColumnExpr)(arg0) !is null) {
                    precision = 19;
                    scale = -1;
                } else {
                    precision = (cast(SQLIntegerExpr) arg0).getNumber().intValue();
                }

                if (argumentns.size() > 1) {
                    scale = (cast(SQLIntegerExpr) argumentns.get(1)).getNumber().intValue();
                }

                if (scale > precision) {
                    if (cast(SQLAllColumnExpr)(arg0) !is null) {
                        precision = 19;
                        if (scale > precision) {
                            precision = scale;
                        }
                    } else {
                        precision = scale;
                    }
                }

                if (scale == 0) {
                    if (precision < 5) {
                        dataType = new SQLDataTypeImpl(SQLDataType.Constants.SMALLINT);
                    } else if (precision < 9) {
                        dataType = new SQLDataTypeImpl(SQLDataType.Constants.INT);
                    } else if (precision <= 20) {
                        dataType = new SQLDataTypeImpl(SQLDataType.Constants.BIGINT);
                    } else {
                        dataType = new SQLDataTypeImpl(SQLDataType.Constants.DECIMAL, precision);
                    }
                } else if (scale == -1) {
                    dataType = new SQLDataTypeImpl(SQLDataType.Constants.DOUBLE_PRECISION);
                } else {
                    dataType = new SQLDataTypeImpl(SQLDataType.Constants.DECIMAL, precision, scale);
                }
            }

        } else if (nameHash == FnvHash.Constants.DEC
                || nameHash == FnvHash.Constants.DECIMAL) {
            dataType = x.clone();
            dataType.setName(SQLDataType.Constants.DECIMAL);

            int precision = 0;
            if (argumentns.size() > 0) {
                precision = (cast(SQLIntegerExpr) argumentns.get(0)).getNumber().intValue();
            }

            int scale = 0;
            if (argumentns.size() > 1) {
                scale = (cast(SQLIntegerExpr) argumentns.get(1)).getNumber().intValue();
                if (precision < scale) {
                    (cast(SQLIntegerExpr) dataType.getArguments().get(1)).setNumber(precision);
                }
            }

        } else if (nameHash == FnvHash.Constants.CHARACTER) {
            if (argumentns.size() == 1) {
                SQLExpr arg0 = argumentns.get(0);

                int len;
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }
                dataType = new SQLCharacterDataType(SQLDataType.Constants.CHAR, len);
            } else if (argumentns.size() == 0) {
                dataType = new SQLCharacterDataType(SQLDataType.Constants.CHAR);
            } else {
                throw new Exception("SQLUtils.toOracleString(x)");
            }
        } else if (nameHash == FnvHash.Constants.CHAR) {
            if (argumentns.size() == 1) {
                SQLExpr arg0 = argumentns.get(0);

                int len;
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }

                if (len <= 2000) {
                    dataType = x;
                    dataType.setName(SQLDataType.Constants.CHAR);
                } else {
                    dataType = new SQLCharacterDataType(SQLDataType.Constants.TEXT);
                }
            } else if (argumentns.size() == 0) {
                dataType = new SQLCharacterDataType(SQLDataType.Constants.CHAR);
            } else {
                throw new Exception("SQLUtils.toOracleString(x)");
            }
        } else if (nameHash == FnvHash.Constants.NCHAR) {
            // no changed
            dataType = x;
            dataType.setName(SQLDataType.Constants.NCHAR);
        } else if (nameHash == FnvHash.Constants.VARCHAR
                || nameHash == FnvHash.Constants.VARCHAR2) {
            if (argumentns.size() > 0) {
                int len;
                SQLExpr arg0 = argumentns.get(0);
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else if (cast(SQLVariantRefExpr)(arg0) !is null) {
                    len = 2000;
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }

                if (len <= 4000) {
                    dataType = new SQLCharacterDataType(SQLDataType.Constants.VARCHAR, len);
                } else {
                    dataType = new SQLCharacterDataType(SQLDataType.Constants.TEXT);
                }
            } else {
                dataType = new SQLCharacterDataType(SQLDataType.Constants.VARCHAR);
            }

        } else if (nameHash == FnvHash.Constants.NVARCHAR
                || nameHash == FnvHash.Constants.NVARCHAR2
                || nameHash == FnvHash.Constants.NCHAR_VARYING) {
            if (argumentns.size() > 0) {
                int len;
                SQLExpr arg0 = argumentns.get(0);
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }
                dataType = new SQLCharacterDataType(SQLDataType.Constants.VARCHAR, len);
            } else {
                dataType = new SQLCharacterDataType(SQLDataType.Constants.VARCHAR);
            }

        } else if (nameHash == FnvHash.Constants.BFILE) {
            dataType = new SQLCharacterDataType(SQLDataType.Constants.VARCHAR, 255);
        } else if (nameHash == FnvHash.Constants.DATE) {
            dataType = new SQLDataTypeImpl(SQLDataType.Constants.TIMESTAMP, 0);
        } else if (nameHash == FnvHash.Constants.TIMESTAMP) {
            x.setName(SQLDataType.Constants.TIMESTAMP);
            if (x.isWithLocalTimeZone()) {
                x.setWithLocalTimeZone(false);
                x.setWithTimeZone(false);
            }
            dataType = x;
        } else if (nameHash == FnvHash.Constants.DATETIME) {
            int len = -1;
            if (argumentns.size() > 0) {
                SQLExpr arg0 = argumentns.get(0);
                if (cast(SQLNumericLiteralExpr)(arg0) !is null) {
                    len = (cast(SQLNumericLiteralExpr) arg0).getNumber().intValue();
                } else {
                    throw new Exception("SQLUtils.toOracleString(x)");
                }
            }

            if (len > 0) {
                dataType = new SQLDataTypeImpl(SQLDataType.Constants.TIMESTAMP, len);
            } else {
                dataType = new SQLDataTypeImpl(SQLDataType.Constants.TIMESTAMP);
            }
        } else if (nameHash == FnvHash.Constants.BLOB
                || nameHash == FnvHash.Constants.LONG_RAW
                || nameHash == FnvHash.Constants.RAW) {
            argumentns.clear();
            dataType = new SQLDataTypeImpl(SQLDataType.Constants.BYTEA);

        } else if (nameHash == FnvHash.Constants.CLOB
                || nameHash == FnvHash.Constants.NCLOB
                || nameHash == FnvHash.Constants.LONG) {
            argumentns.clear();
            dataType = new SQLCharacterDataType(SQLDataType.Constants.TEXT);

        } else if (nameHash == FnvHash.Constants.XMLTYPE) {
            dataType = new SQLDataTypeImpl(SQLDataType.Constants.XML);
        } else {
            dataType = x;
        }

        if (dataType != x) {
            dataType.setParent(x.getParent());
        }

        return dataType;
    }

    public static SQLExpr transformOracleToPostgresql(SQLMethodInvokeExpr x) {
         long nameHashCode64 = x.methodNameHashCode64();
        List!(SQLExpr) parameters = x.getParameters();

        if (nameHashCode64 == FnvHash.Constants.SYS_GUID) {
            SQLMethodInvokeExpr uuid_generate_v4 = new SQLMethodInvokeExpr("uuid_generate_v4");

            uuid_generate_v4.setParent(x.getParent());
            return uuid_generate_v4;
        }

        if (nameHashCode64 == FnvHash.Constants.TRUNC) {
            if (parameters.size() == 1) {
                SQLExpr param0 = parameters.get(0);
                if (/*cast(OracleSysdateExpr)(param0) !is null
                        ||*/ (cast(SQLIdentifierExpr)(param0) !is null
                            && (cast(SQLIdentifierExpr) param0).nameHashCode64() == FnvHash.Constants.CURRENT_TIMESTAMP)) {
                    SQLMethodInvokeExpr current_timestamp = new SQLMethodInvokeExpr("CURRENT_TIMESTAMP");
                    current_timestamp.addParameter(new SQLIntegerExpr(0));

                    current_timestamp.setParent(x.getParent());
                    return current_timestamp;
                }
            }
        }

        if (nameHashCode64 == FnvHash.Constants.CURRENT_TIMESTAMP) {
            if (parameters.size() == 0 &&  cast(SQLColumnDefinition)x.getParent() !is null) {
                SQLDataType dataType = (cast(SQLColumnDefinition) x.getParent()).getDataType();
                if (dataType.nameHashCode64() == FnvHash.Constants.TIMESTAMP
                        && dataType.getArguments().size() == 1) {
                    x.addParameter(dataType.getArguments().get(0).clone());
                } else {
                    x.addParameter(new SQLIntegerExpr(0));
                }
                return x;
            }
        }

        if (nameHashCode64 == FnvHash.Constants.SYSTIMESTAMP) {
            SQLMethodInvokeExpr xx = x.clone();
            xx.setMethodName("CURRENT_TIMESTAMP");
            xx.setParent(x.getParent());
            return xx;
        }

        if (nameHashCode64 == FnvHash.Constants.USERENV) {
            if (x.getParameters().size() == 1) {
                SQLExpr param0 = x.getParameters().get(0);
                if (cast(SQLCharExpr)(param0) !is null) {
                    string text = (cast(SQLCharExpr) param0).getText().str;
                    if ("SESSIONID".equalsIgnoreCase(text)) {
                        SQLMethodInvokeExpr xx = new SQLMethodInvokeExpr();
                        xx.setMethodName("get_session_id");
                        xx.setParent(x.getParent());
                        return xx;
                    }
                }
            }
        }

        if (nameHashCode64 == FnvHash.Constants.USERENV) {
            if (x.getParameters().size() == 1) {
                SQLExpr param0 = x.getParameters().get(0);
                if (cast(SQLCharExpr)(param0) !is null) {
                    string text = (cast(SQLCharExpr) param0).getText().str;
                    if ("SESSIONID".equalsIgnoreCase(text)) {
                        SQLMethodInvokeExpr xx = new SQLMethodInvokeExpr();
                        xx.setMethodName("get_session_id");
                        xx.setParent(x.getParent());
                        return xx;
                    }
                }
            }
        }

        if (nameHashCode64 == FnvHash.Constants.NUMTODSINTERVAL) {
            if (x.getParameters().size() == 2) {
                SQLExpr param0 = x.getParameters().get(0);
                SQLExpr param1 = x.getParameters().get(1);

                if (cast(SQLIntegerExpr)(param0) !is null && cast(SQLCharExpr)(param1) !is null) {
                    string text = (cast(SQLCharExpr) param1).getText().str;
                    if ("DAY".equalsIgnoreCase(text)) {
                        SQLIntervalExpr intervalExpr = new SQLIntervalExpr();
                        intervalExpr.setValue(new SQLCharExpr(param0.stringof ~ " DAYS"));
                        intervalExpr.setParent(x.getParent());
                        return intervalExpr;
                    }
                }
            }
        }

        return x;
    }

    // public static SQLTableSource transformOracleToPostgresql(SQLTableSource x) {
    //     if (cast(OracleSelectTableReference)(x) !is null) {
    //         OracleSelectTableReference xx = cast(OracleSelectTableReference) x;
    //         SQLExprTableSource y = new SQLExprTableSource();
    //         xx.cloneTo(y);

    //         y.setParent(x.getParent());
    //         return y;
    //     }

    //     if (cast(OracleSelectJoin)(x) !is null) {
    //         OracleSelectJoin xx = cast(OracleSelectJoin) x;
    //         SQLJoinTableSource y = new SQLJoinTableSource();
    //         xx.cloneTo(y);

    //         y.setLeft(transformOracleToPostgresql(y.getLeft()));
    //         y.setRight(transformOracleToPostgresql(y.getRight()));

    //         y.setParent(x.getParent());
    //         return y;
    //     }

    //     if (cast(OracleSelectSubqueryTableSource)(x) !is null) {
    //         OracleSelectSubqueryTableSource xx = cast(OracleSelectSubqueryTableSource) x;
    //         SQLSubqueryTableSource y = new SQLSubqueryTableSource();
    //         xx.cloneTo(y);

    //         y.setParent(x.getParent());
    //         return y;
    //     }

    //     if (cast(OracleWithSubqueryEntry)(x) !is null) {
    //         SQLWithSubqueryClause.Entry entry = new SQLWithSubqueryClause.Entry();
    //         (cast(OracleWithSubqueryEntry) x).cloneTo(entry);
    //         entry.setParent(x.getParent());
    //         return entry;
    //     }

    //     return x;
    // }

    // public static SQLSelectQueryBlock transformOracleToPostgresql(SQLSelectQueryBlock x) {
    //     if (cast(OracleSelectQueryBlock)(x) !is null) {
    //         OracleSelectQueryBlock xx = cast(OracleSelectQueryBlock) x;
    //         SQLSelectQueryBlock y = new SQLSelectQueryBlock();
    //         xx.cloneTo(y);
    //         y.setFrom(transformOracleToPostgresql(y.getFrom()));

    //         y.setParent(x.getParent());
    //         return y;
    //     }

    //     return x;
    // }
}
