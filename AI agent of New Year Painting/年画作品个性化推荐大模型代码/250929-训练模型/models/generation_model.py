import torch
import numpy as np
from PIL import Image
from transformers import CLIPTextModel, CLIPTokenizer
from diffusers import StableDiffusionPipeline, StableDiffusionImg2ImgPipeline, DDIMScheduler
import os
from datetime import datetime

class TianjinNewYearPaintingGenerator:
    def __init__(self, model_id="stabilityai/stable-diffusion-2", device=None):
        """初始化年画生成模型"""
        # 自动选择设备
        self.device = device if device else ("cuda" if torch.cuda.is_available() else "cpu")
        print(f"使用设备: {self.device}")
        
        # 加载基础模型
        self.model_id = model_id
        self.pipeline = None
        self.img2img_pipeline = None
        
        # 杨柳青年画风格关键词
        self.yangliuqing_style_keywords = [
            "Yangliuqing New Year Painting",
            "traditional Chinese painting",
            "vibrant colors",
            "detailed brushwork",
            "folk art",
            "Chinese New Year theme",
            "paper texture",
            "ink painting style",
            "classic Chinese patterns",
            "red and gold colors"
        ]
        
        # 初始化模型
        self._initialize_pipelines()
        
    def _initialize_pipelines(self):
        """初始化各种生成管道"""
        try:
            print(f"正在加载模型: {self.model_id}")
            
            # 文生图管道
            self.pipeline = StableDiffusionPipeline.from_pretrained(
                self.model_id,
                torch_dtype=torch.float16 if self.device == "cuda" else torch.float32,
                safety_checker=None  # 为了艺术创作暂时关闭安全检查
            )
            
            # 配置调度器以获得更好的效果
            self.pipeline.scheduler = DDIMScheduler.from_config(self.pipeline.scheduler.config)
            
            # 将模型移至指定设备
            self.pipeline = self.pipeline.to(self.device)
            
            # 图生图管道（用于风格迁移）
            self.img2img_pipeline = StableDiffusionImg2ImgPipeline(
                vae=self.pipeline.vae,
                text_encoder=self.pipeline.text_encoder,
                tokenizer=self.pipeline.tokenizer,
                unet=self.pipeline.unet,
                scheduler=self.pipeline.scheduler,
                safety_checker=None
            )
            self.img2img_pipeline = self.img2img_pipeline.to(self.device)
            
            print("模型加载完成")
        except Exception as e:
            print(f"模型加载失败: {e}")
            
    def _prepare_prompt(self, user_prompt, include_style=True):
        """准备生成提示词"""
        # 基础提示词
        prompt_parts = [user_prompt]
        
        # 添加风格关键词
        if include_style:
            prompt_parts.extend(self.yangliuqing_style_keywords)
            
        # 添加质量提升关键词
        quality_keywords = [
            "high quality",
            "intricate details",
            "masterpiece",
            "sharp focus",
            "clear image"
        ]
        prompt_parts.extend(quality_keywords)
        
        # 组合成完整提示词
        prompt = ", ".join(prompt_parts)
        
        # 负面提示词
        negative_prompt = "low quality, blurry, distorted, ugly, bad art, poor details, pixelated, artifacts"
        
        return prompt, negative_prompt
        
    def generate_from_text(self, user_prompt, num_images=1, height=768, width=512, 
                          num_inference_steps=50, guidance_scale=7.5, include_style=True):
        """从文本描述生成年画风格图像"""
        try:
            if self.pipeline is None:
                print("错误: 模型未初始化")
                return None
                
            # 准备提示词
            prompt, negative_prompt = self._prepare_prompt(user_prompt, include_style)
            
            print(f"生成图像提示词: {prompt}")
            
            # 生成图像
            with torch.no_grad():
                images = self.pipeline(
                    prompt=prompt,
                    negative_prompt=negative_prompt,
                    num_images_per_prompt=num_images,
                    height=height,
                    width=width,
                    num_inference_steps=num_inference_steps,
                    guidance_scale=guidance_scale,
                    generator=torch.manual_seed(42) if num_images == 1 else None
                ).images
                
            return images
        except Exception as e:
            print(f"图像生成失败: {e}")
            return None
            
    def style_transfer(self, reference_image, user_prompt, strength=0.7, 
                      num_inference_steps=50, guidance_scale=7.5):
        """将参考图像转换为杨柳青年画风格"""
        try:
            if self.img2img_pipeline is None:
                print("错误: 图生图模型未初始化")
                return None
                
            # 准备提示词
            prompt, negative_prompt = self._prepare_prompt(user_prompt, include_style=True)
            
            print(f"风格迁移提示词: {prompt}")
            
            # 确保参考图像是PIL.Image格式
            if not isinstance(reference_image, Image.Image):
                reference_image = Image.fromarray(reference_image)
                
            # 调整图像大小
            reference_image = reference_image.resize((512, 768), Image.LANCZOS)
            
            # 执行风格迁移
            with torch.no_grad():
                images = self.img2img_pipeline(
                    prompt=prompt,
                    negative_prompt=negative_prompt,
                    image=reference_image,
                    strength=strength,
                    num_inference_steps=num_inference_steps,
                    guidance_scale=guidance_scale,
                    generator=torch.manual_seed(42)
                ).images
                
            return images
        except Exception as e:
            print(f"风格迁移失败: {e}")
            return None
            
    def generate_with_theme(self, theme,寓意, num_images=1):
        """根据主题和寓意生成特定的年画"""
        # 预定义的主题与关键词映射
        theme_keywords = {
            "仕途高升": ["official", "success", "career advancement", "court", "nobility", "red robe"],
            "驱邪纳吉": ["evil spirits", "protection", "good luck", "talisman", "gods", "auspicious"],
            "神话民俗": ["mythology", "folk tales", "legends", "immortals", "deities", "magic"],
            "吉祥寓意": ["good fortune", "happiness", "prosperity", "lucky symbols", "blessings"],
            "女性主题": ["beautiful women", "goddesses", "femininity", "elegance", "grace"],
            "自然意象": ["nature", "flowers", "birds", "mountains", "rivers", "landscape"],
            "文化传承": ["cultural heritage", "tradition", "history", "ancient", "classics"],
            "生活场景": ["daily life", "family", "community", "celebration", "festivals"],
            "历史典故": ["historical stories", "famous events", "ancient heroes", "historical figures"],
            "安康长寿": ["longevity", "health", "peace", "harmony", "long life", "wellness"]
        }
        
        # 构建主题相关的提示词
        theme_words = theme_keywords.get(theme, [])
        theme_prompt = f"traditional Chinese {theme} painting with {寓意} meaning"
        
        # 如果有主题相关的关键词，添加到提示词中
        if theme_words:
            theme_prompt += ", " + ", ".join(theme_words)
            
        # 生成图像
        return self.generate_from_text(theme_prompt, num_images=num_images)
        
    def save_generated_images(self, images, output_dir="./generated_images", prefix="yangliuqing"):
        """保存生成的图像"""
        try:
            # 创建输出目录
            os.makedirs(output_dir, exist_ok=True)
            
            # 保存每张图像
            saved_paths = []
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            
            for i, image in enumerate(images):
                filename = f"{prefix}_{timestamp}_{i+1}.png"
                filepath = os.path.join(output_dir, filename)
                image.save(filepath)
                saved_paths.append(filepath)
                print(f"图像已保存到: {filepath}")
                
            return saved_paths
        except Exception as e:
            print(f"图像保存失败: {e}")
            return []
            
    def generate_custom_yangliuqing(self, user_instruction, style_adjustment=1.0, num_images=1):
        """根据用户的详细指令生成个性化杨柳青年画"""
        # 解析用户指令，提取关键信息
        # 这里可以根据需要实现更复杂的指令解析逻辑
        
        # 基础提示词
        base_prompt = f"traditional Chinese Yangliuqing New Year painting, {user_instruction}"
        
        # 根据style_adjustment调整风格强度
        if style_adjustment > 1.0:
            # 增加更多风格关键词
            extra_style_keywords = [
                "authentic traditional style",
                "classic Yangliuqing features",
                "historical accuracy",
                "meticulous details",
                "traditional color palette"
            ]
            base_prompt += ", " + ", ".join(extra_style_keywords)
        elif style_adjustment < 1.0:
            # 减少风格关键词，增加现代元素
            modern_keywords = [
                "modern interpretation",
                "contemporary art",
                "creative expression",
                "fresh perspective"
            ]
            base_prompt += ", " + ", ".join(modern_keywords)
            
        # 生成图像
        return self.generate_from_text(base_prompt, num_images=num_images)

