# -*- coding: utf-8 -*-
#选择文件夹模式
import os
import shutil
import tkinter
import tkinter.messagebox
from tkinter.filedialog import askdirectory

#过滤当前目录
fitlerDir = ["framework","game","hall","sdk","upgrade","jltest",".git","IgnoreDir","res"]

module = ""
path = ""

if __name__ == "__main__":

    welcome = "欢迎使用JJCheck\n请确保lua.exe的环境正确配置\n再选择module文件夹进行格式检测\n最后的错误列表会存在当前目录的error.txt文件中\n需要反复运行此脚本直到出现\nTotal: 0 errors / 0 warnings in xx file"
    selectDir = []

    #读取配置文件_path.ini
    wordsIniPath = "./_path.ini"
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
        print("当前没有words.ini配置文件，生成文件.")
        f = open(wordsIniPath,'a',encoding='utf-8')
        f.close()

    print("path",path)

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
    root = tkinter.Tk(className="JJCheck")
    root.geometry('700x500+550+100')     # 设置弹出框的大小 w x h

    varPath = tkinter.StringVar()

    def butClick():
        global module,path
        #清理掉上次文件夹的文件
        listbox.delete(0,tkinter.END)

        _p = askdirectory()
        # print("哎哟，按钮按下了",_p)
        #是否是module目录
        path = _p
        checkList()

    var = tkinter.StringVar()
    var.set("检测moudle[无]")

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

    if module != "" :
        f = open(wordsIniPath,'w',encoding='utf-8')
        f.write(path)
        f.close()
        print("start check dir::[[",module,"]]")
        cdir = os.path.join(path,module)
        os.system("cd ./")
        run = "lua -e \"package.path=[[./src/?.lua;]]..package.path\" ./src/Check.lua -output ./error.txt "+ cdir
        # print(run)
        os.system(run)
    else:
        print("没有选择目录，或者目录为空.")
