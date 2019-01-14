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
module hunt.sql.dialect.mysql.parser.MySqlExprParser;

import hunt.sql.ast;
import hunt.sql.ast.expr.SQLAggregateExpr;
import hunt.sql.ast.expr.SQLBinaryOpExpr;
import hunt.sql.ast.expr.SQLBinaryOperator;
import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.ast.expr.SQLHexExpr;
import hunt.sql.ast.expr.SQLIdentifierExpr;
import hunt.sql.ast.expr.SQLMethodInvokeExpr;
import hunt.sql.ast.expr.SQLUnaryExpr;
import hunt.sql.ast.expr.SQLUnaryOperator;
import hunt.sql.ast.expr.SQLVariantRefExpr;
import hunt.sql.ast.statement.SQLAssignItem;
import hunt.sql.ast.statement.SQLColumnDefinition;
import hunt.sql.ast.statement.SQLForeignKeyImpl;
import hunt.sql.dialect.mysql.ast.MySqlPrimaryKey;
import hunt.sql.dialect.mysql.ast.MySqlUnique;
import hunt.sql.dialect.mysql.ast.MysqlForeignKey;
import hunt.sql.ast.statement.SQLForeignKeyImpl;
import hunt.sql.dialect.mysql.ast.expr.MySqlCharExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlExtractExpr;
import hunt.sql.ast.expr.SQLIntervalExpr;
import hunt.sql.ast.expr.SQLIntervalUnit;
import hunt.sql.dialect.mysql.ast.expr.MySqlMatchAgainstExpr;
// import hunt.sql.dialect.mysql.ast.expr.MySqlMatchAgainstExpr.SearchModifier;
import hunt.sql.dialect.mysql.ast.expr.MySqlOrderingExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlOutFileExpr;
import hunt.sql.dialect.mysql.ast.expr.MySqlUserName;
import hunt.sql.parser;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.dialect.mysql.parser.MySqlLexer;
import hunt.String;
import std.string;
import hunt.sql.util.Utils;
import hunt.sql.util.MyString;
import hunt.sql.dialect.mysql.parser.MySqlSelectParser;
import hunt.text;

public class MySqlExprParser : SQLExprParser {
    public  static string[] AGGREGATE_FUNCTIONS;

    public  static long[] AGGREGATE_FUNCTIONS_CODES;

    // static this() {
    //     string[] strings = [ "AVG", "COUNT", "GROUP_CONCAT", "MAX", "MIN", "STDDEV", "SUM" ];
    //     AGGREGATE_FUNCTIONS_CODES = FnvHash.fnv1a_64_lower(strings, true);
    //     AGGREGATE_FUNCTIONS = new string[AGGREGATE_FUNCTIONS_CODES.length];
    //     foreach(string str ; strings) {
    //         long hash = FnvHash.fnv1a_64_lower(str);
    //         int index = search(AGGREGATE_FUNCTIONS_CODES, hash);
    //         AGGREGATE_FUNCTIONS[index] = str;
    //     }
    // }

    public this(Lexer lexer){
        super(lexer, DBType.MYSQL.name);
        this.aggregateFunctions = AGGREGATE_FUNCTIONS;
        this.aggregateFunctionHashCodes = AGGREGATE_FUNCTIONS_CODES;
    }

    public this(string sql){
        this(new MySqlLexer(sql));
        this.lexer.nextToken();
        import std.stdio;
    }

