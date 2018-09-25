
module hunt.sql.parser.LayoutCharacters;

interface LayoutCharacters {

    /**
     * Tabulator column increment.
     */
    const static int  TabInc = 8;

    /**
     * Tabulator character.
     */
    const static byte TAB    = 0x8;

    /**
     * Line feed character.
     */
    const static byte LF     = 0xA;

    /**
     * Form feed character.
     */
    const static byte FF     = 0xC;

    /**
     * Carriage return character.
     */
    const static byte CR     = 0xD;

    /**
     * End of input character. Used as a sentinel to denote the character one beyond the last defined character in a
     * source file.
     */
    const static byte EOI    = 0x1A;
}
