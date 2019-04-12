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
module hunt.sql.dialect.postgresql.visitor.PGOutputVisitor;

import hunt.sql.ast;
import hunt.sql.ast.expr;
import hunt.sql.ast.statement;
// import hunt.sql.dialect.oracle.ast.OracleDataTypeIntervalDay;
// import hunt.sql.dialect.oracle.ast.OracleDataTypeIntervalYear;
// import hunt.sql.dialect.oracle.ast.clause;
// import hunt.sql.dialect.oracle.ast.expr;
// import hunt.sql.dialect.oracle.ast.stmt;
// import hunt.sql.dialect.oracle.parser.OracleFunctionDataType;
// import hunt.sql.dialect.oracle.parser.OracleProcedureDataType;
// import hunt.sql.dialect.oracle.visitor.OracleASTVisitor;
import hunt.sql.dialect.postgresql.ast.expr.PGBoxExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGCidrExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGCircleExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGExtractExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGInetExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGLineSegmentsExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGMacAddrExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGPointExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGPolygonExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGTypeCastExpr;
import hunt.sql.dialect.postgresql.ast.stmt;
import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock;
// import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock.FetchClause;
// import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock.ForClause;
// import hunt.sql.dialect.postgresql.ast.stmt.PGSelectQueryBlock.WindowClause;
import hunt.sql.visitor.SQLASTOutputVisitor;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.dialect.postgresql.visitor.PGASTVisitor;

import hunt.Byte;
import hunt.collection;
import hunt.logging.ConsoleLogger;
import hunt.String;
import hunt.util.Common;
import hunt.text;

import std.array;
import std.format;
import std.uni;
import std.algorithm.searching;

public class PGOutputVisitor : SQLASTOutputVisitor , PGASTVisitor//, OracleASTVisitor 
{
    alias visit = SQLASTOutputVisitor.visit;
    alias endVisit = SQLASTOutputVisitor.endVisit; 

    public this(Appendable appender){
        super(appender);
        this.dbType = DBType.POSTGRESQL.name;
    }

    public this(Appendable appender, bool parameterized){
        super(appender, parameterized);
        this.dbType = DBType.POSTGRESQL.name;
    }

    override
    public void endVisit(PGSelectQueryBlock.WindowClause x) {

    }

    override
    public bool visit(PGSelectQueryBlock.WindowClause x) {
        print0(ucase ? "WINDOW " : "window ");
        x.getName().accept(this);
        print0(ucase ? " AS " : " as ");
        for (int i = 0; i < x.getDefinition().size(); ++i) {
            if (i != 0) {
                println(", ");
            }
            print('(');
            x.getDefinition().get(i).accept(this);
            print(')');
        }
        return false;
    }

    override
    public void endVisit(PGSelectQueryBlock.FetchClause x) {

    }

    override
    public bool visit(PGSelectQueryBlock.FetchClause x) {
        print0(ucase ? "FETCH " : "fetch ");
        if (PGSelectQueryBlock.FetchClause.Option.FIRST == (x.getOption())) {
            print0(ucase ? "FIRST " : "first ");
        } else if (PGSelectQueryBlock.FetchClause.Option.NEXT == (x.getOption())) {
            print0(ucase ? "NEXT " : "next ");
        }
        x.getCount().accept(this);
        print0(ucase ? " ROWS ONLY" : " rows only");
        return false;
    }

    override
    public void endVisit(PGSelectQueryBlock.ForClause x) {

    }

    override
    public bool visit(PGSelectQueryBlock.ForClause x) {
        print0(ucase ? "FOR " : "for ");
        if (PGSelectQueryBlock.ForClause.Option.UPDATE == (x.getOption())) {
            print0(ucase ? "UPDATE " : "update ");
        } else if (PGSelectQueryBlock.ForClause.Option.SHARE == (x.getOption())) {
            print0(ucase ? "SHARE " : "share ");
        }

        if (x.getOf().size() > 0) {
            for (int i = 0; i < x.getOf().size(); ++i) {
                if (i != 0) {
                    println(", ");
                }
                x.getOf().get(i).accept(this);
            }
        }

        if (x.isNoWait()) {
            print0(ucase ? " NOWAIT" : " nowait");
        }

        return false;
    }


    public bool visit(PGSelectQueryBlock x) {
        print0(ucase ? "SELECT " : "select ");

        if (SQLSetQuantifier.ALL == x.getDistionOption()) {
            print0(ucase ? "ALL " : "all ");
        } else if (SQLSetQuantifier.DISTINCT == x.getDistionOption()) {
            print0(ucase ? "DISTINCT " : "distinct ");

            if (x.getDistinctOn() !is null && x.getDistinctOn().size() > 0) {
                print0(ucase ? "ON " : "on ");
                printAndAccept!SQLExpr((x.getDistinctOn()), ", ");
            }
        }

        printSelectList(x.getSelectList());

        if (x.getInto() !is null) {
            println();
            if (x.getIntoOption().name.length != 0) {
                print0(x.getIntoOption().name());
                print(' ');
            }

            print0(ucase ? "INTO " : "into ");
            x.getInto().accept(this);
        }

        if (x.getFrom() !is null) {
            println();
            print0(ucase ? "FROM " : "from ");
            x.getFrom().accept(this);
        }

        if (x.getWhere() !is null) {
            println();
            print0(ucase ? "WHERE " : "where ");
            x.getWhere().accept(this);
        }

        if (x.getGroupBy() !is null) {
            println();
            x.getGroupBy().accept(this);
        }

        if (x.getWindow() !is null) {
            println();
            x.getWindow().accept(this);
        }

        if (x.getOrderBy() !is null) {
            println();
            x.getOrderBy().accept(this);
        }

        if (x.getLimit() !is null) {
            println();
            x.getLimit().accept(this);
        }

        if (x.getFetch() !is null) {
            println();
            x.getFetch().accept(this);
        }

        if (x.getForClause() !is null) {
            println();
            x.getForClause().accept(this);
        }

        return false;
    }

    override
    public bool visit(SQLTruncateStatement x) {
        print0(ucase ? "TRUNCATE TABLE " : "truncate table ");
        if (x.isOnly()) {
            print0(ucase ? "ONLY " : "only ");
        }

        printlnAndAccept!(SQLExprTableSource)((x.getTableSources()), ", ");

        if (x.getRestartIdentity() !is null) {
            if (x.getRestartIdentity().booleanValue()) {
                print0(ucase ? " RESTART IDENTITY" : " restart identity");
            } else {
                print0(ucase ? " CONTINUE IDENTITY" : " continue identity");
            }
        }

        if (x.getCascade() !is null) {
            if (x.getCascade().booleanValue()) {
                print0(ucase ? " CASCADE" : " cascade");
            } else {
                print0(ucase ? " RESTRICT"  : " restrict");
            }
        }
        return false;
    }

    override
    public void endVisit(PGDeleteStatement x) {

    }

    override
    public bool visit(PGDeleteStatement x) {
        if (x.getWith() !is null) {
            x.getWith().accept(this);
            println();
        }

        print0(ucase ? "DELETE FROM " : "delete from ");

        if (x.isOnly()) {
            print0(ucase ? "ONLY " : "only ");
        }

        printTableSourceExpr(x.getTableName());

        if (x.getAlias() !is null) {
            print0(ucase ? " AS " : " as ");
            print0(x.getAlias());
        }

        SQLTableSource using = x.getUsing();
        if (using !is null) {
            println();
            print0(ucase ? "USING " : "using ");
            using.accept(this);
        }

        if (x.getWhere() !is null) {
            println();
            print0(ucase ? "WHERE " : "where ");
            this.indentCount++;
            x.getWhere().accept(this);
            this.indentCount--;
        }

        if (x.isReturning()) {
            println();
            print0(ucase ? "RETURNING *" : "returning *");
        }

        return false;
    }

    override
    public void endVisit(PGInsertStatement x) {

    }

    override
    public bool visit(PGInsertStatement x) {
        if (x.getWith() !is null) {
            x.getWith().accept(this);
            println();
        }

        print0(ucase ? "INSERT INTO " : "insert into ");

        x.getTableSource().accept(this);

        printInsertColumns(x.getColumns());

        if (x.getValues() !is null) {
            println();
            print0(ucase ? "VALUES " : "values ");
            printlnAndAccept!(ValuesClause)((x.getValuesList()), ", ");
        } else {
            if (x.getQuery() !is null) {
                println();
                x.getQuery().accept(this);
            }
        }

        List!(SQLExpr) onConflictTarget = x.getOnConflictTarget();
        List!(SQLUpdateSetItem) onConflictUpdateSetItems = x.getOnConflictUpdateSetItems();
        bool onConflictDoNothing = x.isOnConflictDoNothing();

        if (onConflictDoNothing
                || (onConflictTarget !is null && onConflictTarget.size() > 0)
                || (onConflictUpdateSetItems !is null && onConflictUpdateSetItems.size() > 0)) {
            println();
            print0(ucase ? "ON CONFLICT" : "on conflict");

            if ((onConflictTarget !is null && onConflictTarget.size() > 0)) {
                print0(" (");
                printAndAccept!SQLExpr((onConflictTarget), ", ");
                print(')');
            }

            SQLName onConflictConstraint = x.getOnConflictConstraint();
            if (onConflictConstraint !is null) {
                print0(ucase ? " ON CONSTRAINT " : " on constraint ");
                printExpr(onConflictConstraint);
            }

            SQLExpr onConflictWhere = x.getOnConflictWhere();
            if (onConflictWhere !is null) {
                print0(ucase ? " WHERE " : " where ");
                printExpr(onConflictWhere);
            }

            if (onConflictDoNothing) {
                print0(ucase ? " DO NOTHING" : " do nothing");
            } else if ((onConflictUpdateSetItems !is null && onConflictUpdateSetItems.size() > 0)) {
                print0(ucase ? " UPDATE SET " : " update set ");
                printAndAccept!SQLUpdateSetItem((onConflictUpdateSetItems), ", ");
            }
        }

        if (x.getReturning() !is null) {
            println();
            print0(ucase ? "RETURNING " : "returning ");
            x.getReturning().accept(this);
        }

        return false;
    }

