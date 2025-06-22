# 🚀 Enterprise Node.js SAM API

企业级Node.js无服务器API项目，基于AWS SAM构建，支持多环境部署、监控和自动化DevOps流程。

## ✨ 功能特性

- 🏗️ **微服务架构**: 模块化Lambda函数设计
- 🌍 **多环境支持**: dev、staging、prod环境分离
- 📊 **完整监控**: CloudWatch仪表板、X-Ray跟踪、应用洞察
- 🔄 **自动化部署**: 一键部署脚本和CI/CD支持
- 🧪 **本地开发**: 完整的本地测试环境
- 🔒 **安全最佳实践**: IAM权限控制、CORS配置
- 📋 **API文档**: RESTful API设计和文档

## 🏛️ 项目架构

```
sam-nodejs-app/
├── 📁 hello-world/          # Hello World API
│   ├── app.mjs              # Lambda处理器
│   └── package.json         # 依赖配置
├── 📁 src/
│   ├── 📁 users/            # 用户管理API
│   │   ├── app.mjs          # 用户CRUD操作
│   │   └── package.json     # 依赖配置
│   └── 📁 common/           # 共享工具函数
├── 📁 events/               # 测试事件
├── template.yaml            # SAM模板
├── deploy.sh               # 部署脚本
├── local-dev.sh            # 本地开发脚本
└── samconfig.toml          # SAM配置
```

## 🔧 API端点

### Hello World API
- `GET /hello` - 返回问候消息

### 用户管理API
- `GET /api/users` - 获取用户列表
  - 查询参数：`page`, `limit`, `role`, `search`
- `GET /api/users/{id}` - 获取单个用户
- `POST /api/users` - 创建新用户

## 🚀 快速开始

### 1. 环境准备

确保已安装以下工具：
- [Node.js 18+](https://nodejs.org/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)
- [Docker](https://www.docker.com/get-started/)

### 2. 配置AWS凭证

```bash
# 方法1: 使用AWS CLI配置
aws configure

# 方法2: 使用环境变量
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_SESSION_TOKEN=your-session-token  # 如果使用临时凭证
export AWS_DEFAULT_REGION=ap-southeast-2
```

### 3. 本地开发

```bash
# 安装依赖
./local-dev.sh install

# 构建项目
./local-dev.sh build

# 启动本地API服务器
./local-dev.sh start

# 在另一个终端运行API测试
./local-dev.sh test
```

### 4. 部署到AWS

```bash
# 部署到开发环境
./deploy.sh dev

# 部署到生产环境（需要额外确认）
./deploy.sh prod --guided

# 查看部署结果和日志
./deploy.sh dev --logs
```

## 📋 本地开发命令

```bash
# 显示帮助
./local-dev.sh --help

# 构建应用
./local-dev.sh build

# 启动本地API服务器 (默认端口3000)
./local-dev.sh start

# 启动在自定义端口
./local-dev.sh start --port 8080

# 运行API测试
./local-dev.sh test

# 查看Lambda日志
./local-dev.sh logs

# 清理构建文件
./local-dev.sh clean

# 安装依赖
./local-dev.sh install
```

## 🌍 部署命令

```bash
# 显示帮助
./deploy.sh --help

# 部署到开发环境
./deploy.sh dev

# 引导式部署到生产环境
./deploy.sh prod --guided

# 仅构建不部署
./deploy.sh dev --build-only

# 部署后显示日志
./deploy.sh staging --logs

# 跳过确认直接部署
./deploy.sh dev --no-confirm
```

## 🧪 API测试示例

### 测试Hello World API
```bash
curl https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/Prod/hello
```

### 测试用户API
```bash
# 获取用户列表
curl https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/Prod/api/users

# 获取单个用户
curl https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/Prod/api/users/1

# 创建新用户
curl -X POST https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/Prod/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","role":"user"}'

# 分页查询
curl "https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/Prod/api/users?page=1&limit=5"

# 角色过滤
curl "https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/Prod/api/users?role=admin"

# 搜索用户
curl "https://your-api-id.execute-api.ap-southeast-2.amazonaws.com/Prod/api/users?search=alice"
```

## 📊 监控和日志

### CloudWatch仪表板
部署后访问CloudWatch仪表板查看：
- Lambda函数性能指标
- API Gateway请求统计
- 错误率和延迟分析

### X-Ray跟踪
启用X-Ray跟踪查看：
- 请求链路追踪
- 性能瓶颈分析
- 依赖关系图

### 日志查看
```bash
# 查看特定函数日志
sam logs --name HelloWorldFunction --tail

# 查看所有函数日志
sam logs --tail

# 查看部署后的日志
./deploy.sh dev --logs
```

## 🏗️ 项目结构详解

### Lambda函数
- **Hello World**: 简单的问候API，演示基本功能
- **Users API**: 完整的CRUD操作，包含输入验证和错误处理

### AWS资源
- **API Gateway**: RESTful API端点
- **Lambda函数**: 无服务器计算
- **DynamoDB**: NoSQL数据库（预留）
- **CloudWatch**: 监控和日志
- **IAM角色**: 权限管理

### 开发工具
- **部署脚本**: 自动化多环境部署
- **本地开发**: 热重载和实时测试
- **测试工具**: API端点自动化测试

## 🔧 自定义配置

### 环境变量
在`template.yaml`中配置：
```yaml
Environment:
  Variables:
    ENVIRONMENT: !Ref Environment
    LOG_LEVEL: !Ref LogLevel
    TABLE_NAME: !Ref UsersTable
```

### 部署参数
支持的部署参数：
- `Environment`: 部署环境 (dev/staging/prod)
- `LogLevel`: 日志级别 (debug/info/warn/error)

## 🔒 安全最佳实践

- ✅ IAM最小权限原则
- ✅ API Gateway CORS配置
- ✅ 输入验证和消毒
- ✅ 错误处理不泄露敏感信息
- ✅ 环境变量分离敏感配置
- ✅ CloudWatch日志记录

## 🚨 故障排除

### 常见问题

**1. Docker未运行**
```bash
# 启动Docker Desktop
open -a Docker
```

**2. AWS凭证问题**
```bash
# 检查当前凭证
aws sts get-caller-identity

# 重新配置
aws configure
```

**3. 端口占用**
```bash
# 查看端口占用
lsof -i :3000

# 使用不同端口
./local-dev.sh start --port 8080
```

**4. 构建失败**
```bash
# 清理并重新构建
./local-dev.sh clean
./local-dev.sh build
```

## 📈 性能优化

- **冷启动优化**: 使用轻量级依赖
- **内存配置**: 根据函数需求调整内存
- **并发控制**: 配置适当的并发限制
- **缓存策略**: 实现适当的缓存机制

## 🔄 CI/CD集成

项目支持与以下CI/CD工具集成：
- GitHub Actions
- AWS CodePipeline
- Jenkins
- GitLab CI

## 📝 许可证

MIT License - 详见LICENSE文件

## 🤝 贡献

欢迎提交Issue和Pull Request！

---

**开发团队**: DevOps团队  
**最后更新**: 2024年6月  
**版本**: 1.0.0
