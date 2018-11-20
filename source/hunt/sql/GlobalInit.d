module hunt.sql.GlobalInit;

import hunt.container;
import hunt.sql.util.Utils;
import hunt.sql.ast.expr.SQLBooleanExpr;
import hunt.sql.ast.SQLDataType;

import hunt.sql.ast.expr.SQLCharExpr;
import hunt.sql.ast.statement.SQLCharacterDataType;

import hunt.sql.ast.expr.SQLDateExpr;
import hunt.sql.ast.expr.SQLIntegerExpr;
import hunt.sql.ast.expr.SQLNCharExpr;
import hunt.sql.ast.expr.SQLTimestampExpr;
import hunt.sql.ast.SQLDataTypeImpl;
import hunt.sql.SQLUtils;
import hunt.sql.parser;

import hunt.sql.ast.expr.SQLBooleanExpr;
import hunt.sql.dialect.mysql.parser.MySqlExprParser;
import hunt.sql.util.FnvHash;
import hunt.sql.dialect.mysql.ast.statement.MySqlShowProfileStatement;
import hunt.sql.parser.Lexer;
import hunt.sql.parser.SymbolTable;
import hunt.sql.dialect.mysql.parser.MySqlLexer;
import hunt.sql.ast.SQLOrderingSpecification;
import hunt.sql.dialect.mysql.ast.clause.MySqlStatementType;
import hunt.sql.dialect.postgresql.parser.PGExprParser;
import hunt.sql.dialect.postgresql.parser.PGLexer;
import hunt.sql.visitor.functions;


