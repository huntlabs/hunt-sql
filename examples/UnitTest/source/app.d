import std.stdio;

import hunt.util.exception;
import hunt.util.UnitTest;
import hunt.logging;
import hunt.container;
import hunt.util.string;

import test;


void main()
{
    writeln("hello eql !");

    new Demo0().test_demo_0();

    new ExportParameters().test_export_parameters();

    new SQLLexerTest().test_lexer();

    new SQLLexerTest().test_lexer2();

    new SchemaStatVisitorTest().test1();

    new SchemaStatVisitorTest().test2();

    new CreateTableSetSchemaDemo().test_schemaStat();

    new MySqlSelectTest_1().test_0();
}
