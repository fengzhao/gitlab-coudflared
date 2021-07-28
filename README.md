# gitlab-coudflared

## 使用cloudflare将内网的gitlab穿透到公网

准备条件，注册一个cf账号，并将域名dns放到cf上解析


```shell
mkdir -p /srv/gitlab
export GITLAB_HOME=/srv/gitlab
# 下载docker-compose文件 
wget https://raw.githubusercontent.com/fengzhao/gitlab-coudflared/main/docker-compose.yml
# 启动gitlab的docker容器，注意将其中的域名替换成自己的域名
docker-compose up -d 



# 下载cloudflared文件
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64  -O /usr/bin/cloudflared



```
