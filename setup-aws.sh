#!/bin/bash
# AWS凭证配置和验证脚本
set -e

echo "🚀 AWS DevOps环境配置脚本"
echo "=============================="

# 检查凭证文件是否存在
if [ ! -f "aws-credentials.env" ]; then
    echo "❌ 未找到 aws-credentials.env 文件"
    echo ""
    echo "请按以下步骤操作："
    echo "1. 复制模板: cp aws-credentials.template aws-credentials.env"
    echo "2. 编辑文件: nano aws-credentials.env"
    echo "3. 填入您从AWS控制台获取的凭证值"
    echo "4. 重新运行此脚本: ./setup-aws.sh"
    echo ""
    exit 1
fi

# 加载环境变量
echo "📋 加载AWS凭证..."
set -a  # 自动导出变量
source aws-credentials.env
set +a

# 检查必需的环境变量
required_vars=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "AWS_SESSION_TOKEN" "AWS_DEFAULT_REGION")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ] || [ "${!var}" = "填入您的${var#AWS_}" ] || [[ "${!var}" == *"填入"* ]]; then
        echo "❌ 变量 $var 未正确设置"
        echo "请编辑 aws-credentials.env 文件并填入正确的值"
        exit 1
    fi
done

# 验证凭证
echo "🔍 验证AWS凭证..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ AWS凭证验证成功！"
    echo ""
    echo "📊 当前AWS账户信息："
    aws sts get-caller-identity --query '{UserId:UserId,Account:Account,Arn:Arn}' --output table
    echo ""
    echo "🌍 当前区域: $AWS_DEFAULT_REGION"
    echo "📦 项目前缀: $STACK_NAME_PREFIX"
    echo ""
    echo "🎉 现在可以使用以下命令："
    echo "  sam init                       # 初始化SAM项目"
    echo "  sam build                      # 构建项目"
    echo "  sam local start-api           # 本地测试API"
    echo "  sam deploy --guided           # 部署到AWS"
    echo "  sam logs --tail               # 查看日志"
    echo ""
else
    echo "❌ AWS凭证验证失败"
    echo "请检查 aws-credentials.env 文件中的凭证是否正确"
    echo "确保从AWS控制台复制了完整的凭证值"
    exit 1
fi 