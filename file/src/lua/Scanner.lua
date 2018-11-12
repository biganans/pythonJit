--[[
    扫描分析 Lua 文件, 按 UTF-8 字读入, 逐字分析

    分为几种状态
    * 无状态
    * 单行注释
    * 多行注释
    * 单行字符串
    * 多行字符串
    * 标识符
    * 空格

]]

local Scanner = {}

local Define = require("lua.Define")
local Util = require("Util")

local STATE_NONE            = 0 -- 无状态
local STATE_ANNO_SINGLE     = 1 -- 单行注释
local STATE_ANNO_MULTI      = 2 -- 多行注释
local STATE_STR_SINGLE      = 3 -- 单行字符串
local STATE_STR_MULTI       = 4 -- 多行字符串
local STATE_TOKEN           = 5 -- 标识符
local STATE_BLOCK           = 6 -- 空格
local mainState_ = STATE_NONE
local waitChar_ = nil -- 当前状态等待的特征字符

local data_ = nil -- 当前整个文件内容, 入参的缓存
local dataCount_ = 0 -- 文件长度
local result_ = nil -- 结果数据, 入参的缓存
local index_ = 1 -- 处理到哪儿了
local step_ = 0 -- 当前处理长度, 字节长度, 用于控制读取往后走
local charStep_ = 0 -- 当前处理的字数, 按照显示的字
local lastc_ = nil -- 往前一个
local c_ = nil -- 当前操作的字符
local lastBlackLine_ = false -- 往前一行是不是空行
local tmpStr_ = "" -- 当前待处理的串
local line_ = 1 -- 当前行
local row_ = 1 -- 当前列, 按字计算, 不按字节

local out_ = {}

local TRACE_TAG = {}
TRACE_TAG[STATE_NONE]           = "<none>"
TRACE_TAG[STATE_ANNO_SINGLE]    = "<anno_s>"
TRACE_TAG[STATE_ANNO_MULTI]     = "<anno_m>"
TRACE_TAG[STATE_STR_SINGLE]     = "<string_s>"
TRACE_TAG[STATE_STR_MULTI]      = "<string_m>"
TRACE_TAG[STATE_TOKEN]          = "<token>"
TRACE_TAG[STATE_BLOCK]          = "<block>"

local handleFunc_ = {}

---------------
-- 私有函数定义
---------------
local _init

local _outStr
local _resetState
local _changeToAnnoSingle
local _changeToAnnoMulti
local _changeToStrSingle
local _changeToStrMulti
local _changeToToken
local _changeToBlock

local _handleStateNone
local _handleStateAnnoSingle
local _handleStateAnnoMulti
local _handleStateStrSingle
local _handleStateStrMulti
local _handleStateToken
local _handleStateBlock

local _handleToken

function Scanner.scanner(str, result)

    -- 初始化变量
    data_ = str
    dataCount_ = #data_
    result_ = result
    index_ = 1
    step_ = 1
    charStep_ = 1
    lastc_ = nil
    c_ = nil
    lastBlackLine_ = false
    tmpStr_ = ""
    line_ = 1
    row_ = 1
    out_ = {}

    local ret = false
    while index_ <= dataCount_ do
        ret, c_, step_ = Util.nextUTF8Char(data_, index_, dataCount_)
        if ret then
            charStep_ = 1
            while true do
                -- print(mainState_, c_, step_)
                if handleFunc_[mainState_](c_) then
                    break
                end
            end

            -- 无状态通用处理
            if c_ == string.char(0x0A) then
                if lastc_ == " " then -- 行末空格
                    result_:addError(line_, row_, 10902)
                end

                -- 是否空行
                if 1 == row_ then
                    if lastBlackLine_ then -- 连续空行
                        result_:addError(line_, row_, 30501)
                    end
                    lastBlackLine_ = true
                else
                    lastBlackLine_ = false
                end

                line_ = line_ + 1
                row_ = 1
            else
                row_ = row_ + charStep_
            end

            -- 每行不超过 120 列，注意是<=120
            if row_ == 121 then
                result_:addError(line_, row_, 10901)
            end

        else
            Util.log("ERROR: scanner false")
        end

        lastc_ = c_
        index_ = index_ + step_
    end

    if lastc_ == " " then -- 文件末尾空格
        result_:addError(line_, row_, 10902)
    end

    -- print(table.concat(out_, "\n"))
end