    override
    public void endVisit(PGSelectStatement x) {

    }

    override
    public bool visit(PGSelectStatement x) {
        return visit(cast(SQLSelectStatement) x);
    }

    override
    public void endVisit(PGUpdateStatement x) {

    }

    override
    public bool visit(PGUpdateStatement x) {
        SQLWithSubqueryClause with_p = x.getWith();
        if (with_p !is null) {
            visit(with_p);
            println();
        }

        print0(ucase ? "UPDATE " : "update ");

        if (x.isOnly()) {
            print0(ucase ? "ONLY " : "only ");
        }

        printTableSource(x.getTableSource());

        println();
        print0(ucase ? "SET " : "set ");
        for (int i = 0, size = x.getItems().size(); i < size; ++i) {
            if (i != 0) {
                print0(", ");
            }
            SQLUpdateSetItem item = x.getItems().get(i);
            visit(item);
        }

        SQLTableSource from = x.getFrom();
        if (from !is null) {
            println();
            print0(ucase ? "FROM " : "from ");
            printTableSource(from);
        }

        SQLExpr where = x.getWhere();
        if (where !is null) {
            println();
            indentCount++;
            print0(ucase ? "WHERE " : "where ");
            printExpr(where);
            indentCount--;
        }

        List!(SQLExpr) returning = x.getReturning();
        if (returning.size() > 0) {
            println();
            print0(ucase ? "RETURNING " : "returning ");
            printAndAccept!SQLExpr((returning), ", ");
        }

        return false;
    }

    override
    public void endVisit(PGSelectQueryBlock x) {

    }

    override
    public bool visit(PGFunctionTableSource x) {
        x.getExpr().accept(this);

        if (x.getAlias() !is null) {
            print0(ucase ? " AS " : " as ");
            print0(x.getAlias());
        }

        if (x.getParameters().size() > 0) {
            print('(');
            printAndAccept!SQLParameter((x.getParameters()), ", ");
            print(')');
        }

        return false;
    }

    override
    public void endVisit(PGFunctionTableSource x) {

    }

    override
    public void endVisit(PGTypeCastExpr x) {
        
    }

    override
    public bool visit(PGTypeCastExpr x) {
        SQLExpr expr = x.getExpr();
        SQLDataType dataType = x.getDataType();

        if (dataType.nameHashCode64() == FnvHash.Constants.VARBIT) {
            dataType.accept(this);
            print(' ');
            printExpr(expr);
            return false;
        }

        if (expr !is null) {
            if (cast(SQLBinaryOpExpr)(expr) !is null) {
                print('(');
                expr.accept(this);
                print(')');
            } else if (cast(PGTypeCastExpr)(expr) !is null && dataType.getArguments().size() == 0) {
                dataType.accept(this);
                print('(');
                visit(cast(PGTypeCastExpr) expr);
                print(')');
                return false;
            } else {
                expr.accept(this);
            }
        }
        print0("::");
        dataType.accept(this);
        return false;
    }

    override
    public void endVisit(PGValuesQuery x) {
        
    }

    override
    public bool visit(PGValuesQuery x) {
        print0(ucase ? "VALUES(" : "values(");
        printAndAccept!SQLExpr((x.getValues()), ", ");
        print(')');
        return false;
    }
    
    override
    public void endVisit(PGExtractExpr x) {
        
    }
    
    override
    public bool visit(PGExtractExpr x) {
        print0(ucase ? "EXTRACT (" : "extract (");
        print0(x.getField().name());
        print0(ucase ? " FROM " : " from ");
        x.getSource().accept(this);
        print(')');
        return false;
    }
    
    override
    public bool visit(PGBoxExpr x) {
        print0(ucase ? "BOX " : "box ");
        x.getValue().accept(this);
        return false;
    }

    override
    public void endVisit(PGBoxExpr x) {
        
    }
    
    override
    public bool visit(PGPointExpr x) {
        print0(ucase ? "POINT " : "point ");
        x.getValue().accept(this);
        return false;
    }
    
    override
    public void endVisit(PGPointExpr x) {
        
    }
    
    override
    public bool visit(PGMacAddrExpr x) {
        print0("macaddr ");
        x.getValue().accept(this);
        return false;
    }
    
    override
    public void endVisit(PGMacAddrExpr x) {
        
    }
    
    override
    public bool visit(PGInetExpr x) {
        print0("inet ");
        x.getValue().accept(this);
        return false;
    }
    
    override
    public void endVisit(PGInetExpr x) {
        
    }
    
    override
    public bool visit(PGCidrExpr x) {
        print0("cidr ");
        x.getValue().accept(this);
        return false;
    }
    
    override
    public void endVisit(PGCidrExpr x) {
        
    }
    
    override
    public bool visit(PGPolygonExpr x) {
        print0("polygon ");
        x.getValue().accept(this);
        return false;
    }
    
    override
    public void endVisit(PGPolygonExpr x) {
        
    }
    
    override
    public bool visit(PGCircleExpr x) {
        print0("circle ");
        x.getValue().accept(this);
        return false;
    }
    
    override
    public void endVisit(PGCircleExpr x) {
        
    }
    
    override
    public bool visit(PGLineSegmentsExpr x) {
        print0("lseg ");
        x.getValue().accept(this);
        return false;
    }

    override
    public void endVisit(PGLineSegmentsExpr x) {
        
    }

    override
    public bool visit(SQLBinaryExpr x) {
        print0(ucase ? "B'" : "b'");
        print0(x.getText());
        print('\'');

        return false;
    }
    
    override
    public void endVisit(PGShowStatement x) {
        
    }
    
    override
    public bool visit(PGShowStatement x) {
        print0(ucase ? "SHOW " : "show ");
        x.getExpr().accept(this);
        return false;
    }

    override public bool visit(SQLLimit x) {
        print0(ucase ? "LIMIT " : "limit ");

        x.getRowCount().accept(this);

        if (x.getOffset() !is null) {
            print0(ucase ? " OFFSET " : " offset ");
            x.getOffset().accept(this);
        }
        return false;
    }

    override
    public void endVisit(PGStartTransactionStatement x) {
        
    }

    override
    public bool visit(PGStartTransactionStatement x) {
        print0(ucase ? "START TRANSACTION" : "start transaction");
        return false;
    }

    override
    public void endVisit(PGConnectToStatement x) {

    }

    override
    public bool visit(PGConnectToStatement x) {
        print0(ucase ? "CONNECT TO " : "connect to ");
        x.getTarget().accept(this);
        return false;
    }

    override
    public bool visit(SQLSetStatement x) {
        print0(ucase ? "SET " : "set ");

        SQLSetStatement.Option option = x.getOption();
        if (option.name.length != 0) {
            print(option.name());
            print(' ');
        }

        List!(SQLAssignItem) items = x.getItems();
        for (int i = 0; i < items.size(); i++) {
            if (i != 0) {
                print0(", ");
            }

            SQLAssignItem item = x.getItems().get(i);
            SQLExpr target = item.getTarget();
            target.accept(this);

            SQLExpr value = item.getValue();

            if (cast(SQLIdentifierExpr)(target) !is null
                    && (cast(SQLIdentifierExpr) target).getName().equalsIgnoreCase("TIME ZONE")) {
                print(' ');
            } else {
                if (cast(SQLPropertyExpr)(value) !is null
                        &&  cast(SQLVariantRefExpr)((cast(SQLPropertyExpr) value).getOwner()) !is null) {
                    print0(" := ");
                } else {
                    print0(" TO ");
                }
            }

            if (cast(SQLListExpr)(value) !is null) {
                SQLListExpr listExpr = cast(SQLListExpr) value;
                printAndAccept!SQLExpr((listExpr.getItems()), ", ");
            } else {
                value.accept(this);
            }
        }

        return false;
    }

    override
    public bool visit(SQLCreateUserStatement x) {
        print0(ucase ? "CREATE USER " : "create user ");
        x.getUser().accept(this);
        print0(ucase ? " PASSWORD " : " password ");

        SQLExpr passoword = x.getPassword();

        if (cast(SQLIdentifierExpr)(passoword) !is null) {
            print('\'');
            passoword.accept(this);
            print('\'');
        } else {
            passoword.accept(this);
        }

        return false;
    }

