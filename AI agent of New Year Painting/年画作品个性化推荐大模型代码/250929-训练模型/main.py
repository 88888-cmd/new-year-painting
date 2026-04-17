import os
import sys
import argparse
from datetime import datetime
import logging

# 添加项目根目录到路径
base_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(base_dir)

# 导入工具和模型
from utils.common_utils import CommonUtils
from models.agent_manager import TianjinNewYearPaintingAgent

# 设置日志
logger = CommonUtils.setup_logging(os.path.join(base_dir, "logs", "system.log"))

class TianjinNewYearPaintingSystem:
    def __init__(self, openai_api_key=None, data_dir="../"):
        """初始化天津杨柳青年画智能系统"""
        self.openai_api_key = openai_api_key
        self.data_dir = data_dir
        self.agent = None
        
    def initialize(self):
        """初始化系统"""
        try:
            logger.info("正在初始化天津杨柳青年画智能系统...")
            
            # 设置OpenAI API密钥环境变量
            if self.openai_api_key:
                os.environ["OPENAI_API_KEY"] = self.openai_api_key
                
            # 初始化Agent
            self.agent = TianjinNewYearPaintingAgent(
                data_dir=self.data_dir,
                openai_api_key=self.openai_api_key
            )
            
            logger.info("系统初始化成功")
            return True
        except Exception as e:
            logger.error(f"系统初始化失败: {e}")
            return False
            
    def start_cli(self):
        """启动命令行界面"""
        if not self.agent:
            if not self.initialize():
                print("系统初始化失败，无法启动命令行界面")
                return False
                
        print("\n=====================================")
        print("      天津杨柳青年画智能系统")
        print("=====================================")
        print("欢迎使用天津杨柳青年画智能系统！")
        print("您可以与系统进行对话，获取年画推荐、生成年画或咨询年画相关问题。")
        print("输入'帮助'查看可用功能，输入'退出'结束使用。")
        print("=====================================\n")
        
        # 模拟用户ID
        user_id = f"user_{CommonUtils.generate_unique_id()}"
        print(f"您的用户ID: {user_id}")
        
        while True:
            try:
                user_input = input("\n用户: ")
                
                if user_input.lower() in ["退出", "quit", "exit", "bye"]:
                    print("\n系统: 感谢使用天津杨柳青年画智能系统，再见！")
                    break
                    
                # 处理用户输入
                start_time = datetime.now()
                response = self.agent.process_user_input(user_id, user_input)
                end_time = datetime.now()
                
                # 打印响应
                print(f"系统: {response}")
                print(f"(响应时间: {(end_time - start_time).total_seconds():.2f}秒)")
                
            except KeyboardInterrupt:
                print("\n\n系统: 感谢使用天津杨柳青年画智能系统，再见！")
                break
            except Exception as e:
                error_msg = f"处理请求时发生错误: {e}"
                print(f"系统: {error_msg}")
                logger.error(error_msg)
                
        return True
        
    def start_api_service(self, host="0.0.0.0", port=8000, reload=False):
        """启动API服务"""
        try:
            logger.info(f"正在启动API服务，监听地址: {host}:{port}")
            
            # 设置环境变量
            if self.openai_api_key:
                os.environ["OPENAI_API_KEY"] = self.openai_api_key
                
            # 导入uvicorn和app
            import uvicorn
            from api_service.app import app
            
            # 启动服务
            uvicorn.run(
                app, 
                host=host, 
                port=port,
                reload=reload,
                log_level="info"
            )
            
            return True
        except Exception as e:
            logger.error(f"启动API服务失败: {e}")
            return False
            
    def batch_generate(self, prompts_file, output_dir):
        """批量生成年画"""
        if not self.agent:
            if not self.initialize():
                print("系统初始化失败，无法批量生成年画")
                return False
                
        try:
            # 确保输出目录存在
            CommonUtils.ensure_dir(output_dir)
            
            # 读取提示词文件
            if not os.path.exists(prompts_file):
                print(f"提示词文件不存在: {prompts_file}")
                return False
                
            with open(prompts_file, 'r', encoding='utf-8') as f:
                prompts = [line.strip() for line in f if line.strip()]
                
            if not prompts:
                print("没有找到有效的提示词")
                return False
                
            print(f"开始批量生成年画，共{len(prompts)}个提示词...")
            
            # 批量生成
            results = []
            for i, prompt in enumerate(prompts, 1):
                print(f"生成进度: {i}/{len(prompts)} - {prompt}")
                
                try:
                    # 生成年画
                    user_id = f"batch_user_{i}"
                    result = self.agent.generate_painting(user_id, prompt)
                    
                    # 提取图像路径
                    image_path = None
                    if "已保存至" in result:
                        image_path = result.split("已保存至：")[-1].strip()
                        
                    results.append({
                        "prompt": prompt,
                        "result": result,
                        "image_path": image_path
                    })
                    
                except Exception as e:
                    error_msg = f"生成失败: {e}"
                    print(error_msg)
                    logger.error(error_msg)
                    results.append({"prompt": prompt, "error": str(e)})
                    
            # 保存结果
            result_file = os.path.join(output_dir, "batch_results.json")
            CommonUtils.save_json(results, result_file)
            
            print(f"批量生成完成，结果已保存至: {result_file}")
            return True
        except Exception as e:
            logger.error(f"批量生成失败: {e}")
            return False

def parse_arguments():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(description="天津杨柳青年画智能系统")
    
    # 模式选择
    parser.add_argument(
        "--mode", 
        choices=["cli", "api", "batch"], 
        default="cli",
        help="运行模式: cli(命令行), api(API服务), batch(批量生成)"
    )
    
    # OpenAI API密钥
    parser.add_argument(
        "--api-key", 
        type=str, 
        help="OpenAI API密钥"
    )
    
    # 数据目录
    parser.add_argument(
        "--data-dir", 
        type=str, 
        default="../",
        help="数据文件所在目录"
    )
    
    # API服务参数
    parser.add_argument(
        "--host", 
        type=str, 
        default="0.0.0.0",
        help="API服务主机地址"
    )
    parser.add_argument(
        "--port", 
        type=int, 
        default=8000,
        help="API服务端口"
    )
    parser.add_argument(
        "--reload", 
        action="store_true",
        help="API服务是否启用热重载（开发模式）"
    )
    
    # 批量生成参数
    parser.add_argument(
        "--prompts-file", 
        type=str,
        help="批量生成的提示词文件路径（batch模式）"
    )
    parser.add_argument(
        "--output-dir", 
        type=str, 
        default="./batch_output",
        help="批量生成的输出目录（batch模式）"
    )
    
    return parser.parse_args()

def main():
    """主函数"""
    # 解析命令行参数
    args = parse_arguments()
    
    # 创建系统实例
    system = TianjinNewYearPaintingSystem(
        openai_api_key=args.api_key,
        data_dir=args.data_dir
    )
    
    # 根据模式运行
    if args.mode == "cli":
        # 启动命令行界面
        system.start_cli()
        
    elif args.mode == "api":
        # 启动API服务
        system.start_api_service(
            host=args.host,
            port=args.port,
            reload=args.reload
        )
        
    elif args.mode == "batch":
        # 批量生成
        if not args.prompts_file:
            print("错误: batch模式需要指定提示词文件路径 --prompts-file")
            return 1
            
        system.batch_generate(args.prompts_file, args.output_dir)
        
    else:
        print(f"错误: 不支持的模式: {args.mode}")
        return 1
        
    return 0

if __name__ == "__main__":
    # 运行主函数
    sys.exit(main())