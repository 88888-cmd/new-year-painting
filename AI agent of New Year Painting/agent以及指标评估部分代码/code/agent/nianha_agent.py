#!/usr/bin/env python3
"""
年画智能系统 - Strands Agent 主程序
使用 Gemini 作为推理引擎，调用年画相关工具
"""

import os
from strands import Agent
from strands.models.openai import OpenAIModel
from dotenv import load_dotenv

# 导入工具
from nianha_tools import (
    nianha_qa,
    analyze_user_preferences,
    recommend_nianha,
    generate_nianha_image
)

# 加载环境变量
load_dotenv()

# 配置 Gemini 模型（使用OpenAI兼容模式）
gemini_model = OpenAIModel(
    client_args={
        "api_key": os.getenv("GEMINI_API_KEY"),
        "base_url": os.getenv("GEMINI_BASE_URL"),
    },
    model_id=os.getenv("GEMINI_MODEL", "gemini-2.5-flash"),
    params={
        "max_tokens": 2000,
        "temperature": 0.7,
    }
)

# 创建 Agent
agent = Agent(
    model=gemini_model,
    tools=[
        nianha_qa,
        analyze_user_preferences,
        recommend_nianha,
        generate_nianha_image
    ],
    system_prompt="""你是一个年画智能助手，专门帮助用户了解、欣赏和创作年画。

你可以使用以下工具：

1. **nianha_qa**: 回答关于年画的知识问题
   - 年画历史、文化、工艺等知识性问题

2. **analyze_user_preferences**: 分析用户偏好
   - 根据用户浏览历史、点赞收藏等行为分析用户偏好标签

3. **recommend_nianha**: 推荐年画作品
   - 根据用户画像和偏好推荐相关年画作品

4. **generate_nianha_image**: 生成年画图像
   - 根据描述生成年画风格的图像

工作流程建议：
- 如果用户询问年画知识，使用 nianha_qa 工具
- 如果用户提供了历史行为数据，先用 analyze_user_preferences 分析偏好
- 分析完偏好后，可以用 recommend_nianha 生成推荐
- 如果用户想看具体图像，使用 generate_nianha_image 生成

请用中文回复用户，态度友好专业。
"""
)


def chat_interactive():
    """交互式对话模式"""
    print("=" * 60)
    print("年画智能助手")
    print("=" * 60)
    print("我可以帮您：")
    print("  - 回答年画相关的知识问题")
    print("  - 分析您的年画偏好")
    print("  - 推荐适合您的年画作品")
    print("  - 生成年画风格的图像")
    print("\n输入 'quit' 或 'exit' 退出\n")
    print("=" * 60)

    while True:
        user_input = input("\n您: ")

        if user_input.lower() in ['quit', 'exit', '退出', 'q']:
            print("\n感谢使用年画智能助手！再见！")
            break

        if not user_input.strip():
            continue

        print("\n助手: ", end="", flush=True)

        try:
            # 调用 agent
            response = agent(user_input)
            result_text = response.text if hasattr(response, 'text') else str(response)
            print(result_text)

        except KeyboardInterrupt:
            print("\n\n对话已中断")
            break
        except Exception as e:
            print(f"\n错误：{str(e)}")


def run_example_workflow():
    """运行示例工作流"""
    print("=" * 60)
    print("年画智能助手 - 示例工作流")
    print("=" * 60)

    # 示例1：知识问答
    print("\n【示例1：知识问答】")
    print("用户：什么是杨柳青年画？它有什么特点？")
    response = agent("什么是杨柳青年画？它有什么特点？")
    print(f"助手：{response.text if hasattr(response, 'text') else response}\n")

    # 示例2：分析偏好并推荐
    print("\n【示例2：分析偏好并推荐】")
    user_query = """我最近喜欢过这些年画作品：
    - 《武将门神》，线版风格，驱邪纳吉主题
    - 《天官赐福》，套印风格，吉祥寓意主题
    - 《年年有余》，彩印风格，富贵吉祥主题

请分析我的偏好，并推荐一些相似的作品。"""

    print(f"用户：{user_query}")
    response = agent(user_query)
    print(f"助手：{response.text if hasattr(response, 'text') else response}\n")

    # 示例3：生成图像
    print("\n【示例3：生成年画图像】")
    print("用户：请生成一幅传统门神年画，要威武雄壮，红色调，有金色装饰")
    response = agent("请生成一幅传统门神年画，要威武雄壮，红色调，有金色装饰")
    print(f"助手：{response.text if hasattr(response, 'text') else response}\n")

    print("=" * 60)


if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "example":
        # 运行示例工作流
        run_example_workflow()
    else:
        # 交互式对话模式
        chat_interactive()
