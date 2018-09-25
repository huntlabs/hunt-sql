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
module hunt.sql.ast.expr.SQLBinaryOperator;

import std.uni;
/**
 * 
 * 二元操作符
 * 
 */
public struct SQLBinaryOperator {
    enum SQLBinaryOperator Union = SQLBinaryOperator("UNION", 0);
    enum SQLBinaryOperator COLLATE = SQLBinaryOperator("COLLATE", 20);
    enum SQLBinaryOperator BitwiseXor = SQLBinaryOperator("^", 50);
    enum SQLBinaryOperator BitwiseXorEQ = SQLBinaryOperator("^=", 110);

    enum SQLBinaryOperator Multiply = SQLBinaryOperator("*", 60);
    enum SQLBinaryOperator Divide = SQLBinaryOperator("/", 60);
    enum SQLBinaryOperator DIV = SQLBinaryOperator("DIV", 60); // mysql integer division
    enum SQLBinaryOperator Modulus = SQLBinaryOperator("%", 60);
    enum SQLBinaryOperator Mod = SQLBinaryOperator("MOD", 60);
    
    enum SQLBinaryOperator Add = SQLBinaryOperator("+", 70);
    enum SQLBinaryOperator Subtract = SQLBinaryOperator("-", 70);
    
    enum SQLBinaryOperator SubGt = SQLBinaryOperator("->", 20);
    enum SQLBinaryOperator SubGtGt = SQLBinaryOperator("->>", 20);
    enum SQLBinaryOperator PoundGt = SQLBinaryOperator("#>", 20);
    enum SQLBinaryOperator PoundGtGt = SQLBinaryOperator("#>>", 20);
    enum SQLBinaryOperator QuesQues = SQLBinaryOperator("??", 20);
    enum SQLBinaryOperator QuesBar = SQLBinaryOperator("?|", 20);
    enum SQLBinaryOperator QuesAmp = SQLBinaryOperator("?&", 20);

    enum SQLBinaryOperator LeftShift = SQLBinaryOperator("<<", 80); 
    enum SQLBinaryOperator RightShift = SQLBinaryOperator(">>", 80);

    enum SQLBinaryOperator BitwiseAnd = SQLBinaryOperator("&", 90);
    enum SQLBinaryOperator BitwiseOr = SQLBinaryOperator("|", 100);
    
    enum SQLBinaryOperator GreaterThan = SQLBinaryOperator(">", 110);
    enum SQLBinaryOperator GreaterThanOrEqual = SQLBinaryOperator(">=", 110);
    enum SQLBinaryOperator Is = SQLBinaryOperator("IS", 110);
    enum SQLBinaryOperator LessThan = SQLBinaryOperator("<", 110);
    enum SQLBinaryOperator LessThanOrEqual = SQLBinaryOperator("<=", 110);
    enum SQLBinaryOperator LessThanOrEqualOrGreaterThan = SQLBinaryOperator("<=>",110);
    enum SQLBinaryOperator LessThanOrGreater = SQLBinaryOperator("<>", 110);
    
    enum SQLBinaryOperator Like = SQLBinaryOperator("LIKE", 110);
    enum SQLBinaryOperator SoudsLike = SQLBinaryOperator("SOUNDS LIKE", 110);
    enum SQLBinaryOperator NotLike = SQLBinaryOperator("NOT LIKE", 110);

    enum SQLBinaryOperator ILike = SQLBinaryOperator("ILIKE", 110);
    enum SQLBinaryOperator NotILike = SQLBinaryOperator("NOT ILIKE", 110);
    enum SQLBinaryOperator AT_AT = SQLBinaryOperator("@@", 110); // postgresql textsearch
    enum SQLBinaryOperator SIMILAR_TO = SQLBinaryOperator("SIMILAR TO", 110);
    enum SQLBinaryOperator POSIX_Regular_Match = SQLBinaryOperator("~", 110);
    enum SQLBinaryOperator POSIX_Regular_Match_Insensitive = SQLBinaryOperator("~*", 110);
    enum SQLBinaryOperator POSIX_Regular_Not_Match = SQLBinaryOperator("!~", 110);
    enum SQLBinaryOperator POSIX_Regular_Not_Match_POSIX_Regular_Match_Insensitive = SQLBinaryOperator("!~*", 110);
    enum SQLBinaryOperator Array_Contains = SQLBinaryOperator("@>", 110);
    enum SQLBinaryOperator Array_ContainedBy = SQLBinaryOperator("<@", 110);
    enum SQLBinaryOperator SAME_AS = SQLBinaryOperator("~=", 110);