    public this(string sql, SQLParserFeature[] features...){
        super(new MySqlLexer(sql, features), DBType.MYSQL.name);
        this.aggregateFunctions = AGGREGATE_FUNCTIONS;
        this.aggregateFunctionHashCodes = AGGREGATE_FUNCTIONS_CODES;
        if (sql.length > 6) {
            char c0 = charAt(sql, 0);
            char c1 = charAt(sql, 1);
            char c2 = charAt(sql, 2);
            char c3 = charAt(sql, 3);
            char c4 = charAt(sql, 4);
            char c5 = charAt(sql, 5);
            char c6 = charAt(sql, 6);

            if (c0 == 'S' && c1 == 'E' && c2 == 'L' && c3 == 'E' && c4 == 'C' && c5 == 'T' && c6 == ' ') {
                lexer.reset(6, ' ', Token.SELECT);
                return;
            }

            if (c0 == 's' && c1 == 'e' && c2 == 'l' && c3 == 'e' && c4 == 'c' && c5 == 't' && c6 == ' ') {
                lexer.reset(6, ' ', Token.SELECT);
                return;
            }

            if (c0 == 'I' && c1 == 'N' && c2 == 'S' && c3 == 'E' && c4 == 'R' && c5 == 'T' && c6 == ' ') {
                lexer.reset(6, ' ', Token.INSERT);
                return;
            }

            if (c0 == 'i' && c1 == 'n' && c2 == 's' && c3 == 'e' && c4 == 'r' && c5 == 't' && c6 == ' ') {
                lexer.reset(6, ' ', Token.INSERT);
                return;
            }

            if (c0 == 'U' && c1 == 'P' && c2 == 'D' && c3 == 'A' && c4 == 'T' && c5 == 'E' && c6 == ' ') {
                lexer.reset(6, ' ', Token.UPDATE);
                return;
            }

            if (c0 == 'u' && c1 == 'p' && c2 == 'd' && c3 == 'a' && c4 == 't' && c5 == 'e' && c6 == ' ') {
                lexer.reset(6, ' ', Token.UPDATE);
                return;
            }

            if (c0 == '/' && c1 == '*' && isEnabled(SQLParserFeature.OptimizedForParameterized)) {
                MySqlLexer mySqlLexer = cast(MySqlLexer) lexer;
                mySqlLexer.skipFirstHintsOrMultiCommentAndNextToken();
                return;
            }
        }
        this.lexer.nextToken();

    }

    public this(string sql, bool keepComments){
        this(new MySqlLexer(sql, true, keepComments));
        this.lexer.nextToken();
    }


    public this(string sql, bool skipComment,bool keepComments){
        this(new MySqlLexer(sql, skipComment, keepComments));
        this.lexer.nextToken();
    }

    override public SQLExpr primary() {
         Token tok = lexer.token();

        if (lexer.identifierEquals(FnvHash.Constants.OUTFILE)) {
            lexer.nextToken();
            SQLExpr file = primary();
            SQLExpr expr = new MySqlOutFileExpr(file);

            return primaryRest(expr);

        }

        switch (tok) {
            case Token.VARIANT:
                SQLVariantRefExpr varRefExpr = new SQLVariantRefExpr(lexer.stringVal());
                lexer.nextToken();
                if (varRefExpr.getName().equalsIgnoreCase("@@global")) {
                    accept(Token.DOT);
                    varRefExpr = new SQLVariantRefExpr(lexer.stringVal(), true);
                    lexer.nextToken();
                } else if (varRefExpr.getName() == "@" && lexer.token() == Token.LITERAL_CHARS) {
                    varRefExpr.setName("@'" ~ lexer.stringVal() ~ "'");
                    lexer.nextToken();
                } else if (varRefExpr.getName() == "@@" && lexer.token() == Token.LITERAL_CHARS) {
                    varRefExpr.setName("@@'" ~ lexer.stringVal() ~ "'");
                    lexer.nextToken();
                }
                return primaryRest(varRefExpr);
            case Token.VALUES:
                lexer.nextToken();
                if (lexer.token() != Token.LPAREN) {
                    throw new ParserException("syntax error, illegal values clause. " ~ lexer.info());
                }
                return this.methodRest(new SQLIdentifierExpr("VALUES"), true);
            case Token.BINARY:
                lexer.nextToken();
                if (lexer.token() == Token.COMMA || lexer.token() == Token.SEMI || lexer.token() == Token.EOF) {
                    return new SQLIdentifierExpr("BINARY");
                } else {
                    SQLUnaryExpr binaryExpr = new SQLUnaryExpr(SQLUnaryOperator.BINARY, expr());
                    return primaryRest(binaryExpr);
                }
            default:
                return super.primary();
        }

    }

