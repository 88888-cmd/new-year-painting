# 年画推荐系统 - 管理后台

基于 Vue.js 的年画作品管理后台系统。

## 功能模块

- 🎨 **作品管理**: 年画作品的增删改查、分类管理
- 👥 **用户管理**: 用户信息管理、权限控制
- 📦 **订单管理**: 订单查询、状态管理、退款处理
- 🎁 **积分商品**: 积分商品管理、兑换记录
- 📝 **内容管理**: 帖子管理、评论审核
- 🎯 **营销管理**: Banner 管理、优惠券管理
- 📊 **数据统计**: 用户数据、销售数据分析

## 技术栈

- Vue.js 2.x
- Element UI
- Vuex (状态管理)
- Vue Router (路由管理)
- Axios (HTTP 请求)

## 项目设置

### 安装依赖
```bash
npm install
```

### 开发环境运行
```bash
npm run serve
```
访问 http://localhost:8080

### 生产环境构建
```bash
npm run build
```

### 代码检查和修复
```bash
npm run lint
```

## 项目结构

```
frontend-admin/
├── public/              # 静态资源
├── src/
│   ├── api/            # API 接口
│   ├── assets/         # 资源文件
│   ├── components/     # 公共组件
│   ├── layout/         # 布局组件
│   ├── router/         # 路由配置
│   ├── store/          # Vuex 状态管理
│   ├── styles/         # 全局样式
│   ├── utils/          # 工具函数
│   ├── views/          # 页面组件
│   ├── App.vue         # 根组件
│   └── main.js         # 入口文件
├── babel.config.js     # Babel 配置
├── vue.config.js       # Vue CLI 配置
└── package.json        # 项目依赖
```

## 配置说明

### API 地址配置
编辑 `src/utils/request.js` 修改后端 API 地址：
```javascript
const baseURL = process.env.VUE_APP_BASE_API || 'http://localhost:8000/api'
```

### 环境变量
创建 `.env.development` 和 `.env.production` 文件：
```
VUE_APP_BASE_API=http://localhost:8000/api
```

## 默认账号

- 用户名: admin
- 密码: admin123

## 更多配置
参考 [Vue CLI 配置文档](https://cli.vuejs.org/config/)
