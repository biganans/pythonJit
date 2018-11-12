--[[--

    根据代码规范做一些静态检查, 目前只针对 Lua 文件
    ./run [-output resultfile] filepath
]]
local Util = require("Util")
local FileInfo = require("FileInfo")
local Result = require("Result")
local Checker = require("lua.Checker")

local outputPath_ = nil
local rootPath_ = nil -- 当前的根目录

---------------
-- 函数定义
---------------
local _run
local _checkItem
local _checkFolder
local _checkFile
local _output

---------------
-- 函数实现
---------------
function _run()

    if arg[1] == "-output" then
        outputPath_ = arg[2]
        local f = io.open(outputPath_, "w+")
        if f then
            f:close()
        else
            Util.log("ERROR: ", outputPath_, " can't open")
            return
        end
    end

    for i,v in ipairs(arg) do
        if outputPath_ and (i == 1 or i == 2) then
        else
            if Util.isFolder(v) then
                if string.sub(v, string.len(v)) == "/" then
                    rootPath_ = v
                else
                    rootPath_ = v .. "/"
                end
            else
                rootPath_ = nil
            end
            _checkItem(v)
        end
    end

    _output()
end

function _checkItem(path)
    if Util.isFolder(path) then
        _checkFolder(path)
    else
        local item = _checkFile(path)
        if item then
            -- 从项目目录输出, 不从绝对路径
            if rootPath_ and string.find(item.path, rootPath_) then
                item.path = string.sub(item.path, string.len(rootPath_))
            end
            Result.add(item)
        end
    end
end

function _checkFolder(path)
    local files = Util.getDir(path)
    for i,v in ipairs(files) do
        _checkItem(v)
    end
end

function _checkFile(path)
    local info = FileInfo.new(path)
    info.pathInfo = Util.getPathInfo(path)
    info.result = Result.newItem(path)

    -- 跳过某些文件
    if string.find(path, "/pb/proto/")
        or string.find(path, "/res/")
        or string.find(path, ".git/") then

    elseif string.lower(info.pathInfo.extname) == ".lua" then
        info.result:setJump(false)
        Checker.check(info)
    end

    return info.result
end

function _output()
    local result = Result.output()
    if outputPath_ then
        local f = io.open(outputPath_, "w+")
        if f then
            f:write(result)
            f:flush()
            f:close()
        else
            Util.log("ERROR: ", outputPath_, " can't open")
        end
    else
        print(result)
    end
end

---------------
-- 启动
---------------
_run()
