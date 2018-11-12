local Util = {}

local lfs = lfs
if not lfs then
    lfs = require("lfs")
end

local DEBUG_FILE = false -- shell 调用模式下调试用, 命令行模式不要用
local logFile_ = nil

-- shell 调用时无输出, 保存日志到文件
function Util.log(...)
    print(...)
    if not DEBUG_FILE then
        return
    end

    if not logFile_ then
        logFile_ = io.open("log.log", "w+")
    end

    if logFile_ then
        logFile_:write(...)
        logFile_:write("\n")
    end
end

function Util.vardump(object, label)
    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local function _vardump(object, label, indent, nest)
        label = label or "<var>"
        local postfix = ""
        if nest > 1 then postfix = "," end
        if type(object) ~= "table" then
            if type(label) == "string" then
                result[#result +1] = string.format("%s%s = %s%s", indent, label, _v(object), postfix)
            else
                result[#result +1] = string.format("%s%s%s", indent, _v(object), postfix)
            end
        elseif not lookupTable[object] then
            lookupTable[object] = true

            if type(label) == "string" then
                result[#result +1 ] = string.format("%s%s = {", indent, label)
            else
                result[#result +1 ] = string.format("%s{", indent)
            end
            local indent2 = indent .. "    "
            local keys = {}
            local values = {}
            for k, v in pairs(object) do
                keys[#keys + 1] = k
                values[k] = v
            end
            table.sort(keys, function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                else
                    return tostring(a) < tostring(b)
                end
            end)
            for i, k in ipairs(keys) do
                _vardump(values[k], k, indent2, nest + 1)
            end
            result[#result +1] = string.format("%s}%s", indent, postfix)
        end
    end
    _vardump(object, label, "", 1)

    return table.concat(result, "\n")
end

function Util.isFolder(path)
    local attr = lfs.attributes(path)
    if attr then
        return attr.mode == "directory"
    end
    return false
end

function Util.getDir(path)
    local files = {}
    for entry in lfs.dir(path) do
        if entry ~= '.' and entry ~= '..' then
            if string.sub(path, string.len(path)) == "/" then
                table.insert(files, path .. entry)
            else
                table.insert(files, path .. '/' .. entry)
            end
        end
    end
    return files
end

function Util.getPathInfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        elseif b == 92 then -- 92 = char "\"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function Util.readFile(path)
    local str = nil
    if path then
        local f = io.open(path, "rb")
        if f then
            str = f:read("*a")
            f:close()
        else
            Util.log("ERROR, readFile can't open ", path)
        end
    else
        Util.log("ERROR, readFile path is nil")
    end
    return str
end

function Util.isAscii(byte)
    if byte > 127 then
        return false
    else
        return true
    end
end

function Util.isUTF8Str(str)
    local ret = true
    if str then
        local index = 1
        local count = #str
        local first = nil
        local second = nil
        local third = nil

        while true do
            first = string.byte(str, index)
            if first < 0x80 then -- 小于 0x80 的为 ASCII 字符
                index = index + 1
            elseif first < 0xC0 then -- 0x80 与 0xC0 之间为无效 UTF-8 字符
                -- Util.log(string.format("isUTF8Str ERROR: 1 0x%x", first))
                ret = false
                break
            elseif first < 0xE0 then -- 首字符小于 0xE0 为双字节 UTF-8 字符
                second = string.byte(str, index + 1)
                -- 第二字节为 10XXXXXX
                if second < 0x80 or second > 0xBF then
                    -- Util.log(string.format("isUTF8Str ERROR: 2 0x%x, 0x%x", first, second))
                    ret = false
                    break
                end
                index = index + 2
            elseif first < 0xF0 then -- 首字符小于 0xF0 为三字节 UTF-8 字符
                second = string.byte(str, index + 1)
                third = string.byte(str, index + 2)
                -- 第二字节为 10XXXXXX, 第三字节为 10XXXXXX
                if second < 0x80 or second > 0xBF
                    or third < 0x80 or third > 0xBF then
                    -- Util.log(string.format("isUTF8Str ERROR: 3 0x%x, 0x%x, 0x%x", first, second, third))
                    ret = false
                    break
                end
                index = index + 3
            else
                ret = false
                break
            end

            if index > count then
                break
            end
        end
    end
    return ret
end

function Util.isBOM(str)
    local ret = false
    if str and 3 == string.len(str)
        and 0xEF == string.byte(str, 1)
        and 0xBB == string.byte(str, 2)
        and 0xBF == string.byte(str, 3) then
        ret = true
    end
    return ret
end

--[[--
    获取下一个 UTF-8 字符, 包括 ASCII
    @param str: 内容
    @param index: 从什么位置开始
    @param count: str 的长度

    @return
        - ret: 是否正确
        - c: 一个 UTF-8 字
        - step: 字长
]]
function Util.nextUTF8Char(str, index, count)
    local ret = true
    local c = nil
    local step = 0

    if not count then
        count = #str
    end

    if index > count then
        Util.log("ERROR: nextUTF8Char str length is less index")
        return ret
    end

    local first = string.byte(str, index)
    if first < 0x80 then
        c = string.char(first)
        step = 1
    elseif first < 0xC0 then -- 0x80 与 0xC0 之间为无效 UTF-8 字符
        Util.log(string.format("ERROR: nextUTF8Char 1 0x%x", first))
        ret = false
    elseif first < 0xE0 then -- 首字符小于 0xE0 为双字节 UTF-8 字符
        if index < count then
            local second = string.byte(str, index + 1)
            -- 第二字节为 10XXXXXX
            if second < 0x80 or second > 0xBF then
                Util.log(string.format("ERROR: nextUTF8Char 2 0x%x, 0x%x", first, second))
                ret = false
            else
                c = string.char(first) .. string.char(second)
                step = 2
            end
        else
            Util.log("ERROR: nextUTF8Char not have second")
            ret = false
        end
    elseif first < 0xF0 then -- 首字符小于 0xF0 为三字节 UTF-8 字符
        if index < count -1 then
            local second = string.byte(str, index + 1)
            local third = string.byte(str, index + 2)
            -- 第二字节为 10XXXXXX, 第三字节为 10XXXXXX
            if second < 0x80 or second > 0xBF
                or third < 0x80 or third > 0xBF then
                Util.log(string.format("ERROR: nextUTF8Char 3 0x%x, 0x%x, 0x%x", first, second, third))
                ret = false
            else
                c = string.char(first) .. string.char(second) .. string.char(third)
                step = 3
            end
        else
            Util.log("ERROR: nextUTF8Char not have second or third")
            ret = false
        end
    else
        Util.log("ERROR: nextUTF8Char first is out range")
        ret = false
    end

    return ret, c, step
end

-- 数字, 字母, 下划线
function Util.isLuaChar(c)
    local c = string.byte(c, 1)
    if (c >= 0x30 and c <= 0x39)        -- 0 ~ 9
        or (c >= 0x41 and c <= 0x5A)    -- A ~ Z
        or (c >= 0x61 and c <= 0x7A)    -- a ~ z
        or c == 0x5F then               -- _
        return true
    end
    return false
end

-- 查找是否从这儿开始是这个特征串
function Util.isStartBy(str, index, count, tag, tagCount)
    local ret = false
    if tag and tagCount and (index + tagCount <= count)
        and string.sub(str, index, index + tagCount - 1) == tag then
        ret = true
    end
    return ret
end

-- 该字符是否被转义: 前提是该字符处于字符串中, 该字符前的 \ 是否连续奇数个
function Util.isEscape(str, index)
    local index = index - 1
    local ret = false
    local char = nil

    while index >= 1 do
        char = string.sub(str, index, index)
        if char and char == "\\" then
            if ret then
                ret = false
            else
                ret = true
            end
            index = index - 1
        else
            break
        end
    end

    return ret
end

return Util