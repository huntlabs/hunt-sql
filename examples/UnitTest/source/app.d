import std.stdio;

import hunt.Exceptions;
import hunt.util.UnitTest;
import hunt.logging;
import hunt.collection;
import hunt.String;

import test;


void main()
{
    writeln("hello hunt-sql !");

    // new Demo0().test_demo_0();

    // new ExportParameters().test_export_parameters();
    // new ExportParameters().test_pg_export_parameters();


    // new ExportParameters().test_sql_format();

    // new SQLLexerTest().test_lexer();

    // new SQLLexerTest().test_lexer2();

    // new SchemaStatVisitorTest().test1();

    // new SchemaStatVisitorTest().test2();

    // new SchemaStatVisitorTest().test3();

    // new CreateTableSetSchemaDemo().test_schemaStat();

    // new MySqlSelectTest_1().test_0();

    //  new MySqlSelectTest_1().test_1();

    // new MySqlUpdateTest_1().test_0();

    // new MySqlUpdateTest_1().test_1();

    // new BuilderSelectTest().test_0();

    // new SelectTest().test_0();

    // new MySqlVisitorDemo().test_for_demo();
    // new MySqlVisitorDemo().test_for_insert();

    // new PostgresqlTest().test_0();
    new PostgresqlTest().test_delete();

    // new PageTest().test();
}
