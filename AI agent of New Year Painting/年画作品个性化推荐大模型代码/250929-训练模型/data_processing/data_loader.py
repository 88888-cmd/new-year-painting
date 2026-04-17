import pandas as pd
import numpy as np
import os

class TianjinNewYearPaintingDataLoader:
    def __init__(self, data_dir=r'c:\Users\ZJN\Desktop\data新'):
        """初始化数据加载器，设置数据目录"""
        self.data_dir = data_dir
        self.loaded_data = {}
        
    def load_all_data(self):
        """加载所有相关数据文件"""
        # 加载年画作品数据
        self.loaded_data['paintings'] = self._load_painting_data()
        
        # 加载用户信息数据
        self.loaded_data['users'] = self._load_user_data()
        
        # 加载用户行为数据
        self.loaded_data['browse_records'] = self._load_browse_records()
        self.loaded_data['ratings'] = self._load_ratings()
        self.loaded_data['favorites'] = self._load_favorites()
        self.loaded_data['reviews'] = self._load_reviews()
        
        # 加载物品维度数据
        self.loaded_data['styles'] = self._load_styles()
        self.loaded_data['themes'] = self._load_themes()
        
        # 加载喜好矩阵
        self.loaded_data['user_item_matrix'] = self._load_user_item_matrix()
        
        return self.loaded_data
        
    def _load_painting_data(self):
        """加载年画作品数据"""
        file_path = os.path.join(self.data_dir, '年画作品.csv')
        try:
            df = pd.read_csv(file_path, encoding='utf-8')
            print(f"成功加载年画作品数据，共{len(df)}条记录")
            return df
        except Exception as e:
            print(f"加载年画作品数据失败: {e}")
            return pd.DataFrame()
            
    def _load_user_data(self):
        """加载用户信息数据"""
        file_path = os.path.join(self.data_dir, '用户信息.csv')
        try:
            df = pd.read_csv(file_path, encoding='utf-8')
            print(f"成功加载用户信息数据，共{len(df)}条记录")
            return df
        except Exception as e:
            print(f"加载用户信息数据失败: {e}")
            return pd.DataFrame()
            
    def _load_browse_records(self):
        """加载用户浏览记录"""
        file_path = os.path.join(self.data_dir, '用户浏览年画物品记录.csv')
        try:
            df = pd.read_csv(file_path, encoding='utf-8')
            print(f"成功加载用户浏览记录，共{len(df)}条记录")
            return df
        except Exception as e:
            print(f"加载用户浏览记录失败: {e}")
            return pd.DataFrame()
            
    def _load_ratings(self):
        """加载用户评分数据"""
        file_path = os.path.join(self.data_dir, '用户作品打分.csv')
        try:
            df = pd.read_csv(file_path, encoding='utf-8')
            print(f"成功加载用户评分数据，共{len(df)}条记录")
            return df
        except Exception as e:
            print(f"加载用户评分数据失败: {e}")
            return pd.DataFrame()
            
    def _load_favorites(self):
        """加载用户收藏记录"""
        file_path = os.path.join(self.data_dir, '用户收藏记录.csv')
        try:
            df = pd.read_csv(file_path, encoding='utf-8')
            # 处理重复的id
            df = df.drop_duplicates()
            print(f"成功加载用户收藏记录，共{len(df)}条记录")
            return df
        except Exception as e:
            print(f"加载用户收藏记录失败: {e}")
            return pd.DataFrame()
            
    def _load_reviews(self):
        """加载用户评价数据"""
        file_path = os.path.join(self.data_dir, '用户评价.csv')
        try:
            # 由于文件较大，只加载前10000行
            df = pd.read_csv(file_path, encoding='utf-8', nrows=10000)
            print(f"成功加载用户评价数据，共{len(df)}条记录")
            return df
        except Exception as e:
            print(f"加载用户评价数据失败: {e}")
            return pd.DataFrame()
            
    def _load_styles(self):
        """加载年画风格数据"""
        file_path = os.path.join(self.data_dir, '年画风格.csv')
        try:
            df = pd.read_csv(file_path, encoding='utf-8')
            print(f"成功加载年画风格数据，共{len(df)}条记录")
            return df
        except Exception as e:
            print(f"加载年画风格数据失败: {e}")
            return pd.DataFrame()
            
    def _load_themes(self):
        """加载年画主题数据"""
        file_path = os.path.join(self.data_dir, '年画主体.csv')
        try:
            df = pd.read_csv(file_path, encoding='utf-8')
            print(f"成功加载年画主题数据，共{len(df)}条记录")
            return df
        except Exception as e:
            print(f"加载年画主题数据失败: {e}")
            return pd.DataFrame()
            
    def _load_user_item_matrix(self):
        """加载用户物品喜好矩阵"""
        file_path = os.path.join(self.data_dir, '用户物品喜好矩阵表.csv')
        try:
            df = pd.read_csv(file_path, encoding='utf-8')
            print(f"成功加载用户物品喜好矩阵，共{len(df)}条记录")
            return df
        except Exception as e:
            print(f"加载用户物品喜好矩阵失败: {e}")
            return pd.DataFrame()
            
    def preprocess_for_recommendation(self):
        """为推荐系统预处理数据"""
        if not self.loaded_data:
            self.load_all_data()
            
        # 创建用户-物品交互矩阵
        user_item_interactions = []
        
        # 添加浏览记录
        browse_data = self.loaded_data['browse_records']
        if not browse_data.empty:
            browse_interactions = browse_data.groupby(['user_id', 'painting_id']).size().reset_index(name='browse_count')
            browse_interactions['interaction_type'] = 'browse'
            user_item_interactions.append(browse_interactions)
            
        # 添加评分记录
        ratings_data = self.loaded_data['ratings']
        if not ratings_data.empty:
            ratings_interactions = ratings_data.copy()
            ratings_interactions['interaction_type'] = 'rating'
            user_item_interactions.append(ratings_interactions)
            
        # 添加收藏记录
        favorites_data = self.loaded_data['favorites']
        if not favorites_data.empty:
            favorites_interactions = favorites_data.groupby(['user_id', 'painting_id']).size().reset_index(name='favorite_count')
            favorites_interactions['interaction_type'] = 'favorite'
            user_item_interactions.append(favorites_interactions)
            
        # 合并所有交互数据
        if user_item_interactions:
            all_interactions = pd.concat(user_item_interactions)
            return all_interactions
        else:
            return pd.DataFrame()

if __name__ == "__main__":
    # 测试数据加载器
    data_loader = TianjinNewYearPaintingDataLoader()
    data = data_loader.load_all_data()
    print("\n数据加载完成，数据概览：")
    for key, df in data.items():
        print(f"{key}: {len(df)}条记录")
        
    # 测试推荐系统数据预处理
    interactions = data_loader.preprocess_for_recommendation()
    print(f"\n推荐系统交互数据: {len(interactions)}条记录")