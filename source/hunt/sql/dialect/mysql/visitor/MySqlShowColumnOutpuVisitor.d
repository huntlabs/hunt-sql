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
module hunt.sql.dialect.mysql.visitor.MySqlShowColumnOutpuVisitor;

import hunt.sql.SQLUtils;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.statement.SQLCreateTableStatement;
import hunt.sql.ast.statement.SQLTableElement;
import hunt.sql.dialect.mysql.ast.MySqlUnique;
import hunt.sql.dialect.mysql.ast.statement.MySqlCreateTableStatement;
import hunt.sql.visitor.SQLASTOutputVisitor;

import hunt.string;
import hunt.lang;
import hunt.container;
import hunt.sql.dialect.mysql.visitor.MySqlOutputVisitor;

/**
 * Created by wenshao on 27/07/2017.
 */
public class MySqlShowColumnOutpuVisitor : MySqlOutputVisitor {

    alias visit = MySqlOutputVisitor.visit;
    alias endVisit = MySqlOutputVisitor.endVisit;

    alias print = SQLASTOutputVisitor.print;

    public this(Appendable appender) {
        super(appender);
    }

    override public bool visit(MySqlCreateTableStatement x) {
        List!(SQLColumnDefinition) columns = new ArrayList!(SQLColumnDefinition)();
        List!(string) dataTypes = new ArrayList!(string)();
        List!(string) defaultValues = new ArrayList!(string)();

        int name_len = -1, dataType_len = -1, defaultVal_len = 7, extra_len = 5;
        foreach(SQLTableElement element ; x.getTableElementList()) {
            if (cast(SQLColumnDefinition)(element) !is null) {
                SQLColumnDefinition column = cast(SQLColumnDefinition) element;
                columns.add(column);

                string name = SQLUtils.normalize(column.getName().getSimpleName());
                if (name_len < name.length) {
                    name_len = cast(int)(name.length);
                }

                string dataType = column.getDataType().getName();
                if (column.getDataType().getArguments().size() > 0) {
                    dataType ~= "(";
                    for (int i = 0; i < column.getDataType().getArguments().size(); i++) {
                        if (i != 0) {
                            dataType ~= ",";
                        }
                        SQLExpr arg = column.getDataType().getArguments().get(i);
                        dataType ~= (cast(Object)(arg)).toString();
                    }
                    dataType ~= ")";
                }

                if (dataType_len < dataType.length) {
                    dataType_len = cast(int)(dataType.length);
                }
                dataTypes.add(dataType);

                if (column.getDefaultExpr() is null) {
                    defaultValues.add(null);
                } else {
                    string defaultVal = SQLUtils.toMySqlString(column.getDefaultExpr());
                    if (defaultVal.length > 2 && charAt(defaultVal, 0) == '\'' && charAt(defaultVal, defaultVal.length - 1) == '\'') {
                        defaultVal = defaultVal.substring(1, cast(int)(defaultVal.length - 1));
                    }
                    defaultValues.add(defaultVal);

                    if (defaultVal_len < defaultVal.length) {
                        defaultVal_len = cast(int)(defaultVal.length);
                    }
                }

                if (column.isAutoIncrement()) {
                    extra_len = "auto_increment".length;
                } else if (column.getOnUpdate() !is null) {
                    extra_len = "on update CURRENT_TIMESTAMP".length;
                }
            }
        }

        print("+-");
        print('-', name_len);
        print("-+-");
        print('-', dataType_len);
        print("-+------+-----+-");
        print('-', defaultVal_len);
        print("-+-");
        print('-', extra_len);
        print("-+\n");

        print("| ");
        print("Field", name_len, ' ');
        print(" | ");
        print("Type", dataType_len, ' ');
        print(" | Null | Key | ");
        print("Default", defaultVal_len, ' ');
        print(" | ");
        print("Extra", extra_len, ' ');
        print(" |\n");

        print("+-");
        print('-', name_len);
        print("-+-");
        print('-', dataType_len);
        print("-+------+-----+-");
        print('-', defaultVal_len);
        print("-+-");
        print('-', extra_len);
        print("-+\n");

        for (int i = 0; i < columns.size(); i++) {
            SQLColumnDefinition column = columns.get(i);
            string name = SQLUtils.normalize(column.getName().getSimpleName());

            print("| ");
            print(name, name_len, ' ');
            print(" | ");

            print(dataTypes.get(i), dataType_len, ' ');
            print(" | ");

            if (column.containsNotNullConstaint()) {
                print("NO ");
            } else {
                print("YES");
            }
            print("  | ");

            MySqlUnique unique = null;
            if (x.isPrimaryColumn(name)) {
                print("PRI");
            } else if (x.isUNI(name)) {
                print("UNI");
            } else if (x.isMUL(name)) {
                print("MUL");
            } else {
                print("   ");
            }
            print(" | ");

            string defaultVal = defaultValues.get(i);
            if (defaultVal is null) {
                print("NULL", defaultVal_len, ' ');
            } else {
                print(defaultVal, defaultVal_len, ' ');
            }
            print(" | ");

            if (column.isAutoIncrement()) {
                print("auto_increment", extra_len, ' ');
            } else if (column.getOnUpdate() !is null) {
                print("on update CURRENT_TIMESTAMP", extra_len, ' ');
            } else {
                print(' ', extra_len);
            }
            print(" |");
            print("\n");
        }
        print("+-");
        print('-', name_len);
        print("-+-");
        print('-', dataType_len);
        print("-+------+-----+-");
        print('-', defaultVal_len);
        print("-+-");
        print('-', extra_len);
        print("-+\n");
        
        return false;
    }

    void print(char ch, int count) {
        for (int i = 0; i < count; ++i)  {
            print(ch);
        }
    }

    void print(string text, int columnSize, char ch) {
        print(text);
        print(' ', columnSize - cast(int)(text.length));
    }
}
