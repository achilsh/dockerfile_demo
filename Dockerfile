### 这个是指定 基础镜像，后续的指令都是具有这个镜像来操作的。
FROM ubuntu:20.04  as ub20.04  

### 主要是给image 添加一些元数据， 以键值对的形式编写。
LABEL maintainer="xxx@126.com" timeValue="2021-12-12" 

### 给 RUN,CMD,ENTRYPOINT,COPY,ADD 命令设置 工作路径。如果工作路径不存在，则会被自动创建。如果没有设置，默认就是： / 
### 在 dockerfile中， 可随意的新增一条记录 WORKDIR XXX, 然后再进行 其他的一些命令，这样就可以不需要再 RUN cd 进行目录的切换啥的。
WORKDIR  /home/user/demo

### 下面的实例就是 随意切换 WORKDIR 的值。
# FROM golang:1.21-bullseye as build

# WORKDIR /grpc-go
# COPY . .

# WORKDIR /grpc-go/interop/observability
# RUN go build -o server/ server/server.go && \
#     go build -o client/ client/client.go

# #
# # Stage 2:
# #
# # - Copy only the necessary files to reduce Docker image size.
# # - Have an ENTRYPOINT script which will launch the interop test client or server
# #   with the given parameters.
# #

# FROM golang:1.21-bullseye

# ENV GRPC_GO_LOG_SEVERITY_LEVEL info
# ENV GRPC_GO_LOG_VERBOSITY_LEVEL 2

# WORKDIR /grpc-go/interop/observability/server
# COPY --from=build /grpc-go/interop/observability/server/server .

# WORKDIR /grpc-go/interop/observability/client
# COPY --from=build /grpc-go/interop/observability/client/client .

# WORKDIR /grpc-go/interop/observability
# COPY --from=build /grpc-go/interop/observability/run.sh .

# ENTRYPOINT ["/grpc-go/interop/observability/run.sh"]


### 环境变量声明， 在Dockerfile中使用环境变量方式是： $DemoV1, 同时 环境变量在容器运行后的系统上也有效。就是进程里也有效，用于控制业务逻辑。
ENV DemoV1=123.123  Demov3=123.1323
ENV Demov2 123.123 
RUN echo ${DemoV1}  ${Demov2} ${Demov3}


# FROM golang:latest

# ENV GOPATH=/opt/repo
# ENV GO111MODULE=on
# ENV GOPROXY=https://goproxy.io,direct
# ENV GOPROXY https://goproxy.cn,direct
# WORKDIR $GOPATH/src/github.com/EDDYCJY/go-gin-example
# COPY . $GOPATH/src/github.com/EDDYCJY/go-gin-example
# RUN go build .

# EXPOSE 8000
# ENTRYPOINT ["./go-gin-example"]


## 主要作用是用来存放一些不定的参数，这样就可以在构建image时，由外部传入。
### 定义 dockerfile中的参数，该参数只能在 构建image中的 dockerfile中有效，image构建完后就不存在该变量。
### 可以在dockerfile文件中定义这些参数。可以在 docker build 命令中参数选项：  --build-arg 指定 A1=222 A2=3333 来覆盖。
ARG A2 
ARG A1=123 
ARG user_name   ##后面就可以使用user_name.如何使用？ $user_name;  ARG 变量的定义从Dockerfile中定义它的那一行开始生效，而不是从命令行或其他地方使用ARG开始生效

## RUN 用来执行 紧跟后面的命令。比如一下安装三方包，编译源码等指令。所有在linux上运行的命令都可以。
RUN echo $user_name \
    && echo "this is test demo run Dockerfile"




## 定义匿名卷， 在启动容器时忘记手动挂载卷， 比如： -v local_path:container_path ； 那么local_path 就会被挂载到下面定义的匿名卷上。
### 
VOLUME ["/mnt/data1", "/mnt/data2"]
VOLUME /mnt/data3 /mnt/data4 
VOLUME /mnt/data5


## 指定后续执行命令的用户和用户组，比如命令： RUN， ENTRYPOINT, CMD; 该用户名和用户组必须事先创建的。
USER root:root

##  使用 useradd 命令不会为用户创建密码。
RUN useradd -d /home/user -m -s "/bin/bash" user
# RUN adduser -S -D -H -h /app user
USER user

## 该镜像起来的容器将开发 8080端口。当然可以在docker run -p host_port:container_port ; 不管是否设置了这个： the EXPOSE settings, you can override them at runtime by using the -p flag. 
EXPOSE 8080
EXPOSE 8081/udp 
EXPOSE 8082/tcp


### 将本地的local_path目录中的文件或目录  copy 到容器中的指定位置 container_path
ARG local_path=.
ARG container_path=/home/user
COPY  ${local_path} ${container_path} 
# COPY X1.log  xxy.*  ${container_path}         ##### 将多个文件，copy 到 容器的目录中。

# FROM golang:1.21 as from_other_builder         ###这里采用多阶段构建，通过在一个镜像来做编译源码，然后再通过 一个 FROM 获取新源镜像，把从第一个构建的东西copy 到第二个镜像的某个位置。可有效减少镜像文件的的 大小。
# FROM  new_images
##COPY --from=from_other_builder  /go/src/grpc-go/client . ### --from 指定某一个镜像，后面跟着某个镜像中的位置 和 新镜像的某个位置。
# COPY --from=from_other_builder ${other_src_file_or_direction}  ${to_dst_in_container}


########## ENTRYPOINT 用于设置容器创建时的主要命令。（不可被覆盖），格式是： ENTRYPOINT["bin_file", "param1", "param2"]
##########  docker run <image> 的参数将被加到  ENTRYPOINT 自己参数的后面。比如： 比如我运行 docker run -it image_name ;echo "is ok" 就会把 ;echo "is ok" 加到其参数后面一起运行。
########  如果存在多条 ENTRYPOINT 那么只有最后一条生效。
######### ENTRYPOINT 可以和 CMD 配合一起使用， ENTRYPOINT 存放一些固定数值， CMD 中存放可变参数的默认值。可以在 docker run image_name -c xxx.yaml 修改默认参数。

############# CMD 用于指定容器创建时的默认命令。（可以被覆盖）
## 比如：
# ENTRYPOINT ["/opt/iam/bin/iam-watcher"] ### 存放固定参数
# CMD ["-c", "/etc/iam/iam-watcher.yaml"] ### 存放可变的默认，就是在docker run 时，可以指定具体新值来替代默认值。
# 等同于： /opt/iam/bin/iam-watcher -c /etc/iam/iam-watcher.yaml, 可以在运行时 修改他， docker run image_name -c xxx.yaml
ENTRYPOINT ["sleep" , "5"] ## 比如我运行 docker run -it image_name ;echo "is ok"



### CMD 使用,  CMD 用于指定容器创建时的默认命令。（可以被覆盖）
## CMD ["executable","param1","param2"]
## CMD ["param1","param2"] (as default parameters to ENTRYPOINT)