    override public  SQLExpr primaryRest(SQLExpr expr) {
        if (expr is null) {
            throw new Exception("expr");
        }

        if (lexer.token() == Token.LITERAL_CHARS) {
            if (cast(SQLIdentifierExpr)(expr) !is null) {
                SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) expr;
                string ident = identExpr.getName();

                if (equalsIgnoreCase(ident, "x")) {
                    string charValue = lexer.stringVal();
                    lexer.nextToken();
                    expr = new SQLHexExpr(charValue);

                    return primaryRest(expr);
//                } else if (equalsIgnoreCase(ident, "b")) {
//                    string charValue = lexer.stringVal();
//                    lexer.nextToken();
//                    expr = new SQLBinaryExpr(charValue);
//
//                    return primaryRest(expr);
                } else if (ident.startsWith("_")) {
                    string charValue = lexer.stringVal();
                    lexer.nextToken();

                    MySqlCharExpr mysqlCharExpr = new MySqlCharExpr(charValue);
                    mysqlCharExpr.setCharset(identExpr.getName());
                    if (lexer.identifierEquals(FnvHash.Constants.COLLATE)) {
                        lexer.nextToken();

                        string collate = lexer.stringVal();
                        mysqlCharExpr.setCollate(collate);
                        accept(Token.IDENTIFIER);
                    }

                    expr = mysqlCharExpr;

                    return primaryRest(expr);
                }
            } else if (cast(SQLCharExpr)(expr) !is null) {
                string text2 = (cast(SQLCharExpr) expr).getText.str();
                do {
                    string chars = lexer.stringVal();
                    text2 ~= chars;
                    lexer.nextToken();
                } while (lexer.token() == Token.LITERAL_CHARS || lexer.token() == Token.LITERAL_ALIAS);
                expr = new SQLCharExpr(text2);
            } else if (cast(SQLVariantRefExpr)(expr) !is null) {
                SQLMethodInvokeExpr concat = new SQLMethodInvokeExpr("CONCAT");
                concat.addArgument(expr);
                concat.addArgument(this.primary());
                expr = concat;

                return primaryRest(expr);
            }
        } else if (lexer.token() == Token.IDENTIFIER) {
            if (cast(SQLHexExpr)(expr) !is null) {
                if ("USING".equalsIgnoreCase(lexer.stringVal())) {
                    lexer.nextToken();
                    if (lexer.token() != Token.IDENTIFIER) {
                        throw new ParserException("syntax error, illegal hex. " ~ lexer.info());
                    }
                    string charSet = lexer.stringVal();
                    lexer.nextToken();
                    expr.getAttributes().put("USING", new MyString(charSet));

                    return primaryRest(expr);
                }
            } else if (lexer.identifierEquals(FnvHash.Constants.COLLATE)) {
                lexer.nextToken();

                if (lexer.token() == Token.EQ) {
                    lexer.nextToken();
                }

                if (lexer.token() != Token.IDENTIFIER
                        && lexer.token() != Token.LITERAL_CHARS) {
                    throw new ParserException("syntax error. " ~ lexer.info());
                }

                string collate = lexer.stringVal();
                lexer.nextToken();

                SQLBinaryOpExpr binaryExpr = new SQLBinaryOpExpr(expr, SQLBinaryOperator.COLLATE,
                                                                 new SQLIdentifierExpr(collate), DBType.MYSQL.name);

                expr = binaryExpr;

                return primaryRest(expr);
            } else if (cast(SQLVariantRefExpr)(expr) !is null) {
                if (lexer.identifierEquals(FnvHash.Constants.COLLATE)) {
                    lexer.nextToken();

                    if (lexer.token() != Token.IDENTIFIER
                            && lexer.token() != Token.LITERAL_CHARS) {
                        throw new ParserException("syntax error. " ~ lexer.info());
                    }

                    string collate = lexer.stringVal();
                    lexer.nextToken();

                    expr.putAttribute("COLLATE", new MyString(collate));

                    return primaryRest(expr);
                }
            }
        }

//        if (lexer.token() == Token.LPAREN && cast(SQLIdentifierExpr)(expr) !is null) {
//            SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) expr;
//            string ident = identExpr.getName();
//
//            if ("POSITION".equalsIgnoreCase(ident)) {
//                return parsePosition();
//            }
//        }

        if (lexer.token() == Token.VARIANT && "@" == lexer.stringVal()) {
            return userNameRest(expr);
        }

        if (lexer.token() == Token.ERROR) {
            throw new ParserException("syntax error. " ~ lexer.info());
        }

