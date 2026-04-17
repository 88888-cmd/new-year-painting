# 年画推荐系统 - 后端服务

基于 Django 的年画推荐系统后端 API 服务。

## 功能模块

- 🔐 **用户认证**: JWT 认证、权限管理
- 🎨 **作品管理**: 年画作品 CRUD、分类管理
- 📦 **订单系统**: 订单创建、支付、退款
- 🎁 **积分系统**: 积分任务、积分商品兑换
- 💬 **社区功能**: 帖子、评论、点赞
- 🤖 **AI 推荐**: 个性化推荐算法
- 📚 **知识图谱**: 年画知识问答
- 📁 **文件管理**: 图片、视频上传
- 🔍 **搜索功能**: 全文搜索、标签搜索

## 技术栈

- Python 3.8+
- Django 3.2+
- Django REST Framework
- MySQL 5.7+
- Redis (缓存)
- Celery (异步任务)
- ChromaDB (向量数据库)

## 环境要求

- Python 3.8+
- MySQL 5.7+
- Redis (可选)

## 快速开始

### 1. 创建虚拟环境
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate  # Windows
```

### 2. 安装依赖
```bash
pip install -r requirements.txt
```

### 3. 配置数据库
编辑 `server/settings.py`:
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'painting',
        'USER': 'your_username',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

### 4. 导入数据库
```bash
mysql -u root -p < ../database/painting.sql
```

### 5. 数据库迁移
```bash
python manage.py migrate
```

### 6. 创建超级用户
```bash
python manage.py createsuperuser
```

### 7. 运行开发服务器
```bash
python manage.py runserver
```

访问 http://localhost:8000

## 项目结构

```
backend/
├── myapp/              # 主应用
│   ├── models.py      # 数据模型
│   ├── views.py       # 视图函数
│   ├── serializers.py # 序列化器
│   ├── urls.py        # 路由配置
│   └── admin.py       # 后台管理
├── server/            # 项目配置
│   ├── settings.py    # 配置文件
│   ├── urls.py        # 主路由
│   └── wsgi.py        # WSGI 配置
├── middlewares/       # 中间件
├── locale/            # 国际化
├── upload/            # 上传文件
├── knowledge_base/    # 知识库
├── chroma_db/         # 向量数据库
├── manage.py          # 管理脚本
├── api_r.py           # API 路由
├── requirements.txt   # 依赖列表
└── README.md          # 说明文档
```

## API 文档

### 认证接口
- `POST /api/login/` - 用户登录
- `POST /api/register/` - 用户注册
- `POST /api/logout/` - 用户登出

### 作品接口
- `GET /api/paintings/` - 获取作品列表
- `GET /api/paintings/{id}/` - 获取作品详情
- `POST /api/paintings/` - 创建作品
- `PUT /api/paintings/{id}/` - 更新作品
- `DELETE /api/paintings/{id}/` - 删除作品

### 推荐接口
- `GET /api/recommendations/` - 获取推荐作品
- `POST /api/recommendations/feedback/` - 推荐反馈

### 订单接口
- `GET /api/orders/` - 获取订单列表
- `POST /api/orders/` - 创建订单
- `GET /api/orders/{id}/` - 获取订单详情

更多 API 详情请访问 http://localhost:8000/api/docs/

## 配置说明

### 环境变量
创建 `.env` 文件：
```
DEBUG=True
SECRET_KEY=your-secret-key
DATABASE_NAME=painting
DATABASE_USER=root
DATABASE_PASSWORD=your-password
DATABASE_HOST=localhost
DATABASE_PORT=3306
```

### 静态文件
```bash
python manage.py collectstatic
```

### 敏感词过滤
编辑 `sensitive_words.txt` 添加敏感词。

## 部署

### 使用 Gunicorn
```bash
pip install gunicorn
gunicorn server.wsgi:application --bind 0.0.0.0:8000
```

### 使用 Nginx
配置 Nginx 反向代理到 Gunicorn。

### 使用 Docker
```bash
docker build -t painting-backend .
docker run -p 8000:8000 painting-backend
```

## 开发调试

### 运行测试
```bash
python manage.py test
```

### 查看日志
日志文件位于 `logs/` 目录。

### Django Shell
```bash
python manage.py shell
```

## 常见问题

### 1. 数据库连接失败
检查 MySQL 服务是否启动，配置是否正确。

### 2. 静态文件 404
运行 `python manage.py collectstatic`。

### 3. 跨域问题
安装并配置 `django-cors-headers`。

## 更多信息

- [Django 官方文档](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
