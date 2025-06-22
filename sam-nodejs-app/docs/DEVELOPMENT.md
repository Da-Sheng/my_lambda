# 🛠️ 开发指南

Node.js SAM应用本地开发、测试和调试完整指南。

## 📋 目录

- [环境准备](#环境准备)
- [本地开发](#本地开发)
- [代码结构](#代码结构)
- [测试指南](#测试指南)
- [调试技巧](#调试技巧)
- [开发最佳实践](#开发最佳实践)

## 环境准备

### 必需工具

| 工具 | 版本要求 | 安装命令 | 用途 |
|------|----------|-----------|------|
| Node.js | 18.x+ | [官方下载](https://nodejs.org/) | JavaScript运行时 |
| npm | 8.x+ | Node.js自带 | 包管理器 |
| AWS CLI | 2.x | `brew install awscli` | AWS服务管理 |
| SAM CLI | 1.x | `brew install aws-sam-cli` | 无服务器应用管理 |
| Docker | 20.x+ | [Docker Desktop](https://docker.com/) | 本地Lambda容器 |

### 环境验证

```bash
# 验证工具版本
node --version        # v18+
aws --version         # 2.x
sam --version         # 1.x
docker --version      # 20.x+
```

## 本地开发

### 🚀 快速启动

```bash
# 启动本地开发服务器
./local-dev.sh

# API服务器地址: http://localhost:3000
```

### 手动操作

```bash
# 1. 安装依赖
cd hello-world && npm install && cd ..
cd src/users && npm install && cd ../..

# 2. 构建应用
sam build

# 3. 启动API
sam local start-api --port 3000

# 4. 测试函数
sam local invoke HelloWorldFunction
```

## 代码结构

### Lambda函数结构

```
function-name/
├── app.mjs              # 主处理函数
├── package.json         # 依赖配置
├── tests/               # 测试文件
└── node_modules/        # 依赖包
```

### 标准处理函数

```javascript
export const lambdaHandler = async (event, context) => {
    try {
        const { httpMethod, pathParameters, body } = event;
        
        // 业务逻辑
        switch (httpMethod) {
            case 'GET':
                return await handleGet(pathParameters);
            case 'POST':
                return await handlePost(JSON.parse(body));
            default:
                return createErrorResponse(405, '方法不允许');
        }
    } catch (error) {
        console.error('错误:', error);
        return createErrorResponse(500, '服务器错误');
    }
};

const createResponse = (statusCode, body) => ({
    statusCode,
    headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(body)
});
```

## 测试指南

### 单元测试

```bash
# 运行测试
cd hello-world && npm test
cd src/users && npm test
```

### API测试

```bash
# 测试Hello World
curl http://localhost:3000/hello

# 测试用户API
curl http://localhost:3000/api/users

# 创建用户
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

## 调试技巧

### VS Code调试

创建 `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug SAM Local",
            "type": "node",
            "request": "attach",
            "port": 5858,
            "address": "localhost"
        }
    ]
}
```

启动调试:

```bash
sam local start-api --debug-port 5858
```

### 日志调试

```javascript
export const lambdaHandler = async (event, context) => {
    console.log('事件:', JSON.stringify(event, null, 2));
    console.log('上下文:', JSON.stringify(context, null, 2));
    
    try {
        // 业务逻辑
    } catch (error) {
        console.error('错误详情:', {
            message: error.message,
            stack: error.stack,
            event
        });
    }
};
```

## 开发最佳实践

### 代码规范

- 使用ES6模块语法 (`.mjs`)
- 函数名使用驼峰命名
- 常量使用大写命名
- 适当的错误处理和日志

### 性能优化

- 将初始化代码移到处理函数外部
- 使用连接池复用数据库连接
- 合理设置Lambda内存和超时
- 定期更新依赖包

### 安全最佳实践

- 输入验证和清理
- 使用环境变量管理配置
- 最小权限原则
- 定期安全审计

```bash
# 安全检查
npm audit
npm audit fix
```

---

本开发指南帮助您高效开发和调试Node.js SAM应用。
