/**
 * 用户管理API Lambda函数
 * 支持GET /users（获取用户列表）、GET /users/{id}（获取单个用户）、POST /users（创建用户）
 */

// 模拟用户数据库 - 在实际项目中会连接DynamoDB
let users = [
    { 
        id: 1, 
        name: 'Alice Johnson', 
        email: 'alice@example.com',
        role: 'admin',
        createdAt: '2024-01-15T08:30:00Z'
    },
    { 
        id: 2, 
        name: 'Bob Smith', 
        email: 'bob@example.com',
        role: 'user',
        createdAt: '2024-01-16T09:15:00Z'
    },
    { 
        id: 3, 
        name: 'Charlie Brown', 
        email: 'charlie@example.com',
        role: 'moderator',
        createdAt: '2024-01-17T10:00:00Z'
    }
];

// 工具函数：生成标准API响应
const createResponse = (statusCode, body, headers = {}) => ({
    statusCode,
    headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
        ...headers
    },
    body: JSON.stringify(body)
});

// 工具函数：输入验证
const validateUserInput = (userData) => {
    const errors = [];
    
    if (!userData.name || typeof userData.name !== 'string' || userData.name.trim().length < 2) {
        errors.push('用户名必须至少2个字符');
    }
    
    if (!userData.email || typeof userData.email !== 'string') {
        errors.push('邮箱地址是必需的');
    } else {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(userData.email)) {
            errors.push('邮箱地址格式无效');
        }
    }
    
    if (userData.role && !['admin', 'user', 'moderator'].includes(userData.role)) {
        errors.push('角色必须是: admin, user, 或 moderator');
    }
    
    return errors;
};

export const lambdaHandler = async (event, context) => {
    try {
        const { httpMethod, pathParameters, body, queryStringParameters } = event;
        
        console.log('收到请求:', {
            method: httpMethod,
            path: pathParameters,
            query: queryStringParameters,
            body: body ? JSON.parse(body) : null
        });
        
        switch (httpMethod) {
            case 'GET':
                if (pathParameters && pathParameters.id) {
                    // 获取单个用户
                    const userId = parseInt(pathParameters.id);
                    if (isNaN(userId)) {
                        return createResponse(400, {
                            success: false,
                            error: '无效的用户ID',
                            message: '用户ID必须是数字'
                        });
                    }
                    
                    const user = users.find(u => u.id === userId);
                    if (!user) {
                        return createResponse(404, {
                            success: false,
                            error: '用户未找到',
                            message: `用户ID ${userId} 不存在`
                        });
                    }
                    
                    return createResponse(200, {
                        success: true,
                        data: user
                    });
                } else {
                    // 获取用户列表（支持分页和过滤）
                    let filteredUsers = [...users];
                    
                    // 角色过滤
                    if (queryStringParameters?.role) {
                        filteredUsers = filteredUsers.filter(u => u.role === queryStringParameters.role);
                    }
                    
                    // 名称搜索
                    if (queryStringParameters?.search) {
                        const searchTerm = queryStringParameters.search.toLowerCase();
                        filteredUsers = filteredUsers.filter(u => 
                            u.name.toLowerCase().includes(searchTerm) || 
                            u.email.toLowerCase().includes(searchTerm)
                        );
                    }
                    
                    // 简单分页
                    const page = parseInt(queryStringParameters?.page) || 1;
                    const limit = parseInt(queryStringParameters?.limit) || 10;
                    const offset = (page - 1) * limit;
                    const paginatedUsers = filteredUsers.slice(offset, offset + limit);
                    
                    return createResponse(200, {
                        success: true,
                        data: paginatedUsers,
                        pagination: {
                            page,
                            limit,
                            total: filteredUsers.length,
                            totalPages: Math.ceil(filteredUsers.length / limit)
                        }
                    });
                }
                
            case 'POST':
                // 创建新用户
                if (!body) {
                    return createResponse(400, {
                        success: false,
                        error: '请求体为空',
                        message: '创建用户需要提供用户数据'
                    });
                }
                
                const userData = JSON.parse(body);
                
                // 输入验证
                const validationErrors = validateUserInput(userData);
                if (validationErrors.length > 0) {
                    return createResponse(400, {
                        success: false,
                        error: '输入验证失败',
                        message: validationErrors
                    });
                }
                
                // 检查邮箱是否已存在
                const existingUser = users.find(u => u.email.toLowerCase() === userData.email.toLowerCase());
                if (existingUser) {
                    return createResponse(409, {
                        success: false,
                        error: '邮箱已存在',
                        message: '该邮箱地址已被其他用户使用'
                    });
                }
                
                // 创建新用户
                const newUser = {
                    id: Math.max(...users.map(u => u.id), 0) + 1,
                    name: userData.name.trim(),
                    email: userData.email.toLowerCase(),
                    role: userData.role || 'user',
                    createdAt: new Date().toISOString()
                };
                
                users.push(newUser);
                
                return createResponse(201, {
                    success: true,
                    message: '用户创建成功',
                    data: newUser
                });
                
            case 'OPTIONS':
                // CORS预检请求
                return createResponse(200, {}, {
                    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
                });
                
            default:
                return createResponse(405, {
                    success: false,
                    error: '方法不允许',
                    message: `HTTP方法 ${httpMethod} 不受支持`
                });
        }
        
    } catch (err) {
        console.error('处理请求时发生错误:', err);
        
        return createResponse(500, {
            success: false,
            error: '服务器内部错误',
            message: '处理请求时发生未知错误',
            timestamp: new Date().toISOString()
        });
    }
}; 