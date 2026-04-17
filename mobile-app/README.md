# 年画推荐系统 - 移动端应用

基于 Flutter 开发的年画作品推荐移动应用。

## 功能特性

- 🎨 **作品浏览**: 浏览年画作品，支持分类筛选
- 🔍 **智能搜索**: 关键词搜索、标签筛选
- ⭐ **个性化推荐**: 基于用户行为的智能推荐
- 💝 **收藏评分**: 收藏喜欢的作品，进行评分
- 🛒 **在线购买**: 作品购买、订单管理
- 🎁 **积分商城**: 积分兑换商品
- 💬 **社区互动**: 发帖、评论、点赞
- 🤖 **AI 问答**: 年画知识问答
- 👤 **个人中心**: 个人信息、订单、收藏管理

## 技术栈

- Flutter 3.0+
- Dart 2.17+
- Provider (状态管理)
- Dio (网络请求)
- Shared Preferences (本地存储)

## 环境要求

- Flutter SDK 3.0+
- Dart SDK 2.17+
- Android Studio / Xcode
- Android SDK (Android 开发)
- iOS SDK (iOS 开发)

## 快速开始

### 1. 安装依赖
```bash
flutter pub get
```

### 2. 运行应用

#### Android
```bash
flutter run
```

#### iOS
```bash
flutter run -d ios
```

### 3. 构建发布版本

#### Android APK
```bash
flutter build apk --release
```

#### iOS IPA
```bash
flutter build ios --release
```

## 项目结构

```
mobile-app/
├── android/            # Android 原生代码
├── ios/                # iOS 原生代码
├── lib/                # Dart 代码
│   ├── api/           # API 接口
│   ├── models/        # 数据模型
│   ├── pages/         # 页面
│   ├── providers/     # 状态管理
│   ├── utils/         # 工具类
│   ├── widgets/       # 自定义组件
│   └── main.dart      # 入口文件
├── assets/            # 资源文件
├── plugin/            # 自定义插件
├── pubspec.yaml       # 项目配置
└── README.md          # 说明文档
```

## 配置说明

### API 地址配置
编辑 `lib/utils/config.dart` 修改后端 API 地址：
```dart
class Config {
  static const String baseUrl = 'http://your-api-domain.com/api';
}
```

### 应用图标和启动页
- Android: `android/app/src/main/res/`
- iOS: `ios/Runner/Assets.xcassets/`

## 自定义插件

项目包含以下自定义插件：
- `audio_player`: 音频播放
- `record`: 录音功能
- `video_cover`: 视频封面提取

## 常见问题

### 1. 依赖安装失败
```bash
flutter clean
flutter pub get
```

### 2. iOS 构建失败
```bash
cd ios
pod install
cd ..
flutter run
```

### 3. Android 签名配置
编辑 `android/app/build.gradle` 配置签名信息。

## 开发调试

### 热重载
在应用运行时按 `r` 键进行热重载。

### 调试模式
```bash
flutter run --debug
```

### 性能分析
```bash
flutter run --profile
```

## 更多信息

- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 语言指南](https://dart.dev/guides)
