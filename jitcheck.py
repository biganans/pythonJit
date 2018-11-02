# -*- coding: utf-8 -*-
import os
import shutil
import tkinter
#import sys

#模块名
moudle = ""
#jit程序
jitName = "luajit-win32.exe"
#输出加密文件
outFiles = "_jitTemp"
#过滤文件夹
fitlerFileName = [".git","IgnoreDir","res"]
#过滤当前目录
fitlerDir = ["framework","sdk","upgrade","test"]

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
    #         moudle = arg
    path = ".\\"

    welcome = "欢迎使用Jitcheck\n请确保luajit-win32.exe的环境正确配置\n再选择moudle检测"
    selectDir = []
    #遍历当前的目录
    for parent,dirnames,filenames in os.walk(path):
        for dirname in dirnames:
            if dirname not in fitlerDir:
                selectDir.append(dirname)
        break
    # print(selectDir)

    #创建窗体
    root = tkinter.Tk(className="jitcheck")
    root.geometry('400x500+550+100')     # 设置弹出框的大小 w x h

    var = tkinter.StringVar()
    var.set("检测moudle[无]")

    fm1 = tkinter.Frame(root,height=160,width=480)
    fm1.pack(ipady=4,anchor="w")
    lb1 = tkinter.Label(fm1,text=welcome,fg='green',font=30,justify="left",anchor="w").pack(fill="x")
    lb0 = tkinter.Label(fm1,text="请选择文件夹名字:",font=30,anchor="w").pack(side="left",fill="x")


    fm0 = tkinter.Frame(root,height=160,width=480)
    lb2 = tkinter.Label(fm0,textvariable=var,fg='red',font=30,anchor="w").pack(side="left")
    fm0.pack(ipady=4,anchor="w")

    fm2 = tkinter.Frame(root,height=160,width=480)
    fm2.pack(padx = 10,anchor="w")
    listbox = tkinter.Listbox(fm2,selectmode="single")
    listbox.pack(expand=1,fill="both",pady=20,side="left")
    for item in selectDir:
        listbox.insert(tkinter.END,item)

    listbox.see(0)
    sl = tkinter.Scrollbar(fm2)
    sl.pack(side = "right",fill = "y")
    listbox['yscrollcommand'] = sl.set
    sl['command'] = listbox.yview

    if len(selectDir) > 0:
        listbox.selection_set(0)
        moudle = selectDir[0]
        var.set("检测moudle["+moudle+"]")

    def prinfItem(event):
        global moudle
        index = listbox.curselection()
        if len(index) > 0 :
            print("index",index)
            moudle = selectDir[index[0]]
            print("moudle",moudle)
            var.set("检测moudle["+moudle+"]")
            root.update()

        print(listbox.curselection())

    listbox.bind('<ButtonRelease-1>',prinfItem)

    def dealFile():
        global moudle
        if moudle != "" :
            root.destroy()

    fm4 = tkinter.Frame(root,height=160,width=480)
    fm4.pack(ipady=4,anchor="w")
    btn = tkinter.Button(fm4,text="开始检测",command=dealFile).pack(side="right")


    root.mainloop()

    print("start check lua jit moudle::[[",moudle,"]]")

    resourePath = os.path.join(path,moudle)
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
    os.system("pause")
