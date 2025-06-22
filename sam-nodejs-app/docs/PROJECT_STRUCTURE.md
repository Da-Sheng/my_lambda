# 🏗️ 项目结构说明

Node.js SAM应用完整目录结构和文件说明。

## 📋 目录

- [项目概览](#项目概览)
- [核心目录](#核心目录)
- [配置文件](#配置文件)
- [脚本文件](#脚本文件)
- [Lambda函数](#lambda函数)
- [文档系统](#文档系统)
- [命名规范](#命名规范)

## 项目概览

```
sam-nodejs-app/
├── docs/                    # 📚 项目文档
│   ├── DEVELOPMENT.md       # 开发指南
│   ├── DEPLOYMENT.md        # 部署指南
│   ├── API.md               # API接口文档
│   └── PROJECT_STRUCTURE.md # 项目结构说明
├── hello-world/             # 🌍 Hello World Lambda函数
│   ├── app.mjs              # 主处理函数
│   ├── package.json         # 依赖配置
│   └── tests/               # 测试文件
├── src/                     # 📁 业务逻辑源码
│   ├── common/              # 公共组件
│   └── users/               # 用户管理服务
├── events/                  # 🎯 测试事件文件
├── .aws-sam/               # ⚙️ SAM构建缓存
├── template.yaml           # 📜 SAM模板
├── samconfig.toml          # ⚙️ SAM配置
├── deploy.sh               # �� 部署脚本
├── local-dev.sh            # 🛠️ 本地开发脚本
├── README.md               # 📖 项目说明
└── .gitignore              # 🚫 Git忽略文件
```

## 核心目录

### `/docs` - 文档目录

```
docs/
├── DEVELOPMENT.md          # 开发指南
├── DEPLOYMENT.md           # 部署指南
├── API.md                  # API接口文档
└── PROJECT_STRUCTURE.md   # 项目结构说明
```

**用途**: 集中存放项目所有文档  
**维护**: 随代码变更同步更新  
**格式**: Markdown格式，支持GitHub渲染

### `/hello-world` - Hello World服务

```
hello-world/
├── app.mjs                 # Lambda处理函数
├── package.json            # 依赖配置
├── tests/                  # 测试文件
│   └── unit/
│       └── test-handler.mjs
└── node_modules/           # NPM依赖包
```

**功能**: 基础问候服务  
**端点**: `GET /hello`  
**技术栈**: Node.js 18.x, ES6模块

### `/src` - 业务逻辑源码

```
src/
├── common/                 # 公共组件
│   ├── response.mjs        # 统一响应格式
│   ├── validation.mjs      # 参数验证
│   └── database.mjs        # 数据库操作
└── users/                  # 用户管理服务
    ├── app.mjs             # Lambda处理函数
    ├── package.json        # 依赖配置
    └── handlers/           # 具体业务处理
        ├── get-users.mjs
        ├── create-user.mjs
        ├── update-user.mjs
        └── delete-user.mjs
```

**架构**: 微服务架构  
**复用**: common目录提供跨服务组件  
**扩展**: 新服务按相同模式添加

### `/events` - 测试事件

```
events/
├── event.json              # 默认测试事件
├── hello-world-event.json  # Hello World测试
└── users-event.json        # 用户服务测试
```

**用途**: 本地调试和测试  
**格式**: AWS Lambda事件标准格式  
**调用**: `sam local invoke -e events/event.json`

### `/.aws-sam` - SAM构建目录

```
.aws-sam/
├── build/                  # 构建输出
├── cache/                  # 构建缓存
└── deps/                   # 依赖缓存
```

**状态**: 自动生成，不纳入版本控制  
**清理**: `sam build --clean`  
**缓存**: 加速后续构建过程

## 配置文件

### `template.yaml` - SAM模板

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: Node.js SAM应用

Parameters:           # 模板参数
  Environment:        # 环境标识
    Type: String
    Default: dev

Globals:             # 全局配置
  Function:          # Lambda函数默认配置
    Timeout: 15
    MemorySize: 256
    Runtime: nodejs18.x

Resources:           # AWS资源定义
  HelloWorldFunction: # Lambda函数
  UsersFunction:     # 用户管理函数
  ApiGatewayApi:     # API Gateway
  DynamoDBTable:     # DynamoDB表

Outputs:             # 输出值
  ApiGatewayUrl:     # API访问地址
  DynamoDBTableName: # 数据库表名
```

**作用**: 定义AWS资源和配置  
**语法**: CloudFormation YAML格式  
**部署**: `sam deploy` 基于此文件创建资源

### `samconfig.toml` - SAM配置

```toml
version = 0.1

[default]              # 默认配置
[default.deploy]
[default.deploy.parameters]
stack_name = "sam-nodejs-app-dev"
s3_bucket = "sam-nodejs-app-dev-deployment"
s3_prefix = "sam-nodejs-app-dev"
region = "us-east-1"
capabilities = "CAPABILITY_IAM"
parameter_overrides = "Environment=dev"

[prod]                 # 生产环境配置
[prod.deploy]
[prod.deploy.parameters]
stack_name = "sam-nodejs-app-prod"
s3_bucket = "sam-nodejs-app-prod-deployment"
parameter_overrides = "Environment=prod"
```

**功能**: 多环境部署配置  
**使用**: `sam deploy --config-env prod`  
**环境**: 支持dev、staging、prod等环境

### `package.json` - 函数依赖

```json
{
  "name": "hello-world",
  "version": "1.0.0",
  "description": "Hello World Lambda函数",
  "main": "app.mjs",
  "type": "module",
  "scripts": {
    "test": "node --experimental-loader=./loader.mjs tests/unit/test-handler.mjs"
  },
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.x.x"
  },
  "devDependencies": {
    "chai": "^4.x.x",
    "mocha": "^10.x.x"
  }
}
```

**说明**: 每个Lambda函数独立的依赖管理  
**模块**: 使用ES6模块 (`"type": "module"`)  
**测试**: 包含测试脚本配置

## 脚本文件

### `deploy.sh` - 部署脚本

```bash
#!/bin/bash
# 一键部署脚本

# 功能:
# - 环境参数验证
# - S3存储桶创建
# - SAM构建和部署
# - 部署结果验证

# 使用:
# ./deploy.sh dev           # 部署到开发环境
# ./deploy.sh prod --confirm # 部署到生产环境
```

**特点**: 支持多环境、参数验证、自动创建依赖资源  
**安全**: 生产环境需要明确确认  
**日志**: 详细的部署过程输出

### `local-dev.sh` - 本地开发脚本

```bash
#!/bin/bash
# 本地开发环境启动脚本

# 功能:
# - 依赖安装检查
# - SAM本地API启动
# - 热重载监控
# - 错误处理

# 服务: http://localhost:3000
```

**用途**: 一键启动本地开发环境  
**监控**: 支持代码变更自动重启  
**调试**: 集成调试端口配置

## Lambda函数

### 函数结构模式

```javascript
// app.mjs - 标准Lambda函数结构
export const lambdaHandler = async (event, context) => {
  // 1. 事件解析
  const { httpMethod, pathParameters, body, queryStringParameters } = event;
  
  // 2. 参数验证
  const validatedData = validateInput(body, queryStringParameters);
  
  // 3. 业务逻辑处理
  const result = await processBusinessLogic(validatedData);
  
  // 4. 响应格式化
  return formatResponse(200, result);
};

// 辅助函数
const formatResponse = (statusCode, body) => ({
  statusCode,
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  },
  body: JSON.stringify(body)
});
```

### 错误处理模式

```javascript
export const lambdaHandler = async (event, context) => {
  try {
    // 业务逻辑
  } catch (error) {
    console.error('函数执行错误:', {
      message: error.message,
      stack: error.stack,
      event: JSON.stringify(event)
    });
    
    return formatResponse(500, {
      error: '服务器内部错误',
      requestId: context.awsRequestId
    });
  }
};
```

### 环境配置模式

```javascript
// 环境变量读取
const config = {
  tableName: process.env.DYNAMODB_TABLE_NAME,
  region: process.env.AWS_REGION,
  environment: process.env.ENVIRONMENT || 'dev',
  logLevel: process.env.LOG_LEVEL || 'info'
};

// 条件配置
const isProduction = config.environment === 'prod';
const timeout = isProduction ? 30 : 10;
```

## 文档系统

### 文档标准

- **格式**: Markdown格式
- **结构**: 统一的目录和章节布局
- **链接**: 内部相互引用和外部资源链接
- **代码**: 语法高亮和完整示例
- **更新**: 与代码变更同步维护

### 文档类型

| 文档 | 目标用户 | 更新频率 |
|------|----------|-----------|
| README.md | 新用户 | 主要功能变更时 |
| DEVELOPMENT.md | 开发者 | 开发流程变更时 |
| DEPLOYMENT.md | 运维人员 | 部署流程变更时 |
| API.md | 前端开发者 | API变更时 |
| PROJECT_STRUCTURE.md | 架构师 | 结构调整时 |

## 命名规范

### 文件命名

- **组件**: `kebab-case` (hello-world)
- **函数**: `camelCase` (lambdaHandler)
- **常量**: `UPPER_CASE` (API_BASE_URL)
- **配置**: `lowercase` (template.yaml)

### AWS资源命名

```
格式: {项目名}-{环境}-{资源类型}-{功能}
示例:
- sam-nodejs-app-dev-HelloWorldFunction
- sam-nodejs-app-prod-ApiGatewayApi
- sam-nodejs-app-staging-DynamoDBTable
```

### 环境标识

- **开发**: `dev`
- **测试**: `staging`
- **生产**: `prod`
- **本地**: `local`

## 实际部署示例

### 当前部署状态

```
堆栈名称: sam-nodejs-app-dev
区域: us-east-1
资源:
├── HelloWorldFunction      # Lambda函数
├── UsersFunction          # 用户管理函数
├── ServerlessRestApi      # API Gateway
├── DynamoDBTable          # DynamoDB表
└── ApplicationInsights    # 监控组件
```

### API端点

```
API Gateway URL: https://xyz123.execute-api.us-east-1.amazonaws.com/Prod/
端点:
├── GET  /hello        # Hello World服务
└── GET  /api/users    # 用户列表服务
```

---

本项目结构文档帮助开发者快速理解和维护代码架构。
