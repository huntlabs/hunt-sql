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
module test.SQLLexerTest;

import hunt.logging;
import hunt.container;
import hunt.string;
import hunt.sql;
import std.conv;
import std.traits;
import test.base;


public class SQLLexerTest {

    public void test_lexer()  {
        mixin(DO_TEST);
        string sql = "SELECT * FROM T WHERE F1 = ? ORDER BY F2";
        Lexer lexer = new Lexer(sql);
        for (;;) {
            lexer.nextToken();
            Token tok = lexer.token();

            if (tok == Token.IDENTIFIER) {
                logDebug(tok ~ "\t\t" ~ lexer.stringVal());
            } else if (tok == Token.LITERAL_INT) {
                logDebug(tok ~ "\t\t" ~ lexer.numberString());
            } else {
                logDebug(tok ~ "\t\t\t" ~ tok);
            }
            
            if (tok == Token.WHERE) {
                logDebug("where pos : " ~ lexer.pos().to!string);
            }

            if (tok == Token.EOF) {
                break;
            }
        }
    }
    
    public void test_lexer2() {
        mixin(DO_TEST);

        string sql = "SELECT substr('''a''bc',0,3) FROM dual";
        Lexer lexer = new Lexer(sql);
        for (;;) {
            lexer.nextToken();
            Token tok = lexer.token();

            if (tok == Token.IDENTIFIER) {
                logDebug(tok ~ "\t\t" ~ lexer.stringVal());
            } else if (tok == Token.LITERAL_INT) {
                logDebug(tok ~ "\t\t" ~ lexer.numberString());
            } else if (tok == Token.LITERAL_CHARS) {
                logDebug(tok ~ "\t\t" ~ lexer.stringVal());
            } 
            else {
                logDebug(tok ~ "\t\t\t" ~ tok);
            }

            if (tok == Token.EOF) {
                break;
            }
        }
    }
    
}
