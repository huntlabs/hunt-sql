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
module hunt.sql.util.HexBin;
import std.conv;
/**
 * format validation This class encodes/decodes hexadecimal data
 * 
 */
public  class HexBin {

    private enum int    BASE_LENGTH        = 128;
    private enum  int    LOOKUP_LENGTH      = 16;
    private __gshared byte[] HEX_NUMBER_TABLE;
    private __gshared char[] UPPER_CHARS ;
    private __gshared char[] LOWER_CHARS ;

    shared static this() {
        HEX_NUMBER_TABLE   = new byte[BASE_LENGTH];
        UPPER_CHARS        = new char[LOOKUP_LENGTH];
        LOWER_CHARS        = new char[LOOKUP_LENGTH];

        for (int i = 0; i < BASE_LENGTH; i++) {
            HEX_NUMBER_TABLE[i] = -1;
        }
        for (int i = '9'; i >= '0'; i--) {
            HEX_NUMBER_TABLE[i] = cast(byte) (i - '0');
        }
        for (int i = 'F'; i >= 'A'; i--) {
            HEX_NUMBER_TABLE[i] = cast(byte) (i - 'A' + 10);
        }
        for (int i = 'f'; i >= 'a'; i--) {
            HEX_NUMBER_TABLE[i] = cast(byte) (i - 'a' + 10);
        }

        for (int i = 0; i < 10; i++) {
            UPPER_CHARS[i] = cast(char) ('0' + i);
            LOWER_CHARS[i] = cast(char) ('0' + i);
        }
        for (int i = 10; i <= 15; i++) {
            UPPER_CHARS[i] = cast(char) ('A' + i - 10);
            LOWER_CHARS[i] = cast(char) ('a' + i - 10);
        }
    }
    
    public static string encode(byte[] bytes) {
        return encode(bytes, true);
    }

    public static string encode(byte[] bytes, bool upperCase) {

        if (bytes is null) {
            return null;
        }

         char[] chars = upperCase ? UPPER_CHARS : LOWER_CHARS;

        char[] hex = new char[bytes.length * 2];
        for (int i = 0; i < bytes.length; i++) {
            int b = bytes[i] & 0xFF;
            hex[i * 2] = chars[b >> 4];
            hex[i * 2 + 1] = chars[b & 0xf];
        }
        return to!string(hex);
    }

    /**
     * Decode hex string to a byte array
     * 
     * @param encoded encoded string
     * @return return array of byte to encode
     */
    static public byte[] decode(string encoded) {
        if (encoded is null) {
            return null;
        }

        int lengthData = cast(int)(encoded.length);
        if (lengthData % 2 != 0) {
            return null;
        }

        char[] binaryData = /* encoded.toCharArray() */ to!(char[])(encoded);
        int lengthDecode = lengthData / 2;
        byte[] decodedData = new byte[lengthDecode];
        byte temp1, temp2;
        char tempChar;
        for (int i = 0; i < lengthDecode; i++) {
            tempChar = binaryData[i * 2];
            temp1 = (tempChar < BASE_LENGTH) ? HEX_NUMBER_TABLE[tempChar] : -1;
            if (temp1 == -1) {
                return null;
            }
            tempChar = binaryData[i * 2 + 1];
            temp2 = (tempChar < BASE_LENGTH) ? HEX_NUMBER_TABLE[tempChar] : -1;
            if (temp2 == -1) {
                return null;
            }
            decodedData[i] = cast(byte) ((temp1 << 4) | temp2);
        }
        return decodedData;
    }
}