# 示例使用代码
if __name__ == "__main__":
    # 创建生成器实例
    generator = TianjinNewYearPaintingGenerator()
    
    # 测试文本生成
    print("\n测试1: 根据文本生成杨柳青年画风格图像")
    user_prompt = "a happy family celebrating Chinese New Year with traditional decorations"
    images = generator.generate_from_text(user_prompt, num_images=1)
    
    if images:
        # 显示图像（如果在支持的环境中）
        try:
            for i, img in enumerate(images):
                img.show(title=f"Generated Image {i+1}")
        except Exception as e:
            print(f"无法显示图像: {e}")
            
        # 保存图像
        saved_paths = generator.save_generated_images(images)
        print(f"保存的图像路径: {saved_paths}")
    
    # 测试主题生成
    print("\n测试2: 根据主题和寓意生成特定年画")
    theme_images = generator.generate_with_theme("吉祥寓意", "good fortune and prosperity", num_images=1)
    
    if theme_images:
        # 保存主题生成的图像
        theme_saved_paths = generator.save_generated_images(theme_images, prefix="theme_based")
        print(f"保存的主题图像路径: {theme_saved_paths}")
    
    # 测试自定义生成
    print("\n测试3: 根据自定义指令生成杨柳青年画")
    custom_images = generator.generate_custom_yangliuqing(
        "a dragon and phoenix dancing together, symbolizing power and beauty", 
        style_adjustment=1.2, 
        num_images=1
    )
    
    if custom_images:
        # 保存自定义生成的图像
        custom_saved_paths = generator.save_generated_images(custom_images, prefix="custom")
        print(f"保存的自定义图像路径: {custom_saved_paths}")