    enum SQLBinaryOperator RLike = SQLBinaryOperator("RLIKE", 110);
    enum SQLBinaryOperator NotRLike = SQLBinaryOperator("NOT RLIKE", 110);
    
    enum SQLBinaryOperator NotEqual = SQLBinaryOperator("!=", 110);
    enum SQLBinaryOperator NotLessThan = SQLBinaryOperator("!<", 110);
    enum SQLBinaryOperator NotGreaterThan = SQLBinaryOperator("!>", 110);
    enum SQLBinaryOperator IsNot = SQLBinaryOperator("IS NOT", 110); 
    enum SQLBinaryOperator Escape = SQLBinaryOperator("ESCAPE", 110); 
    enum SQLBinaryOperator RegExp = SQLBinaryOperator("REGEXP", 110);
    enum SQLBinaryOperator NotRegExp = SQLBinaryOperator("NOT REGEXP", 110);
    enum SQLBinaryOperator Equality = SQLBinaryOperator("=", 110);
    
    enum SQLBinaryOperator BitwiseNot = SQLBinaryOperator("!", 130);
    enum SQLBinaryOperator Concat = SQLBinaryOperator("||", 140);
    
    enum SQLBinaryOperator BooleanAnd = SQLBinaryOperator("AND", 140); 
    enum SQLBinaryOperator BooleanXor = SQLBinaryOperator("XOR", 150); 
    enum SQLBinaryOperator BooleanOr = SQLBinaryOperator("OR", 160); 
    enum SQLBinaryOperator Assignment = SQLBinaryOperator(":=", 169);

    enum SQLBinaryOperator PG_And = SQLBinaryOperator("&&", 140);
    enum SQLBinaryOperator PG_ST_DISTANCE = SQLBinaryOperator("<->", 20);
    ;

    public static int getPriority(SQLBinaryOperator operator) {
        return 0;
    }

    public  string name;
    public  string name_lcase;
    public  int    priority;

    // this(){
    //     this(sting.init, 0);
    // }

    this(string name, int priority){
        this.name = name;
        this.name_lcase = toLower(name);
        this.priority = priority;
    }
    
    @property public string getName() {
        return this.name;
    }
    
    public int getPriority() {
        return this.priority;
    }
    
    public bool isRelational() {
        switch (this.getName) {
            case Equality.getName:
            case Like.getName:
            case NotEqual.getName:
            case GreaterThan.getName:
            case GreaterThanOrEqual.getName:
            case LessThan.getName:
            case LessThanOrEqual.getName:
            case LessThanOrGreater.getName:
            case NotLike.getName:
            case NotLessThan.getName:
            case NotGreaterThan.getName:
            case RLike.getName:
            case NotRLike.getName:
            case RegExp.getName:
            case NotRegExp.getName:
            case Is.getName:
            case IsNot.getName:
                return true;
            default:
                return false;
        }
    }
    
    public bool isLogical() {
        return this == BooleanAnd || this == BooleanOr || this == BooleanXor;
    }

    public bool isArithmetic() {
        switch (this.getName) {
            case Add.getName:
            case Subtract.getName:
            case Multiply.getName:
            case Divide.getName:
            case DIV.getName:
            case Modulus.getName:
            case Mod.getName:
                return true;
            default:
                return false;
        }
    }

    bool opEquals(const SQLBinaryOperator h) nothrow {
        return name == h.name ;
    } 

    bool opEquals(ref const SQLBinaryOperator h) nothrow {
        return name == h.name ;
    } 
}
