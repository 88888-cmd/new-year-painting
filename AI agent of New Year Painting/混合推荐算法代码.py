import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity, pairwise_distances
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
import torch
from transformers import BertTokenizer, BertForSequenceClassification
import warnings
import chardet

warnings.filterwarnings('ignore')

class AdvancedNewYearPaintingRecommender:
    def __init__(self, data_dir):
        # 初始化数据目录
        self.data_dir = data_dir
        # 加载所有数据
        self.load_data()
        # 预处理数据
        self.preprocess_data()
        # 初始化BERT模型用于情感分析
        #self.initialize_bert_model()
        self.bert_available = False
        # 构建用户-项目交互矩阵
        self.build_user_item_matrix()
        # 构建年画内容特征矩阵
        self.build_painting_content_matrix()
        # 计算相似度
        self.compute_similarities()
    
    def load_data(self):

        with open(f"{self.data_dir}/用户信息.csv", 'rb') as file:
            content = file.read()
            encoding = chardet.detect(content)['encoding']
            
        # 加载用户信息
        self.users = pd.read_csv(f"{self.data_dir}/用户信息.csv",encoding=encoding)

        
        # 加载年画作品
        with open(f"{self.data_dir}/年画作品.csv", 'rb') as file:
            content = file.read()
            encoding = chardet.detect(content)['encoding']
        self.paintings = pd.read_csv(f"{self.data_dir}/年画作品.csv",encoding=encoding)
        # 加载用户浏览记录
        self.browse_records = pd.read_csv(f"{self.data_dir}/用户浏览年画物品记录.csv")
        # 加载用户收藏记录
        self.collection_records = pd.read_csv(f"{self.data_dir}/用户收藏记录.csv")

        with open(f"{self.data_dir}/年画评论.csv", 'rb') as file:
            content = file.read()
            encoding = chardet.detect(content)['encoding']
        # 加载年画评论
        self.comments = pd.read_csv(f"{self.data_dir}/年画评论.csv",encoding=encoding)
        # 加载年画评分
        self.ratings = pd.read_csv(f"{self.data_dir}/年画用户评分打星数.csv")
        # 加载年画风格
        with open(f"{self.data_dir}/年画风格.csv", 'rb') as file:
            content = file.read()
            encoding = chardet.detect(content)['encoding']
        self.styles = pd.read_csv(f"{self.data_dir}/年画风格.csv",encoding=encoding)
        # 加载年画主体
        with open(f"{self.data_dir}/年画主体.csv", 'rb') as file:
            content = file.read()
            encoding = chardet.detect(content)['encoding']
        self.themes = pd.read_csv(f"{self.data_dir}/年画主体.csv",encoding=encoding)
    
    def preprocess_data(self):
        # 转换时间格式
        for df in [self.browse_records, self.collection_records, self.comments, self.ratings]:
            if 'create_time' in df.columns:
                df['create_time'] = pd.to_datetime(df['create_time'], dayfirst=True,format='mixed')
        
        # 合并年画信息和风格、主体
        self.paintings = self.paintings.merge(
            self.styles.rename(columns={'name': 'style_name'}), 
            #on='style_id', 
            #how='left'
            left_on='style_id', 
            right_on='id', 
            how='left',
            suffixes=('', '_style')
        )
        #print(self.styles.head(10))
        #print(self.paintings.head())
        # 注意：年画作品中的theme_id可能对应的字段需要根据实际数据结构调整
        # 这里我们使用left join确保不丢失数据
        self.paintings = self.paintings.merge(
            self.themes.rename(columns={'name': 'theme_name'}), 
            left_on='theme_id', 
            right_on='id', 
            how='left',
            suffixes=('', '_theme')
        )
        
        # 处理缺失值
        self.paintings['style_name'] = self.paintings['style_name'].fillna('未知风格')
        self.paintings['theme_name'] = self.paintings['theme_name'].fillna('未知主题')
    
    def initialize_bert_model(self):
        """初始化BERT模型用于中文情感分析"""
        try:
            # 尝试加载预训练的中文BERT情感分析模型
            self.tokenizer = BertTokenizer.from_pretrained('hfl/chinese-bert-wwm-ext')
            self.model = BertForSequenceClassification.from_pretrained('hfl/chinese-bert-wwm-ext', num_labels=2)
            
            # 检查是否有GPU可用
            self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
            self.model.to(self.device)
            self.bert_available = True
            print("BERT模型初始化成功，将用于评论情感分析。")
        except Exception as e:
            print(f"BERT模型初始化失败: {e}")
            print("将使用基于评分的情感分析替代。")
            self.bert_available = False
    
    def analyze_sentiment(self, text):
        """分析文本情感，返回正面情感得分（0-1之间）"""
        if not self.bert_available or not text or pd.isna(text):
            return 0.5  # 默认中立情感
        
        try:
            # 预处理文本
            inputs = self.tokenizer(text[:512], return_tensors='pt', truncation=True, padding=True)
            inputs = {k: v.to(self.device) for k, v in inputs.items()}
            
            # 模型推理
            with torch.no_grad():
                outputs = self.model(**inputs)
                logits = outputs.logits
                probabilities = torch.softmax(logits, dim=1)
                
            # 返回正面情感概率
            positive_prob = probabilities[0][1].item()
            return positive_prob
        except Exception as e:
            print(f"情感分析出错: {e}")
            return 0.5
    
    def build_user_item_matrix(self):
        # 创建用户-评分矩阵
        rating_matrix = self.ratings.pivot_table(
            index='user_id', 
            columns='painting_id', 
            values='star_count',
            fill_value=0
        )
        
        # 创建用户-浏览记录矩阵（用户对年画的浏览次数）
        browse_counts = self.browse_records.groupby(['user_id', 'painting_id']).size().reset_index(name='browse_count')
        
        # 创建用户-收藏矩阵（用户是否收藏了年画）
        collection_matrix = pd.crosstab(self.collection_records['user_id'], self.collection_records['painting_id'])
        collection_matrix = collection_matrix.clip(upper=1)  # 确保收藏次数不超过1
        
        # 分析评论情感
        if self.bert_available:
            print("正在分析评论情感...")
            # 对每条评论进行情感分析
            self.comments['sentiment_score'] = self.comments['content'].apply(self.analyze_sentiment)
        else:
            # 基于评分推断情感
            # 首先合并评分数据
            merged_comments = self.comments.merge(
                self.ratings[['painting_id', 'user_id', 'star_count']],
                on=['painting_id', 'user_id'],
                how='left'
            )
            # 将评分转换为情感分数（1-5星 -> 0-1）
            merged_comments['sentiment_score'] = merged_comments['star_count'].apply(lambda x: (x-1)/4 if pd.notna(x) else 0.5)
            self.comments = merged_comments
        
        # 创建用户-评论情感矩阵
        comment_sentiment_matrix = self.comments.groupby(['user_id', 'painting_id'])['sentiment_score'].mean().unstack(fill_value=0)
        
        # 获取所有用户和年画的唯一ID
        all_users = sorted(set(rating_matrix.index) | set(browse_counts['user_id']) | set(collection_matrix.index) | set(comment_sentiment_matrix.index))
        all_paintings = sorted(set(rating_matrix.columns) | set(browse_counts['painting_id']) | set(collection_matrix.columns) | set(comment_sentiment_matrix.columns))
        
        # 初始化综合评分矩阵
        self.user_item_matrix = pd.DataFrame(0, index=all_users, columns=all_paintings)
        
        # 填充评分数据（权重最高）
        for user_id in rating_matrix.index:
            for painting_id in rating_matrix.columns:
                if rating_matrix.at[user_id, painting_id] > 0:
                    self.user_item_matrix.at[user_id, painting_id] = rating_matrix.at[user_id, painting_id]
        
        # 添加浏览权重
        scaler_browse = MinMaxScaler(feature_range=(0.1, 1))
        max_browse_count = browse_counts['browse_count'].max()
        for _, row in browse_counts.iterrows():
            user_id = row['user_id']
            painting_id = row['painting_id']
            # 归一化浏览次数
            browse_score = (row['browse_count'] / max_browse_count) * 0.5  # 浏览权重设为0.5
            if self.user_item_matrix.at[user_id, painting_id] == 0:
                self.user_item_matrix.at[user_id, painting_id] = browse_score
            else:
                # 如果已有评分，增加浏览带来的额外分数
                self.user_item_matrix.at[user_id, painting_id] += browse_score
        
        # 添加收藏权重
        for user_id in collection_matrix.index:
            for painting_id in collection_matrix.columns:
                if collection_matrix.at[user_id, painting_id] > 0:
                    if self.user_item_matrix.at[user_id, painting_id] == 0:
                        self.user_item_matrix.at[user_id, painting_id] = 3  # 收藏权重设为3
                    else:
                        # 如果已有评分，增加收藏带来的额外分数
                        self.user_item_matrix.at[user_id, painting_id] += 1
        
        # 添加评论情感权重
        scaler_sentiment = MinMaxScaler(feature_range=(1, 5))  # 将情感分数映射到1-5分
        for user_id in comment_sentiment_matrix.index:
            for painting_id in comment_sentiment_matrix.columns:
                sentiment_score = comment_sentiment_matrix.at[user_id, painting_id]
                if sentiment_score > 0:
                    # 将情感分数映射到评分范围内
                    scaled_sentiment = (sentiment_score * 4) + 1  # 0-1 -> 1-5
                    if self.user_item_matrix.at[user_id, painting_id] == 0:
                        self.user_item_matrix.at[user_id, painting_id] = scaled_sentiment
                    else:
                        # 如果已有评分，根据情感调整
                        if sentiment_score > 0.7:  # 积极评论
                            self.user_item_matrix.at[user_id, painting_id] = min(5, self.user_item_matrix.at[user_id, painting_id] + 0.5)
                        elif sentiment_score < 0.3:  # 消极评论
                            self.user_item_matrix.at[user_id, painting_id] = max(1, self.user_item_matrix.at[user_id, painting_id] - 0.5)
    
    def build_painting_content_matrix(self):
        # 创建年画内容特征矩阵
        # 提取风格和主题作为分类特征
        style_dummies = pd.get_dummies(self.paintings['style_name'], prefix='style')
        theme_dummies = pd.get_dummies(self.paintings['theme_name'], prefix='theme')
        
        # 计算年画的统计特征
        # 计算每个年画的平均评分
        avg_rating = self.ratings.groupby('painting_id')['star_count'].mean().reset_index(name='avg_rating')
        avg_rating = avg_rating.set_index('painting_id')
        
        # 计算每个年画的受欢迎度（浏览次数）
        popularity = self.browse_records.groupby('painting_id').size().reset_index(name='popularity')
        popularity = popularity.set_index('painting_id')
        
        # 计算每个年画的收藏率
        collected_count = self.collection_records.groupby('painting_id').size().reset_index(name='collected_count')
        collected_count = collected_count.set_index('painting_id')
        
        # 合并所有特征
        features_df = pd.concat([
            self.paintings[['id']], 
            style_dummies, 
            theme_dummies
        ], axis=1).set_index('id')
        
        # 合并统计特征
        features_df = features_df.merge(avg_rating, left_index=True, right_index=True, how='left')
        features_df = features_df.merge(popularity, left_index=True, right_index=True, how='left')
        features_df = features_df.merge(collected_count, left_index=True, right_index=True, how='left')
        
        # 填充缺失值
        features_df = features_df.fillna(0)
        
        # 归一化数值特征
        scaler = MinMaxScaler()
        numeric_cols = ['avg_rating', 'popularity', 'collected_count']
        for col in numeric_cols:
            if col in features_df.columns:
                features_df[col] = scaler.fit_transform(features_df[[col]])
        
        self.painting_features = features_df
    
    def compute_similarities(self):
        # 计算用户相似度矩阵（基于协同过滤）
        self.user_similarity = cosine_similarity(self.user_item_matrix)
        self.user_similarity_df = pd.DataFrame(
            self.user_similarity, 
            index=self.user_item_matrix.index, 
            columns=self.user_item_matrix.index
        )
        
        # 计算物品相似度矩阵（基于协同过滤）
        self.item_similarity = cosine_similarity(self.user_item_matrix.T)
        self.item_similarity_df = pd.DataFrame(
            self.item_similarity, 
            index=self.user_item_matrix.columns, 
            columns=self.user_item_matrix.columns
        )
        
        # 计算物品内容相似度矩阵
        self.content_similarity = cosine_similarity(self.painting_features)
        self.content_similarity_df = pd.DataFrame(
            self.content_similarity, 
            index=self.painting_features.index, 
            columns=self.painting_features.index
        )
    
    def recommend_for_user(self, user_id, n_recommendations=5, 
                          cf_user_weight=0.3, cf_item_weight=0.3, content_weight=0.4):
        # 检查用户是否存在
        if user_id not in self.user_item_matrix.index:
            print(f"用户 {user_id} 不存在或没有行为记录")
            return pd.DataFrame()
        
        # 获取用户已交互的年画
        user_interacted = self.user_item_matrix.loc[user_id][self.user_item_matrix.loc[user_id] > 0].index.tolist()
        #print(f"用户 {user_id} 交互过的年画",user_interacted)
        
        # 1. 基于用户的协同过滤推荐
        cf_user_recommendations = pd.Series()
        if cf_user_weight > 0:
            # 获取与目标用户最相似的用户
            similar_users = self.user_similarity_df[user_id].sort_values(ascending=False).index[1:20]  # 取前20个最相似用户
            #print("相似用户",similar_users)
            # 收集相似用户交互过的年画
            for sim_user in similar_users:
                sim_user_ratings = self.user_item_matrix.loc[sim_user]
                sim_user_interacted = sim_user_ratings[sim_user_ratings > 0].index.tolist()
                
                # 排除目标用户已经交互过的年画
                #new_items = [item for item in sim_user_interacted if item not in user_interacted]
                # 若排除了所有交互过的年画，会有逻辑错误：用户2浏览过所有年画，然后就都排除了
                new_items = sim_user_interacted
                # 计算相似度加权评分
                similarity_score = self.user_similarity_df.loc[user_id, sim_user]
                for item in new_items:
                    if item not in cf_user_recommendations.index:
                        cf_user_recommendations[item] = 0
                    cf_user_recommendations[item] += similarity_score * sim_user_ratings[item]
            
            # 归一化评分
            if not cf_user_recommendations.empty:
                max_score = cf_user_recommendations.max()
                if max_score > 0:
                    cf_user_recommendations = cf_user_recommendations / max_score
        #print("用户协同过滤结果",len(cf_user_recommendations))
        
        # 2. 基于物品的协同过滤推荐
        cf_item_recommendations = pd.Series()
        if cf_item_weight > 0 and len(user_interacted) > 0:
            # 对用户交互过的每个物品，找到相似的物品
            for item in user_interacted:
                if item in self.item_similarity_df.index:
                    # 获取相似的物品
                    similar_items = self.item_similarity_df[item].sort_values(ascending=False).index[1:11]  # 每个物品取前10个相似物品
                    
                    # 排除用户已经交互过的物品
                    #new_items = [i for i in similar_items if i not in user_interacted]
                    # 若排除了所有交互过的年画，会有逻辑错误：用户2浏览过所有年画，然后就都排除了
                    new_items = similar_items
                    # 计算相似度加权评分
                    user_rating = self.user_item_matrix.loc[user_id, item]
                    for sim_item in new_items:
                        if sim_item not in cf_item_recommendations.index:
                            cf_item_recommendations[sim_item] = 0
                        cf_item_recommendations[sim_item] += self.item_similarity_df.loc[item, sim_item] * user_rating
            
            # 归一化评分
            if not cf_item_recommendations.empty:
                max_score = cf_item_recommendations.max()
                if max_score > 0:
                    cf_item_recommendations = cf_item_recommendations / max_score
        #print("物品协同过滤结果",len(cf_item_recommendations))
        
        # 3. 基于内容的推荐
        content_recommendations = pd.Series()
        if content_weight > 0 and len(user_interacted) > 0:
            # 计算用户偏好特征
            user_preferred_features = pd.Series(0, index=self.painting_features.columns)
            for item in user_interacted:
                if item in self.painting_features.index:
                    # 根据用户对物品的评分加权特征
                    user_rating = self.user_item_matrix.loc[user_id, item]
                    user_preferred_features += self.painting_features.loc[item] * user_rating
            
            # 归一化用户偏好
            if user_preferred_features.sum() > 0:
                user_preferred_features = user_preferred_features / user_preferred_features.sum()
            
            # 计算所有物品与用户偏好的相似度（包括已经有交互的物品）
            for item in self.painting_features.index:
                # if item not in user_interacted:
                item_features = self.painting_features.loc[item]
                # 计算余弦相似度
                similarity = np.dot(user_preferred_features, item_features) / (
                    np.linalg.norm(user_preferred_features) * np.linalg.norm(item_features) + 1e-10
                )
                content_recommendations[item] = similarity
            
            # 归一化评分
            if not content_recommendations.empty:
                max_score = content_recommendations.max()
                if max_score > 0:
                    content_recommendations = content_recommendations / max_score
        #print("内容协同过滤结果",len(content_recommendations))
        
        # 4. 混合推荐结果
        final_recommendations = pd.Series()
        
        # 收集所有推荐物品
        all_items = set()
        if not cf_user_recommendations.empty:
            all_items.update(cf_user_recommendations.index)
        if not cf_item_recommendations.empty:
            all_items.update(cf_item_recommendations.index)
        if not content_recommendations.empty:
            all_items.update(content_recommendations.index)
        #print("推荐结果数量：",len(all_items))
        
        # 计算加权分数
        for item in all_items:
            score = 0
            if not cf_user_recommendations.empty and item in cf_user_recommendations.index:
                score += cf_user_recommendations[item] * cf_user_weight
            if not cf_item_recommendations.empty and item in cf_item_recommendations.index:
                score += cf_item_recommendations[item] * cf_item_weight
            if not content_recommendations.empty and item in content_recommendations.index:
                score += content_recommendations[item] * content_weight
            final_recommendations[item] = score
        
        # 如果没有推荐结果，返回空
        if final_recommendations.empty:
            print("算法没有推荐结果")
            return pd.DataFrame()
        
        # 排序并获取前n个推荐
        final_recommendations = final_recommendations.sort_values(ascending=False)
        top_n_items = final_recommendations.head(n_recommendations).index.tolist()
        
        # 获取年画的详细信息
        recommended_paintings = self.paintings[self.paintings['id'].isin(top_n_items)].copy()
        
        # 添加推荐分数
        scores = [final_recommendations[p] for p in top_n_items if p in final_recommendations.index]
        recommended_paintings['recommendation_score'] = scores
        
        # 按推荐分数排序
        recommended_paintings = recommended_paintings.sort_values('recommendation_score', ascending=False)
        
        return recommended_paintings[['id', 'name', 'style_name', 'theme_name', 'recommendation_score']]
    
    def evaluate_recommender(self, test_size=0.1, n_recommendations=5):
        """评估推荐系统性能"""
        from sklearn.metrics import precision_score, recall_score, f1_score, confusion_matrix
        
        # 准备评估数据
        # 创建用户-物品交互记录
        interactions = []
        for user_id in self.user_item_matrix.index:
            for painting_id in self.user_item_matrix.columns:
                if self.user_item_matrix.at[user_id, painting_id] > 0:
                    interactions.append((user_id, painting_id, 1))  # 1表示有交互
        
        # 转换为DataFrame
        interactions_df = pd.DataFrame(interactions, columns=['user_id', 'painting_id', 'interaction'])
        
        # 切分训练集和测试集
        train, test = train_test_split(interactions_df, test_size=test_size, random_state=10)
        
        # 创建训练集用户-物品矩阵
        train_matrix = self.user_item_matrix.copy()
        # 移除测试集中的交互
        for _, row in test.iterrows():
            user_id = row['user_id']
            painting_id = row['painting_id']
            if user_id in train_matrix.index and painting_id in train_matrix.columns:
                train_matrix.at[user_id, painting_id] = 0
        
        # 保存原始矩阵并替换为训练矩阵
        original_matrix = self.user_item_matrix
        self.user_item_matrix = train_matrix
        
        # 重新计算相似度
        self.compute_similarities()
        
        # 用于存储预测结果和实际结果
        y_true = []
        y_pred = []
        
        # 为每个用户生成推荐并评估
        for user_id in test['user_id'].unique()[0:20]:
            # 获取用户在测试集中的交互物品
            #print(self.user_item_matrix.loc[user_id].tolist())
            #user_test_items = test[test['user_id'] == user_id]['painting_id'].tolist()
            user_test_items = original_matrix.loc[user_id][original_matrix.loc[user_id] > 0].index.tolist()
            #user_test_items = self.user_item_matrix.loc[user_id][self.user_item_matrix.loc[user_id] > 0].index.tolist()
            #print(f"用户{user_id}和物品的交互列表",user_test_items,f"\tlen:",len(user_test_items))
            if len(user_test_items) == 0:
                continue

            
            # 生成推荐
            #recommendations = self.recommend_for_user(user_id, n_recommendations)
            recommendations = self.recommend_for_user(user_id, len(user_test_items)+1)
            
            if recommendations.empty:
                # 如果没有推荐结果，所有预测都是0
                y_true.extend([1] * len(user_test_items))
                y_pred.extend([0] * len(user_test_items))
                continue
            
            # 获取推荐的物品ID
            recommended_items = recommendations['id'].tolist()
            #print(f"用户{user_id}的物品推荐列表",recommended_items,f"\tlen:",len(recommended_items))
            # 构建真实值和预测值向量
            for item in user_test_items:
                y_true.append(1)
                y_pred.append(1 if item in recommended_items else 0)
            
            # 对于没有出现在测试集中的推荐物品，标记为假阳性
            for item in recommended_items:
                if item not in user_test_items:
                    y_true.append(0)
                    y_pred.append(1)
            #print(f"用户{user_id}y_true\t:",y_true,f"\tlen:",len(y_true))
            #print(f"用户{user_id}y_pred\t:",y_pred,f"\tlen:",len(y_true))
        
        # 恢复原始矩阵
        self.user_item_matrix = original_matrix
        self.compute_similarities()
        
        # 计算评估指标
        if len(y_true) > 0:
            cm = confusion_matrix(y_true, y_pred)
            #print("Confusion Matrix:\n", cm)
            precision = precision_score(y_true, y_pred)
            recall = recall_score(y_true, y_pred)
            f1 = f1_score(y_true, y_pred)
            
            print(f"推荐系统评估结果:")
            print(f"精确率 (Precision): {precision:.4f}")
            print(f"召回率 (Recall): {recall:.4f}")
            print(f"F1分数: {f1:.4f}")
            
            return {
                'precision': precision,
                'recall': recall,
                'f1': f1
            }
        else:
            print("没有足够的测试数据进行评估")
            return None

