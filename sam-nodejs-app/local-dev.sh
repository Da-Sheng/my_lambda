#!/bin/bash

# 本地开发测试脚本
# 提供本地API测试、热重载、日志查看等功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# 显示帮助
show_help() {
    echo -e "${BLUE}SAM本地开发工具${NC}"
    echo
    echo "用法: $0 [命令] [选项]"
    echo
    echo "命令:"
    echo "  build        构建应用"
    echo "  start        启动本地API服务器"
    echo "  test         运行API测试"
    echo "  logs         查看Lambda日志"
    echo "  clean        清理构建文件"
    echo "  install      安装依赖"
    echo
    echo "选项:"
    echo "  --port PORT  指定API服务器端口 (默认: 3000)"
    echo "  --debug      启用调试模式"
    echo "  --help       显示帮助"
    echo
    echo "示例:"
    echo "  $0 start              # 启动本地API服务器"
    echo "  $0 start --port 8080  # 在8080端口启动"
    echo "  $0 test               # 运行API测试"
}

# 默认参数
COMMAND=""
PORT=3000
DEBUG=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        build|start|test|logs|clean|install)
            COMMAND="$1"
            shift
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --debug)
            DEBUG=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            error "未知参数: $1"
            ;;
    esac
done

# 检查命令
if [[ -z "$COMMAND" ]]; then
    show_help
    exit 1
fi

# 检查Docker是否运行
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        error "Docker未运行。请启动Docker Desktop"
    fi
}

# 构建应用
build_app() {
    log "🔨 构建SAM应用..."
    sam build
    log "✅ 构建完成"
}

# 安装依赖
install_deps() {
    log "📦 安装Lambda函数依赖..."
    
    # Hello World函数依赖
    if [[ -f "hello-world/package.json" ]]; then
        log "安装Hello World依赖..."
        cd hello-world && npm install && cd ..
    fi
    
    # 用户API依赖
    if [[ -f "src/users/package.json" ]]; then
        log "安装用户API依赖..."
        cd src/users && npm install && cd ..
    fi
    
    log "✅ 依赖安装完成"
}

# 启动本地API服务器
start_local_api() {
    check_docker
    
    log "🚀 启动本地API服务器 (端口: $PORT)"
    
    # 设置环境变量
    export AWS_SAM_LOCAL_TIMEOUT=60
    
    if [[ "$DEBUG" == true ]]; then
        log "🐛 启用调试模式"
        sam local start-api --port "$PORT" --debug
    else
        sam local start-api --port "$PORT"
    fi
}

# API测试
run_tests() {
    log "🧪 运行API测试..."
    
    local base_url="http://localhost:$PORT"
    
    # 检查服务器是否运行
    if ! curl -s "$base_url" >/dev/null 2>&1; then
        warn "本地API服务器未运行"
        log "请先运行: $0 start"
        return 1
    fi
    
    echo
    log "测试Hello World API..."
    echo "GET $base_url/hello"
    curl -s "$base_url/hello" | jq . || echo "请求失败"
    
    echo
    log "测试用户API..."
    
    # 获取用户列表
    echo "GET $base_url/api/users"
    curl -s "$base_url/api/users" | jq . || echo "请求失败"
    
    # 获取单个用户
    echo
    echo "GET $base_url/api/users/1"
    curl -s "$base_url/api/users/1" | jq . || echo "请求失败"
    
    # 测试分页
    echo
    echo "GET $base_url/api/users?page=1&limit=2"
    curl -s "$base_url/api/users?page=1&limit=2" | jq . || echo "请求失败"
    
    # 测试角色过滤
    echo
    echo "GET $base_url/api/users?role=admin"
    curl -s "$base_url/api/users?role=admin" | jq . || echo "请求失败"
    
    # 创建新用户
    echo
    echo "POST $base_url/api/users"
    curl -s -X POST "$base_url/api/users" \
        -H "Content-Type: application/json" \
        -d '{"name":"Test User","email":"test@example.com","role":"user"}' | jq . || echo "请求失败"
    
    echo
    log "✅ API测试完成"
}

# 查看日志
show_logs() {
    log "📋 显示Lambda函数日志..."
    
    echo "选择要查看的函数:"
    echo "1) HelloWorldFunction"
    echo "2) UsersFunction"
    echo "3) 所有函数"
    read -p "请选择 (1-3): " choice
    
    case $choice in
        1)
            sam logs --name HelloWorldFunction --tail
            ;;
        2)
            sam logs --name UsersFunction --tail
            ;;
        3)
            sam logs --tail
            ;;
        *)
            error "无效选择"
            ;;
    esac
}

# 清理
clean_build() {
    log "🧹 清理构建文件..."
    rm -rf .aws-sam
    log "✅ 清理完成"
}

# 执行命令
case $COMMAND in
    build)
        build_app
        ;;
    install)
        install_deps
        ;;
    start)
        build_app
        start_local_api
        ;;
    test)
        run_tests
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_build
        ;;
    *)
        error "未知命令: $COMMAND"
        ;;
esac 