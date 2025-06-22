# 🚀 部署指南

Node.js SAM应用多环境部署和运维完整指南。

## 📋 目录

- [环境配置](#环境配置)
- [部署流程](#部署流程)
- [多环境管理](#多环境管理)
- [监控和日志](#监控和日志)
- [故障排查](#故障排查)
- [性能优化](#性能优化)

## 环境配置

### AWS凭证配置

#### 方式一：临时凭证（推荐）

```bash
# 1. 从AWS SSO获取临时凭证
# 访问: https://console.aws.amazon.com/
# 选择: Command line or programmatic access

# 2. 配置环境变量
export AWS_ACCESS_KEY_ID="ASIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
export AWS_DEFAULT_REGION="us-east-1"

# 3. 验证配置
aws sts get-caller-identity
```

#### 方式二：长期凭证

```bash
# 配置AWS CLI
aws configure

# 验证权限
aws sts get-caller-identity
```

### 环境变量设置

```bash
# 设置部署环境
export ENVIRONMENT=dev          # dev/staging/prod
export STACK_NAME_PREFIX=myapp  # 堆栈前缀
export AWS_DEFAULT_REGION=us-east-1
```

## 部署流程

### 🚀 一键部署（推荐）

```bash
# 开发环境部署
./deploy.sh dev

# 生产环境部署（需要确认）
./deploy.sh prod --confirm
```

### 手动部署步骤

```bash
# 1. 构建应用
sam build --parallel

# 2. 部署到AWS
sam deploy \
  --stack-name myapp-dev \
  --s3-bucket myapp-dev-deployment \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides Environment=dev \
  --tags Environment=dev

# 3. 验证部署
aws cloudformation describe-stacks \
  --stack-name myapp-dev \
  --query 'Stacks[0].StackStatus'
```

### 首次部署

```bash
# 首次部署需要引导配置
sam deploy --guided

# 配置选项:
# Stack Name: sam-nodejs-app-dev
# AWS Region: us-east-1
# Parameter Environment: dev
# Confirm changes before deploy: Y
# Allow SAM CLI IAM role creation: Y
# Save parameters to samconfig.toml: Y
```

## 多环境管理

### 环境配置文件

#### samconfig.toml

```toml
version = 0.1

[default]
[default.deploy]
[default.deploy.parameters]
stack_name = "sam-nodejs-app-dev"
s3_bucket = "sam-nodejs-app-dev-deployment"
s3_prefix = "sam-nodejs-app-dev"
region = "us-east-1"
capabilities = "CAPABILITY_IAM"
parameter_overrides = "Environment=dev"

[prod]
[prod.deploy]
[prod.deploy.parameters]
stack_name = "sam-nodejs-app-prod"
s3_bucket = "sam-nodejs-app-prod-deployment"
s3_prefix = "sam-nodejs-app-prod"
region = "us-east-1"
capabilities = "CAPABILITY_IAM"
parameter_overrides = "Environment=prod"
```

### 环境特定配置

```yaml
# template.yaml 参数配置
Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]

Conditions:
  IsProd: !Equals [!Ref Environment, prod]

Resources:
  MyFunction:
    Properties:
      Environment:
        Variables:
          LOG_LEVEL: !If [IsProd, WARN, DEBUG]
          TIMEOUT: !If [IsProd, 30, 10]
```

### 部署命令示例

```bash
# 部署到不同环境
sam deploy --config-env default  # 开发环境
sam deploy --config-env staging  # 暂存环境
sam deploy --config-env prod     # 生产环境
```

## 监控和日志

### CloudWatch监控

```bash
# 查看函数日志
sam logs --name HelloWorldFunction --tail

# 查看特定时间段日志
aws logs filter-log-events \
  --log-group-name "/aws/lambda/sam-nodejs-app-dev-HelloWorldFunction" \
  --start-time $(date -d '1 hour ago' +%s)000

# 创建告警
aws cloudwatch put-metric-alarm \
  --alarm-name "HighErrorRate" \
  --alarm-description "Lambda错误率过高" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

### X-Ray分布式追踪

```bash
# 查看追踪数据
aws xray get-trace-summaries \
  --time-range-type TimeRangeByStartTime \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s)

# 获取特定追踪详情
aws xray batch-get-traces --trace-ids trace-id-here
```

## 故障排查

### 常见问题

#### 1. 部署失败

```bash
# 检查CloudFormation事件
aws cloudformation describe-stack-events --stack-name sam-nodejs-app-dev

# 检查S3存储桶权限
aws s3 ls s3://sam-nodejs-app-dev-deployment/

# 验证IAM权限
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/myuser \
  --action-names lambda:CreateFunction \
  --resource-arns "*"
```

#### 2. Lambda函数错误

```bash
# 查看函数配置
aws lambda get-function --function-name sam-nodejs-app-dev-HelloWorldFunction

# 查看最新错误
aws logs filter-log-events \
  --log-group-name "/aws/lambda/sam-nodejs-app-dev-HelloWorldFunction" \
  --filter-pattern "ERROR"

# 测试函数
aws lambda invoke \
  --function-name sam-nodejs-app-dev-HelloWorldFunction \
  --payload '{"test": true}' \
  response.json
```

#### 3. API网关问题

```bash
# 获取API信息
aws apigateway get-rest-apis

# 测试特定端点
aws apigateway test-invoke-method \
  --rest-api-id abcdef123 \
  --resource-id xyz789 \
  --http-method GET
```

### 日志分析

```bash
# 查看错误统计
aws logs filter-log-events \
  --log-group-name "/aws/lambda/sam-nodejs-app-dev-HelloWorldFunction" \
  --filter-pattern "ERROR" \
  --start-time $(date -d '24 hours ago' +%s)000 | \
  jq '.events | length'

# 查看性能指标
aws logs filter-log-events \
  --log-group-name "/aws/lambda/sam-nodejs-app-dev-HelloWorldFunction" \
  --filter-pattern "REPORT" \
  --start-time $(date -d '1 hour ago' +%s)000
```

## 性能优化

### 监控性能指标

```bash
# 监控冷启动时间
aws logs filter-log-events \
  --log-group-name "/aws/lambda/sam-nodejs-app-dev-HelloWorldFunction" \
  --filter-pattern "[timestamp, requestId, \"REPORT\", ...]" \
  --start-time $(date -d '1 hour ago' +%s)000

# 查看内存使用情况
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name MemoryUtilization \
  --dimensions Name=FunctionName,Value=sam-nodejs-app-dev-HelloWorldFunction \
  --start-time $(date -d '1 hour ago' -u +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

### 配置优化

```bash
# 调整内存配置
aws lambda update-function-configuration \
  --function-name sam-nodejs-app-dev-HelloWorldFunction \
  --memory-size 256

# 设置预置并发（付费功能）
aws lambda put-provisioned-concurrency-config \
  --function-name sam-nodejs-app-dev-HelloWorldFunction \
  --qualifier '$LATEST' \
  --provisioned-concurrency-config AllocatedConcurrency=10
```

### 清理和维护

```bash
# 清理构建缓存
sam build --clean

# 删除无用的Lambda版本
aws lambda list-versions-by-function \
  --function-name sam-nodejs-app-dev-HelloWorldFunction | \
  jq '.Versions[] | select(.Version != "$LATEST") | .Version' | \
  xargs -I {} aws lambda delete-function \
  --function-name sam-nodejs-app-dev-HelloWorldFunction:{} 

# 删除整个堆栈
aws cloudformation delete-stack --stack-name sam-nodejs-app-dev
```

---

本部署指南确保您的Node.js SAM应用安全、高效地部署到生产环境。
