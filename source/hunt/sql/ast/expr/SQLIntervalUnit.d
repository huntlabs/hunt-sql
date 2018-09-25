/*
 * Copyright 2015-2018 HuntLabs.cn
 *
 * Licensed under the Apache License = SQLIntervalUnit(""); Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing = SQLIntervalUnit(""); software
 * distributed under the License is distributed on an "AS IS" BASIS = SQLIntervalUnit("");
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND = SQLIntervalUnit(""); either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
module hunt.sql.ast.expr.SQLIntervalUnit;
import std.uni;

public struct SQLIntervalUnit {
    enum SQLIntervalUnit YEAR = SQLIntervalUnit("YEAR"); 
    enum SQLIntervalUnit YEAR_MONTH = SQLIntervalUnit("YEAR_MONTH");
    enum SQLIntervalUnit QUARTER = SQLIntervalUnit("QUARTER");
    enum SQLIntervalUnit MONTH = SQLIntervalUnit("MONTH");
    enum SQLIntervalUnit WEEK = SQLIntervalUnit("WEEK"); 
    enum SQLIntervalUnit DAY = SQLIntervalUnit("DAY");
    enum SQLIntervalUnit DAY_HOUR = SQLIntervalUnit("DAY_HOUR");
    enum SQLIntervalUnit DAY_MINUTE = SQLIntervalUnit("DAY_MINUTE");
    enum SQLIntervalUnit DAY_SECOND = SQLIntervalUnit("DAY_SECOND");
    enum SQLIntervalUnit DAY_MICROSECOND = SQLIntervalUnit("DAY_MICROSECOND");
    enum SQLIntervalUnit HOUR = SQLIntervalUnit("HOUR");
    enum SQLIntervalUnit HOUR_MINUTE = SQLIntervalUnit("HOUR_MINUTE");
    enum SQLIntervalUnit HOUR_SECOND = SQLIntervalUnit("HOUR_SECOND");
    enum SQLIntervalUnit HOUR_MICROSECOND = SQLIntervalUnit("HOUR_MICROSECOND");
    enum SQLIntervalUnit MINUTE = SQLIntervalUnit("MINUTE");
    enum SQLIntervalUnit MINUTE_SECOND = SQLIntervalUnit("MINUTE_SECOND");
    enum SQLIntervalUnit MINUTE_MICROSECOND = SQLIntervalUnit("MINUTE_MICROSECOND");
    enum SQLIntervalUnit SECOND = SQLIntervalUnit("SECOND");
    enum SQLIntervalUnit SECOND_MICROSECOND = SQLIntervalUnit("SECOND_MICROSECOND");
    enum SQLIntervalUnit MICROSECOND = SQLIntervalUnit("MICROSECOND");
    
    // public  string name_lcase;
    
    // private SQLIntervalUnit() {
    //     this.name_lcase = name().toLowerCase();
    // }
    // private static SQLIntervalUnit[] _values;

    // static this()
    // {
    //     _values = [YEAR,YEAR_MONTH,QUARTER,MONTH,WEEK,DAY,DAY_HOUR,DAY_MINUTE,DAY_SECOND,DAY_MICROSECOND,HOUR,HOUR_MINUTE,
    //             HOUR_SECOND,HOUR_MICROSECOND,MINUTE,MINUTE_SECOND,MINUTE_MICROSECOND,SECOND,SECOND_MICROSECOND,MICROSECOND];
    // }


    private string _name;

    this(string name)
    {
        _name = name;
    }

    @property string name()
    {
        return _name;
    }

    @property string name_lcase()
    {
        return toLower(_name);
    }

    bool opEquals(const SQLIntervalUnit h) nothrow {
        return _name == h._name ;
    } 

    bool opEquals(ref const SQLIntervalUnit h) nothrow {
        return _name == h._name ;
    } 

}
