--[[--
    结果管理
]]
local Result = {}

local ResultDef = require("ResultDef")

local data_ = {}
local totalError_ = 0
local totalWarning_ = 0
local totalFile_ = 0

---------------
-- 私有函数定义
---------------
local _addFile
local _addJumpFile
local _addOne

--[[--
    添加结果
    * params
        * path: 文件路径
        * error: table
        * warning: table
            * line: 哪一行
            * row: 哪一列
            * code: 错误码
            * prompt: 提示语
        * jump: 跳过该文件
]]
function Result.add(params)
    if not params then
        print("ERR: params is nil")
        return
    end

    if params.jump then
        _addJumpFile(params.path)
        return
    end

    local filePath = tostring(params.path) or "unknown path"
    local errorCount = #params.error
    local warningCount = #params.warning

    totalError_ = totalError_ + errorCount
    totalWarning_ = totalWarning_ + warningCount
    totalFile_ = totalFile_ + 1

    _addFile(filePath, errorCount, warningCount)
    if errorCount > 0 or warningCount > 0 then
        if ResultDef.OUTPUT_SEPARATE then
            _addEmptyLine()
        end
    end
    for i,v in ipairs(params.error) do
        _addOne("E", filePath, v.line, v.row, v.code, v.prompt)
    end
    for i,v in ipairs(params.warning) do
        _addOne("W", filePath, v.line, v.row, v.code, v.prompt)
    end
    if errorCount > 0 or warningCount > 0 then
        if ResultDef.OUTPUT_SEPARATE then
            _addEmptyLine()
        end
    end
end

--[[--
    将收集的内容按格式输出, 返回字符串
]]
function Result.output()
    -- 汇总输出
    table.insert(data_, string.format(
        "Total: %d errors / %d warnings in %d file",
        totalError_, totalWarning_, totalFile_))
    table.insert(data_, "") -- shell 最后一行得为空行
    return table.concat(data_, "\n")
end

function Result.newItem(path)
    local item = {}
    item.path = path
    item.error = {}
    item.warning = {}
    item.jump = true

    function item:setJump(flag)
        self.jump = flag
    end

    function item:addError(line, row, code, prompt)
        local item = {}
        item.line = line
        item.row = row
        item.code = code
        item.prompt = prompt
        table.insert(self.error, item)
    end

    function item:addWarning(line, row, code, prompt)
        local item = {}
        item.line = line
        item.row = row
        item.code = code
        item.prompt = prompt
        table.insert(self.warning, item)
    end

    return item
end

function Result.getTotalError()
    return totalError_
end

function Result.getTotalWarning()
    return totalWarning_
end

function Result.getTotalFile()
    return totalFile_
end

---------------
-- 私有函数定义
---------------
function _addFile(filePath, errorCount, warningCount)
    if not ResultDef.OUTPUT_FILE_SUMMAR then
        return
    end

    if errorCount > 0 and warningCount > 0 then
        table.insert(data_, string.format(
            "Checking %s        %d errors / %d warnings",
            filePath, errorCount, warningCount))
    elseif errorCount > 0 then
        table.insert(data_, string.format("Checking %s        %d errors", filePath, errorCount))
    elseif warningCount > 0 then
        table.insert(data_, string.format("Checking %s        %d warnings", filePath, warningCount))
    else
        table.insert(data_, string.format("Checking %s        OK", filePath))
    end
end

function _addJumpFile(filePath)
    if ResultDef.OUTPUT_JUMP then
        table.insert(data_, string.format("Jump %s", filePath))
    end
end

function _addOne(tag, filePath, line, row, code, prompt)
    local tag = tostring(tag) or "U"
    local filePath = tostring(filePath) or "unknown path"
    local line = tonumber(line) or 0
    local row = tonumber(row) or 0
    local code = tostring(code) or "0"
    local prompt = tostring(prompt)

    -- prompt 是无效数据, 则使用 code 对应的默认
    if not prompt or prompt == "nil" or prompt == "" then
        prompt = ResultDef.LUA_PROMPT[code]
        if not prompt then
            prompt = ""
        end
    end

    table.insert(data_, string.format("-   %s:%d:%d:[%s%s]    %s", filePath, line, row, tag, code, prompt))
end

function _addEmptyLine()
    table.insert(data_, "")
end

return Result