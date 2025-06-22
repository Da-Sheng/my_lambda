# 📡 API接口文档

Node.js SAM应用REST API完整接口说明。

## 📋 目录

- [接口概览](#接口概览)
- [认证授权](#认证授权)
- [接口详情](#接口详情)
- [错误处理](#错误处理)
- [测试指南](#测试指南)
- [性能规范](#性能规范)

## 接口概览

### 已部署的API端点

- **Hello World API**: `GET /hello`
- **用户管理API**: `GET /api/users`

### API基础信息

- **当前版本**: v1.0
- **响应格式**: JSON
- **字符编码**: UTF-8
- **访问控制**: CORS已启用

## 接口详情

### 1. Hello World服务

#### 获取问候信息

```http
GET /hello
```

**响应示例**:

```json
{
  "message": "hello world",
  "timestamp": "2024-01-20T10:30:00Z"
}
```

**响应说明**:

| 字段 | 类型 | 描述 |
|------|------|------|
| `message` | string | 问候消息 |
| `timestamp` | string | ISO8601时间戳 |

### 2. 用户管理服务

#### 获取用户列表

```http
GET /api/users
```

**查询参数**:

| 参数 | 类型 | 必需 | 默认值 | 描述 |
|------|------|------|---------|------|
| `page` | integer | 否 | 1 | 页码 |
| `limit` | integer | 否 | 10 | 每页数量 |

**响应示例**:

```json
{
  "users": [
    {
      "id": "user_001",
      "name": "张三",
      "email": "zhangsan@example.com",
      "status": "active",
      "createdAt": "2024-01-15T08:30:00Z",
      "updatedAt": "2024-01-20T10:15:00Z"
    },
    {
      "id": "user_002", 
      "name": "李四",
      "email": "lisi@example.com",
      "status": "active",
      "createdAt": "2024-01-16T09:45:00Z",
      "updatedAt": "2024-01-19T14:22:00Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 45,
    "itemsPerPage": 10,
    "hasNext": true,
    "hasPrevious": false
  },
  "meta": {
    "timestamp": "2024-01-20T10:30:00Z",
    "requestId": "req_123456"
  }
}
```

## 错误处理

### 错误响应格式

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "请求参数验证失败",
    "details": [
      {
        "field": "email",
        "message": "邮箱格式不正确"
      }
    ]
  },
  "meta": {
    "timestamp": "2024-01-20T10:30:00Z",
    "requestId": "req_123456"
  }
}
```

### HTTP状态码

| 状态码 | 含义 | 使用场景 |
|---------|------|----------|
| `200` | 成功 | 请求成功处理 |
| `201` | 已创建 | 资源创建成功 |
| `400` | 请求错误 | 参数验证失败 |
| `404` | 未找到 | 资源不存在 |
| `500` | 服务器错误 | 内部错误 |

## 测试指南

### 本地测试

```bash
# 启动本地服务
./local-dev.sh

# 基础测试
curl http://localhost:3000/hello

# 用户接口测试
curl http://localhost:3000/api/users
```

### 生产环境测试

```bash
# 替换为实际部署的API Gateway URL
API_BASE="https://your-api-id.execute-api.us-east-1.amazonaws.com/Prod"

# Hello World测试
curl $API_BASE/hello

# 用户列表测试  
curl "$API_BASE/api/users?page=1&limit=5"
```

### 自动化测试

```javascript
// tests/api.test.js
describe('API端点测试', () => {
  const baseUrl = process.env.API_BASE_URL || 'http://localhost:3000';

  test('GET /hello 应返回问候信息', async () => {
    const response = await fetch(`${baseUrl}/hello`);
    const data = await response.json();
    
    expect(response.status).toBe(200);
    expect(data.message).toBe('hello world');
    expect(data.timestamp).toBeDefined();
  });

  test('GET /api/users 应返回用户列表', async () => {
    const response = await fetch(`${baseUrl}/api/users`);
    const data = await response.json();
    
    expect(response.status).toBe(200);
    expect(data.users).toBeInstanceOf(Array);
    expect(data.pagination).toBeDefined();
  });
});
```

## 性能规范

### 响应时间目标

| 接口类型 | P50 | P95 | P99 |
|----------|-----|-----|-----|
| 简单查询 | <100ms | <200ms | <500ms |
| 复杂查询 | <300ms | <600ms | <1s |

### 并发处理

- **最大并发**: 1000 req/s
- **平均并发**: 100 req/s
- **突发处理**: 支持5分钟内3倍流量突发

---

本API文档为开发者提供完整的接口使用指南，持续更新中。
