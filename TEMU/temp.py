#!/usr/bin/env python3
# -*- coding:utf-8 -*-

import tkinter
from tkinter import messagebox, scrolledtext
import subprocess
import select
import os
import signal
import shutil
import _thread
import threading
import subprocess
from tkinter.constants import BOTH, BOTTOM, LEFT, RIGHT, TRUE
from tkinter.filedialog import(askdirectory, askopenfilename, askopenfilenames, asksaveasfilename)

WINDOW_SIZE = "1960x1020"

# Run Button
btn_upd = None
# Output textbox
txt_out = None
# current script job/process
cur_process = None
# mark if Tk is closing
close_flag = False
# Tk root
root = tkinter.Tk()


def disable_allbtn():
    global close_flag
    global btn_upd
    if close_flag:
        return
    btn_upd.configure(state=tkinter.DISABLED)

def enable_allbtn():
    global close_flag
    global btn_upd
    if close_flag:
        return
    btn_upd.configure(state=tkinter.NORMAL)

def read_file() :
    global direct
    direct=askopenfilename(title='Select a Assemble File', initialdir='/home', filetypes=[('Assemble file','*.S')])
    # print('directory is %s' %direct)
    path=os.path.abspath(os.path.dirname(__file__))
    path=path+'/mips_sc/src/temp.S'
    shutil.copyfile(direct, path)  # 复制文件
    path1=os.path.abspath(os.path.dirname(__file__))
    path1=path1+'/mips_sc/src/Makefile.testcase'
    f=open(path1, 'w')
    f.write('USER_PROGRAM := temp')

def exe_make():
    #current_path=os.path.abspath(os.path.dirname(__file__))
    #print(current_path)
    # current_path=
    # current_path=current_path+'/gui.sh'
    sub=subprocess.Popen("make clean && cd mips_sc/ && make",shell=TRUE, stdout=subprocess.PIPE) 
    sub.wait()
    txt_out.insert(tkinter.INSERT,  sub.stdout.read())
    txt_out.insert(tkinter.INSERT,  "Complie succeed!\n")


