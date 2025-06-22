#!/bin/bash

# 企业级SAM部署脚本
# 支持多环境部署：dev, staging, prod
# 使用方法: ./deploy.sh [环境] [选项]

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# 显示帮助信息
show_help() {
    echo -e "${BLUE}企业级SAM部署脚本${NC}"
    echo
    echo "用法: $0 [环境] [选项]"
    echo
    echo "环境:"
    echo "  dev      开发环境 (默认)"
    echo "  staging  预发布环境"
    echo "  prod     生产环境"
    echo
    echo "选项:"
    echo "  --guided         引导式部署配置"
    echo "  --no-confirm     跳过部署确认"
    echo "  --build-only     仅构建不部署"
    echo "  --logs           部署后显示日志"
    echo "  --help           显示此帮助信息"
    echo
    echo "示例:"
    echo "  $0 dev                    # 部署到开发环境"
    echo "  $0 prod --guided          # 引导式部署到生产环境"
    echo "  $0 staging --logs         # 部署到预发布环境并显示日志"
}

# 参数解析
ENVIRONMENT="dev"
GUIDED=false
NO_CONFIRM=false
BUILD_ONLY=false
SHOW_LOGS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|prod)
            ENVIRONMENT="$1"
            shift
            ;;
        --guided)
            GUIDED=true
            shift
            ;;
        --no-confirm)
            NO_CONFIRM=true
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --logs)
            SHOW_LOGS=true
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

# 验证环境
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    error "无效的环境: $ENVIRONMENT. 必须是 dev, staging, 或 prod"
fi

# 项目配置
STACK_NAME="sam-nodejs-app-$ENVIRONMENT"
REGION=${AWS_DEFAULT_REGION:-ap-southeast-2}
S3_BUCKET="sam-deploy-bucket-$ENVIRONMENT-$(date +%s)"

log "🚀 开始部署到 $ENVIRONMENT 环境"
log "📦 Stack名称: $STACK_NAME"
log "🌍 AWS区域: $REGION"

# 检查AWS凭证
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    error "AWS凭证未配置或已过期。请运行 aws configure 或设置环境变量"
fi

# 显示当前AWS账户信息
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
log "👤 AWS账户: $ACCOUNT_ID"

# 生产环境额外确认
if [[ "$ENVIRONMENT" == "prod" && "$NO_CONFIRM" != true ]]; then
    warn "即将部署到生产环境！"
    read -p "请输入 'DEPLOY_TO_PROD' 确认: " -r
    if [[ $REPLY != "DEPLOY_TO_PROD" ]]; then
        log "部署已取消"
        exit 0
    fi
fi

# 构建应用
log "🔨 构建SAM应用..."
if ! sam build; then
    error "SAM构建失败"
fi

# 如果只构建，则退出
if [[ "$BUILD_ONLY" == true ]]; then
    log "✅ 构建完成 (仅构建模式)"
    exit 0
fi

# 创建部署S3存储桶 (如果不存在)
log "📦 检查部署存储桶..."
if ! aws s3 ls "s3://$S3_BUCKET" >/dev/null 2>&1; then
    log "创建S3存储桶: $S3_BUCKET"
    aws s3 mb "s3://$S3_BUCKET" --region "$REGION"
fi

# 部署配置
DEPLOY_CMD="sam deploy"
DEPLOY_CMD+=" --stack-name $STACK_NAME"
DEPLOY_CMD+=" --region $REGION"
DEPLOY_CMD+=" --capabilities CAPABILITY_IAM"
DEPLOY_CMD+=" --parameter-overrides Environment=$ENVIRONMENT"

if [[ "$GUIDED" == true ]]; then
    DEPLOY_CMD+=" --guided"
else
    DEPLOY_CMD+=" --resolve-s3 --no-confirm-changeset --no-fail-on-empty-changeset"
fi

# 执行部署
log "🚀 开始部署..."
log "执行命令: $DEPLOY_CMD"

if eval $DEPLOY_CMD; then
    log "✅ 部署成功完成！"
    
    # 获取API端点
    API_ENDPOINT=$(aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayEndpoint`].OutputValue' \
        --output text 2>/dev/null || echo "N/A")
    
    # 显示部署结果
    echo
    log "📊 部署结果摘要:"
    echo "  🏷️  环境: $ENVIRONMENT"
    echo "  📦 Stack: $STACK_NAME"
    echo "  🌍 区域: $REGION"
    echo "  🔗 API端点: $API_ENDPOINT"
    echo
    
    # 测试API
    if [[ "$API_ENDPOINT" != "N/A" ]]; then
        log "🧪 测试API端点..."
        
        # 测试Hello World
        echo "测试 Hello World API:"
        if curl -s "${API_ENDPOINT}hello" | jq . 2>/dev/null; then
            echo "  ✅ Hello World API 正常"
        else
            warn "  ⚠️  Hello World API 测试失败"
        fi
        
        # 测试用户API
        echo "测试用户管理API:"
        if curl -s "${API_ENDPOINT}api/users" | jq . 2>/dev/null; then
            echo "  ✅ 用户API 正常"
        else
            warn "  ⚠️  用户API 测试失败"
        fi
    fi
    
    # 显示CloudWatch仪表板链接
    DASHBOARD_URL="https://${REGION}.console.aws.amazon.com/cloudwatch/home?region=${REGION}#dashboards:name=${STACK_NAME}-${ENVIRONMENT}-dashboard"
    log "📈 CloudWatch仪表板: $DASHBOARD_URL"
    
    # 显示日志 (如果请求)
    if [[ "$SHOW_LOGS" == true ]]; then
        log "📋 显示最近日志..."
        sam logs --stack-name "$STACK_NAME" --tail
    fi
    
else
    error "部署失败"
fi

log "🎉 部署流程完成！" 