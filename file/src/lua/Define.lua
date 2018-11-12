local LuaDef = {}

LuaDef.TOKEN = {}
LuaDef.TOKEN.TK_AND = 1
LuaDef.TOKEN.TK_BREAK = 2
LuaDef.TOKEN.TK_DO = 3
LuaDef.TOKEN.TK_ELSE = 4
LuaDef.TOKEN.TK_ELSEIF = 5
LuaDef.TOKEN.TK_END = 6
LuaDef.TOKEN.TK_FALSE = 7
LuaDef.TOKEN.TK_FOR = 8
LuaDef.TOKEN.TK_FUNCTION = 9
LuaDef.TOKEN.TK_GOTO = 10
LuaDef.TOKEN.TK_IF = 11
LuaDef.TOKEN.TK_IN = 12
LuaDef.TOKEN.TK_LOCAL = 13
LuaDef.TOKEN.TK_NIL = 14
LuaDef.TOKEN.TK_NOT = 15
LuaDef.TOKEN.TK_OR = 16
LuaDef.TOKEN.TK_REPEAT = 17
LuaDef.TOKEN.TK_RETURN = 18
LuaDef.TOKEN.TK_THEN = 19
LuaDef.TOKEN.TK_TRUE = 20
LuaDef.TOKEN.TK_UNTIL = 21
LuaDef.TOKEN.TK_WHILE = 22
LuaDef.TOKEN.TK_CONCAT = 23
LuaDef.TOKEN.TK_DOTS = 24
LuaDef.TOKEN.TK_EQ = 25
LuaDef.TOKEN.TK_GE = 26
LuaDef.TOKEN.TK_LE = 27
LuaDef.TOKEN.TK_NE = 28
LuaDef.TOKEN.TK_DBCOLON = 29
LuaDef.TOKEN.TK_EOS = 30
LuaDef.TOKEN.TK_NUMBER = 31
LuaDef.TOKEN.TK_NAME = 32
LuaDef.TOKEN.TK_STRING = 33

local token = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function",
    "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return",
    "then", "true", "until", "while",
    "..", "...", "==", ">=", "<=", "~=", "::",
    "<eof>", "<number>", "<name>", "<string>",
}
local index = 1
for i,v in ipairs(token) do
    LuaDef.TOKEN[v] = index
    index = index + 1
end

return LuaDef