def cb_runbash_withoutput(script):
    global cur_process
    global txt_out
    global root
    global close_flag
    # clear output
    txt_out.delete(1.0, tkinter.END)
    # create subprocess
    process = subprocess.Popen(script, shell=True, preexec_fn=os.setsid,
        stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    # read subprocess stderr/stdout in non-blocking
    outpoll = select.poll()
    errpoll = select.poll()
    outpoll.register(process.stdout, select.POLLIN)
    errpoll.register(process.stderr, select.POLLIN)
    # store current subprocess
    cur_process = process
    while True:
        output = ""
        errput = ""
        # poll stdout, timeout 2ms
        if outpoll.poll(0):
            output = process.stdout.readline().decode()
            # insert stdout to txt_out
            if output and not close_flag:
                txt_out.insert(tkinter.INSERT, output)
        # poll stderr, timeout 2ms
        if errpoll.poll(0):
            errput = process.stderr.readline().decode()
            # insert stderr to txt_out
            if errput and not close_flag:
                txt_out.insert(tkinter.INSERT, errput)
        # scroll text if have output
        if (output or errput) and not close_flag:
            txt_out.see(tkinter.END)
        # do eventloop when not closing
        if not close_flag:
            root.update()
        # process end
        if output == "" and process.poll() is not None:
            break
    # get process return code
    code = process.poll()
    # reset current subprocess
    cur_process = None
    return code

# callback 函数
current_path=''
def cb_update():
    global close_flag
    current_path=os.path.abspath(os.path.dirname(__file__))
    #print(current_path)
    # current_path=
    current_path=current_path+'/sh/gui.sh'
    disable_allbtn()
    code = cb_runbash_withoutput(current_path)
    # exit when closing
    if close_flag:
        return
    if code != 0:
        messagebox.showerror(title="Error", message="run bash script failed")
    else:
        messagebox.showinfo(title="Info", message="run bash script success")
    enable_allbtn()

# callback 函数
current_path1=''
def help():
    global close_flag
    current_path1=os.path.abspath(os.path.dirname(__file__))
    # current_path=
    current_path1=current_path1+'/sh/hel.sh'
    disable_allbtn()
    code = cb_runbash_withoutput(current_path1)
    #print(current_path1)
    # exit when closing
    if close_flag:
        return
    if code != 0:
        messagebox.showerror(title="Error", message="run bash script failed")
    else:
        messagebox.showinfo(title="Info", message="run bash script success")
    enable_allbtn()

current_path2=''
def infor():
    global close_flag
    current_path2=os.path.abspath(os.path.dirname(__file__))
    # current_path=
    current_path2=current_path2+'/sh/infor.sh'
    disable_allbtn()
    code = cb_runbash_withoutput(current_path2)
   # print(current_path1)
    # exit when closing
    if close_flag:
        return
    if code != 0:
        messagebox.showerror(title="Error", message="run bash script failed")
    else:
        messagebox.showinfo(title="Info", message="run bash script success")
    enable_allbtn()

current_path3=''
def infow():
    global close_flag
    current_path3=os.path.abspath(os.path.dirname(__file__))
    # current_path=
    current_path3=current_path3+'/sh/infow.sh'
    disable_allbtn()
    code = cb_runbash_withoutput(current_path3)
   # print(current_path1)
    # exit when closing
    if close_flag:
        return
    if code != 0:
        messagebox.showerror(title="Error", message="run bash script failed")
    else:
        messagebox.showinfo(title="Info", message="run bash script success")
    enable_allbtn()

current_path4=''
def p():
    global close_flag
    current_path4=os.path.abspath(os.path.dirname(__file__))
    # current_path=
    current_path4=current_path4+'/sh/p.sh'
    disable_allbtn()
    code = cb_runbash_withoutput(current_path4)
   # print(current_path1)
    # exit when closing
    if close_flag:
        return
    if code != 0:
        messagebox.showerror(title="Error", message="run bash script failed")
    else:
        messagebox.showinfo(title="Info", message="run bash script success")
    enable_allbtn()

current_path5=''
def x():
    global close_flag
    current_path5=os.path.abspath(os.path.dirname(__file__))
    # current_path=
    current_path5=current_path5+'/sh/x.sh'
    disable_allbtn()
    code = cb_runbash_withoutput(current_path5)
   # print(current_path1)
    # exit when closing
    if close_flag:
        return
    if code != 0:
        messagebox.showerror(title="Error", message="run bash script failed")
    else:
        messagebox.showinfo(title="Info", message="run bash script success")
    enable_allbtn()

current_path6=''
def d():
    global close_flag
    current_path6=os.path.abspath(os.path.dirname(__file__))
    # current_path=
    current_path6=current_path6+'/sh/d.sh'
    disable_allbtn()
    code = cb_runbash_withoutput(current_path6)
   # print(current_path1)
    # exit when closing
    if close_flag:
        return
    if code != 0:
        messagebox.showerror(title="Error", message="run bash script failed")
    else:
        messagebox.showinfo(title="Info", message="run bash script success")
    enable_allbtn()


def on_closing():
    global cur_process
    global root
    global close_flag
    # if cur_process still running
    if cur_process:
        if messagebox.askokcancel("Quit", "There is task running, do you want to quit?"):
            # kill subprocess
            os.killpg(os.getpgid(cur_process.pid), signal.SIGTERM)
            cur_process = None
        else:
            return
    # mark closing
    close_flag = True
    # close window
    root.destroy()

root.title("TEMU Simulator")
root.geometry(WINDOW_SIZE)
# register cloing event callback
root.protocol("WM_DELETE_WINDOW", on_closing)

file=tkinter.Button(root, text='File', width=10, height=1, command=read_file)
file.pack(side=LEFT)
complie=tkinter.Button(root, text='compile', width=10, height=2, command=exe_make).pack(side=LEFT)
btn_upd = tkinter.Button(root, text="run", command = cb_update)
hel=tkinter.Button(root,text='help', command=help).pack(side=RIGHT)
inforr=tkinter.Button(root,text='register', command=infor).pack(side=RIGHT)
inforw=tkinter.Button(root,text='watch point', command=infow).pack(side=RIGHT)
p=tkinter.Button(root,text='calculator', command=p).pack(side=BOTTOM)
x=tkinter.Button(root,text='scan storage', command=x).pack(side=BOTTOM)
d=tkinter.Button(root,text='delete wp', command=d).pack(side=BOTTOM)
btn_upd.pack(fill=tkinter.X, pady=10)

txt_out = scrolledtext.ScrolledText(root)
txt_out.pack(fill=tkinter.BOTH, expand=True, padx=20, pady=20)

tkinter.mainloop()