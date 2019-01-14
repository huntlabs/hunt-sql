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
module hunt.sql.dialect.postgresql.parser.PGExprParser;

import hunt.sql.ast.SQLDataType;
import hunt.sql.ast.SQLExpr;
import hunt.sql.ast.expr;
import hunt.sql.dialect.postgresql.ast.expr.PGBoxExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGCidrExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGCircleExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGDateField;
import hunt.sql.dialect.postgresql.ast.expr.PGExtractExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGInetExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGLineSegmentsExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGMacAddrExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGPointExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGPolygonExpr;
import hunt.sql.dialect.postgresql.ast.expr.PGTypeCastExpr;
import hunt.sql.parser.Lexer;
import hunt.sql.parser.SQLExprParser;
import hunt.sql.parser.SQLParserFeature;
import hunt.sql.parser.Token;
import hunt.sql.util.FnvHash;
import hunt.sql.util.DBType;
import hunt.sql.dialect.postgresql.parser.PGSelectParser;
import hunt.sql.dialect.postgresql.parser.PGLexer;
import std.uni;
//import hunt.lang;
import hunt.collection;
import hunt.String;
import hunt.sql.util.Utils;
import hunt.text;

public class PGExprParser : SQLExprParser {

    public  static string[] AGGREGATE_FUNCTIONS;

    public  static long[] AGGREGATE_FUNCTIONS_CODES;

    // static this(){
    //     string[] strings = [ "AVG", "COUNT", "MAX", "MIN", "STDDEV", "SUM", "ROW_NUMBER" ];
    //     AGGREGATE_FUNCTIONS_CODES = FnvHash.fnv1a_64_lower(strings, true);
    //     AGGREGATE_FUNCTIONS = new string[AGGREGATE_FUNCTIONS_CODES.length];
    //     foreach(string str ; strings) {
    //         long hash = FnvHash.fnv1a_64_lower(str);
    //         int index = search(AGGREGATE_FUNCTIONS_CODES, hash);
    //         AGGREGATE_FUNCTIONS[index] = str;
    //     }
    // }

    public this(string sql){
        this(new PGLexer(sql));
        this.lexer.nextToken();
        this.dbType = DBType.POSTGRESQL.name;
    }

    public this(string sql, SQLParserFeature[] features...){
        this(new PGLexer(sql));
        this.lexer.nextToken();
        this.dbType = DBType.POSTGRESQL.name;
    }

    public this(Lexer lexer){
        super(lexer);
        this.aggregateFunctions = AGGREGATE_FUNCTIONS;
        this.aggregateFunctionHashCodes = AGGREGATE_FUNCTIONS_CODES;
        this.dbType = DBType.POSTGRESQL.name;
    }
    
    override
    public SQLDataType parseDataType() {
        if (lexer.token() == Token.TYPE) {
            lexer.nextToken();
        }
        return super.parseDataType();
    }
    
    override public PGSelectParser createSelectParser() {
        return new PGSelectParser(this);
    }

    override public SQLExpr primary() {
        if (lexer.token() == Token.ARRAY) {
            string ident = lexer.stringVal();
            lexer.nextToken();

            if (lexer.token() == Token.LPAREN) {
                SQLIdentifierExpr array = new SQLIdentifierExpr(ident);
                return this.methodRest(array, true);
            } else {
                SQLArrayExpr array = new SQLArrayExpr();
                array.setExpr(new SQLIdentifierExpr(ident));
                accept(Token.LBRACKET);
                this.exprList(array.getValues(), array);
                accept(Token.RBRACKET);
                return primaryRest(array);
            }

        } else if (lexer.token() == Token.POUND) {
            lexer.nextToken();
            if (lexer.token() == Token.LBRACE) {
                lexer.nextToken();
                string varName = lexer.stringVal();
                lexer.nextToken();
                accept(Token.RBRACE);
                SQLVariantRefExpr expr = new SQLVariantRefExpr("#{" ~ varName ~ "}");
                return primaryRest(expr);
            } else {
                SQLExpr value = this.primary();
                SQLUnaryExpr expr = new SQLUnaryExpr(SQLUnaryOperator.Pound, value);
                return primaryRest(expr);
            }
        } else if (lexer.token() == Token.VALUES) {
            lexer.nextToken();

            SQLValuesExpr values = new SQLValuesExpr();
            for (;;) {
                accept(Token.LPAREN);
                SQLListExpr listExpr = new SQLListExpr();
                exprList(listExpr.getItems(), listExpr);
                accept(Token.RPAREN);

                listExpr.setParent(values);

                values.getValues().add(listExpr);

                if (lexer.token() == Token.COMMA) {
                    lexer.nextToken();
                    continue;
                }
                break;
            }
            return values;
        }
        
        return super.primary();
    }