    override protected void printGrantPrivileges(SQLGrantStatement x) {
        List!(SQLExpr) privileges = x.getPrivileges();
        int i = 0;
        foreach(SQLExpr privilege ; privileges) {
            if (i != 0) {
                print(", ");
            }

            if (cast(SQLIdentifierExpr)(privilege) !is null) {
                string name = (cast(SQLIdentifierExpr) privilege).getName();
                if ("RESOURCE".equalsIgnoreCase(name)) {
                    continue;
                }
            }

            privilege.accept(this);
            i++;
        }
    }

    override public bool visit(SQLGrantStatement x) {
        if (x.getOn() is null) {
            print("ALTER ROLE ");
            x.getTo().accept(this);
            print(' ');
            Set!(SQLIdentifierExpr) pgPrivilegs = new LinkedHashSet!(SQLIdentifierExpr)();
            foreach(SQLExpr privilege ; x.getPrivileges()) {
                if (cast(SQLIdentifierExpr)(privilege) !is null) {
                    string name = (cast(SQLIdentifierExpr) privilege).getName();
                    if (equalsIgnoreCase(name, "CONNECT")) {
                        pgPrivilegs.add(new SQLIdentifierExpr("LOGIN"));
                    }
                    if (toLower(name).startsWith("create ")) {
                        pgPrivilegs.add(new SQLIdentifierExpr("CREATEDB"));
                    }
                }
            }
            int i = 0;
            foreach(SQLIdentifierExpr privilege ; pgPrivilegs) {
                if (i != 0) {
                    print(' ');
                }
                privilege.accept(this);
                i++;
            }
            return false;
        }

        return super.visit(x);
    }
    /** **************************************************************************/
    // for oracle to postsql
    /** **************************************************************************/

    // public bool visit(OracleSysdateExpr x) {
    //     print0(ucase ? "CURRENT_TIMESTAMP" : "CURRENT_TIMESTAMP");
    //     return false;
    // }

    // override
    // public void endVisit(OracleSysdateExpr x) {

    // }

    // override
    // public bool visit(OracleExceptionStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleExceptionStatement x) {

    // }

    // override
    // public bool visit(OracleExceptionStatement.Item x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleExceptionStatement.Item x) {

    // }

    // override
    // public bool visit(OracleArgumentExpr x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleArgumentExpr x) {

    // }

    // override
    // public bool visit(OracleSetTransactionStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleSetTransactionStatement x) {

    // }

    // override
    // public bool visit(OracleExplainStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleExplainStatement x) {

    // }

    // override
    // public bool visit(OracleAlterTableDropPartition x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTableDropPartition x) {

    // }

    // override
    // public bool visit(OracleAlterTableTruncatePartition x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTableTruncatePartition x) {

    // }

    // override
    // public bool visit(OracleAlterTableSplitPartition.TableSpaceItem x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTableSplitPartition.TableSpaceItem x) {

    // }

    // override
    // public bool visit(OracleAlterTableSplitPartition.UpdateIndexesClause x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTableSplitPartition.UpdateIndexesClause x) {

    // }

    // override
    // public bool visit(OracleAlterTableSplitPartition.NestedTablePartitionSpec x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTableSplitPartition.NestedTablePartitionSpec x) {

    // }

    // override
    // public bool visit(OracleAlterTableSplitPartition x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTableSplitPartition x) {

    // }

    // override
    // public bool visit(OracleAlterTableModify x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTableModify x) {

    // }

    // override
    // public bool visit(OracleCreateIndexStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleCreateIndexStatement x) {

    // }

    // override
    // public bool visit(OracleForStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleForStatement x) {

    // }

    // public bool visit(OracleSizeExpr x) {
    //     x.getValue().accept(this);
    //     print0(x.getUnit().name());
    //     return false;
    // }

    // override
    // public void endVisit(OracleSizeExpr x) {

    // }

    // override
    // public bool visit(OracleFileSpecification x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleFileSpecification x) {

    // }

    // override
    // public bool visit(OracleAlterTablespaceAddDataFile x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTablespaceAddDataFile x) {

    // }

    // override
    // public bool visit(OracleAlterTablespaceStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTablespaceStatement x) {

    // }

    // override
    // public bool visit(OracleExitStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleExitStatement x) {

    // }

    // override
    // public bool visit(OracleContinueStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleContinueStatement x) {

    // }

    // override
    // public bool visit(OracleRaiseStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleRaiseStatement x) {

    // }

    // override
    // public bool visit(OracleCreateDatabaseDbLinkStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleCreateDatabaseDbLinkStatement x) {

    // }

    // override
    // public bool visit(OracleDropDbLinkStatement x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleDropDbLinkStatement x) {

    // }

    // override
    // public bool visit(OracleDataTypeIntervalYear x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleDataTypeIntervalYear x) {

    // }

    // override
    // public bool visit(OracleDataTypeIntervalDay x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleDataTypeIntervalDay x) {

    // }

    // override
    // public bool visit(OracleUsingIndexClause x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleUsingIndexClause x) {

    // }

    // override
    // public bool visit(OracleLobStorageClause x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleLobStorageClause x) {

    // }

    // public bool visit(OracleSelectTableReference x) {
    //     if (x.isOnly()) {
    //         print0(ucase ? "ONLY (" : "only (");
    //         printTableSourceExpr(x.getExpr());

    //         if (x.getPartition() !is null) {
    //             print(' ');
    //             x.getPartition().accept(this);
    //         }

    //         print(')');
    //     } else {
    //         printTableSourceExpr(x.getExpr());

    //         if (x.getPartition() !is null) {
    //             print(' ');
    //             x.getPartition().accept(this);
    //         }
    //     }

    //     if (x.getHints().size() > 0) {
    //         this.printHints(x.getHints());
    //     }

    //     if (x.getSampleClause() !is null) {
    //         print(' ');
    //         x.getSampleClause().accept(this);
    //     }

    //     if (x.getPivot() !is null) {
    //         println();
    //         x.getPivot().accept(this);
    //     }

    //     printAlias(x.getAlias());

    //     return false;
    // }

    // override
    // public void endVisit(OracleSelectTableReference x) {

    // }

    // override
    // public bool visit(PartitionExtensionClause x) {
    //     return false;
    // }

    // override
    // public void endVisit(PartitionExtensionClause x) {

    // }

    private void printHints(List!(SQLHint) hints) {
        if (hints.size() > 0) {
            print0("/*~ ");
            printAndAccept!SQLHint((hints), ", ");
            print0(" */");
        }
    }

    // public bool visit(OracleIntervalExpr x) {
    //     if (cast(SQLLiteralExpr)x.getValue() !is null) {
    //         print0(ucase ? "INTERVAL " : "interval ");
    //         x.getValue().accept(this);
    //         print(' ');
    //     } else {
    //         print('(');
    //         x.getValue().accept(this);
    //         print0(") ");
    //     }

    //     print0(x.getType().name());

    //     if (x.getPrecision() !is null) {
    //         print('(');
    //         printExpr(x.getPrecision());
    //         if (x.getFactionalSecondsPrecision() !is null) {
    //             print0(", ");
    //             print(x.getFactionalSecondsPrecision().intValue());
    //         }
    //         print(')');
    //     }

    //     if (x.getToType() !is null) {
    //         print0(ucase ? " TO " : " to ");
    //         print0(x.getToType().name());
    //         if (x.getToFactionalSecondsPrecision() !is null) {
    //             print('(');
    //             printExpr(x.getToFactionalSecondsPrecision());
    //             print(')');
    //         }
    //     }

    //     return false;
    // }

    // override
    // public bool visit(OracleOuterExpr x) {
    //     x.getExpr().accept(this);
    //     print0("(+)");
    //     return false;
    // }

    // override
    // public void endVisit(OracleDatetimeExpr x) {

    // }

    // public bool visit(OracleBinaryFloatExpr x) {
    //     print0(x.getValue().toString());
    //     print('F');
    //     return false;
    // }

    // override
    // public void endVisit(OracleBinaryFloatExpr x) {

    // }

    // public bool visit(OracleBinaryDoubleExpr x) {
    //     print0(x.getValue().toString());
    //     print('D');
    //     return false;
    // }

    // override
    // public void endVisit(OracleBinaryDoubleExpr x) {

    // }

    // override
    // public void endVisit(OracleCursorExpr x) {

    // }

    // override
    // public bool visit(OracleIsSetExpr x) {
    //     x.getNestedTable().accept(this);
    //     print0(ucase ? " IS A SET" : " is a set");
    //     return false;
    // }

    // override
    // public void endVisit(OracleIsSetExpr x) {

    // }