        return super.primaryRest(expr);
    }

    public SQLName userName() {
        SQLName name = this.name();
        if (lexer.token() == Token.LPAREN && name.hashCode64() == FnvHash.Constants.CURRENT_USER) {
            lexer.nextToken();
            accept(Token.RPAREN);
            return name;
        }

        return cast(SQLName) userNameRest(name);
    }

    private SQLExpr userNameRest(SQLExpr expr) {
        if (lexer.token() != Token.VARIANT || !lexer.stringVal().startsWith("@")) {
            return expr;
        }

        MySqlUserName userName = new MySqlUserName();
        if (cast(SQLCharExpr)(expr) !is null) {
            userName.setUserName((cast(SQLCharExpr) expr).toString());
        } else {
            userName.setUserName((cast(SQLIdentifierExpr) expr).getName());
        }


        string strVal = lexer.stringVal();
        lexer.nextToken();

        if (strVal.length > 1) {
            userName.setHost(strVal.substring(1));
            return userName;
        }

        if (lexer.token() == Token.LITERAL_CHARS) {
            userName.setHost("'" ~ lexer.stringVal() ~ "'");
        } else {
            userName.setHost(lexer.stringVal());
        }
        lexer.nextToken();

        if (lexer.token() == Token.IDENTIFIED) {
            Lexer.SavePoint mark = lexer.mark();

            lexer.nextToken();
            if (lexer.token() == Token.BY) {
                lexer.nextToken();
                if (lexer.identifierEquals(FnvHash.Constants.PASSWORD)) {
                    lexer.reset(mark);
                } else {
                    userName.setIdentifiedBy(lexer.stringVal());
                    lexer.nextToken();
                }
            } else {
                lexer.reset(mark);
            }
        }

        return userName;
    }

    override protected SQLExpr parsePosition() {

        SQLExpr subStr = this.primary();
        accept(Token.IN);
        SQLExpr str = this.expr();
        accept(Token.RPAREN);

        SQLMethodInvokeExpr locate = new SQLMethodInvokeExpr("LOCATE");
        locate.addParameter(subStr);
        locate.addParameter(str);

        return primaryRest(locate);
    }

    override protected SQLExpr parseExtract() {
        SQLExpr _expr;
        if (lexer.token() != Token.IDENTIFIER) {
            throw new ParserException("syntax error. " ~ lexer.info());
        }

        string unitVal = lexer.stringVal();
        SQLIntervalUnit unit = SQLIntervalUnit(toUpper(unitVal));
        lexer.nextToken();

        accept(Token.FROM);

        SQLExpr value = expr();

        MySqlExtractExpr extract = new MySqlExtractExpr();
        extract.setValue(value);
        extract.setUnit(unit);
        accept(Token.RPAREN);

        _expr = extract;

        return primaryRest(_expr);
    }

    override protected SQLExpr parseMatch() {

        MySqlMatchAgainstExpr matchAgainstExpr = new MySqlMatchAgainstExpr();

        if (lexer.token() == Token.RPAREN) {
            lexer.nextToken();
        } else {
            exprList(matchAgainstExpr.getColumns(), matchAgainstExpr);
            accept(Token.RPAREN);
        }

        acceptIdentifier("AGAINST");

        accept(Token.LPAREN);
        SQLExpr against = primary();
        matchAgainstExpr.setAgainst(against);

        if (lexer.token() == Token.IN) {
            lexer.nextToken();
            if (lexer.identifierEquals(FnvHash.Constants.NATURAL)) {
                lexer.nextToken();
                acceptIdentifier("LANGUAGE");
                acceptIdentifier("MODE");
                if (lexer.token() == Token.WITH) {
                    lexer.nextToken();
                    acceptIdentifier("QUERY");
                    acceptIdentifier("EXPANSION");
                    matchAgainstExpr.setSearchModifier(MySqlMatchAgainstExpr.SearchModifier.IN_NATURAL_LANGUAGE_MODE_WITH_QUERY_EXPANSION);
                } else {
                    matchAgainstExpr.setSearchModifier(MySqlMatchAgainstExpr.SearchModifier.IN_NATURAL_LANGUAGE_MODE);
                }
            } else if (lexer.identifierEquals(FnvHash.Constants.BOOLEAN)) {
                lexer.nextToken();
                acceptIdentifier("MODE");
                matchAgainstExpr.setSearchModifier(MySqlMatchAgainstExpr.SearchModifier.IN_BOOLEAN_MODE);
            } else {
                throw new ParserException("syntax error. " ~ lexer.info());
            }
        } else if (lexer.token() == Token.WITH) {
            throw new ParserException("TODO. " ~ lexer.info());
        }

        accept(Token.RPAREN);

        return primaryRest(matchAgainstExpr);
    }

    override public SQLSelectParser createSelectParser() {
        return new MySqlSelectParser(this);
    }

    override protected SQLExpr parseInterval() {
        accept(Token.INTERVAL);

        if (lexer.token() == Token.LPAREN) {
            lexer.nextToken();

            SQLMethodInvokeExpr methodInvokeExpr = new SQLMethodInvokeExpr("INTERVAL");
            if (lexer.token() != Token.RPAREN) {
                exprList(methodInvokeExpr.getParameters(), methodInvokeExpr);
            }

            accept(Token.RPAREN);
            
            // 
            
            if (methodInvokeExpr.getParameters().size() == 1 // 
                    && lexer.token() == Token.IDENTIFIER) {
                SQLExpr value = methodInvokeExpr.getParameters().get(0);
                string unit = lexer.stringVal();
                lexer.nextToken();
                
                SQLIntervalExpr intervalExpr = new SQLIntervalExpr();
                intervalExpr.setValue(value);
                intervalExpr.setUnit(SQLIntervalUnit(toUpper(unit)));
                return intervalExpr;
            } else {
                return primaryRest(methodInvokeExpr);
            }
        } else {
            SQLExpr value = expr();

            if (lexer.token() != Token.IDENTIFIER) {
                throw new ParserException("Syntax error. " ~ lexer.info());
            }

            string unit = lexer.stringVal();
            lexer.nextToken();

            SQLIntervalExpr intervalExpr = new SQLIntervalExpr();
            intervalExpr.setValue(value);
            intervalExpr.setUnit(SQLIntervalUnit(toUpper(unit)));

            return intervalExpr;
        }
    }

    override public SQLColumnDefinition parseColumn() {
        SQLColumnDefinition column = new SQLColumnDefinition();
        column.setDbType(dbType);
        column.setName(name());
        column.setDataType(parseDataType());

        return parseColumnRest(column);
    }

    override public SQLColumnDefinition parseColumnRest(SQLColumnDefinition column) {
        if (lexer.token() == Token.ON) {
            lexer.nextToken();
            accept(Token.UPDATE);
            SQLExpr expr = this.expr();
            column.setOnUpdate(expr);
        }

        if (lexer.identifierEquals(FnvHash.Constants.CHARACTER)) {
            lexer.nextToken();
            accept(Token.SET);
            MySqlCharExpr charSetCollateExpr=new MySqlCharExpr();
            charSetCollateExpr.setCharset(lexer.stringVal());
            lexer.nextToken();
            if (lexer.identifierEquals(FnvHash.Constants.COLLATE)) {
                lexer.nextToken();
                charSetCollateExpr.setCollate(lexer.stringVal());
                lexer.nextToken();
            }
            column.setCharsetExpr(charSetCollateExpr);
            return parseColumnRest(column);
        }

        if (lexer.identifierEquals(FnvHash.Constants.CHARSET)) {
            lexer.nextToken();
            MySqlCharExpr charSetCollateExpr=new MySqlCharExpr();
            charSetCollateExpr.setCharset(lexer.stringVal());
            lexer.nextToken();
            if (lexer.identifierEquals(FnvHash.Constants.COLLATE)) {
                lexer.nextToken();
                charSetCollateExpr.setCollate(lexer.stringVal());
                lexer.nextToken();
            }
            column.setCharsetExpr(charSetCollateExpr);
            return parseColumnRest(column);
        }
        if (lexer.identifierEquals(FnvHash.Constants.AUTO_INCREMENT)) {
            lexer.nextToken();
            column.setAutoIncrement(true);
            return parseColumnRest(column);
        }

        if (lexer.identifierEquals(FnvHash.Constants.PRECISION)
                && column.getDataType().nameHashCode64() ==FnvHash.Constants.DOUBLE) {
            lexer.nextToken();
        }

        if (lexer.token() == Token.PARTITION) {
            throw new ParserException("syntax error " ~ lexer.info());
        }

        if (lexer.identifierEquals(FnvHash.Constants.STORAGE)) {
            lexer.nextToken();
            SQLExpr expr = expr();
            column.setStorage(expr);
        }
        
        if (lexer.token() == Token.AS) {
            lexer.nextToken();
            accept(Token.LPAREN);
            SQLExpr expr = expr();
            column.setAsExpr(expr);
            accept(Token.RPAREN);
        }
        
        if (lexer.identifierEquals(FnvHash.Constants.STORED)) {
            lexer.nextToken();
            column.setSorted(true);
        }
        
        if (lexer.identifierEquals(FnvHash.Constants.VIRTUAL)) {
            lexer.nextToken();
            column.setVirtual(true);
        }

        super.parseColumnRest(column);

        return column;
    }

    override protected SQLDataType parseDataTypeRest(SQLDataType dataType) {
        super.parseDataTypeRest(dataType);

        for (;;) {
            if (lexer.identifierEquals(FnvHash.Constants.UNSIGNED)) {
                lexer.nextToken();
                (cast(SQLDataTypeImpl) dataType).setUnsigned(true);
            } else if (lexer.identifierEquals(FnvHash.Constants.ZEROFILL)) {
                lexer.nextToken();
                (cast(SQLDataTypeImpl) dataType).setZerofill(true);
            } else {
                break;
            }
        }

        return dataType;
    }

    override public SQLAssignItem parseAssignItem() {
        SQLAssignItem item = new SQLAssignItem();

        SQLExpr var = primary();

        string ident = null;
        long identHash = 0;
        if (cast(SQLIdentifierExpr)(var) !is null) {
            SQLIdentifierExpr identExpr = cast(SQLIdentifierExpr) var;
            ident = identExpr.getName();
            identHash = identExpr.hashCode64();

            if (identHash == FnvHash.Constants.GLOBAL) {
                ident = lexer.stringVal();
                lexer.nextToken();
                var = new SQLVariantRefExpr(ident, true);
            } else if (identHash == FnvHash.Constants.SESSION) {
                ident = lexer.stringVal();
                lexer.nextToken();
                var = new SQLVariantRefExpr(ident, false, true);
            } else {
                var = new SQLVariantRefExpr(ident);
            }
        }

        if (identHash == FnvHash.Constants.NAMES) {
            string charset = lexer.stringVal();

            SQLExpr varExpr = null;
            bool chars = false;
             Token token = lexer.token();
            if (token == Token.IDENTIFIER) {
                lexer.nextToken();
            } else if (token == Token.DEFAULT) {
                charset = "DEFAULT";
                lexer.nextToken();
            } else if (token == Token.QUES) {
                varExpr = new SQLVariantRefExpr("?");
                lexer.nextToken();
            } else {
                chars = true;
                accept(Token.LITERAL_CHARS);
            }

            if (lexer.identifierEquals(FnvHash.Constants.COLLATE)) {
                MySqlCharExpr charsetExpr = new MySqlCharExpr(charset);
                lexer.nextToken();

                string collate = lexer.stringVal();
                lexer.nextToken();
                charsetExpr.setCollate(collate);

                item.setValue(charsetExpr);
            } else {
                if (varExpr !is null) {
                    item.setValue(varExpr);
                } else {
                    item.setValue(chars
                            ? new SQLCharExpr(charset)
                            : new SQLIdentifierExpr(charset)
                    );
                }
            }

            item.setTarget(var);
            return item;
        } else if (identHash == FnvHash.Constants.CHARACTER) {
            var = new SQLIdentifierExpr("CHARACTER SET");
            accept(Token.SET);
            if (lexer.token() == Token.EQ) {
                lexer.nextToken();
            }
        } else {
            if (lexer.token() == Token.COLONEQ) {
                lexer.nextToken();
            } else {
                accept(Token.EQ);
            }
        }

        if (lexer.token() == Token.ON) {
            lexer.nextToken();
            item.setValue(new SQLIdentifierExpr("ON"));
        } else {
            item.setValue(this.expr());
        }

        item.setTarget(var);
        return item;
    }

    override public SQLName nameRest(SQLName name) {
        if (lexer.token() == Token.VARIANT && "@" == lexer.stringVal()) {
            lexer.nextToken();
            MySqlUserName userName = new MySqlUserName();
            userName.setUserName((cast(SQLIdentifierExpr) name).getName());

            if (lexer.token() == Token.LITERAL_CHARS) {
                userName.setHost("'" ~ lexer.stringVal() ~ "'");
            } else {
                userName.setHost(lexer.stringVal());
            }
            lexer.nextToken();

            if (lexer.token() == Token.IDENTIFIED) {
                lexer.nextToken();
                accept(Token.BY);
                userName.setIdentifiedBy(lexer.stringVal());
                lexer.nextToken();
            }

            return userName;
        }
        return super.nameRest(name);
    }

    override
    public MySqlPrimaryKey parsePrimaryKey() {
        accept(Token.PRIMARY);
        accept(Token.KEY);

        MySqlPrimaryKey primaryKey = new MySqlPrimaryKey();

        if (lexer.identifierEquals(FnvHash.Constants.USING)) {
            lexer.nextToken();
            primaryKey.setIndexType(lexer.stringVal());
            lexer.nextToken();
        }

        if (lexer.token() != Token.LPAREN) {
            SQLName name = this.name();
            primaryKey.setName(name);
        }

        accept(Token.LPAREN);
        for (;;) {
            SQLExpr expr;
            if (lexer.token() == Token.LITERAL_ALIAS) {
                expr = this.name();
            } else {
                expr = this.expr();
            }
            primaryKey.addColumn(expr);
            if (!(lexer.token() == (Token.COMMA))) {
                break;
            } else {
                lexer.nextToken();
            }
        }
        accept(Token.RPAREN);

        if (lexer.identifierEquals(FnvHash.Constants.USING)) {
            lexer.nextToken();
            primaryKey.setIndexType(lexer.stringVal());
            lexer.nextToken();
        }

        return primaryKey;
    }

    override public MySqlUnique parseUnique() {
        accept(Token.UNIQUE);

        if (lexer.token() == Token.KEY) {
            lexer.nextToken();
        }

        if (lexer.token() == Token.INDEX) {
            lexer.nextToken();
        }

        MySqlUnique unique = new MySqlUnique();

        if (lexer.token() != Token.LPAREN) {
            SQLName indexName = name();
            unique.setName(indexName);
        }
        
        //5.5语法 USING BTREE 放在index 名字后
        if (lexer.identifierEquals(FnvHash.Constants.USING)) {
            lexer.nextToken();
            unique.setIndexType(lexer.stringVal());
            lexer.nextToken();
        }

        accept(Token.LPAREN);
        for (;;) {
            SQLExpr column = this.expr();
            if (lexer.token() == Token.ASC) {
                column = new MySqlOrderingExpr(column, SQLOrderingSpecification.ASC);
                lexer.nextToken();
            } else if (lexer.token() == Token.DESC) {
                column = new MySqlOrderingExpr(column, SQLOrderingSpecification.DESC);
                lexer.nextToken();
            }
            unique.addColumn(column);
            if (!(lexer.token() == (Token.COMMA))) {
                break;
            } else {
                lexer.nextToken();
            }
        }
        accept(Token.RPAREN);

        if (lexer.identifierEquals(FnvHash.Constants.USING)) {
            lexer.nextToken();
            unique.setIndexType(lexer.stringVal());
            lexer.nextToken();
        }

        if (lexer.identifierEquals(FnvHash.Constants.KEY_BLOCK_SIZE)) {
            lexer.nextToken();
            if (lexer.token() == Token.EQ) {
                lexer.nextToken();
            }
            SQLExpr value = this.primary();
            unique.setKeyBlockSize(value);
        }

        return unique;
    }

    override public MysqlForeignKey parseForeignKey() {
        accept(Token.FOREIGN);
        accept(Token.KEY);

        MysqlForeignKey fk = new MysqlForeignKey();

        if (lexer.token() != Token.LPAREN) {
            SQLName indexName = name();
            fk.setIndexName(indexName);
        }

        accept(Token.LPAREN);
        this.names(fk.getReferencingColumns(), fk);
        accept(Token.RPAREN);

        accept(Token.REFERENCES);

        fk.setReferencedTableName(this.name());

        accept(Token.LPAREN);
        this.names(fk.getReferencedColumns());
        accept(Token.RPAREN);

        if (lexer.identifierEquals(FnvHash.Constants.MATCH)) {
            lexer.nextToken();
            if (lexer.identifierEquals("FULL") || lexer.token() == Token.FULL) {
                fk.setReferenceMatch(SQLForeignKeyImpl.Match.FULL);
                lexer.nextToken();
            } else if (lexer.identifierEquals(FnvHash.Constants.PARTIAL)) {
                fk.setReferenceMatch(SQLForeignKeyImpl.Match.PARTIAL);
                lexer.nextToken();
            } else if (lexer.identifierEquals(FnvHash.Constants.SIMPLE)) {
                fk.setReferenceMatch(SQLForeignKeyImpl.Match.SIMPLE);
                lexer.nextToken();
            } else {
                throw new ParserException("TODO : " ~ lexer.info());
            }
        }

        while (lexer.token() == Token.ON) {
            lexer.nextToken();
            
            if (lexer.token() == Token.DELETE) {
                lexer.nextToken();
                
                SQLForeignKeyImpl.Option option = parseReferenceOption();
                fk.setOnDelete(option);
            } else if (lexer.token() == Token.UPDATE) {
                lexer.nextToken();
                
                SQLForeignKeyImpl.Option option = parseReferenceOption();
                fk.setOnUpdate(option);
            } else {
                throw new ParserException("syntax error, expect DELETE or UPDATE, actual " ~ lexer.token() ~ " "
                                          ~ lexer.info());
            }
        }
        return fk;
    }

    override protected SQLAggregateExpr parseAggregateExprRest(SQLAggregateExpr aggregateExpr) {
        if (lexer.token() == Token.ORDER) {
            SQLOrderBy orderBy = this.parseOrderBy();
            aggregateExpr.putAttribute("ORDER BY", orderBy);
        }
        if (lexer.identifierEquals(FnvHash.Constants.SEPARATOR)) {
            lexer.nextToken();

            SQLExpr seperator = this.primary();
            seperator.setParent(aggregateExpr);

            aggregateExpr.putAttribute("SEPARATOR", cast(Object)seperator);
        }
        return aggregateExpr;
    }

    public MySqlOrderingExpr parseSelectGroupByItem() {
        MySqlOrderingExpr item = new MySqlOrderingExpr();

        item.setExpr(expr());

        if (lexer.token() == Token.ASC) {
            lexer.nextToken();
            item.setType(SQLOrderingSpecification.ASC);
        } else if (lexer.token() == Token.DESC) {
            lexer.nextToken();
            item.setType(SQLOrderingSpecification.DESC);
        }

        return item;
    }
    
    override public SQLPartition parsePartition() {
        accept(Token.PARTITION);

        SQLPartition partitionDef = new SQLPartition();

        partitionDef.setName(this.name());

        SQLPartitionValue values = this.parsePartitionValues();
        if (values !is null) {
            partitionDef.setValues(values);
        }

        for (;;) {
            bool storage = false;
            if (lexer.identifierEquals(FnvHash.Constants.DATA)) {
                lexer.nextToken();
                acceptIdentifier("DIRECTORY");
                if (lexer.token() == Token.EQ) {
                    lexer.nextToken();
                }
                partitionDef.setDataDirectory(this.expr());
            } else if (lexer.token() == Token.TABLESPACE) {
                lexer.nextToken();
                if (lexer.token() == Token.EQ) {
                    lexer.nextToken();
                }
                SQLName tableSpace = this.name();
                partitionDef.setTablespace(tableSpace);
            } else if (lexer.token() == Token.INDEX) {
                lexer.nextToken();
                acceptIdentifier("DIRECTORY");
                if (lexer.token() == Token.EQ) {
                    lexer.nextToken();
                }
                partitionDef.setIndexDirectory(this.expr());
            } else if (lexer.identifierEquals(FnvHash.Constants.MAX_ROWS)) {
                lexer.nextToken();
                if (lexer.token() == Token.EQ) {
                    lexer.nextToken();
                }
                SQLExpr maxRows = this.primary();
                partitionDef.setMaxRows(maxRows);
            } else if (lexer.identifierEquals(FnvHash.Constants.MIN_ROWS)) {
                lexer.nextToken();
                if (lexer.token() == Token.EQ) {
                    lexer.nextToken();
                }
                SQLExpr minRows = this.primary();
                partitionDef.setMaxRows(minRows);
            } else if (lexer.identifierEquals(FnvHash.Constants.ENGINE)  //
                       ) {
                storage = (lexer.token() == Token.STORAGE || lexer.identifierEquals(FnvHash.Constants.STORAGE));
                if (storage) {
                    lexer.nextToken();
                }
                acceptIdentifier("ENGINE");

                if (lexer.token() == Token.EQ) {
                    lexer.nextToken();
                }

                SQLName engine = this.name();
                partitionDef.setEngine(engine);
            } else if (lexer.token() == Token.COMMENT) {
                lexer.nextToken();
                if (lexer.token() == Token.EQ) {
                    lexer.nextToken();
                }
                SQLExpr comment = this.primary();
                partitionDef.setComment(comment);
            } else {
                break;
            }
        }
        
        if (lexer.token() == Token.LPAREN) {
            lexer.nextToken();
            
            for (;;) {
                acceptIdentifier("SUBPARTITION");
                
                SQLName subPartitionName = this.name();
                SQLSubPartition subPartition = new SQLSubPartition();
                subPartition.setName(subPartitionName);
                
                partitionDef.addSubPartition(subPartition);
                
                if (lexer.token() == Token.COMMA) {
                    lexer.nextToken();
                    continue;
                }
                break;
            }
            
            accept(Token.RPAREN);
        }
        return partitionDef;
    }

    override protected SQLExpr parseAliasExpr(string alias_p) {
        string chars = alias_p.substring(1, cast(int)(alias_p.length - 1));
        return new SQLCharExpr(chars);
    }
}
