# gitlab 简介

GitLab是利用Ruby on Rails开发的一个开源的代码版本管理系统，实现一个自托管的Git项目仓库，可通过Web界面进行访问公开的或者私人项目。

Gitlab 不单单是一个代码托管的 VCS 版本控制系统，其他例如 CI/CD Pipelie，Wiki，Issue Tracking，Kanban 等等都是极少数人所知，但却可以极大提高软件的开发效率及部署效率的。

GitLab 分为两个版本，GitLab CE（社区版）及 GitLab EE（企业版），其中 GitLab CE 为 MIT 许可证可以免费进行使用，而 GitLab EE 则为在 GitLab CE 的版本上增强了许多功能，但需要进行付费使用。

无论是 GitLab CE 或者 GitLab EE 都可以选择自行托管私服务器私有部署，或者是可以直接选择 gitlab.com 的 SaaS 服务，gitlab.com 目前也提供免费的套餐，有需要的话可以随时进行升级计划。

omnibus方式即是通过gitlab提供的一个打包好的文件（将gitlab的所有服务打包在一起），通过类似一键安装来完成gitlab-ce企业私有代码库的安装，也是安装最省力的方式。



```shell
docker pull gitlab/gitlab-ce

```

# gitlab-coudflared

## 使用cloudflare将内网的gitlab穿透到公网

准备条件，注册一个cf账号，并将域名dns放到cf上解析


```shell

###################################使用docker安装配置gitlab################################
mkdir -p /srv/gitlab  && export GITLAB_HOME=/srv/gitlab

# 下载docker-compose文件 
wget https://raw.githubusercontent.com/fengzhao/gitlab-coudflared/main/docker-compose.yml

# 启动gitlab的docker容器，注意将其中的域名替换成自己的域名
docker-compose up -d 

# 本地修改hosts文件，看看能否通过域名访问

# 进入容器，准备修改root密码
docker exec -it gitlab bash 

# 进入gitlab控制台
[root@gitlab ~]# gitlab-rails console production
Loading production environment (Rails 4.2.8)
 
# 获取第一个用户，可以看到第一个默认为 root
irb(main):001:0> user = User.where(id:1).first
=> #<User id:1 @root>
 
# 设置新密码
irb(main):002:0> user.password='xxx123456'
=> "xxx123456"
 
# 保存设置
irb(main):003:0> user.save!


####################################配置cloudflared########################################
# 下载cloudflared文件
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64  -O /usr/bin/cloudflared

# 在服务器上登录cf
cloudflared tunnel login
# 复制URL地址到浏览器打开并登录cf账号，然后选择gitlab要绑定的外网访问域名。
# CF会签发一个私钥文件cert.pem（其实就是认证CF的私钥文件），下载这个私钥后并传到服务器中。（现在Linux中会直接下载）
# ~/.cloudflared/cert.pem

# 在服务器上创建cf Tunnel 
# NAME为tunnel名称，CF会为这个tunnel生成一个UUID，生成 ~/.cloudflared/UUID.json 文件
cloudflared tunnel create  <NAME> 

# 查看当前账号的所有tunnel
cloudflared tunnel list

# 为当前tunnel配置映射

# 注册成服务
sudo cloudflared service install

# 配置
wget https://raw.githubusercontent.com/fengzhao/gitlab-coudflared/main/config.yml -O /etc/cloudflared/config.yml

# 启动
sudo systemctl start cloudflared

# 开机自启
sudo systemctl start cloudflared
 

####################################域名配置########################################

# 登录cf控制台，选择域名，添加一条cname记录：gitlab.example.com  uuid.cfargotunnel.com(注意替换成实际的uuid)

```