---------------
-- 私有函数实现
---------------
function _init()
    handleFunc_[STATE_NONE] = _handleStateNone
    handleFunc_[STATE_ANNO_SINGLE] = _handleStateAnnoSingle
    handleFunc_[STATE_ANNO_MULTI] = _handleStateAnnoMulti
    handleFunc_[STATE_STR_SINGLE] = _handleStateStrSingle
    handleFunc_[STATE_STR_MULTI] = _handleStateStrMulti
    handleFunc_[STATE_TOKEN] = _handleStateToken
    handleFunc_[STATE_BLOCK] = _handleStateBlock

end

function _outStr()
    if #tmpStr_ > 0 then
        table.insert(out_, TRACE_TAG[mainState_] .. tmpStr_)
    end
    tmpStr_ = ""
end

function _resetState()
    _outStr()
    mainState_ = STATE_NONE
end

function _changeToAnnoSingle()
    _outStr()
    mainState_ = STATE_ANNO_SINGLE
    waitChar_ = string.char(0x0A)
end

function _changeToAnnoMulti()
    _outStr()
    mainState_ = STATE_ANNO_MULTI
    waitChar_ = "]"
end

function _changeToStrSingle(c)
    _outStr()
    mainState_ = STATE_STR_SINGLE
    waitChar_ = c
end

function _changeToStrMulti()
    _outStr()
    mainState_ = STATE_STR_MULTI
    waitChar_ = "]"
end

function _changeToToken(c)
    _outStr()
    mainState_ = STATE_TOKEN
    tmpStr_ = c
end

function _changeToBlock(c)
    _outStr()
    mainState_ = STATE_BLOCK
    tmpStr_ = c
end

function _handleStateNone(c)
    if step_ == 1 then
        if Util.isLuaChar(c) then -- 有效标识符
            _changeToToken(c)
        elseif c == '"'
            or c == "'"
            then -- 单行字符串
            _changeToStrSingle(c)
        elseif c == "[" then -- 多行字符串
            if Util.isStartBy(data_, index_, dataCount_, "[[", 2) then
                _changeToStrMulti()
                step_ = 2
                charStep_ = 2
            end
        elseif c == "-" then -- 注释
            if Util.isStartBy(data_, index_, dataCount_, "--[[", 4) then
                _changeToAnnoMulti()
                step_ = 4
                charStep_ = 4
            elseif Util.isStartBy(data_, index_, dataCount_, "--", 2) then
                _changeToAnnoSingle()
                step_ = 2
                charStep_ = 2
            end
        elseif c == string.char(0x0A) then -- LF 跳过
            _outStr()
        elseif c == " " then -- 空格, 跳过
            _changeToBlock(c)
        else
            _outStr()
            tmpStr_ = c
        end
    else -- 非 ASCII
        Util.log("ERROR: _handleStateNone, c is not ASCII")
    end
    return true
end

function _handleStateAnnoSingle(c)
    if c == waitChar_ then
        _resetState()
    else
        tmpStr_ = tmpStr_ .. c
    end
    return true
end

function _handleStateAnnoMulti(c)
    if c == waitChar_ and Util.isStartBy(data_, index_, dataCount_, "]]", 2) then
        _resetState()
        step_ = 2
    else
        tmpStr_ = tmpStr_ .. c
    end
    return true
end

function _handleStateStrSingle(c)
    if c == waitChar_ and not Util.isEscape(data_, index_) then
        _resetState()
    else
        tmpStr_ = tmpStr_ .. c
    end
    return true
end

function _handleStateStrMulti(c)
    if c == waitChar_ and Util.isStartBy(data_, index_, dataCount_, "]]", 2) then
        _resetState()
        step_ = 2
    else
        tmpStr_ = tmpStr_ .. c
    end
    return true
end

function _handleStateToken(c)
    local ret = true
    if Util.isLuaChar(c) then
        tmpStr_ = tmpStr_ .. c
    else
        _handleToken(tmpStr_)
        _resetState()
        ret = false
    end
    return ret
end

function _handleStateBlock(c)
    local ret = true
    if c == " " then
        tmpStr_ = tmpStr_ .. c
    else
        ret = false
        -- 空格结束
        if (#tmpStr_ == row_ - 1) and (#tmpStr_%4 ~= 0) then
            result_:addError(line_, row_, 30101)
        end

        _resetState()
    end
    return ret
end

function _handleToken(token)
    -- print(token)
end

_init()
return Scanner