/* shared */ static this()
{
    import std.stdio;

    {
        SQLBooleanExpr.DEFAULT_DATA_TYPE = new SQLDataTypeImpl(SQLDataType.Constants.BOOLEAN);
    }

    {
        SQLCharExpr.DEFAULT_DATA_TYPE = new SQLCharacterDataType("varchar");

    }
    {
        SQLDateExpr.DEFAULT_DATA_TYPE = new SQLCharacterDataType("date");
    }

    {
        SQLIntegerExpr.DEFAULT_DATA_TYPE = new SQLDataTypeImpl("bigint");
    }

    {
        SQLNCharExpr.defaultDataType = new SQLCharacterDataType("nvarchar");
    }

    {
        SQLTimestampExpr.DEFAULT_DATA_TYPE = new SQLCharacterDataType("datetime");
    }

    {
        SQLUtils.DEFAULT_FORMAT_OPTION = new SQLUtils.FormatOption(true, true);
        SQLUtils.DEFAULT_LCASE_FORMAT_OPTION = new SQLUtils.FormatOption(false, true);
    }

    {
        InsertColumnsCache.global = new InsertColumnsCache(8192);
    }

    {
        SQLBooleanExpr.DEFAULT_DATA_TYPE = new SQLDataTypeImpl(SQLDataType.Constants.BOOLEAN);
    }

    {
        string[] strings = ["AVG", "COUNT", "GROUP_CONCAT", "MAX", "MIN", "STDDEV", "SUM"];
        MySqlExprParser.AGGREGATE_FUNCTIONS_CODES = FnvHash.fnv1a_64_lower(strings, true);
        MySqlExprParser.AGGREGATE_FUNCTIONS
            = new string[MySqlExprParser.AGGREGATE_FUNCTIONS_CODES.length];

        
        foreach (string str; strings)
        {
            long hash = FnvHash.fnv1a_64_lower(str);
            int index = search(MySqlExprParser.AGGREGATE_FUNCTIONS_CODES, hash);
            MySqlExprParser.AGGREGATE_FUNCTIONS[index] = str;
        }
    }

    {
        MySqlShowProfileStatement.Type.ALL = new MySqlShowProfileStatement.Type("ALL");
        MySqlShowProfileStatement.Type.BLOCK_IO = new MySqlShowProfileStatement.Type("BLOCK IO");
        MySqlShowProfileStatement.Type.CONTEXT_SWITCHES = new MySqlShowProfileStatement.Type(
                "CONTEXT SWITCHES");
        MySqlShowProfileStatement.Type.CPU = new MySqlShowProfileStatement.Type("CPU");
        MySqlShowProfileStatement.Type.IPC = new MySqlShowProfileStatement.Type("IPC");
        MySqlShowProfileStatement.Type.MEMORY = new MySqlShowProfileStatement.Type("MEMORY");
        MySqlShowProfileStatement.Type.PAGE_FAULTS = new MySqlShowProfileStatement.Type(
                "PAGE FAULTS");
        MySqlShowProfileStatement.Type.SOURCE = new MySqlShowProfileStatement.Type("SOURCE");
        MySqlShowProfileStatement.Type.SWAPS = new MySqlShowProfileStatement.Type("SWAPS");
    }

    {
        Lexer.symbols_l2 = new SymbolTable(512);
        for (int i = '0'; i <= '9'; ++i)
        {
            Lexer.digits[i] = i - '0';
        }
    }

    {
        MySqlLexer.quoteTable = new SymbolTable(8192);

        Map!(string, Token) map = new HashMap!(string, Token)();

        map.putAll(Keywords.DEFAULT_KEYWORDS.getKeywords());

        map.put("DUAL", Token.DUAL);
        map.put("FALSE", Token.FALSE);
        map.put("IDENTIFIED", Token.IDENTIFIED);
        map.put("IF", Token.IF);
        map.put("KILL", Token.KILL);

        map.put("LIMIT", Token.LIMIT);
        map.put("TRUE", Token.TRUE);
        map.put("BINARY", Token.BINARY);
        map.put("SHOW", Token.SHOW);
        map.put("CACHE", Token.CACHE);
        map.put("ANALYZE", Token.ANALYZE);
        map.put("OPTIMIZE", Token.OPTIMIZE);
        map.put("ROW", Token.ROW);
        map.put("BEGIN", Token.BEGIN);
        map.put("END", Token.END);
        map.put("DIV", Token.DIV);
        map.put("MERGE", Token.MERGE);

        // for oceanbase & mysql 5.7
        map.put("PARTITION", Token.PARTITION);

        map.put("CONTINUE", Token.CONTINUE);
        map.put("UNDO", Token.UNDO);
        map.put("SQLSTATE", Token.SQLSTATE);
        map.put("CONDITION", Token.CONDITION);
        map.put("MOD", Token.MOD);
        map.put("CONTAINS", Token.CONTAINS);
        map.put("RLIKE", Token.RLIKE);
        map.put("FULLTEXT", Token.FULLTEXT);

        MySqlLexer.DEFAULT_MYSQL_KEYWORDS = new Keywords(map);

        for (dchar c = 0; c < MySqlLexer.identifierFlags.length; ++c)//@gxc char->dchar
        {
            if (c >= 'A' && c <= 'Z')
            {
                MySqlLexer.identifierFlags[c] = true;
            }
            else if (c >= 'a' && c <= 'z')
            {
                MySqlLexer.identifierFlags[c] = true;
            }
            else if (c >= '0' && c <= '9')
            {
                MySqlLexer.identifierFlags[c] = true;
            }
        }
        // identifierFlags['`'] = true;
        MySqlLexer.identifierFlags['_'] = true;
        //identifierFlags['-'] = true; // mysql
    }

    {
        string[] strings = [ "AVG", "COUNT", "MAX", "MIN", "STDDEV", "SUM" ];
        SQLExprParser.AGGREGATE_FUNCTIONS_CODES = FnvHash.fnv1a_64_lower(strings, true);
        SQLExprParser.AGGREGATE_FUNCTIONS = new string[SQLExprParser.AGGREGATE_FUNCTIONS_CODES.length];
        foreach(string str ; strings) {
            long hash = FnvHash.fnv1a_64_lower(str);
            int index = search(SQLExprParser.AGGREGATE_FUNCTIONS_CODES, hash);
            SQLExprParser.AGGREGATE_FUNCTIONS[index] = str;
        }
    }

    {
        SQLOrderingSpecification.ASC = new SQLOrderingSpecification("ASC");
        SQLOrderingSpecification.DESC = new  SQLOrderingSpecification("DESC");
    }

    {
            // MySqlStatementType._types = [SELECT,UPDATE,INSERT,DELETE,WHILE,IF,LOOP,BLOCK,DECLARE,SELECTINTO,CASE,UNDEFINED];
    }

    {
        string[] strings = [ "AVG", "COUNT", "MAX", "MIN", "STDDEV", "SUM", "ROW_NUMBER" ];
        PGExprParser.AGGREGATE_FUNCTIONS_CODES = FnvHash.fnv1a_64_lower(strings, true);
        PGExprParser.AGGREGATE_FUNCTIONS = new string[PGExprParser.AGGREGATE_FUNCTIONS_CODES.length];
        foreach(string str ; strings) {
            long hash = FnvHash.fnv1a_64_lower(str);
            int index = search(PGExprParser.AGGREGATE_FUNCTIONS_CODES, hash);
            PGExprParser.AGGREGATE_FUNCTIONS[index] = str;
        }
    }

    {
        Map!(string, Token) map = new HashMap!(string, Token)();

        map.putAll(Keywords.DEFAULT_KEYWORDS.getKeywords());

        map.put("BEGIN", Token.BEGIN);
        map.put("CASCADE", Token.CASCADE);
        map.put("CONTINUE", Token.CONTINUE);
        map.put("CURRENT", Token.CURRENT);
        map.put("FETCH", Token.FETCH);
        map.put("FIRST", Token.FIRST);

        map.put("IDENTITY", Token.IDENTITY);
        map.put("LIMIT", Token.LIMIT);
        map.put("NEXT", Token.NEXT);
        map.put("NOWAIT", Token.NOWAIT);
        map.put("OF", Token.OF);

        map.put("OFFSET", Token.OFFSET);
        map.put("ONLY", Token.ONLY);
        map.put("RECURSIVE", Token.RECURSIVE);
        map.put("RESTART", Token.RESTART);

        map.put("RESTRICT", Token.RESTRICT);
        map.put("RETURNING", Token.RETURNING);
        map.put("ROW", Token.ROW);
        map.put("ROWS", Token.ROWS);
        map.put("SHARE", Token.SHARE);
        map.put("SHOW", Token.SHOW);
        map.put("START", Token.START);
        
        map.put("USING", Token.USING);
        map.put("WINDOW", Token.WINDOW);
        
        map.put("TRUE", Token.TRUE);
        map.put("FALSE", Token.FALSE);
        map.put("ARRAY", Token.ARRAY);
        map.put("IF", Token.IF);
        map.put("TYPE", Token.TYPE);
        map.put("ILIKE", Token.ILIKE);

        PGLexer.DEFAULT_PG_KEYWORDS = new Keywords(map);
    }

    {
        Ascii.instance = new Ascii();
    }

    {
        Bin.instance = new Bin();
    }

    {
        BitLength.instance = new BitLength();
    }
    {
        Char.instance = new Char();
    }
    {
        Concat.instance = new Concat();
    }
    {
        Elt.instance = new Elt();
    }
    {
        Greatest.instance = new Greatest();
    }
    {
        Hex.instance = new Hex();
    }

    {
        If.instance = new If();
    }
    {
        Insert.instance = new Insert();
    }
    {
        Instr.instance = new Instr();
    }
    {
        Isnull.instance = new Isnull();
    }
    {
        Lcase.instance = new Lcase();
    }
    {
        Least.instance = new Least();
    }
    {
        Left.instance = new Left();
    }
    {
        Length.instance = new Length();
    }
    {
        Locate.instance = new Locate();
    }
    {
        Lpad.instance = new Lpad();
    }
    {
        Ltrim.instance = new Ltrim();
    }
    {
        Nil.instance = new Nil();
    }
    {
        Now.instance = new Now();
    }

    {
        OneParamFunctions.instance = new OneParamFunctions();
    }
    {
        Reverse.instance = new Reverse();
    }
    {
        Right.instance = new Right();
    }
    {
        Substring.instance = new Substring();
    }
    {
        Trim.instance = new Trim();
    }
    {
        Ucase.instance = new Ucase();
    }
    {
        Unhex.instance = new Unhex();
    }

    // writeln("---GlobalInit OK---");
}
