import pandas as pd
import numpy as np
from datetime import datetime
from sklearn.preprocessing import StandardScaler, LabelEncoder

class TianjinNewYearPaintingPreprocessor:
    def __init__(self, data_loader):
        """初始化数据预处理器"""
        self.data_loader = data_loader
        self.data = data_loader.loaded_data
        self.encoders = {}
        self.scalers = {}
        
    def preprocess_all_data(self):
        """预处理所有数据"""
        # 预处理用户数据
        self.data['users'] = self._preprocess_user_data()
        
        # 预处理年画作品数据
        self.data['paintings'] = self._preprocess_painting_data()
        
        # 预处理用户行为数据
        self.data['browse_records'] = self._preprocess_browse_data()
        self.data['ratings'] = self._preprocess_rating_data()
        self.data['favorites'] = self._preprocess_favorite_data()
        
        # 创建用户画像
        self.user_profiles = self._create_user_profiles()
        
        # 创建物品画像
        self.item_profiles = self._create_item_profiles()
        
        # 创建用户-物品评分矩阵
        self.user_item_matrix = self._create_user_item_matrix()
        
        return self.data
        
    def _preprocess_user_data(self):
        """预处理用户数据"""
        if self.data['users'].empty:
            return pd.DataFrame()
            
        df = self.data['users'].copy()
        
        # 处理缺失值
        df = df.fillna({'gender': 0, 'profession': '未知', 'email': 'unknown@example.com'})
        
        # 处理性别编码
        if 'gender' not in self.encoders:
            self.encoders['gender'] = LabelEncoder()
            df['gender_encoded'] = self.encoders['gender'].fit_transform(df['gender'].astype(str))
        else:
            df['gender_encoded'] = self.encoders['gender'].transform(df['gender'].astype(str))
            
        # 处理职业编码
        if 'profession' not in self.encoders:
            self.encoders['profession'] = LabelEncoder()
            df['profession_encoded'] = self.encoders['profession'].fit_transform(df['profession'].astype(str))
        else:
            df['profession_encoded'] = self.encoders['profession'].transform(df['profession'].astype(str))
            
        # 计算用户年龄
        if 'birthday' in df.columns:
            df['birthday'] = pd.to_datetime(df['birthday'], errors='coerce')
            current_year = datetime.now().year
            df['age'] = current_year - df['birthday'].dt.year
            df['age'] = df['age'].fillna(df['age'].median())
            
        # 标准化用户积分
        if 'normal_points' in df.columns and 'cultural_points' in df.columns:
            if 'points' not in self.scalers:
                self.scalers['points'] = StandardScaler()
                points_data = df[['normal_points', 'cultural_points']].fillna(0)
                df[['normal_points_scaled', 'cultural_points_scaled']] = \
                    self.scalers['points'].fit_transform(points_data)
            else:
                points_data = df[['normal_points', 'cultural_points']].fillna(0)
                df[['normal_points_scaled', 'cultural_points_scaled']] = \
                    self.scalers['points'].transform(points_data)
                    
        return df
        
    def _preprocess_painting_data(self):
        """预处理年画作品数据"""
        if self.data['paintings'].empty:
            return pd.DataFrame()
            
        df = self.data['paintings'].copy()
        
        # 处理缺失值
        df = df.fillna({'content': '', 'author_id': 0})
        
        # 过滤已删除的作品
        df = df[df['is_delete'] == 0]
        
        # 提取作品元数据
        df['has_image'] = df['image_url'].notna() & (df['image_url'] != '')
        df['has_audio'] = df['bg_mp3_url'].notna() & (df['bg_mp3_url'] != '')
        
        # 合并风格和主题信息
        if not self.data['styles'].empty:
            styles_map = dict(zip(self.data['styles']['id'], self.data['styles']['name']))
            df['style_name'] = df['style_id'].map(styles_map).fillna('未知')
            
        if not self.data['themes'].empty:
            themes_map = dict(zip(self.data['themes']['id'], self.data['themes']['name']))
            df['theme_name'] = df['theme_id'].map(themes_map).fillna('未知')
            
        # 创建风格和主题的one-hot编码
        if 'style_name' in df.columns:
            style_dummies = pd.get_dummies(df['style_name'], prefix='style')
            df = pd.concat([df, style_dummies], axis=1)
            
        if 'theme_name' in df.columns:
            theme_dummies = pd.get_dummies(df['theme_name'], prefix='theme')
            df = pd.concat([df, theme_dummies], axis=1)
            
        return df
        
    def _preprocess_browse_data(self):
        """预处理浏览记录数据"""
        if self.data['browse_records'].empty:
            return pd.DataFrame()
            
        df = self.data['browse_records'].copy()
        
        # 转换时间格式
        df['create_time'] = pd.to_datetime(df['create_time'], errors='coerce')
        
        # 计算每天的浏览次数
        daily_browse = df.groupby(['user_id', df['create_time'].dt.date]).size().reset_index(name='daily_browse_count')
        daily_browse.columns = ['user_id', 'browse_date', 'daily_browse_count']
        
        # 合并回原数据
        df['browse_date'] = df['create_time'].dt.date
        df = pd.merge(df, daily_browse, on=['user_id', 'browse_date'], how='left')
        
        return df
        
    def _preprocess_rating_data(self):
        """预处理评分数据"""
        if self.data['ratings'].empty:
            return pd.DataFrame()
            
        df = self.data['ratings'].copy()
        
        # 转换时间格式
        df['create_time'] = pd.to_datetime(df['create_time'], errors='coerce')
        
        # 确保评分在1-5范围内
        df['star_count'] = df['star_count'].clip(1, 5)
        
        # 计算作品的平均评分
        avg_ratings = df.groupby('painting_id')['star_count'].mean().reset_index(name='avg_rating')
        df = pd.merge(df, avg_ratings, on='painting_id', how='left')
        
        return df
        
    def _preprocess_favorite_data(self):
        """预处理收藏数据"""
        if self.data['favorites'].empty:
            return pd.DataFrame()
            
        df = self.data['favorites'].copy()
        
        # 转换时间格式
        df['create_time'] = pd.to_datetime(df['create_time'], errors='coerce')
        
        # 去重处理
        df = df.drop_duplicates(subset=['user_id', 'painting_id'])
        
        return df
        
    def _create_user_profiles(self):
        """创建用户画像"""
        users_df = self.data['users']
        if users_df.empty:
            return pd.DataFrame()
            
        # 聚合用户行为数据
        user_profiles = users_df.copy()
        
        # 添加浏览统计
        if not self.data['browse_records'].empty:
            browse_stats = self.data['browse_records'].groupby('user_id').agg({
                'painting_id': ['count', 'nunique'],
                'create_time': ['min', 'max']
            }).reset_index()
            browse_stats.columns = ['user_id', 'total_browse_count', 'unique_paintings_browsed', 'first_browse_time', 'last_browse_time']
            user_profiles = pd.merge(user_profiles, browse_stats, on='user_id', how='left')
            
        # 添加评分统计
        if not self.data['ratings'].empty:
            rating_stats = self.data['ratings'].groupby('user_id').agg({
                'star_count': ['mean', 'count'],
                'create_time': ['min', 'max']
            }).reset_index()
            rating_stats.columns = ['user_id', 'avg_rating_given', 'total_ratings_count', 'first_rating_time', 'last_rating_time']
            user_profiles = pd.merge(user_profiles, rating_stats, on='user_id', how='left')
            
        # 添加收藏统计
        if not self.data['favorites'].empty:
            favorite_stats = self.data['favorites'].groupby('user_id').agg({
                'painting_id': 'count',
                'create_time': ['min', 'max']
            }).reset_index()
            favorite_stats.columns = ['user_id', 'total_favorites_count', 'first_favorite_time', 'last_favorite_time']
            user_profiles = pd.merge(user_profiles, favorite_stats, on='user_id', how='left')
            
        # 填充缺失值
        user_profiles = user_profiles.fillna({
            'total_browse_count': 0,
            'unique_paintings_browsed': 0,
            'avg_rating_given': 0,
            'total_ratings_count': 0,
            'total_favorites_count': 0
        })
        
        return user_profiles
        
    def _create_item_profiles(self):
        """创建物品画像"""
        paintings_df = self.data['paintings']
        if paintings_df.empty:
            return pd.DataFrame()
            
        # 聚合作品相关数据
        item_profiles = paintings_df.copy()
        
        # 添加浏览统计
        if not self.data['browse_records'].empty:
            item_browse_stats = self.data['browse_records'].groupby('painting_id').size().reset_index(name='total_browse_count')
            item_profiles = pd.merge(item_profiles, item_browse_stats, on='painting_id', how='left')
            
        # 添加评分统计
        if not self.data['ratings'].empty:
            item_rating_stats = self.data['ratings'].groupby('painting_id').agg({
                'star_count': ['mean', 'count']
            }).reset_index()
            item_rating_stats.columns = ['painting_id', 'avg_rating_received', 'total_ratings_received']
            item_profiles = pd.merge(item_profiles, item_rating_stats, on='painting_id', how='left')
            
        # 添加收藏统计
        if not self.data['favorites'].empty:
            item_favorite_stats = self.data['favorites'].groupby('painting_id').size().reset_index(name='total_favorites_received')
            item_profiles = pd.merge(item_profiles, item_favorite_stats, on='painting_id', how='left')
            
        # 填充缺失值
        item_profiles = item_profiles.fillna({
            'total_browse_count': 0,
            'avg_rating_received': 0,
            'total_ratings_received': 0,
            'total_favorites_received': 0
        })
        
        return item_profiles
        
    def _create_user_item_matrix(self):
        """创建用户-物品评分矩阵"""
        if self.data['ratings'].empty:
            return pd.DataFrame()
            
        # 使用评分数据创建矩阵
        user_item_matrix = self.data['ratings'].pivot_table(
            index='user_id',
            columns='painting_id',
            values='star_count',
            fill_value=0
        )
        
        return user_item_matrix

if __name__ == "__main__":
    from data_loader import TianjinNewYearPaintingDataLoader
    
    # 测试数据预处理器
    data_loader = TianjinNewYearPaintingDataLoader()
    data_loader.load_all_data()
    
    preprocessor = TianjinNewYearPaintingPreprocessor(data_loader)
    preprocessed_data = preprocessor.preprocess_all_data()
    
    print("\n数据预处理完成，用户画像维度:")
    print(list(preprocessor.user_profiles.columns))
    print(f"用户画像数量: {len(preprocessor.user_profiles)}")
    
    print("\n物品画像维度:")
    print(list(preprocessor.item_profiles.columns))
    print(f"物品画像数量: {len(preprocessor.item_profiles)}")
    
    if not preprocessor.user_item_matrix.empty:
        print(f"\n用户-物品矩阵形状: {preprocessor.user_item_matrix.shape}")