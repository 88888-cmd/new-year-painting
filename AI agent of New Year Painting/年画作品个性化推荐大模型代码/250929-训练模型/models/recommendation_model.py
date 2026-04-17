import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.decomposition import TruncatedSVD
import faiss
from datetime import datetime, timedelta

class TianjinNewYearPaintingRecommender:
    def __init__(self, preprocessor, n_components=50, n_neighbors=20):
        """初始化推荐系统"""
        self.preprocessor = preprocessor
        self.user_profiles = preprocessor.user_profiles
        self.item_profiles = preprocessor.item_profiles
        self.user_item_matrix = preprocessor.user_item_matrix
        self.n_components = n_components
        self.n_neighbors = n_neighbors
        
        # 模型初始化
        self.svd_model = None
        self.user_similarity_matrix = None
        self.item_similarity_matrix = None
        self.user_embeddings = None
        self.item_embeddings = None
        self.faiss_index = None
        
        # 训练模型
        self._train_models()
        
    def _train_models(self):
        """训练推荐模型"""
        # 检查是否有足够的数据进行训练
        if self.user_item_matrix.empty:
            print("警告: 用户-物品矩阵为空，无法训练推荐模型")
            return
            
        # 训练SVD模型用于矩阵分解
        self._train_svd()
        
        # 计算用户相似度矩阵
        self._compute_user_similarity()
        
        # 计算物品相似度矩阵
        self._compute_item_similarity()
        
        # 创建FAISS索引用于快速近邻搜索
        self._create_faiss_index()
        
    def _train_svd(self):
        """训练SVD模型进行矩阵分解"""
        try:
            self.svd_model = TruncatedSVD(n_components=self.n_components, random_state=42)
            self.user_embeddings = self.svd_model.fit_transform(self.user_item_matrix)
            self.item_embeddings = self.svd_model.components_.T
            
            explained_variance = np.sum(self.svd_model.explained_variance_ratio_)
            print(f"SVD模型训练完成，解释方差比: {explained_variance:.4f}")
        except Exception as e:
            print(f"SVD模型训练失败: {e}")
            
    def _compute_user_similarity(self):
        """计算用户相似度矩阵"""
        try:
            if self.user_embeddings is not None:
                self.user_similarity_matrix = cosine_similarity(self.user_embeddings)
                print("用户相似度矩阵计算完成")
        except Exception as e:
            print(f"用户相似度矩阵计算失败: {e}")
            
    def _compute_item_similarity(self):
        """计算物品相似度矩阵"""
        try:
            if self.item_embeddings is not None:
                self.item_similarity_matrix = cosine_similarity(self.item_embeddings)
                print("物品相似度矩阵计算完成")
        except Exception as e:
            print(f"物品相似度矩阵计算失败: {e}")
            
    def _create_faiss_index(self):
        """创建FAISS索引用于快速近邻搜索"""
        try:
            if self.item_embeddings is not None:
                # 归一化嵌入向量
                item_vectors = self.item_embeddings.astype('float32')
                faiss.normalize_L2(item_vectors)
                
                # 创建索引
                self.faiss_index = faiss.IndexFlatIP(item_vectors.shape[1])
                self.faiss_index.add(item_vectors)
                print("FAISS索引创建完成")
        except Exception as e:
            print(f"FAISS索引创建失败: {e}")
            
    def get_recommendations_for_user(self, user_id, n_recommendations=10, method='hybrid'):
        """为指定用户推荐年画作品"""
        # 检查用户是否存在
        if user_id not in self.user_item_matrix.index:
            print(f"警告: 用户ID {user_id} 不存在")
            return self._get_popular_recommendations(n_recommendations)
            
        # 根据不同方法生成推荐
        if method == 'collaborative':
            return self._collaborative_filtering_recommend(user_id, n_recommendations)
        elif method == 'content_based':
            return self._content_based_recommend(user_id, n_recommendations)
        elif method == 'hybrid':
            return self._hybrid_recommend(user_id, n_recommendations)
        else:
            print(f"警告: 未知的推荐方法 {method}")
            return self._get_popular_recommendations(n_recommendations)
            
    def _collaborative_filtering_recommend(self, user_id, n_recommendations):
        """基于协同过滤的推荐"""
        try:
            # 获取用户评分
            user_ratings = self.user_item_matrix.loc[user_id].values.reshape(1, -1)
            
            # 预测评分
            if self.svd_model is not None:
                user_predicted_ratings = self.svd_model.inverse_transform(self.user_embeddings[self.user_item_matrix.index.get_loc(user_id)].reshape(1, -1))[0]
            else:
                # 如果没有SVD模型，使用用户相似度进行推荐
                if self.user_similarity_matrix is None:
                    return self._get_popular_recommendations(n_recommendations)
                    
                user_idx = self.user_item_matrix.index.get_loc(user_id)
                similar_users = self.user_similarity_matrix[user_idx].argsort()[::-1][1:self.n_neighbors+1]
                similar_users_ratings = self.user_item_matrix.iloc[similar_users].values
                user_predicted_ratings = similar_users_ratings.mean(axis=0)
                
            # 过滤掉用户已经评分过的作品
            user_rated_items = np.where(user_ratings > 0)[1]
            user_predicted_ratings[user_rated_items] = -np.inf
            
            # 获取评分最高的n个作品
            top_item_indices = user_predicted_ratings.argsort()[::-1][:n_recommendations]
            top_painting_ids = self.user_item_matrix.columns[top_item_indices].values
            
            return self._get_painting_details(top_painting_ids)
        except Exception as e:
            print(f"协同过滤推荐失败: {e}")
            return self._get_popular_recommendations(n_recommendations)
            
    def _content_based_recommend(self, user_id, n_recommendations):
        """基于内容的推荐"""
        try:
            # 获取用户喜欢的作品
            user_ratings = self.user_item_matrix.loc[user_id]
            liked_items = user_ratings[user_ratings > 3].index.tolist()  # 评分大于3的视为喜欢
            
            if not liked_items:
                return self._get_popular_recommendations(n_recommendations)
                
            # 计算用户喜欢的作品的平均嵌入
            liked_indices = [self.user_item_matrix.columns.get_loc(item) for item in liked_items if item in self.user_item_matrix.columns]
            if not liked_indices or self.item_embeddings is None:
                return self._get_popular_recommendations(n_recommendations)
                
            user_preference_vector = self.item_embeddings[liked_indices].mean(axis=0).reshape(1, -1)
            
            # 使用FAISS搜索最相似的作品
            if self.faiss_index is not None:
                user_preference_vector = user_preference_vector.astype('float32')
                faiss.normalize_L2(user_preference_vector)
                distances, indices = self.faiss_index.search(user_preference_vector, len(self.user_item_matrix.columns))
                
                # 过滤掉用户已经评分过的作品
                recommended_indices = []
                for idx in indices[0]:
                    painting_id = self.user_item_matrix.columns[idx]
                    if painting_id not in liked_items and len(recommended_indices) < n_recommendations:
                        recommended_indices.append(idx)
                        
                top_painting_ids = self.user_item_matrix.columns[recommended_indices].values
            else:
                # 如果没有FAISS索引，使用余弦相似度
                similarities = cosine_similarity(user_preference_vector, self.item_embeddings)[0]
                top_indices = similarities.argsort()[::-1][:n_recommendations*2]  # 获取更多以过滤
                
                # 过滤掉用户已经评分过的作品
                recommended_indices = []
                for idx in top_indices:
                    painting_id = self.user_item_matrix.columns[idx]
                    if painting_id not in liked_items and len(recommended_indices) < n_recommendations:
                        recommended_indices.append(idx)
                        
                top_painting_ids = self.user_item_matrix.columns[recommended_indices].values
                
            return self._get_painting_details(top_painting_ids)
        except Exception as e:
            print(f"基于内容的推荐失败: {e}")
            return self._get_popular_recommendations(n_recommendations)
            
    def _hybrid_recommend(self, user_id, n_recommendations):
        """混合推荐方法"""
        try:
            # 获取两种推荐结果
            cf_recommendations = self._collaborative_filtering_recommend(user_id, n_recommendations*2)
            cb_recommendations = self._content_based_recommend(user_id, n_recommendations*2)
            
            # 合并结果并去重
            all_recommendations = pd.concat([cf_recommendations, cb_recommendations]).drop_duplicates(subset='id')
            
            # 根据流行度和相似度排序
            if not all_recommendations.empty:
                # 计算最终得分（可以根据实际情况调整权重）
                if 'avg_rating_received' in all_recommendations.columns:
                    all_recommendations['score'] = all_recommendations['avg_rating_received'].fillna(0) * 0.5 + \
                                                  all_recommendations.index.to_series().apply(lambda x: 1/(x+1)) * 0.5
                    all_recommendations = all_recommendations.sort_values('score', ascending=False)
                
                # 返回前n个推荐
                return all_recommendations.head(n_recommendations)
            else:
                return self._get_popular_recommendations(n_recommendations)
        except Exception as e:
            print(f"混合推荐失败: {e}")
            return self._get_popular_recommendations(n_recommendations)
            
    def _get_popular_recommendations(self, n_recommendations):
        """获取热门推荐（当其他推荐方法失败时使用）"""
        try:
            if not self.item_profiles.empty:
                # 按总浏览量、平均评分和收藏数排序
                popular_items = self.item_profiles.copy()
                popular_items['popularity_score'] = 0
                
                if 'total_browse_count' in popular_items.columns:
                    popular_items['popularity_score'] += popular_items['total_browse_count'].fillna(0) * 0.3
                
                if 'avg_rating_received' in popular_items.columns:
                    popular_items['popularity_score'] += popular_items['avg_rating_received'].fillna(0) * 5
                
                if 'total_favorites_received' in popular_items.columns:
                    popular_items['popularity_score'] += popular_items['total_favorites_received'].fillna(0) * 2
                
                # 排序并返回
                popular_items = popular_items.sort_values('popularity_score', ascending=False)
                return popular_items[popular_items['is_delete'] == 0].head(n_recommendations)
            else:
                return pd.DataFrame()
        except Exception as e:
            print(f"热门推荐获取失败: {e}")
            return pd.DataFrame()
            
    def _get_painting_details(self, painting_ids):
        """获取作品详细信息"""
        try:
            if not self.item_profiles.empty:
                # 确保painting_ids是字符串类型以匹配
                painting_ids_str = [str(pid) if not isinstance(pid, str) else pid for pid in painting_ids]
                
                # 筛选出对应的作品
                details = self.item_profiles[self.item_profiles['id'].astype(str).isin(painting_ids_str)]
                
                # 按照指定的顺序排序
                details['id_str'] = details['id'].astype(str)
                details = details.set_index('id_str').loc[painting_ids_str].reset_index(drop=True)
                
                return details
            else:
                return pd.DataFrame()
        except Exception as e:
            print(f"获取作品详情失败: {e}")
            return pd.DataFrame()
            
    def get_recommendations_based_on_recent_activities(self, user_id, time_window_days=7, n_recommendations=10):
        """基于用户近期活动进行推荐"""
        try:
            # 检查用户是否存在
            if user_id not in self.preprocessor.data['users']['id'].values:
                return self._get_popular_recommendations(n_recommendations)
                
            # 获取时间窗口
            end_date = datetime.now()
            start_date = end_date - timedelta(days=time_window_days)
            
            # 获取用户近期浏览记录
            browse_data = self.preprocessor.data['browse_records']
            recent_browses = browse_data[
                (browse_data['user_id'] == user_id) & 
                (browse_data['create_time'] >= start_date) & 
                (browse_data['create_time'] <= end_date)
            ]
            
            # 获取用户近期评分记录
            rating_data = self.preprocessor.data['ratings']
            recent_ratings = rating_data[
                (rating_data['user_id'] == user_id) & 
                (rating_data['create_time'] >= start_date) & 
                (rating_data['create_time'] <= end_date)
            ]
            
            # 获取用户近期收藏记录
            favorite_data = self.preprocessor.data['favorites']
            recent_favorites = favorite_data[
                (favorite_data['user_id'] == user_id) & 
                (favorite_data['create_time'] >= start_date) & 
                (favorite_data['create_time'] <= end_date)
            ]
            
            # 如果近期没有活动，使用混合推荐
            if recent_browses.empty and recent_ratings.empty and recent_favorites.empty:
                return self.get_recommendations_for_user(user_id, n_recommendations, method='hybrid')
                
            # 分析近期偏好
            recent_painting_ids = set()
            
            if not recent_browses.empty:
                recent_painting_ids.update(recent_browses['painting_id'].unique())
                
            if not recent_ratings.empty:
                # 只考虑高分作品
                high_rated = recent_ratings[recent_ratings['star_count'] > 3]['painting_id'].unique()
                recent_painting_ids.update(high_rated)
                
            if not recent_favorites.empty:
                recent_painting_ids.update(recent_favorites['painting_id'].unique())
                
            # 获取这些作品的详细信息
            recent_paintings = self.item_profiles[self.item_profiles['id'].isin(recent_painting_ids)]
            
            if recent_paintings.empty:
                return self.get_recommendations_for_user(user_id, n_recommendations, method='hybrid')
                
            # 分析用户近期偏好的风格和主题
            style_counts = recent_paintings['style_name'].value_counts()
            theme_counts = recent_paintings['theme_name'].value_counts()
            
            # 基于偏好的风格和主题进行推荐
            recommended_paintings = []
            
            # 优先推荐相同风格的作品
            if not style_counts.empty:
                top_style = style_counts.idxmax()
                style_recommendations = self.item_profiles[
                    (self.item_profiles['style_name'] == top_style) & 
                    (~self.item_profiles['id'].isin(recent_painting_ids))
                ].head(n_recommendations // 2)
                recommended_paintings.append(style_recommendations)
                
            # 然后推荐相同主题的作品
            if not theme_counts.empty:
                top_theme = theme_counts.idxmax()
                theme_recommendations = self.item_profiles[
                    (self.item_profiles['theme_name'] == top_theme) & 
                    (~self.item_profiles['id'].isin(recent_painting_ids))
                ].head(n_recommendations // 2)
                recommended_paintings.append(theme_recommendations)
                
            # 合并结果
            if recommended_paintings:
                final_recommendations = pd.concat(recommended_paintings).drop_duplicates().head(n_recommendations)
                
                # 如果结果不足，使用混合推荐补充
                if len(final_recommendations) < n_recommendations:
                    remaining = n_recommendations - len(final_recommendations)
                    hybrid_recs = self.get_recommendations_for_user(user_id, remaining, method='hybrid')
                    # 过滤掉已经推荐过的和近期活动过的
                    hybrid_recs = hybrid_recs[
                        ~hybrid_recs['id'].isin(final_recommendations['id']) &
                        ~hybrid_recs['id'].isin(recent_painting_ids)
                    ].head(remaining)
                    final_recommendations = pd.concat([final_recommendations, hybrid_recs])
                    
                return final_recommendations
            else:
                return self.get_recommendations_for_user(user_id, n_recommendations, method='hybrid')
        except Exception as e:
            print(f"基于近期活动的推荐失败: {e}")
            return self.get_recommendations_for_user(user_id, n_recommendations, method='hybrid')

if __name__ == "__main__":
    from data_processing.data_loader import TianjinNewYearPaintingDataLoader
    from data_processing.data_preprocessor import TianjinNewYearPaintingPreprocessor
    
    # 测试推荐系统
    data_loader = TianjinNewYearPaintingDataLoader()
    data_loader.load_all_data()
    
    preprocessor = TianjinNewYearPaintingPreprocessor(data_loader)
    preprocessor.preprocess_all_data()
    
    recommender = TianjinNewYearPaintingRecommender(preprocessor)
    
    # 为用户1推荐作品
    if not preprocessor.user_profiles.empty:
        user_id = preprocessor.user_profiles['id'].iloc[0]
        recommendations = recommender.get_recommendations_for_user(user_id, n_recommendations=10)
        
        print(f"\n为用户 {user_id} 推荐的年画作品:")
        if not recommendations.empty:
            for idx, row in recommendations.iterrows():
                print(f"{idx+1}. {row['name']} (风格: {row.get('style_name', '未知')}, 主题: {row.get('theme_name', '未知')})")
        else:
            print("未找到推荐作品")
            
        # 测试基于近期活动的推荐
        recent_recommendations = recommender.get_recommendations_based_on_recent_activities(user_id)
        print(f"\n基于用户 {user_id} 近期活动的推荐:")
        if not recent_recommendations.empty:
            for idx, row in recent_recommendations.iterrows():
                print(f"{idx+1}. {row['name']} (风格: {row.get('style_name', '未知')}, 主题: {row.get('theme_name', '未知')})")
        else:
            print("未找到推荐作品")