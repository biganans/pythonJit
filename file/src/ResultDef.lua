--[[
    相关定义
]]
local def = {}

def.OUTPUT_JUMP = false -- 是否输出跳过的文件
def.OUTPUT_FILE_SUMMAR = false -- 是否输出单个文件汇总信息
def.OUTPUT_SEPARATE = false -- 是否输出空行作为分隔

-- 类型
def.ERROR = 1
def.WARNING = 2

-- 文件类型
def.LUA = 1
def.CPP = 2
def.JS = 3

------------------
-- Code 定义 x xx xx
-- 1     表示大类
-- 2 ~ 3 表示二级条目
-- 4 ~ 5 表示该条目中的细则
------------------
-- 提示
def.LUA_PROMPT = {
-- 已支持
["10101"] = "文件格式不对, 应该采用 UTF-8 无 BOM 编码",
["10102"] = "文件名不能包含非 ASCII 字符",
["10103"] = "回车换行应使用 unix 方式（仅包含 LF, 没有 CRLF）",

["10901"] = "行长超过 120",
["10902"] = "行末不允许有空格",
["20101"] = "文件名使用大驼峰命名, 后缀使用小写的 lua",

["30101"] = "代码缩进为 4 个空格",
["30501"] = "不允许连续的空行",

-- 规范外的
["90101"] = "空文件",

-- 未支持
["10201"] = "对于类文件(使用 class 定义的), 所有成员变量必须在 ctor 中进行声明并赋初值",
["10301"] = "非类文件中变量必须使用 local",
["10401"] = "文件头要有本文件的功能描述注释, 类文件成员变量要有注释说明",
["10501"] = "函数要有接口说明注释, 包括功能描述, 参数和返回值说明, 注意事项等",
["10601"] = "不允许使用全局变量",
["10701"] = "文件中使用的导入文件, 需要在文件头导入, 不能每次用的时候导入. 导入赋值为 local 变量, 变量名和文件名一致",
["10801"] = "== 比较时, 常量放左边",
["11001"] = "运算符优先级不同时必须使用小括号来规定运算顺序",
["11101"] = "函数返回值需要赋初值",
["11201"] = "布尔型和非空判断不使用 ==",
["11301"] = "取数组长度使用 #",
["11401"] = "文件内使用的本地函数, 需要在文件头部声明, 文件末尾实现",
["11501"] = "类的成员变量, 都通过接口来访问, 不能在外部直接引用",

["20201"] = "本地变量、成员变量、成员函数使用小驼峰命名",
["20301"] = "常量, 枚举定义使用大写, 用下划线 “_” 分隔单词",
["20401"] = "类成员变量, 文件内的本地变量加下划线后缀",
["20501"] = "本地函数加下划线前缀",
["20601"] = "变量名绕开系统保留字",

["30201"] = "比较符(~=、==、>、>=、<、<=), 连接符(..), 运算符(+、-、*、/、%、^) 左右需要有空格; 逗号前不需要空格, 逗号后需要有空格; 括号不需要空格",
["30301"] = "函数之间用空行隔开",
["30401"] = "代码块之间用空行隔开",
["30601"] = "if、for、while、do、else 等语句单独一行",
["30701"] = "函数最大行数 120, 包括空行",

["40101"] = "单行注释使用 --",
["40201"] = "多行注释使用 Lua 格式",
["40401"] = "独立成行的注释, 上方需要空行, 下方不需要",

["50101"] = "对变量进行有效性判断后再使用, 包括入参, 函数返回值, 外部变量",
["50201"] = "使用 .. 时, 确保两边的参数不为空, 对非字符串常量需要加上 tostring",

-- warning
["60201"] = "函数尽量保持只有一个 return 语句",
["60301"] = "一行只声明一个变量",

}

def.CPP_PROMPT = {}

def.JS_PROMPT = {}

return def