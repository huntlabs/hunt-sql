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
module hunt.sql.dialect.postgresql.ast.expr.PGDateField;

public struct PGDateField {
    enum PGDateField CENTURY = PGDateField("CENTURY");
    enum PGDateField DAY = PGDateField("DAY");
    enum PGDateField DECADE = PGDateField("DECADE");
    enum PGDateField DOW = PGDateField("DOW");
    enum PGDateField DOY = PGDateField("DOY");
    enum PGDateField EPOCH = PGDateField("EPOCH");
    enum PGDateField HOUR = PGDateField("HOUR");
    enum PGDateField ISODOW = PGDateField("ISODOW");
    enum PGDateField ISOYEAR = PGDateField("ISOYEAR");
    enum PGDateField MICROSECONDS = PGDateField("MICROSECONDS");
    enum PGDateField MILLENNIUM = PGDateField("MILLENNIUM");
    enum PGDateField MILLISECONDS = PGDateField("MILLISECONDS");
    enum PGDateField MINUTE = PGDateField("MINUTE");
    enum PGDateField MONTH = PGDateField("MONTH");
    enum PGDateField QUARTER = PGDateField("QUARTER");
    enum PGDateField SECOND = PGDateField("SECOND");
    enum PGDateField TIMEZONE = PGDateField("TIMEZONE");
    enum PGDateField TIMEZONE_HOUR = PGDateField("TIMEZONE_HOUR");
    enum PGDateField TIMEZONE_MINUTE = PGDateField("TIMEZONE_MINUTE");
    enum PGDateField WEEK = PGDateField("WEEK");
    enum PGDateField YEAR = PGDateField("YEAR");

    private string _name;

    this(string name)
    {
        _name = name;
    }

    @property string name()
    {
        return _name;
    }


     bool opEquals(const PGDateField h) nothrow {
        return _name == h._name ;
    } 

    bool opEquals(ref const PGDateField h) nothrow {
        return _name == h._name ;
    } 
}