    // override
    // public bool visit(ModelClause.ReturnRowsClause x) {
    //     if (x.isAll()) {
    //         print0(ucase ? "RETURN ALL ROWS" : "return all rows");
    //     } else {
    //         print0(ucase ? "RETURN UPDATED ROWS" : "return updated rows");
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(ModelClause.ReturnRowsClause x) {

    // }

    // override
    // public bool visit(ModelClause.MainModelClause x) {
    //     if (x.getMainModelName() !is null) {
    //         print0(ucase ? " MAIN " : " main ");
    //         x.getMainModelName().accept(this);
    //     }

    //     println();
    //     x.getModelColumnClause().accept(this);

    //     foreach(ModelClause.CellReferenceOption opt ; x.getCellReferenceOptions()) {
    //         println();
    //         print0(opt.name);
    //     }

    //     println();
    //     x.getModelRulesClause().accept(this);

    //     return false;
    // }

    // override
    // public void endVisit(ModelClause.MainModelClause x) {

    // }

    // override
    // public bool visit(ModelClause.ModelColumnClause x) {
    //     if (x.getQueryPartitionClause() !is null) {
    //         x.getQueryPartitionClause().accept(this);
    //         println();
    //     }

    //     print0(ucase ? "DIMENSION BY (" : "dimension by (");
    //     printAndAccept(x.getDimensionByColumns(), ", ");
    //     print(')');

    //     println();
    //     print0(ucase ? "MEASURES (" : "measures (");
    //     printAndAccept(x.getMeasuresColumns(), ", ");
    //     print(')');
    //     return false;
    // }

    // override
    // public void endVisit(ModelClause.ModelColumnClause x) {

    // }

    // override
    // public bool visit(ModelClause.QueryPartitionClause x) {
    //     print0(ucase ? "PARTITION BY (" : "partition by (");
    //     printAndAccept(x.getExprList(), ", ");
    //     print(')');
    //     return false;
    // }

    // override
    // public void endVisit(ModelClause.QueryPartitionClause x) {

    // }

    // override
    // public bool visit(ModelClause.ModelColumn x) {
    //     x.getExpr().accept(this);
    //     if (x.getAlias() !is null) {
    //         print(' ');
    //         print0(x.getAlias());
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(ModelClause.ModelColumn x) {

    // }

    // override
    // public bool visit(ModelClause.ModelRulesClause x) {
    //     if (x.getOptions().size() > 0) {
    //         print0(ucase ? "RULES" : "rules");
    //         foreach(ModelClause.ModelRuleOption opt ; x.getOptions()) {
    //             print(' ');
    //             print0(opt.name);
    //         }
    //     }

    //     if (x.getIterate() !is null) {
    //         print0(ucase ? " ITERATE (" : " iterate (");
    //         x.getIterate().accept(this);
    //         print(')');

    //         if (x.getUntil() !is null) {
    //             print0(ucase ? " UNTIL (" : " until (");
    //             x.getUntil().accept(this);
    //             print(')');
    //         }
    //     }

    //     print0(" (");
    //     printAndAccept(x.getCellAssignmentItems(), ", ");
    //     print(')');
    //     return false;

    // }

    // override
    // public void endVisit(ModelClause.ModelRulesClause x) {

    // }

    // override
    // public bool visit(ModelClause.CellAssignmentItem x) {
    //     if (x.getOption() !is null) {
    //         print0(x.getOption().name);
    //         print(' ');
    //     }

    //     x.getCellAssignment().accept(this);

    //     if (x.getOrderBy() !is null) {
    //         print(' ');
    //         x.getOrderBy().accept(this);
    //     }

    //     print0(" = ");
    //     x.getExpr().accept(this);

    //     return false;
    // }

    // override
    // public void endVisit(ModelClause.CellAssignmentItem x) {

    // }

    // override
    // public bool visit(ModelClause.CellAssignment x) {
    //     x.getMeasureColumn().accept(this);
    //     print0("[");
    //     printAndAccept(x.getConditions(), ", ");
    //     print0("]");
    //     return false;
    // }

    // override
    // public void endVisit(ModelClause.CellAssignment x) {

    // }

    // override
    // public bool visit(ModelClause x) {
    //     print0(ucase ? "MODEL" : "model");

    //     this.indentCount++;
    //     foreach(ModelClause.CellReferenceOption opt ; x.getCellReferenceOptions()) {
    //         print(' ');
    //         print0(opt.name);
    //     }

    //     if (x.getReturnRowsClause() !is null) {
    //         print(' ');
    //         x.getReturnRowsClause().accept(this);
    //     }

    //     foreach(ModelClause.ReferenceModelClause item ; x.getReferenceModelClauses()) {
    //         print(' ');
    //         item.accept(this);
    //     }

    //     x.getMainModel().accept(this);
    //     this.indentCount--;

    //     return false;
    // }

    // override
    // public void endVisit(ModelClause x) {

    // }

    // override
    // public bool visit(OracleReturningClause x) {
    //     print0(ucase ? "RETURNING " : "returning ");
    //     printAndAccept(x.getItems(), ", ");
    //     print0(ucase ? " INTO " : " into ");
    //     printAndAccept(x.getValues(), ", ");

    //     return false;
    // }

    // override
    // public void endVisit(OracleReturningClause x) {

    // }

    // override
    // public bool visit(OracleInsertStatement x) {
    //     //visit(cast(SQLInsertStatement) x);

    //     print0(ucase ? "INSERT " : "insert ");

    //     if (x.getHints().size() > 0) {
    //         printAndAccept(x.getHints(), ", ");
    //         print(' ');
    //     }

    //     print0(ucase ? "INTO " : "into ");

    //     x.getTableSource().accept(this);

    //     printInsertColumns(x.getColumns());

    //     if (x.getValues() !is null) {
    //         println();
    //         print0(ucase ? "VALUES " : "values ");
    //         x.getValues().accept(this);
    //     } else {
    //         if (x.getQuery() !is null) {
    //             println();
    //             x.getQuery().accept(this);
    //         }
    //     }

    //     if (x.getReturning() !is null) {
    //         println();
    //         x.getReturning().accept(this);
    //     }

    //     if (x.getErrorLogging() !is null) {
    //         println();
    //         x.getErrorLogging().accept(this);
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(OracleInsertStatement x) {

    // }

    // override
    // public bool visit(OracleMultiInsertStatement.InsertIntoClause x) {
    //     print0(ucase ? "INTO " : "into ");

    //     x.getTableSource().accept(this);

    //     if (x.getColumns().size() > 0) {
    //         this.indentCount++;
    //         println();
    //         print('(');
    //         for (int i = 0, size = x.getColumns().size(); i < size; ++i) {
    //             if (i != 0) {
    //                 if (i % 5 == 0) {
    //                     println();
    //                 }
    //                 print0(", ");
    //             }
    //             x.getColumns().get(i).accept(this);
    //         }
    //         print(')');
    //         this.indentCount--;
    //     }

    //     if (x.getValues() !is null) {
    //         println();
    //         print0(ucase ? "VALUES " : "values ");
    //         x.getValues().accept(this);
    //     } else {
    //         if (x.getQuery() !is null) {
    //             println();
    //             x.getQuery().accept(this);
    //         }
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(OracleMultiInsertStatement.InsertIntoClause x) {

    // }

    // override
    // public bool visit(OracleMultiInsertStatement x) {
    //     print0(ucase ? "INSERT " : "insert ");

    //     if (x.getHints().size() > 0) {
    //         this.printHints(x.getHints());
    //     }

    //     if (x.getOption() !is null) {
    //         print0(x.getOption().name());
    //         print(' ');
    //     }

    //     for (int i = 0, size = x.getEntries().size(); i < size; ++i) {
    //         this.indentCount++;
    //         println();
    //         x.getEntries().get(i).accept(this);
    //         this.indentCount--;
    //     }

    //     println();
    //     x.getSubQuery().accept(this);

    //     return false;
    // }

    // override
    // public void endVisit(OracleMultiInsertStatement x) {

    // }

    // override
    // public bool visit(OracleMultiInsertStatement.ConditionalInsertClause x) {
    //     for (int i = 0, size = x.getItems().size(); i < size; ++i) {
    //         if (i != 0) {
    //             println();
    //         }

    //         OracleMultiInsertStatement.ConditionalInsertClauseItem item = x.getItems().get(i);

    //         item.accept(this);
    //     }

    //     if (x.getElseItem() !is null) {
    //         println();
    //         print0(ucase ? "ELSE" : "else");
    //         this.indentCount++;
    //         println();
    //         x.getElseItem().accept(this);
    //         this.indentCount--;
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(OracleMultiInsertStatement.ConditionalInsertClause x) {

    // }

    // override
    // public bool visit(OracleMultiInsertStatement.ConditionalInsertClauseItem x) {
    //     print0(ucase ? "WHEN " : "when ");
    //     x.getWhen().accept(this);
    //     print0(ucase ? " THEN" : " then");
    //     this.indentCount++;
    //     println();
    //     x.getThen().accept(this);
    //     this.indentCount--;
    //     return false;
    // }

    // override
    // public void endVisit(OracleMultiInsertStatement.ConditionalInsertClauseItem x) {

    // }

    // override
    // public bool visit(OracleSelectQueryBlock x) {
    //     if (isPrettyFormat() && x.hasBeforeComment()) {
    //         printlnComments(x.getBeforeCommentsDirect());
    //     }

    //     print0(ucase ? "SELECT " : "select ");

    //     if (x.getHintsSize() > 0) {
    //         printAndAccept(x.getHints(), ", ");
    //         print(' ');
    //     }

    //     if (SQLSetQuantifier.ALL == x.getDistionOption()) {
    //         print0(ucase ? "ALL " : "all ");
    //     } else if (SQLSetQuantifier.DISTINCT == x.getDistionOption()) {
    //         print0(ucase ? "DISTINCT " : "distinct ");
    //     } else if (SQLSetQuantifier.UNIQUE == x.getDistionOption()) {
    //         print0(ucase ? "UNIQUE " : "unique ");
    //     }

    //     printSelectList(x.getSelectList());

    //     if (x.getInto() !is null) {
    //         println();
    //         print0(ucase ? "INTO " : "into ");
    //         x.getInto().accept(this);
    //     }

    //     println();
    //     print0(ucase ? "FROM " : "from ");
    //     if (x.getFrom() is null) {
    //         print0(ucase ? "DUAL" : "dual");
    //     } else {
    //         x.getFrom().accept(this);
    //     }

    //     if (x.getWhere() !is null) {
    //         println();
    //         print0(ucase ? "WHERE " : "where ");
    //         x.getWhere().accept(this);
    //     }

    //     printHierarchical(x);

    //     if (x.getGroupBy() !is null) {
    //         println();
    //         x.getGroupBy().accept(this);
    //     }

    //     if (x.getModelClause() !is null) {
    //         println();
    //         x.getModelClause().accept(this);
    //     }

    //     SQLOrderBy orderBy = x.getOrderBy();
    //     if (orderBy !is null) {
    //         println();
    //         orderBy.accept(this);
    //     }

    //     printFetchFirst(x);

    //     if (x.isForUpdate()) {
    //         println();
    //         print0(ucase ? "FOR UPDATE" : "for update");
    //         if (x.getForUpdateOfSize() > 0) {
    //             print('(');
    //             printAndAccept(x.getForUpdateOf(), ", ");
    //             print(')');
    //         }

    //         if (x.isNoWait()) {
    //             print0(ucase ? " NOWAIT" : " nowait");
    //         } else if (x.isSkipLocked()) {
    //             print0(ucase ? " SKIP LOCKED" : " skip locked");
    //         } else if (x.getWaitTime() !is null) {
    //             print0(ucase ? " WAIT " : " wait ");
    //             x.getWaitTime().accept(this);
    //         }
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(OracleSelectQueryBlock x) {

    // }

    // override
    // public bool visit(OracleLockTableStatement x) {
    //     print0(ucase ? "LOCK TABLE " : "lock table ");
    //     x.getTable().accept(this);
    //     print0(ucase ? " IN " : " in ");
    //     print0(x.getLockMode().toString());
    //     print0(ucase ? " MODE " : " mode ");
    //     if (x.isNoWait()) {
    //         print0(ucase ? "NOWAIT" : "nowait");
    //     } else if (x.getWait() !is null) {
    //         print0(ucase ? "WAIT " : "wait ");
    //         x.getWait().accept(this);
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(OracleLockTableStatement x) {

    // }

    // override
    // public bool visit(OracleAlterSessionStatement x) {
    //     print0(ucase ? "ALTER SESSION SET " : "alter session set ");
    //     printAndAccept(x.getItems(), ", ");
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterSessionStatement x) {

    // }

    // public bool visit(OracleRangeExpr x) {
    //     x.getLowBound().accept(this);
    //     print0("..");
    //     x.getUpBound().accept(this);
    //     return false;
    // }

    // override
    // public void endVisit(OracleRangeExpr x) {

    // }

    // override
    // public bool visit(OracleAlterIndexStatement x) {
    //     print0(ucase ? "ALTER INDEX " : "alter index ");
    //     x.getName().accept(this);

    //     if (x.getRenameTo() !is null) {
    //         print0(ucase ? " RENAME TO " : " rename to ");
    //         x.getRenameTo().accept(this);
    //     }

    //     if (x.getMonitoringUsage() !is null) {
    //         print0(ucase ? " MONITORING USAGE" : " monitoring usage");
    //     }

    //     if (x.getRebuild() !is null) {
    //         print(' ');
    //         x.getRebuild().accept(this);
    //     }

    //     if (x.getParallel() !is null) {
    //         print0(ucase ? " PARALLEL" : " parallel");
    //         x.getParallel().accept(this);
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterIndexStatement x) {

    // }

    // public bool visit(OracleCheck x) {
    //     visit(cast(SQLCheck) x);
    //     return false;
    // }

    // override
    // public void endVisit(OracleCheck x) {

    // }

    // override
    // public bool visit(OracleSupplementalIdKey x) {
    //     print0(ucase ? "SUPPLEMENTAL LOG DATA (" : "supplemental log data (");

    //     int count = 0;

    //     if (x.isAll()) {
    //         print0(ucase ? "ALL" : "all");
    //         count++;
    //     }

    //     if (x.isPrimaryKey()) {
    //         if (count != 0) {
    //             print0(", ");
    //         }
    //         print0(ucase ? "PRIMARY KEY" : "primary key");
    //         count++;
    //     }

    //     if (x.isUnique()) {
    //         if (count != 0) {
    //             print0(", ");
    //         }
    //         print0(ucase ? "UNIQUE" : "unique");
    //         count++;
    //     }

    //     if (x.isUniqueIndex()) {
    //         if (count != 0) {
    //             print0(", ");
    //         }
    //         print0(ucase ? "UNIQUE INDEX" : "unique index");
    //         count++;
    //     }

    //     if (x.isForeignKey()) {
    //         if (count != 0) {
    //             print0(", ");
    //         }
    //         print0(ucase ? "FOREIGN KEY" : "foreign key");
    //         count++;
    //     }

    //     print0(ucase ? ") COLUMNS" : ") columns");
    //     return false;
    // }

    // override
    // public void endVisit(OracleSupplementalIdKey x) {

    // }

    // override
    // public bool visit(OracleSupplementalLogGrp x) {
    //     print0(ucase ? "SUPPLEMENTAL LOG GROUP " : "supplemental log group ");
    //     x.getGroup().accept(this);
    //     print0(" (");
    //     printAndAccept(x.getColumns(), ", ");
    //     print(')');
    //     if (x.isAlways()) {
    //         print0(ucase ? " ALWAYS" : " always");
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(OracleSupplementalLogGrp x) {

    // }

    // override
    // public bool visit(OracleCreateTableStatement.Organization x) {
    //     string type = x.getType();

    //     print0(ucase ? "ORGANIZATION " : "organization ");
    //     print0(ucase ? type : toLower(type));

    //     printOracleSegmentAttributes(x);

    //     if (x.getPctthreshold() !is null) {
    //         println();
    //         print0(ucase ? "PCTTHRESHOLD " : "pctthreshold ");
    //         print(x.getPctfree());
    //     }

    //     if ("EXTERNAL".equalsIgnoreCase(type)) {
    //         print0(" (");

    //         this.indentCount++;
    //         if (x.getExternalType() !is null) {
    //             println();
    //             print0(ucase ? "TYPE " : "type ");
    //             x.getExternalType().accept(this);
    //         }

    //         if (x.getExternalDirectory() !is null) {
    //             println();
    //             print0(ucase ? "DEFAULT DIRECTORY " : "default directory ");
    //             x.getExternalDirectory().accept(this);
    //         }

    //         if (x.getExternalDirectoryRecordFormat() !is null) {
    //             println();
    //             this.indentCount++;
    //             print0(ucase ? "ACCESS PARAMETERS (" : "access parameters (");
    //             x.getExternalDirectoryRecordFormat().accept(this);
    //             this.indentCount--;
    //             println();
    //             print(')');
    //         }

    //         if (x.getExternalDirectoryLocation().size() > 0) {
    //             println();
    //             print0(ucase ? "LOCATION (" : " location(");
    //             printAndAccept(x.getExternalDirectoryLocation(), ", ");
    //             print(')');
    //         }

    //         this.indentCount--;
    //         println();
    //         print(')');

    //         if (x.getExternalRejectLimit() !is null) {
    //             println();
    //             print0(ucase ? "REJECT LIMIT " : "reject limit ");
    //             x.getExternalRejectLimit().accept(this);
    //         }
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(OracleCreateTableStatement.Organization x) {

    // }

    // override
    // public bool visit(OracleCreateTableStatement.OIDIndex x) {
    //     print0(ucase ? "OIDINDEX" : "oidindex");

    //     if (x.getName() !is null) {
    //         print(' ');
    //         x.getName().accept(this);
    //     }
    //     print(" (");
    //     this.indentCount++;
    //     printOracleSegmentAttributes(x);
    //     this.indentCount--;
    //     println();
    //     print(")");
    //     return false;
    // }

    // override
    // public void endVisit(OracleCreateTableStatement.OIDIndex x) {

    // }

    // override
    // public bool visit(OracleCreatePackageStatement x) {
    //     if (x.isOrReplace()) {
    //         print0(ucase ? "CREATE OR REPLACE PACKAGE " : "create or replace procedure ");
    //     } else {
    //         print0(ucase ? "CREATE PACKAGE " : "create procedure ");
    //     }

    //     if (x.isBody()) {
    //         print0(ucase ? "BODY " : "body ");
    //     }

    //     x.getName().accept(this);

    //     if (x.isBody()) {
    //         println();
    //         print0(ucase ? "BEGIN" : "begin");
    //     }

    //     this.indentCount++;

    //     List!(SQLStatement) statements = x.getStatements();
    //     for (int i = 0, size = statements.size(); i < size; ++i) {
    //         println();
    //         SQLStatement stmt = statements.get(i);
    //         stmt.accept(this);
    //     }

    //     this.indentCount--;

    //     if (x.isBody() || statements.size() > 0) {
    //         println();
    //         print0(ucase ? "END " : "end ");
    //         x.getName().accept(this);
    //         print(';');
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(OracleCreatePackageStatement x) {

    // }

    // override
    // public bool visit(OracleExecuteImmediateStatement x) {
    //     print0(ucase ? "EXECUTE IMMEDIATE " : "execute immediate ");
    //     x.getDynamicSql().accept(this);

    //     List!(SQLExpr) into = x.getInto();
    //     if (into.size() > 0) {
    //         print0(ucase ? " INTO " : " into ");
    //         printAndAccept(into, ", ");
    //     }

    //     List!(SQLArgument) using = x.getArguments();
    //     if (using.size() > 0) {
    //         print0(ucase ? " USING " : " using ");
    //         printAndAccept(using, ", ");
    //     }

    //     List!(SQLExpr) returnInto = x.getReturnInto();
    //     if (returnInto.size() > 0) {
    //         print0(ucase ? " RETURNNING INTO " : " returnning into ");
    //         printAndAccept(returnInto, ", ");
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(OracleExecuteImmediateStatement x) {

    // }

    // override
    // public bool visit(OracleTreatExpr x) {
    //     print0(ucase ? "TREAT (" : "treat (");
    //     x.getExpr().accept(this);
    //     print0(ucase ? " AS " : " as ");
    //     if (x.isRef()) {
    //         print0(ucase ? "REF " : "ref ");
    //     }
    //     x.getType().accept(this);
    //     print(')');
    //     return false;
    // }

    // override
    // public void endVisit(OracleTreatExpr x) {

    // }

    // override
    // public bool visit(OracleCreateSynonymStatement x) {
    //     if (x.isOrReplace()) {
    //         print0(ucase ? "CREATE OR REPLACE " : "create or replace ");
    //     } else {
    //         print0(ucase ? "CREATE " : "create ");
    //     }

    //     if (x.isPublic()) {
    //         print0(ucase ? "PUBLIC " : "public ");
    //     }

    //     print0(ucase ? "SYNONYM " : "synonym ");

    //     x.getName().accept(this);

    //     print0(ucase ? " FOR " : " for ");
    //     x.getObject().accept(this);

    //     return false;
    // }

    // override
    // public void endVisit(OracleCreateSynonymStatement x) {

    // }

    // override
    // public bool visit(OracleCreateTypeStatement x) {
    //     if (x.isOrReplace()) {
    //         print0(ucase ? "CREATE OR REPLACE TYPE " : "create or replace type ");
    //     } else {
    //         print0(ucase ? "CREATE TYPE " : "create type ");
    //     }

    //     if (x.isBody()) {
    //         print0(ucase ? "BODY " : "body ");
    //     }

    //     x.getName().accept(this);

    //     SQLName under = x.getUnder();
    //     if (under !is null) {
    //         print0(ucase ? " UNDER " : " under ");
    //         under.accept(this);
    //     }

    //     SQLName authId = x.getAuthId();
    //     if (authId !is null) {
    //         print0(ucase ? " AUTHID " : " authid ");
    //         authId.accept(this);
    //     }

    //     if (x.isForce()) {
    //         print0(ucase ? "FORCE " : "force ");
    //     }

    //     List!(SQLParameter) parameters = x.getParameters();
    //     SQLDataType tableOf = x.getTableOf();

    //     if (x.isObject()) {
    //         print0(" AS OBJECT");
    //     }

    //     if (parameters.size() > 0) {
    //         if (x.isParen()) {
    //             print(" (");
    //         } else {
    //             print0(ucase ? " IS" : " is");
    //         }
    //         indentCount++;
    //         println();

    //         for (int i = 0; i < parameters.size(); ++i) {
    //             SQLParameter param = parameters.get(i);
    //             param.accept(this);

    //             SQLDataType dataType = param.getDataType();

    //             if (i < parameters.size() - 1) {
    //                 if (cast(OracleFunctionDataType)(dataType) !is null
    //                         && (cast(OracleFunctionDataType) dataType).getBlock() !is null) {
    //                     // skip
    //                     println();
    //                 } else  if (cast(OracleProcedureDataType)(dataType) !is null
    //                         && (cast(OracleProcedureDataType) dataType).getBlock() !is null) {
    //                     // skip
    //                     println();
    //                 } else {
    //                     println(", ");
    //                 }
    //             }
    //         }

    //         indentCount--;
    //         println();

    //         if (x.isParen()) {
    //             print0(")");
    //         } else {
    //             print0("END");
    //         }
    //     } else if (tableOf !is null) {
    //         print0(ucase ? " AS TABLE OF " : " as table of ");
    //         tableOf.accept(this);
    //     } else if (x.getVarraySizeLimit() !is null) {
    //         print0(ucase ? " VARRAY (" : " varray (");
    //         x.getVarraySizeLimit().accept(this);
    //         print0(ucase ? ") OF " : ") of ");
    //         x.getVarrayDataType().accept(this);
    //     }

    //     bool isFinal = x.getFinal();
    //     if (isFinal !is null) {
    //         if (isFinal.booleanValue()) {
    //             print0(ucase ? " FINAL" : " ");
    //         } else {
    //             print0(ucase ? " NOT FINAL" : " not ");
    //         }
    //     }

    //     bool instantiable = x.getInstantiable();
    //     if (instantiable !is null) {
    //         if (instantiable.booleanValue()) {
    //             print0(ucase ? " INSTANTIABLE" : " instantiable");
    //         } else {
    //             print0(ucase ? " NOT INSTANTIABLE" : " not instantiable");
    //         }
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(OracleCreateTypeStatement x) {

    // }

    // override
    // public bool visit(OraclePipeRowStatement x) {
    //     print0(ucase ? "PIPE ROW(" : "pipe row(");
    //     printAndAccept(x.getParameters(), ", ");
    //     print(')');
    //     return false;
    // }

    // override
    // public void endVisit(OraclePipeRowStatement x) {

    // }

    // public bool visit(OraclePrimaryKey x) {
    //     visit(cast(SQLPrimaryKey) x);
    //     return false;
    // }

    // override
    // public void endVisit(OraclePrimaryKey x) {

    // }

    // override
    // public bool visit(OracleCreateTableStatement x) {
    //     printCreateTable(x, false);

    //     if (x.getOf() !is null) {
    //         println();
    //         print0(ucase ? "OF " : "of ");
    //         x.getOf().accept(this);
    //     }

    //     if (x.getOidIndex() !is null) {
    //         println();
    //         x.getOidIndex().accept(this);
    //     }

    //     if (x.getOrganization() !is null) {
    //         println();
    //         this.indentCount++;
    //         x.getOrganization().accept(this);
    //         this.indentCount--;
    //     }

    //     printOracleSegmentAttributes(x);

    //     if (x.isInMemoryMetadata()) {
    //         println();
    //         print0(ucase ? "IN_MEMORY_METADATA" : "in_memory_metadata");
    //     }

    //     if (x.isCursorSpecificSegment()) {
    //         println();
    //         print0(ucase ? "CURSOR_SPECIFIC_SEGMENT" : "cursor_specific_segment");
    //     }

    //     if (x.getParallel() == Boolean.TRUE) {
    //         println();
    //         print0(ucase ? "PARALLEL" : "parallel");
    //     } else if (x.getParallel() == Boolean.FALSE) {
    //         println();
    //         print0(ucase ? "NOPARALLEL" : "noparallel");
    //     }

    //     if (x.getCache() == Boolean.TRUE) {
    //         println();
    //         print0(ucase ? "CACHE" : "cache");
    //     } else if (x.getCache() == Boolean.FALSE) {
    //         println();
    //         print0(ucase ? "NOCACHE" : "nocache");
    //     }

    //     if (x.getLobStorage() !is null) {
    //         println();
    //         x.getLobStorage().accept(this);
    //     }

    //     if (x.isOnCommitPreserveRows()) {
    //         println();
    //         print0(ucase ? "ON COMMIT PRESERVE ROWS" : "on commit preserve rows");
    //     } else if (x.isOnCommitDeleteRows()) {
    //         println();
    //         print0(ucase ? "ON COMMIT DELETE ROWS" : "on commit delete rows");
    //     }

    //     if (x.isMonitoring()) {
    //         println();
    //         print0(ucase ? "MONITORING" : "monitoring");
    //     }

    //     SQLPartitionBy partitionBy = x.getPartitioning();
    //     if (partitionBy !is null) {
    //         println();
    //         print0(ucase ? "PARTITION BY " : "partition by ");
    //         partitionBy.accept(this);
    //     }

    //     if (x.getCluster() !is null) {
    //         println();
    //         print0(ucase ? "CLUSTER " : "cluster ");
    //         x.getCluster().accept(this);
    //         print0(" (");
    //         printAndAccept(x.getClusterColumns(), ",");
    //         print0(")");
    //     }

    //     if (x.getSelect() !is null) {
    //         println();
    //         print0(ucase ? "AS" : "as");
    //         println();
    //         x.getSelect().accept(this);
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(OracleCreateTableStatement x) {

    // }

    // override
    // public bool visit(OracleAlterIndexStatement.Rebuild x) {
    //     print0(ucase ? "REBUILD" : "rebuild");

    //     if (x.getOption() !is null) {
    //         print(' ');
    //         x.getOption().accept(this);
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterIndexStatement.Rebuild x) {

    // }

    // override
    // public bool visit(OracleStorageClause x) {
    //     return false;
    // }

    // override
    // public void endVisit(OracleStorageClause x) {

    // }

    // override
    // public bool visit(OracleGotoStatement x) {
    //     print0(ucase ? "GOTO " : "GOTO ");
    //     x.getLabel().accept(this);
    //     return false;
    // }

    // override
    // public void endVisit(OracleGotoStatement x) {

    // }

    // override
    // public bool visit(OracleLabelStatement x) {
    //     print0("<<");
    //     x.getLabel().accept(this);
    //     print0(">>");
    //     return false;
    // }

    // override
    // public void endVisit(OracleLabelStatement x) {

    // }

    // override
    // public bool visit(OracleAlterTriggerStatement x) {
    //     print0(ucase ? "ALTER TRIGGER " : "alter trigger ");
    //     x.getName().accept(this);

    //     if (x.isCompile()) {
    //         print0(ucase ? " COMPILE" : " compile");
    //     }

    //     if (x.getEnable() !is null) {
    //         if (x.getEnable().booleanValue()) {
    //             print0(ucase ? "ENABLE" : "enable");
    //         } else {
    //             print0(ucase ? "DISABLE" : "disable");
    //         }
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTriggerStatement x) {

    // }

    // override
    // public bool visit(OracleAlterSynonymStatement x) {
    //     print0(ucase ? "ALTER SYNONYM " : "alter synonym ");
    //     x.getName().accept(this);

    //     if (x.isCompile()) {
    //         print0(ucase ? " COMPILE" : " compile");
    //     }

    //     if (x.getEnable() !is null) {
    //         if (x.getEnable().booleanValue()) {
    //             print0(ucase ? "ENABLE" : "enable");
    //         } else {
    //             print0(ucase ? "DISABLE" : "disable");
    //         }
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterSynonymStatement x) {

    // }

    // override
    // public bool visit(OracleAlterViewStatement x) {
    //     print0(ucase ? "ALTER VIEW " : "alter view ");
    //     x.getName().accept(this);

    //     if (x.isCompile()) {
    //         print0(ucase ? " COMPILE" : " compile");
    //     }

    //     if (x.getEnable() !is null) {
    //         if (x.getEnable().booleanValue()) {
    //             print0(ucase ? "ENABLE" : "enable");
    //         } else {
    //             print0(ucase ? "DISABLE" : "disable");
    //         }
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterViewStatement x) {

    // }

    // override
    // public bool visit(OracleAlterTableMoveTablespace x) {
    //     print0(ucase ? " MOVE TABLESPACE " : " move tablespace ");
    //     x.getName().accept(this);
    //     return false;
    // }

    // override
    // public void endVisit(OracleAlterTableMoveTablespace x) {

    // }

    // public bool visit(OracleForeignKey x) {
    //     visit(cast(SQLForeignKeyImpl) x);
    //     return false;
    // }

    // override
    // public void endVisit(OracleForeignKey x) {

    // }

    // public bool visit(OracleUnique x) {
    //     visit(cast(SQLUnique) x);
    //     return false;
    // }

    // override
    // public void endVisit(OracleUnique x) {

    // }

    // public bool visit(OracleSelectSubqueryTableSource x) {
    //     print('(');
    //     this.indentCount++;
    //     println();
    //     x.getSelect().accept(this);
    //     this.indentCount--;
    //     println();
    //     print(')');

    //     if (x.getPivot() !is null) {
    //         println();
    //         x.getPivot().accept(this);
    //     }

    //     printFlashback(x.getFlashback());

    //     if ((x.getAlias() !is null) && (x.getAlias().length != 0)) {
    //         print(' ');
    //         print0(x.getAlias());
    //     }

    //     return false;
    // }

    // override
    // public bool visit(OracleSelectUnPivot x) {
    //     print0(ucase ? "UNPIVOT" : "unpivot");
    //     if (x.getNullsIncludeType() !is null) {
    //         print(' ');
    //         print0(OracleSelectUnPivot.NullsIncludeType.toString(x.getNullsIncludeType(), ucase));
    //     }

    //     print0(" (");
    //     if (x.getItems().size() == 1) {
    //         (cast(SQLExpr) x.getItems().get(0)).accept(this);
    //     } else {
    //         print0(" (");
    //         printAndAccept(x.getItems(), ", ");
    //         print(')');
    //     }

    //     if (x.getPivotFor().size() > 0) {
    //         print0(ucase ? " FOR " : " for ");
    //         if (x.getPivotFor().size() == 1) {
    //             (cast(SQLExpr) x.getPivotFor().get(0)).accept(this);
    //         } else {
    //             print('(');
    //             printAndAccept(x.getPivotFor(), ", ");
    //             print(')');
    //         }
    //     }

    //     if (x.getPivotIn().size() > 0) {
    //         print0(ucase ? " IN (" : " in (");
    //         printAndAccept(x.getPivotIn(), ", ");
    //         print(')');
    //     }

    //     print(')');
    //     return false;
    // }

    // override
    // public bool visit(OracleUpdateStatement x) {
    //     print0(ucase ? "UPDATE " : "update ");

    //     if (x.getHints().size() > 0) {
    //         printAndAccept(x.getHints(), ", ");
    //         print(' ');
    //     }

    //     if (x.isOnly()) {
    //         print0(ucase ? "ONLY (" : "only (");
    //         x.getTableSource().accept(this);
    //         print(')');
    //     } else {
    //         x.getTableSource().accept(this);
    //     }

    //     printAlias(x.getAlias());

    //     println();

    //     print0(ucase ? "SET " : "set ");
    //     for (int i = 0, size = x.getItems().size(); i < size; ++i) {
    //         if (i != 0) {
    //             print0(", ");
    //         }
    //         x.getItems().get(i).accept(this);
    //     }

    //     if (x.getWhere() !is null) {
    //         println();
    //         print0(ucase ? "WHERE " : "where ");
    //         this.indentCount++;
    //         x.getWhere().accept(this);
    //         this.indentCount--;
    //     }

    //     if (x.getReturning().size() > 0) {
    //         println();
    //         print0(ucase ? "RETURNING " : "returning ");
    //         printAndAccept(x.getReturning(), ", ");
    //         print0(ucase ? " INTO " : " into ");
    //         printAndAccept(x.getReturningInto(), ", ");
    //     }

    //     return false;
    // }

    // override
    // public bool visit(SampleClause x) {
    //     print0(ucase ? "SAMPLE " : "sample ");

    //     if (x.isBlock()) {
    //         print0(ucase ? "BLOCK " : "block ");
    //     }

    //     print('(');
    //     printAndAccept(x.getPercent(), ", ");
    //     print(')');

    //     if (x.getSeedValue() !is null) {
    //         print0(ucase ? " SEED (" : " seed (");
    //         x.getSeedValue().accept(this);
    //         print(')');
    //     }

    //     return false;
    // }

    // override
    // public void endVisit(SampleClause x) {

    // }

    // public bool visit(OracleSelectJoin x) {
    //     x.getLeft().accept(this);
    //     SQLTableSource right = x.getRight();

    //     if (x.getJoinType() == SQLJoinTableSource.JoinType.COMMA) {
    //         print0(", ");
    //         x.getRight().accept(this);
    //     } else {
    //         bool isRoot = cast(SQLSelectQueryBlock)x.getParent() !is null;
    //         if (isRoot) {
    //             this.indentCount++;
    //         }

    //         println();
    //         print0(ucase ? x.getJoinType().name : x.getJoinType().name_lcase);
    //         print(' ');

    //         if (cast(SQLJoinTableSource)(right) !is null) {
    //             print('(');
    //             right.accept(this);
    //             print(')');
    //         } else {
    //             right.accept(this);
    //         }

    //         if (isRoot) {
    //             this.indentCount--;
    //         }

    //         if (x.getCondition() !is null) {
    //             print0(ucase ? " ON " : " on ");
    //             x.getCondition().accept(this);
    //             print(' ');
    //         }

    //         if (x.getUsing().size() > 0) {
    //             print0(ucase ? " USING (" : " using (");
    //             printAndAccept(x.getUsing(), ", ");
    //             print(')');
    //         }

    //         printFlashback(x.getFlashback());
    //     }

    //     return false;
    // }

    // override
    // public bool visit(OracleSelectPivot x) {
    //     print0(ucase ? "PIVOT" : "pivot");
    //     if (x.isXml()) {
    //         print0(ucase ? " XML" : " xml");
    //     }
    //     print0(" (");
    //     printAndAccept(x.getItems(), ", ");

    //     if (x.getPivotFor().size() > 0) {
    //         print0(ucase ? " FOR " : " for ");
    //         if (x.getPivotFor().size() == 1) {
    //             (cast(SQLExpr) x.getPivotFor().get(0)).accept(this);
    //         } else {
    //             print('(');
    //             printAndAccept(x.getPivotFor(), ", ");
    //             print(')');
    //         }
    //     }

    //     if (x.getPivotIn().size() > 0) {
    //         print0(ucase ? " IN (" : " in (");
    //         printAndAccept(x.getPivotIn(), ", ");
    //         print(')');
    //     }

    //     print(')');

    //     return false;
    // }

    // override
    // public bool visit(OracleSelectPivot.Item x) {
    //     x.getExpr().accept(this);
    //     if ((x.getAlias() !is null) && (x.getAlias().length > 0)) {
    //         print0(ucase ? " AS " : " as ");
    //         print0(x.getAlias());
    //     }
    //     return false;
    // }

    // override
    // public bool visit(OracleSelectRestriction.CheckOption x) {
    //     print0(ucase ? "CHECK OPTION" : "check option");
    //     if (x.getConstraint() !is null) {
    //         print(' ');
    //         x.getConstraint().accept(this);
    //     }
    //     return false;
    // }

    // override
    // public bool visit(OracleSelectRestriction.ReadOnly x) {
    //     print0(ucase ? "READ ONLY" : "read only");
    //     return false;
    // }

    // public bool visit(OracleDbLinkExpr x) {
    //     SQLExpr expr = x.getExpr();
    //     if (expr !is null) {
    //         expr.accept(this);
    //         print('@');
    //     }
    //     print0(x.getDbLink());
    //     return false;
    // }

    // override
    // public void endVisit(OracleAnalytic x) {

    // }

    // override
    // public void endVisit(OracleAnalyticWindowing x) {

    // }

    // public void endVisit(OracleDbLinkExpr x) {

    // }

    // override
    // public void endVisit(OracleDeleteStatement x) {

    // }

    // override
    // public void endVisit(OracleIntervalExpr x) {

    // }

    // override
    // public void endVisit(OracleOuterExpr x) {

    // }

    // override
    // public void endVisit(OracleSelectJoin x) {

    // }

    // override
    // public void endVisit(OracleSelectPivot x) {

    // }

    // override
    // public void endVisit(OracleSelectPivot.Item x) {

    // }

    // override
    // public void endVisit(OracleSelectRestriction.CheckOption x) {

    // }

    // override
    // public void endVisit(OracleSelectRestriction.ReadOnly x) {

    // }

    // override
    // public void endVisit(OracleSelectSubqueryTableSource x) {

    // }

    // override
    // public void endVisit(OracleSelectUnPivot x) {

    // }

    // override
    // public void endVisit(OracleUpdateStatement x) {

    // }

    // public bool visit(OracleDeleteStatement x) {
    //     return visit(cast(SQLDeleteStatement) x);
    // }

    private void printFlashback(SQLExpr flashback) {
        if (flashback is null) {
            return;
        }

        println();

        if (cast(SQLBetweenExpr)(flashback) !is null) {
            flashback.accept(this);
        } else {
            print0(ucase ? "AS OF " : "as of ");
            flashback.accept(this);
        }
    }

    // public bool visit(OracleWithSubqueryEntry x) {
    //     print0(x.getAlias());

    //     if (x.getColumns().size() > 0) {
    //         print0(" (");
    //         printAndAccept(x.getColumns(), ", ");
    //         print(')');
    //     }

    //     print0(ucase ? " AS " : " as ");
    //     print('(');
    //     this.indentCount++;
    //     println();
    //     x.getSubQuery().accept(this);
    //     this.indentCount--;
    //     println();
    //     print(')');

    //     if (x.getSearchClause() !is null) {
    //         println();
    //         x.getSearchClause().accept(this);
    //     }

    //     if (x.getCycleClause() !is null) {
    //         println();
    //         x.getCycleClause().accept(this);
    //     }
    //     return false;
    // }

    // override
    // public void endVisit(OracleWithSubqueryEntry x) {

    // }

    // override
    // public bool visit(SearchClause x) {
    //     print0(ucase ? "SEARCH " : "search ");
    //     print0(x.getType().name());
    //     print0(ucase ? " FIRST BY " : " first by ");
    //     printAndAccept(x.getItems(), ", ");
    //     print0(ucase ? " SET " : " set ");
    //     x.getOrderingColumn().accept(this);

    //     return false;
    // }

    // override
    // public void endVisit(SearchClause x) {

    // }

    // override
    // public bool visit(CycleClause x) {
    //     print0(ucase ? "CYCLE " : "cycle ");
    //     printAndAccept(x.getAliases(), ", ");
    //     print0(ucase ? " SET " : " set ");
    //     x.getMark().accept(this);
    //     print0(ucase ? " TO " : " to ");
    //     x.getValue().accept(this);
    //     print0(ucase ? " DEFAULT " : " default ");
    //     x.getDefaultValue().accept(this);

    //     return false;
    // }

    // override
    // public void endVisit(CycleClause x) {

    // }

    // public bool visit(OracleAnalytic x) {
    //     print0(ucase ? "OVER (" : "over (");

    //     bool space = false;
    //     if (x.getPartitionBy().size() > 0) {
    //         print0(ucase ? "PARTITION BY " : "partition by ");
    //         printAndAccept(x.getPartitionBy(), ", ");

    //         space = true;
    //     }

    //     SQLOrderBy orderBy = x.getOrderBy();
    //     if (orderBy !is null) {
    //         if (space) {
    //             print(' ');
    //         }
    //         visit(orderBy);
    //         space = true;
    //     }

    //     OracleAnalyticWindowing windowing = x.getWindowing();
    //     if (windowing !is null) {
    //         if (space) {
    //             print(' ');
    //         }
    //         visit(windowing);
    //     }

    //     print(')');

    //     return false;
    // }

    // public bool visit(OracleAnalyticWindowing x) {
    //     print0(x.getType().name().toUpperCase());
    //     print(' ');
    //     x.getExpr().accept(this);
    //     return false;
    // }

    // override
    // public bool visit(OracleIsOfTypeExpr x) {
    //     printExpr(x.getExpr());
    //     print0(ucase ? " IS OF TYPE (" : " is of type (");

    //     List!(SQLExpr) types = x.getTypes();
    //     for (int i = 0, size = types.size(); i < size; ++i) {
    //         if (i != 0) {
    //             print0(", ");
    //         }
    //         SQLExpr type = types.get(i);
    //         if (Boolean.TRUE == type.getAttribute("ONLY")) {
    //             print0(ucase ? "ONLY " : "only ");
    //         }
    //         type.accept(this);
    //     }

    //     print(')');
    //     return false;
    // }

    // public void endVisit(OracleIsOfTypeExpr x) {

    // }

    // override
    // public bool visit(OracleRunStatement x) {
    //     print0("@@");
    //     printExpr(x.getExpr());
    //     return false;
    // }

    // override
    // public void endVisit(OracleRunStatement x) {

    // }

    override
    public bool visit(SQLIfStatement.Else x) {
        print0(ucase ? "ELSE" : "else");
        this.indentCount++;
        println();

        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            if (i != 0) {
                println();
            }
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
        }

        this.indentCount--;
        return false;
    }

    override
    public bool visit(SQLIfStatement.ElseIf x) {
        print0(ucase ? "ELSE IF " : "else if ");
        x.getCondition().accept(this);
        print0(ucase ? " THEN" : " then");
        this.indentCount++;

        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            println();
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
        }

        this.indentCount--;
        return false;
    }

    override
    public bool visit(SQLIfStatement x) {
        print0(ucase ? "IF " : "if ");
        int lines = this.lines;
        this.indentCount++;
        x.getCondition().accept(this);
        this.indentCount--;

        if (lines != this.lines) {
            println();
        } else {
            print(' ');
        }
        print0(ucase ? "THEN" : "then");

        this.indentCount++;
        for (int i = 0, size = x.getStatements().size(); i < size; ++i) {
            println();
            SQLStatement item = x.getStatements().get(i);
            item.accept(this);
        }
        this.indentCount--;

        foreach(SQLIfStatement.ElseIf elseIf ; x.getElseIfList()) {
            println();
            elseIf.accept(this);
        }

        if (x.getElseItem() !is null) {
            println();
            x.getElseItem().accept(this);
        }
        println();
        print0(ucase ? "END IF" : "end if");
        return false;
    }

    override
    public bool visit(SQLCreateIndexStatement x) {
        print0(ucase ? "CREATE " : "create ");
        if (x.getType() !is null) {
            print0(x.getType());
            print(' ');
        }

        print0(ucase ? "INDEX " : "index ");

        x.getName().accept(this);

        if (x.getUsing() !is null) {
            print0(ucase ? " USING " : " using ");
            print0(x.getUsing());
        }

        print0(ucase ? " ON " : " on ");
        x.getTable().accept(this);
        print0(" (");
        printAndAccept!SQLSelectOrderByItem((x.getItems()), ", ");
        print(')');

        SQLExpr comment = x.getComment();
        if (comment !is null) {
            print0(ucase ? " COMMENT " : " comment ");
            comment.accept(this);
        }

        return false;
    }

    override
    public bool visit(SQLAlterTableAddColumn x) {
        bool odps = isOdps();
        print0(ucase ? "ADD COLUMN " : "add column ");
        printAndAccept!SQLColumnDefinition((x.getColumns()), ", ");
        return false;
    }

    override protected void visitAggreateRest(SQLAggregateExpr x) {
        SQLOrderBy orderBy = x.getWithinGroup();
        if (orderBy !is null) {
            print(' ');
            orderBy.accept(this);
        }
    }

    override protected void print0(Bytes data) {
        string s = format("E'%(\\\\%03o%)'", data.value());
        print0(s);
    }

    alias print0 = SQLASTOutputVisitor.print0;
}