    override
    protected SQLExpr parseInterval() {
        accept(Token.INTERVAL);
        SQLIntervalExpr intervalExpr = new SQLIntervalExpr();
        if (lexer.token() != Token.LITERAL_CHARS) {
            return new SQLIdentifierExpr("INTERVAL");
        }
        intervalExpr.setValue(new SQLCharExpr(lexer.stringVal()));
        lexer.nextToken();
        return intervalExpr;
    }

    override public SQLExpr primaryRest(SQLExpr expr) {
        if (lexer.token() == Token.COLONCOLON) {
            lexer.nextToken();
            SQLDataType dataType = this.parseDataType();
            
            PGTypeCastExpr castExpr = new PGTypeCastExpr();
            
            castExpr.setExpr(expr);
            castExpr.setDataType(dataType);

            return primaryRest(castExpr);
        }
        
        if (lexer.token() == Token.LBRACKET) {
            SQLArrayExpr array = new SQLArrayExpr();
            array.setExpr(expr);
            lexer.nextToken();
            this.exprList(array.getValues(), array);
            accept(Token.RBRACKET);
            return primaryRest(array);
        }
        
        if (typeid(expr) == typeid(SQLIdentifierExpr)) {
            string ident = (cast(SQLIdentifierExpr)expr).getName();

            if (lexer.token() == Token.COMMA || lexer.token() == Token.RPAREN) {
                return super.primaryRest(expr);
            }

            if ("TIMESTAMP".equalsIgnoreCase(ident)) {
                if (lexer.token() != Token.LITERAL_ALIAS //
                        && lexer.token() != Token.LITERAL_CHARS //
                        && lexer.token() != Token.WITH) {
                    return super.primaryRest(
                            new SQLIdentifierExpr(ident));
                }

                SQLTimestampExpr timestamp = new SQLTimestampExpr();

                if (lexer.token() == Token.WITH) {
                    lexer.nextToken();
                    acceptIdentifier("TIME");
                    acceptIdentifier("ZONE");
                    timestamp.setWithTimeZone(true);
                }

                string literal = lexer.stringVal();
                timestamp.setLiteral(literal);
                accept(Token.LITERAL_CHARS);

                if (lexer.identifierEquals("AT")) {
                    lexer.nextToken();
                    acceptIdentifier("TIME");
                    acceptIdentifier("ZONE");

                    string timezone = lexer.stringVal();
                    timestamp.setTimeZone(timezone);
                    accept(Token.LITERAL_CHARS);
                }


                return primaryRest(timestamp);
            } else  if ("TIMESTAMPTZ".equalsIgnoreCase(ident)) {
                if (lexer.token() != Token.LITERAL_ALIAS //
                        && lexer.token() != Token.LITERAL_CHARS //
                        && lexer.token() != Token.WITH) {
                    return super.primaryRest(
                            new SQLIdentifierExpr(ident));
                }

                SQLTimestampExpr timestamp = new SQLTimestampExpr();
                timestamp.setWithTimeZone(true);

                string literal = lexer.stringVal();
                timestamp.setLiteral(literal);
                accept(Token.LITERAL_CHARS);

                if (lexer.identifierEquals("AT")) {
                    lexer.nextToken();
                    acceptIdentifier("TIME");
                    acceptIdentifier("ZONE");

                    string timezone = lexer.stringVal();
                    timestamp.setTimeZone(timezone);
                    accept(Token.LITERAL_CHARS);
                }


                return primaryRest(timestamp);
            } else if ("EXTRACT".equalsIgnoreCase(ident)) {
                accept(Token.LPAREN);
                
                PGExtractExpr extract = new PGExtractExpr();
                
                string fieldName = lexer.stringVal();
                PGDateField field = PGDateField(toUpper(fieldName));
                lexer.nextToken();
                
                extract.setField(field);
                
                accept(Token.FROM);
                SQLExpr source = this.expr();
                
                extract.setSource(source);
                
                accept(Token.RPAREN);
                
                return primaryRest(extract);     
            } else if ("POINT".equalsIgnoreCase(ident)) {
                SQLExpr value = this.primary();
                PGPointExpr point = new PGPointExpr();
                point.setValue(value);
                return primaryRest(point);
            } else if ("BOX".equalsIgnoreCase(ident)) {
                SQLExpr value = this.primary();
                PGBoxExpr box = new PGBoxExpr();
                box.setValue(value);
                return primaryRest(box);
            } else if ("macaddr".equalsIgnoreCase(ident)) {
                SQLExpr value = this.primary();
                PGMacAddrExpr macaddr = new PGMacAddrExpr();
                macaddr.setValue(value);
                return primaryRest(macaddr);
            } else if ("inet".equalsIgnoreCase(ident)) {
                SQLExpr value = this.primary();
                PGInetExpr inet = new PGInetExpr();
                inet.setValue(value);
                return primaryRest(inet);
            } else if ("cidr".equalsIgnoreCase(ident)) {
                SQLExpr value = this.primary();
                PGCidrExpr cidr = new PGCidrExpr();
                cidr.setValue(value);
                return primaryRest(cidr);
            } else if ("polygon".equalsIgnoreCase(ident)) {
                SQLExpr value = this.primary();
                PGPolygonExpr polygon = new PGPolygonExpr();
                polygon.setValue(value);
                return primaryRest(polygon);
            } else if ("circle".equalsIgnoreCase(ident)) {
                SQLExpr value = this.primary();
                PGCircleExpr circle = new PGCircleExpr();
                circle.setValue(value);
                return primaryRest(circle);
            } else if ("lseg".equalsIgnoreCase(ident)) {
                SQLExpr value = this.primary();
                PGLineSegmentsExpr lseg = new PGLineSegmentsExpr();
                lseg.setValue(value);
                return primaryRest(lseg);
            } else if (equalsIgnoreCase(ident, "b") && lexer.token() == Token.LITERAL_CHARS) {
                string charValue = lexer.stringVal();
                lexer.nextToken();
                expr = new SQLBinaryExpr(charValue);

                return primaryRest(expr);
            }
        }

        return super.primaryRest(expr);
    }

    override
    protected string alias_f() {
        string _alias = super.alias_f();
        if (_alias !is null) {
            return _alias;
        }
        // 某些关键字在alias时,不作为关键字,仍然是作用为别名
        switch (lexer.token()) {
        case Token.INTERSECT:
            // 具体可以参考SQLParser::alias()的方法实现
            _alias = lexer.stringVal();
            lexer.nextToken();
            return _alias;
        // TODO other cases
        default:
            break;
        }
        return _alias;
    }

    override protected void filter(SQLAggregateExpr x) {
        if (lexer.identifierEquals(FnvHash.Constants.FILTER)) {
            lexer.nextToken();
            accept(Token.LPAREN);
            accept(Token.WHERE);
            SQLExpr filter = this.expr();
            accept(Token.RPAREN);
            x.setFilter(filter);
        }
    }
}
