# 天津杨柳青年画智能系统

## 项目简介

本项目是一个集成了生成模型、问答模型和推荐模型的天津杨柳青年画智能系统。该系统能够根据用户需求生成杨柳青年画风格的图像，回答关于年画的问题，并基于用户行为推荐相关年画作品。通过一个智能Agent统一管理这些模型，为用户提供全面的天津杨柳青年画体验。

## 项目结构

```
天津年画推荐系统/
├── data_processing/       # 数据处理模块
│   ├── data_loader.py     # 数据加载器
│   └── data_preprocessor.py  # 数据预处理器
├── models/                # 模型模块
│   ├── recommendation_model.py  # 推荐模型
│   ├── generation_model.py      # 生成模型
│   ├── qa_model.py              # 问答模型
│   └── agent_manager.py         # 智能Agent管理器
├── api_service/           # API服务模块
│   └── app.py             # FastAPI应用
├── utils/                 # 工具类
│   └── common_utils.py    # 通用工具函数
├── main.py                # 主程序入口
├── requirements.txt       # 项目依赖
└── README.md              # 项目说明文档
```

## 功能特点

### 1. 推荐功能
- 基于用户的浏览、评分、收藏和评价记录进行个性化推荐
- 支持协同过滤、内容推荐和混合推荐多种算法
- 能够根据用户近期活动动态调整推荐结果

### 2. 生成功能
- 基于Stable Diffusion模型生成杨柳青年画风格的图像
- 支持根据用户提供的关键词、主题和风格生成个性化年画
- 提供风格迁移、主题生成等多样化的生成能力

### 3. 问答功能
- 基于OpenAI的GPT模型提供年画相关知识问答
- 支持文本和图像的多模态输入
- 能够分析年画图像并提供风格、主题、寓意等详细解释
- 支持连续对话，记住对话历史

### 4. 智能Agent管理
- 统一管理推荐、生成和问答三个模型
- 处理用户输入并调用相应的模型进行处理
- 记录用户活动历史，优化用户体验
- 提供命令行界面和API服务两种使用方式

## 安装依赖

### 前提条件
- Python 3.8+ 
- OpenAI API密钥（用于问答和生成功能）

### 安装步骤

1. 克隆或下载项目代码

2. 安装依赖包：
```bash
pip install -r requirements.txt
```

3. 设置环境变量：
```bash
# Windows
set OPENAI_API_KEY=your_api_key_here

# Linux/Mac
export OPENAI_API_KEY=your_api_key_here
```

## 使用方法

### 命令行模式

启动命令行界面：
```bash
python main.py --mode cli --api-key your_api_key_here
```

在命令行界面中，可以直接与系统交互，输入问题、命令或请求推荐。

### API服务模式

启动API服务：
```bash
python main.py --mode api --api-key your_api_key_here --host 0.0.0.0 --port 8000
```

服务启动后，可以通过HTTP请求访问API接口。

### 批量生成模式

批量生成年画：
```bash
python main.py --mode batch --api-key your_api_key_here --prompts-file prompts.txt --output-dir ./output
```

其中，`prompts.txt`是包含多个生成提示词的文本文件，每行一个提示词。

## API接口说明

服务启动后，可以通过以下API接口访问系统功能：

### 1. 推荐年画
- **URL**: `/api/recommend`
- **方法**: `POST`
- **参数**: 
  - `user_id`: 用户ID
  - `count`: 推荐数量（可选，默认5）
- **返回**: 推荐的年画列表

### 2. 生成年画
- **URL**: `/api/generate`
- **方法**: `POST`
- **参数**: 
  - `user_id`: 用户ID
  - `keywords`: 关键词
  - `style`: 风格（可选，默认"杨柳青"）
  - `theme`: 主题（可选，默认"吉祥喜庆"）
- **返回**: 生成结果和图像路径

### 3. 问答功能
- **URL**: `/api/qa`
- **方法**: `POST`
- **参数**: 
  - `user_id`: 用户ID
  - `question`: 问题
- **返回**: 回答内容

### 4. 图像分析
- **URL**: `/api/analyze_image`
- **方法**: `POST`
- **参数**: 
  - `user_id`: 用户ID
  - `image`: 图像文件
- **返回**: 图像分析结果

### 5. 获取图像
- **URL**: `/api/image/{image_path}`
- **方法**: `GET`
- **参数**: 
  - `image_path`: 图像路径
- **返回**: 图像文件

### 6. 更新用户偏好
- **URL**: `/api/update_preferences`
- **方法**: `POST`
- **参数**: 
  - `user_id`: 用户ID
  - `preferences`: JSON格式的偏好数据
- **返回**: 更新结果

### 7. 健康检查
- **URL**: `/api/health`
- **方法**: `GET`
- **返回**: 系统健康状态

## 注意事项

1. 生成功能需要较大的计算资源，建议在GPU环境下运行以获得更好的性能
2. 问答功能需要有效的OpenAI API密钥
3. 推荐功能需要正确的用户行为数据才能提供准确的推荐结果
4. 首次运行时，系统需要下载预训练模型，可能需要较长时间
5. 生成的图像将保存在系统目录下的`generated_images`文件夹中

## 许可证

本项目采用MIT许可证。

## 致谢

感谢所有为天津杨柳青年画传承和发展做出贡献的艺术家和研究人员。

---

**版本**: 1.0.0
**更新日期**: 2023年12月