# 使用示例
if __name__ == "__main__":
    # 创建推荐器实例
    print("正在初始化高级推荐系统...")
    #recommender = AdvancedNewYearPaintingRecommender("data")
    recommender = AdvancedNewYearPaintingRecommender("data20250930")
    print("推荐系统初始化完成！")
    
    # 为用户推荐年画示例
    # print("\n为用户4669推荐年画:")
    # recommendations_user2 = recommender.recommend_for_user(4669, n_recommendations=10)
    # print(recommendations_user2)
    
    # print("\n为用户6推荐年画:")
    # recommendations_user3 = recommender.recommend_for_user(6, n_recommendations=10)
    # print(recommendations_user3)
    
    # print("\n为用户1136推荐年画:")
    # recommendations_user4 = recommender.recommend_for_user(1136, n_recommendations=10)
    # print(recommendations_user4)
    
    # 可以根据需要调整混合权重
    # print("\n调整混合权重 - 增加基于内容的推荐权重:")
    # recommendations_custom = recommender.recommend_for_user(
    #     50, 
    #     n_recommendations=5, 
    #     cf_user_weight=0.2, 
    #     cf_item_weight=0.2, 
    #     content_weight=0.6
    # )
    # print(recommendations_custom)
    
    # 评估推荐系统性能
    print("\n评估推荐系统性能:")
    evaluation_results = recommender.evaluate_recommender(n_recommendations=5)
