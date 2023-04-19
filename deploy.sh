#!/bin/bash
#本地所有修改的。没有的提交的，都返回到原来的状态
git checkout . 
# 先拉取最新的代码
git pull
# 先安装依赖包
npm install
# 删除dist文件夹 确保生成的文件是最新的
rm -rf dist
# 运行构建命令 生成dist文件夹
npm run build

if [ $? -eq 0 ]; then  
    echo "npm run build 成功"
else  
    echo "npm run build 失败"
    exit 1 
fi

# 判断历史版本文件夹是否存在
if [ ! -d "./release" ]; then
    mkdir "./release"
fi
# 判断日志文件夹是否存在
if [ ! -d "./release-log" ]; then
    mkdir "./release-log"
fi
# 将新构建的dist 文件夹作为一个新版本 放到历史版本文件夹中
# 设置版本号的名称
RELEASE_NAME=release-$(date "+%Y%m%d%H%M%S")
# 将版本号 写入代码里面 就能看到当前版本是哪个，用于后续恢复确认版本
echo "$RELEASE_NAME" > dist/version
# 复制最新的版本文件夹到历史版本里面
cp -r dist release/$RELEASE_NAME
# 将最近3条git 日志 写入log
LOG_FILE_PATH=release-log/$RELEASE_NAME.txt
# 输出日志路径
echo $LOG_FILE_PATH
# 将最近的3条git记录保存到文件
git log  -3  --pretty=format:'%s' --abbrev-commit   | awk   -F ':'   '{print   NR " "  $0 }' > $LOG_FILE_PATH
# 输出这次的更新内容
cat $LOG_FILE_PATH

if [ -d "./pre" ]; then    
    # 移除上一个版本
    rm -rf pre
fi

# 将当前运行版本的文件夹 复制一份到到备份文件夹
cp -r current pre

if [ -d "./current" ]; then    
    #移除当前版本的文件夹
    rm -rf current
fi
# 将新版本的文件放到current
cp -r dist current
# 将当前版本的文件夹 复制到nginx目录
if [ -d /usr/share/nginx/html/ ]; then
    echo "/usr/share/nginx/html/ 目录存在 复制编译好的文件"
    cp -r /root/project/wechat-login-frontend/current/* /usr/share/nginx/html/
else
    echo "目录不存在"
fi