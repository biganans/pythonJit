# -*- coding: utf-8 -*-
import os
import shutil
import tkinter
import tkinter.messagebox
from tkinter.filedialog import askdirectory
#import sys

#模块名
module = "runfast"
#jit程序
jitName = "luajit-win32.exe"
#输出加密文件
outFiles = "_jitTemp"
#过滤文件夹
fitlerFileName = [".git","IgnoreDir","res"]
#过滤当前目录
fitlerDir = ["framework","game","hall","sdk","upgrade"]

def checkFile(name):
    for fName in fitlerFileName:
        if fName in name:
            return 0
    return 1


def checkLua(name):
    lName = name[-4:]
    if lName == ".lua":
        return 1
    return 0

if __name__ == "__main__":
    #是否后面有参数
    # if len(sys.argv) > 1:
    #     arg = sys.argv[1]
    #     if arg:
    #         module = arg
    path = ""

    welcome = "欢迎使用Jitcheck\n请确保luajit-win32.exe的环境正确配置\n选择对应的文件夹\n再选择module检测"

    #读取配置文件_path.ini
    wordsIniPath = "./_jitpath.ini"
    if os.path.exists(wordsIniPath):
        words = open(wordsIniPath,'r',encoding='utf-8')
        # print("words",words)
        try:
            line = words.readlines()
            if len(line) > 0:
                path = line[0]
        finally:
            words.close()
    else:
        # print("当前没有_jitpath.ini配置文件，生成文件.")
        f = open(wordsIniPath,'a',encoding='utf-8')
        f.close()

    print("path",path)

    selectDir = []

    def checkDir():
        global selectDir,path
        selectDir = []
        #遍历当前的目录
        for parent,dirnames,filenames in os.walk(path):
            for dirname in dirnames:
                if dirname not in fitlerDir:
                    selectDir.append(dirname)
            break

    def checkList():
        global module,path
        varPath.set(path)
        checkDir()
        # print("selectDir",selectDir)

        for item in selectDir:
            listbox.insert(tkinter.END,item)

        if len(selectDir) > 0:
            listbox.selection_set(0)
            module = selectDir[0]
            var.set("检测目录["+module+"]")

        listbox.see(0)

    #创建窗体
    root = tkinter.Tk(className="Jitcheck")
    root.geometry('400x500+550+100')     # 设置弹出框的大小 w x h

    varPath = tkinter.StringVar()

    def butClick():
        global module,path
        #清理掉上次文件夹的文件
        listbox.delete(0,tkinter.END)

        _p = askdirectory()
        # print("哎哟，按钮按下了",_p)
        #是否是module目录
        path = _p
        if path != "" and len(path) >0 and path[0] != "":
            checkList()
        else:
            varPath.set("当前没有设置文件夹目录")
            module = ""
            var.set("检测目录["+module+"]")

    var = tkinter.StringVar()
    var.set("检测module[无]")

    fm1 = tkinter.Frame(root,height=160,width=480)
    fm1.pack(ipady=4,anchor="w")
    lb1 = tkinter.Label(fm1,text=welcome,fg='green',font=30,justify="left",anchor="w").pack(fill="x")

    fm2 = tkinter.Frame(root,height=160,width=480)
    lb0 = tkinter.Button(fm1,text="请选择文件夹名字",font=30,anchor="w",command=butClick).pack(side="left",fill="x")
    lb2 = tkinter.Label(fm2,textvariable=varPath,fg='red',font=30,anchor="w").pack(side="left")
    fm2.pack(ipady=4,anchor="w")

    fm3 = tkinter.Frame(root,height=160,width=480)
    lb2 = tkinter.Label(fm3,textvariable=var,fg='red',font=30,anchor="w").pack(side="left")
    fm3.pack(ipady=4,anchor="w")

    fm4 = tkinter.Frame(root,height=160,width=480)
    fm4.pack(padx = 10,anchor="w")
    listbox = tkinter.Listbox(fm4,selectmode="single")
    listbox.pack(expand=1,fill="both",pady=20,side="left")


    sl = tkinter.Scrollbar(fm4)
    sl.pack(side = "right",fill = "y")
    listbox['yscrollcommand'] = sl.set
    sl['command'] = listbox.yview

    def prinfItem(event):
        global module
        index = listbox.curselection()
        if len(index) > 0 :
            # print("index",index)
            module = selectDir[index[0]]
            # print("module",module)
            var.set("检测目录["+module+"]")
            root.update()

        # print(listbox.curselection())

    listbox.bind('<ButtonRelease-1>',prinfItem)

    def dealFile():
        global module
        if module != "" :
            root.destroy()
        else:
            tkinter.messagebox.showerror("错误", "请选择有效目录再进行操作")
            return

    fm4 = tkinter.Frame(root,height=160,width=480)
    fm4.pack(ipady=4,anchor="w")
    btn = tkinter.Button(fm4,text="开始检测",command=dealFile).pack(side="right")

    if path != "" and len(path) >0 and path[0] != "":
        checkList()
    else:
        varPath.set("当前没有设置文件夹目录")

    root.mainloop()

    print("start check lua jit module::[[",module,"]]")

    if module != "" :
        f = open(wordsIniPath,'w',encoding='utf-8')
        f.write(path)
        f.close()

        resourePath = os.path.join(path,module)
        outPath = os.path.join(path,outFiles)

        if not os.path.exists(outPath):
            # print("makedir ",outPath)
            os.makedirs(outPath)
        else:
            shutil.rmtree(outPath)
            os.makedirs(outPath)

        # print("resourePath",resourePath)
        i= 1
        for parent,dirnames,filenames in os.walk(resourePath):
            # print("parent",parent,"dirnames ",dirnames," filenames ",filenames)
            #创建文件夹
            if checkFile(parent) > 0 :
                print("deal dir",parent)
                i = i + 1
                oPath = os.path.join(outPath,parent)
                if not os.path.exists(oPath):
                    # print("oPath ",oPath)
                    os.makedirs(oPath)

                for fileName in filenames:
                    srcpath = os.path.join(parent,fileName)
                    oPath = os.path.join(outPath,parent,fileName)
                    # print("srcpath",srcpath)
                    # print("oPath",oPath)
                    if checkLua(fileName) > 0:
                        #执行加密
                        jiami = jitName + " -b "+srcpath+" "+oPath
                        # print("jiami ",jiami)
                        os.system(jiami)
            # break

        #检查完毕后删除文件
        shutil.rmtree(outPath)
    else:
        print("没有选择目录，或者目录为空.")
    os.system("pause")
