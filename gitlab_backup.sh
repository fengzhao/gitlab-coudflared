#!/bin/bash 

# 当执行时使用到未定义过的变量，显示错误信息。
set -u

# 如果执行遇到错误，自动退出
set -o errexit

## gitlab备份，本地备份后可以传到远端

# 执行一次gitlab备份
/opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1


# gitlab 在本地备份路径，可以在/etc/gitlab/gitlab.rb文件中配置
LocalBackDir=/var/opt/gitlab/backups


# 远程备份服务器的IP地址
RemoteIP=10.10.20.199

# 远程备份服务器的登录账户
RemoteUser=root


# 远程备份服务器上的gitlab备份文件存放路径
RemoteBackDir=/backup/gitlab/



#当前系统日期
DATE=`date +"%Y-%m-%d"`

mkdir -p ${LocalBackDir}/log/

#Log存放路径
LogFile=${LocalBackDir}/log/${DATE}.log

# 查找 gitlab本地备份目录下 时间为60分钟之内的，并且后缀为.tar的gitlab备份文件
BACKUPFILE_SEND_TO_REMOTE=$(find $LocalBackDir -type f -mmin -60  -name '*.tar*')

#新建日志文件
touch $LogFile

#追加日志到日志文件
echo "Gitlab auto backup to remote server, start at  $(date +"%Y-%m-%d %H:%M:%S")" >>  ${LogFile}
echo "---------------------------------------------------------------------------" >> ${LogFile}

# 输出日志，打印出每次scp的文件名
echo "---------------------The file to scp to remote server is: $BACKUPFILE_SEND_TO_REMOTE-------------------------------" >> ${LogFile}



#备份到远程服务器
scp ${BACKUPFILE_SEND_TO_REMOTE} ${RemoteUser}@${RemoteIP}:${RemoteBackDir}

rm -rf   ${BACKUPFILE_SEND_TO_REMOTE} 


#追加日志到日志文件
echo "---------------------------------------------------------------------------" >> $LogFile

