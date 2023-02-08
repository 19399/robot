#使用基础的官方镜像
FROM golang:1.17-alpine As build
#工作目录
WORKDIR /project/
#复制
COPY . /project
#制作镜像的时候运行 设置 go代理， 设置go mod 模式
RUN go env -w GOPROXY=https://goproxy.io,direct
RUN go env -w GO111MODULE=on
#编译二进制文件 Go的runtime环境变量CGO_ENABLED=1，即默认开始cgo，允许你在Go代码中调用C代码

#CGO_ENABLED 如果标准库中是在CGO_ENABLED=1情况下编译的，那么编译出来的最终二进制文件可能是动态链接，
#   所以建议设置 CGO_ENABLED=0以避免移植过程中出现的不必要问题。
# GOOS 编译目标平台上的操作系统（darwin, freebsd, linux, windows）
# GOARCH 编译目标平台上的硬件体系架构（amd64, 386, arm, ppc64等）
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o robot_chatgpt   main.go


FROM alpine
ENV TZ Asia/Shanghai
COPY --from=build /project/wechatbot /project/wechatbot

#定义工作目录为project
WORKDIR /project

#CMD ["./hello"]
#声明镜像使用80端口 并不代表可以 直接访问此端口
EXPOSE 80
#容器启动命令
ENTRYPOINT  ["./wechatbot"]