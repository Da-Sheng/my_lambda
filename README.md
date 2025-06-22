# Node.js SAM DevOps 项目

完整的Node.js无服务器应用DevOps工作流，使用AWS SAM框架。

## 🏗️ 架构特性

- **多环境支持**: 开发、暂存、生产环境独立配置
- **微服务架构**: Lambda函数按业务功能分离  
- **安全凭证管理**: 环境变量方式，Git安全
- **本地开发**: SAM local支持本地测试和调试
- **CI/CD就绪**: 自动化部署脚本
- **监控集成**: CloudWatch日志和X-Ray跟踪

## 🚀 快速开始

### 1. 配置AWS凭证

```bash
# 复制凭证模板
cp aws-credentials.template aws-credentials.env

# 编辑并填入您的AWS凭证
nano aws-credentials.env

# 验证配置
./setup-aws.sh
```

### 2. 初始化项目

```bash
# 创建SAM项目
sam init --runtime nodejs18.x --name sam-app --app-template hello-world

# 进入项目目录
cd sam-app

# 安装依赖
npm install
```

### 3. 本地开发

```bash
# 构建项目
sam build

# 启动本地API
sam local start-api

# 测试API (新终端)
curl http://localhost:3000/hello
```

### 4. 部署到AWS

```bash
# 首次部署（引导配置）
sam deploy --guided

# 后续部署
sam deploy
```

## 📁 项目结构

```
sam-nodejs-devops/
├── aws-credentials.template    # AWS凭证模板
├── setup-aws.sh              # AWS环境配置脚本
├── .gitignore                 # Git忽略文件（保护凭证）
├── sam-app/                   # SAM应用主目录
│   ├── template.yaml          # SAM模板
│   ├── src/                   # Lambda函数源码
│   │   ├── hello/             # Hello World API
│   │   └── users/             # 用户管理API
│   ├── tests/                 # 测试文件
│   └── events/                # 测试事件
├── scripts/                   # 部署脚本
│   ├── deploy-dev.sh
│   ├── deploy-staging.sh
│   └── deploy-prod.sh
└── docs/                      # 文档
```

## 🔧 环境配置

### 开发环境
- 前缀: `dev-sam-nodejs`
- 区域: `ap-southeast-2`
- 日志级别: `debug`

### 暂存环境  
- 前缀: `staging-sam-nodejs`
- 区域: `ap-southeast-2`
- 日志级别: `info`

### 生产环境
- 前缀: `prod-sam-nodejs`
- 区域: `ap-southeast-2`
- 日志级别: `warn`

## 🛡️ 安全最佳实践

- ✅ AWS凭证使用临时令牌
- ✅ 敏感文件加入`.gitignore`
- ✅ 环境变量方式管理配置
- ✅ 不同环境隔离部署
- ✅ IAM权限最小化原则

## 📋 常用命令

```bash
# 验证SAM模板
sam validate

# 构建项目
sam build

# 本地测试单个函数
sam local invoke HelloWorldFunction

# 本地测试API
sam local start-api

# 查看部署日志
sam logs --name HelloWorldFunction --tail

# 删除堆栈
sam delete
```

## 🔍 监控和调试

- **CloudWatch日志**: 自动收集Lambda函数日志
- **X-Ray跟踪**: 分布式跟踪和性能分析
- **CloudWatch指标**: 自定义业务指标
- **AWS Application Insights**: 应用程序监控

## 📚 文档系统

| 文档 | 描述 | 面向用户 |
|------|------|----------|
| [开发指南](docs/DEVELOPMENT.md) | 本地开发、测试和调试 | 开发者 |
| [部署指南](docs/DEPLOYMENT.md) | 多环境部署和运维 | 运维人员 |
| [API文档](docs/API.md) | REST API接口说明 | 前端开发者 |
| [项目结构](docs/PROJECT_STRUCTURE.md) | 代码架构和文件说明 | 架构师 |

## 📋 更多资源

- [AWS SAM 官方文档](https://docs.aws.amazon.com/serverless-application-model/)
- [Node.js Lambda最佳实践](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-handler.html)
- [API Gateway开发指南](https://docs.aws.amazon.com/apigateway/)

---

⚡ **由 AWS SAM 强力驱动** | 🔗 **企业级无服务器DevOps工作流** 