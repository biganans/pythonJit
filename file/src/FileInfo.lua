--[[
    文件信息
    * path
    * pathInfo
        * basename
        * dirname
        * extname
        * filename
    * formatInfo
        * bom     bool
        * utf     bool
        * crlf    bool
    * src: 文件内容
]]
local FileInfo = {}

function FileInfo.new(path)
    local info = {}
    info.path = path
    info.formatInfo = {}
    return info
end

return FileInfo