# 年画作品推荐系统

基于 AI 的年画作品个性化推荐和知识问答系统，包含移动端应用、管理后台和后端服务。

## 项目结构

```
.
├── frontend-admin/     # 管理后台 (Vue.js)
├── mobile-app/         # 移动端应用 (Flutter)
├── backend/            # 后端服务 (Django)
├── database/           # 数据库文件
└── GitHub开源资料/     # 模型训练和数据集
```

## 主要功能

- 🎨 年画作品浏览和搜索
- 🤖 AI 个性化推荐
- 💬 知识问答系统
- 🛒 在线购买和订单管理
- 🎁 积分系统和积分商城
- 👥 用户管理和权限控制
- 📊 数据统计和分析

## 技术栈

| 模块 | 技术 |
|------|------|
| 管理后台 | Vue.js 2.x + Element UI |
| 移动端 | Flutter + Dart |
| 后端 | Django + Django REST Framework |
| 数据库 | MySQL |
| AI/ML | 推荐算法 + 知识图谱 |

## 快速开始

### 1. 数据库配置

```bash
# 导入数据库
mysql -u root -p < database/painting.sql

# 修改后端数据库配置
# 编辑 backend/server/settings.py
```

### 2. 启动后端

```bash
cd backend
pip install -r requirements.txt
python manage.py runserver
# 访问 http://localhost:8000
```

### 3. 启动管理后台

```bash
cd frontend-admin
npm install
npm run serve
# 访问 http://localhost:8080
```

### 4. 启动移动端（可选）

```bash
cd mobile-app
flutter pub get
flutter run
```

## 详细文档

- [管理后台说明](frontend-admin/README.md)
- [移动端说明](mobile-app/README.md)
- [后端 API 说明](backend/README.md)
- [数据库说明](database/README.md)

## 网盘资源

由于模型文件较大，部分资源存放在网盘：

| 资源名称 | 下载链接 | 提取码 |
|---------|---------|--------|
| 用户画像分类大模型微调 | [百度网盘](https://pan.baidu.com/s/1NBknq5WuDz0Emez5YmiYPQ?pwd=7ewg) | 7ewg |
| 年画生成大模型 | [百度网盘](https://pan.baidu.com/s/1sbIQC_glmtyoRCE0xjHnnw?pwd=3s24) | 3s24 |


## 许可证

[MIT License](LICENSE)
