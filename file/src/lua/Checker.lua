--[[
    检查 Lua 文件是否符合编码规范
]]
local Checker = {}

local Util = require("Util")
local Result = require("Result")
local ResultDef = require("ResultDef")
local Scanner = require("lua.Scanner")

local CRLF = string.char(0x0D) .. string.char(0x0A)
local BOM = "\239\187\191"
local BOM_LEN = 3
local func_ = {}

---------------
-- 私有函数定义
---------------
local _init
local _checkFileName
local _checkBOM
local _checkUTF8
local _checkCRLF
local _lua_01_01

function Checker.check(info)

    -- 先检查文件名
    if not _checkFileName(info) then
        return
    end

    info.src = Util.readFile(info.path)
    -- 空文件
    if not info.src or string.len(info.src) == 0 then
        info.result:addWarning(0, 0, 90101)
        return
    end

    -- BOM 头
    if _checkBOM(info.src) then
        info.formatInfo.bom = true
        info.result:addError(0, 0, 10101)
        return
    end

    -- UTF-8 编码
    if not _checkUTF8(info.src) then
        info.formatInfo.utf = false
        info.result:addError(0, 0, 10101)
        return
    end

    -- 换行格式
    if _checkCRLF(info.src) then
        info.formatInfo.crlf = true
        info.result:addError(0, 0, 10103)
        return
    end

    Scanner.scanner(info.src, info.result)

    -- for _, f in ipairs(func_) do
    --     f(info)
    -- end
end

---------------
-- 私有函数实现
---------------
function _init()
    table.insert(func_, _lua_01_01)
end

-- 文件名是否符合规范
function _checkFileName(info)
    local ret = true
    -- 文件名只能包含 ascii 字符
    for i=1, #info.pathInfo.filename do
        if not Util.isAscii(string.byte(info.pathInfo.filename, i)) then
            info.result:addError(0, 0, 10102)
            ret = false
            break
        end
    end

    -- 大驼峰命名
    -- 跳过 config.lua / protobuf.lua
    if not ("config.lua" == info.pathInfo.filename
        or "protobuf.lua" == info.pathInfo.filename) then
        local firstC = string.byte(info.pathInfo.filename, i)
        if firstC < 0x41 or firstC > 0x5A then -- A ~ Z
            info.result:addError(0, 0, 20101)
            ret = false
        end
    end

    -- 以小写 .lua 结尾
    if info.pathInfo.extname ~= ".lua" then
        info.result:addError(0, 0, 20101)
        ret = false
    end

    return ret
end

-- 是否 BOM 头
function _checkBOM(src)
    local ret = false
    if src and src:sub(1, BOM_LEN) == BOM then
        ret = true
    end
    return ret
end

-- 是否 UTF-8
function _checkUTF8(src)
    local ret = false
    if src then
        ret = Util.isUTF8Str(src)
    end
    return ret
end

-- 是否 CRLF
function _checkCRLF(src)
    local ret = false
    if src then
        ret = string.find(src, CRLF)
    end
    return ret
end

-- run
_init()

return Checker
