from django.urls import path, include

from .views.user import login, register, profile, update_profile, change_password, get_tag_data, submit_tag
from .views.painting import get_filter_options, get_list, get_random_list, detail, get_comment_list, add_comment, delete_comment, rate_painting, favorite_painting, cancel_favorite_painting, ai_story, get_my_favorited, get_my_view
from .views.posts import get_category_list as get_posts_category_list, get_list as get_posts_list, detail as posts_detail, publish_posts, delete_posts, get_comment_list as get_posts_comment_list, add_comment as add_posts_comment, delete_comment as delete_posts_comment, thumb as thumb_posts, cancel_thumb as cancel_thumb_posts, get_my_list as get_my_posts_list
from .views.shop import get_category_list as get_goods_category_list, get_list as get_goods_list, detail as goods_detail, get_comment_list as get_goods_comment_list, get_cart_badge, get_cart_list, add_to_cart, delete_cart_item, get_coupon_list, receive as receive_coupon, get_my_list as get_my_coupon_list
from .views.ai import init_chat, chat as ai_chat, voice_to_text, text2image, imageedit
from .views.points import get_main_data as get_points_main_data, complete as complete_points_task, get_goods_category_list as get_points_goods_category_list, get_goods_list as get_points_goods_list, goods_detail as points_goods_detail, get_comment_list as get_points_goods_comment_list
from .views.address import get_list as get_address_list, create as create_address, detail as address_detail, edit as edit_address, delete_address
from .views.order import comment as comment_order_goods, receive as receive_order, detail as order_detail, get_list as get_order_list, prepare_data as prepare_order_data, buy_now as buy_now_order, cart as cart_order, exchange as exchange_order
from .views.refund_order import detail as order_refund_detail, get_list as get_order_refund_list, apply as apply_order_refund, cancel as cancel_order_refund, submit_express as submit_express_order_refund
from .views.wish import get_list as get_wish_list, get_painting_list as get_painting_list_in_wish_page, submit as submit_wish
from .views.painting_calendar import get_data as get_painting_calendar_data
from .views.banner import get_list as get_banner_list, get_article_content as get_banner_article_content

from .views.admin.admin import login as admin_login, profile as admin_profile, edit_password as admin_edit_password
from .views.admin.user import get_list as admin_get_user_list
from .views.admin.painting import get_list as admin_get_painting_list, get_filter_options as admin_get_filter_options, add as admin_add_painting, edit as admin_edit_painting, detail as admin_get_painting_detail, delete as admin_delete_painting
from .views.admin.posts_category import get_list as admin_get_posts_category_list, add as admin_add_posts_category, edit as admin_edit_posts_category, delete as admin_delete_posts_category
from .views.admin.posts import get_list as admin_get_posts_list, detail as admin_get_posts_detail, get_comment_list as admin_get_comment_list, delete as admin_delete_posts
from .views.admin.goods_category import get_list as admin_get_goods_category_list, add as admin_add_goods_category, edit as admin_edit_goods_category, delete as admin_delete_goods_category
from .views.admin.goods import get_list as admin_get_goods_list, add as admin_add_goods, detail as admin_get_goods_detail, edit as admin_edit_goods, delete as admin_delete_goods
from .views.admin.points_goods_category import get_list as admin_get_points_goods_category_list, add as admin_add_points_goods_category, edit as admin_edit_points_goods_category, delete as admin_delete_points_goods_category
from .views.admin.points_goods import get_list as admin_get_points_goods_list, add as admin_add_points_goods, delete as admin_delete_points_goods, detail as admin_get_points_goods_detail, edit as admin_edit_points_goods
from .views.admin.order import get_list as admin_get_order_list, detail as admin_order_detail, delivery as admin_delivery
from .views.admin.order_refund import get_list as admin_get_order_refund_list, detail as admin_order_refund_detail, first_audit as admin_first_audit_refund, receipt as admin_order_refund_receipt, second_audit as admin_second_audit_refund
from .views.admin.coupon import get_list as admin_get_coupon_list, get_log_list as admin_get_coupon_log_list, add as admin_add_coupon, delete as admin_delete_coupon
from .views.admin.points_task import get_list as admin_get_points_task, add as admin_add_points_task, delete as admin_delete_points_task, detail as admin_get_points_task_detail, edit as admin_edit_points_task
from .views.admin.setting import get_points_config as admin_get_points_config, set_points_config as admin_set_points_config
from .views.admin.freight_temp import get_list as admin_get_freight_temp_list, add as admin_add_freight_temp, detail as admin_freight_temp_detail, edit as admin_edit_freight_temp, delete as admin_delete_freight_temp
from .views.admin.painting_calendar import get_list as admin_get_painting_calendar_list, add as admin_add_painting_calendar, delete as admin_delete_painting_calendar
from .views.admin.banner import get_list as admin_get_banner_list, add as admin_add_banner, delete as admin_delete_banner, get_article_content as admin_banner_get_article_content, set_article_content as admin_banner_set_article_content

from .views.admin.file import upload_file as admin_upload_file
from .views.file import upload_file


urlpatterns = [
    # 后台网页端接口
    path('admin/', include([
        # 登录
        path('login', admin_login),

        # 查询个人资料
        path('profile', admin_profile),

        # 修改密码
        path('editPassword', admin_edit_password),

        # 查询用户列表
        path('user/getList', admin_get_user_list),

        # 查询年画列表
        path('painting/getList', admin_get_painting_list),

        # 查询年画筛选器
        path('painting/getFilterOptions', admin_get_filter_options),

        # 添加年画
        path('painting/add', admin_add_painting),

        # 编辑年画
        path('painting/edit', admin_edit_painting),

        # 年画详情
        path('painting/detail', admin_get_painting_detail),

        # 删除年画
        path('painting/delete', admin_delete_painting),

        # 查询帖子分类列表
        path('postsCategory/getList', admin_get_posts_category_list),

        # 添加帖子分类
        path('postsCategory/add', admin_add_posts_category),

        # 编辑帖子分类
        path('postsCategory/edit', admin_edit_posts_category),

        # 删除帖子分类
        path('postsCategory/delete', admin_delete_posts_category),

        # 查询帖子列表
        path('posts/getList', admin_get_posts_list),

        # 查询帖子详情
        path('posts/detail', admin_get_posts_detail),

        # 查询帖子评论
        path('posts/getCommentList', admin_get_comment_list),

        # 删除帖子
        path('posts/delete', admin_delete_posts),


        # 查询商品分类列表
        path('goodsCategory/getList', admin_get_goods_category_list),

        # 添加商品分类
        path('goodsCategory/add', admin_add_goods_category),

        # 编辑商品分类
        path('goodsCategory/edit', admin_edit_goods_category),

        # 删除商品分类
        path('goodsCategory/delete', admin_delete_goods_category),


        # 查询商品列表
        path('goods/getList', admin_get_goods_list),

        # 添加商品
        path('goods/add', admin_add_goods),

        # 查询商品详情
        path('goods/detail', admin_get_goods_detail),

        # 查询商品评价列表
        path('goods/getCommentList', get_goods_comment_list),

        # 编辑商品
        path('goods/edit', admin_edit_goods),

        # 删除商品
        path('goods/delete', admin_delete_goods),


        # 查询积分商品分类列表
        path('pointsGoodsCategory/getList', admin_get_points_goods_category_list),

        # 添加积分商品分类
        path('pointsGoodsCategory/add', admin_add_points_goods_category),

        # 编辑积分商品分类
        path('pointsGoodsCategory/edit', admin_edit_points_goods_category),

        # 删除积分商品分类
        path('pointsGoodsCategory/delete', admin_delete_points_goods_category),

        # 查询积分商品列表
        path('pointsGoods/getList', admin_get_points_goods_list),

        # 添加积分商品
        path('pointsGoods/add', admin_add_points_goods),

        # 编辑积分商品
        path('pointsGoods/edit', admin_edit_points_goods),

        # 积分商品详情
        path('pointsGoods/detail', admin_get_points_goods_detail),

        # 删除积分商品
        path('pointsGoods/delete', admin_delete_points_goods),

        # 查询订单列表
        path('order/getList', admin_get_order_list),

        # 查询订单详情
        path('order/detail', admin_order_detail),

        # 发货订单
        path('order/delivery', admin_delivery),

        # 查询退款单列表
        path('orderRefund/getList', admin_get_order_refund_list),

        # 查询退款单详情
        path('orderRefund/detail', admin_order_refund_detail),

        # 首次审核退款单（仅退款/退货退款）
        path('orderRefund/firstAudit', admin_first_audit_refund),

        # 平台确认已收到退货（退货退款）
        path('orderRefund/receipt', admin_order_refund_receipt),

        # 二次审核退款单（退货退款）
        path('orderRefund/secondAudit', admin_second_audit_refund),

        # 查询优惠券列表
        path('coupon/getList', admin_get_coupon_list),

        # 查询优惠券领取记录列表
        path('coupon/getLogList', admin_get_coupon_log_list),

        # 添加优惠券
        path('coupon/add', admin_add_coupon),

        # 删除优惠券
        path('coupon/delete', admin_delete_coupon),

        # 查询积分任务列表
        path('pointsTask/getList', admin_get_points_task),

        # 添加积分任务
        path('pointsTask/add', admin_add_points_task),

        # 编辑积分任务
        path('pointsTask/edit', admin_edit_points_task),

        # 积分任务详情
        path('pointsTask/detail', admin_get_points_task_detail),

        # 删除积分任务
        path('pointsTask/delete', admin_delete_points_task),

        # 查询积分基础配置
        path('setting/getPointsConfig', admin_get_points_config),

        # 设置积分基础配置
        path('setting/setPointsConfig', admin_set_points_config),

        # 查询运费模板列表
        path('freightTemp/getList', admin_get_freight_temp_list),

        # 添加运费模板
        path('freightTemp/add', admin_add_freight_temp),

        # 查询运费模板详情
        path('freightTemp/detail', admin_freight_temp_detail),

        # 编辑运费模板
        path('freightTemp/edit', admin_edit_freight_temp),

        # 删除运费模板
        path('freightTemp/delete', admin_delete_freight_temp),

        # 查询年画日历列表
        path('paintingCalendar/getList', admin_get_painting_calendar_list),

        # 添加年画日历
        path('paintingCalendar/add', admin_add_painting_calendar),

        # 删除年画日历
        path('paintingCalendar/delete', admin_delete_painting_calendar),

        # 查询轮播图列表
        path('banner/getList', admin_get_banner_list),

        # 添加轮播图
        path('banner/add', admin_add_banner),

        # 删除轮播图
        path('banner/delete', admin_delete_banner),

        # 查询轮播图文章内容
        path('banner/getArticleContent', admin_banner_get_article_content),

        # 设置轮播图文章内容
        path('banner/setArticleContent', admin_banner_set_article_content),

        # 上传图片/视频
        path('file/upload', admin_upload_file),
    ])),




    # 客户端接口
    path('api/', include([
        # 登录
        path('login', login),

        # 注册
        path('register', register),

        # 获取可选择的标签数据
        path('getTagData', get_tag_data),

        # 提交选择标签
        path('submitTag', submit_tag),

        # 查询个人资料
        path('profile', profile),

        # 完善资料
        path('updateProfile', update_profile),

        # 修改密码
        path('changePassword', change_password),

        # 查询年画筛选器
        path('painting/getFilterOptions', get_filter_options),

        # 随机查询年画列表
        path('painting/getRandomList', get_random_list),

        # 查询年画列表
        path('painting/getList', get_list),

        # 查询年画详情（带评论列表）
        path('painting/detail', detail),

        # 生成AI讲解年画故事
        path('painting/getAiStory', ai_story),

        # 查询年画评论
        path('painting/getCommentList', get_comment_list),

        # 发布年画评论（带检测敏感词）
        path('painting/addComment', add_comment),

        # 删除年画评论
        path('painting/delComment', delete_comment),

        # 评分年画
        path('painting/ratePainting', rate_painting),

        # 收藏年画
        path('painting/favoritePainting', favorite_painting),
        # 取消收藏年画
        path('painting/cancelFavoritePainting', cancel_favorite_painting),

        # 查询我收藏的年画
        path('painting/getMyFavorited', get_my_favorited),

        # 查询我浏览的年画
        path('painting/getMyView', get_my_view),


        # 查询帖子分类
        path('posts/getCategoryList', get_posts_category_list),

        # 查询帖子列表
        path('posts/getList', get_posts_list),

        # 查询帖子详情（带评论列表）
        path('posts/detail', posts_detail),

        # 发布帖子（带检测敏感词）
        path('posts/publish', publish_posts),

        # 删除帖子
        path('posts/delete', delete_posts),

        # 查询帖子评论
        path('posts/getCommentList', get_posts_comment_list),

        # 发布帖子评论（带检测敏感词）
        path('posts/addComment', add_posts_comment),

        # 删除帖子评论
        path('posts/delComment', delete_posts_comment),

        # 点赞帖子
        path('posts/thumb', thumb_posts),

        # 取消点赞帖子
        path('posts/cancelThumb', cancel_thumb_posts),

        # 查询我发布的帖子列表
        path('posts/getMyList', get_my_posts_list),


    # 分割线-----------------------


        # 查询商城分类
        path('goods/getCategoryList', get_goods_category_list),

        # 查询商城商品列表
        path('goods/getList', get_goods_list),

        # 查询商城商品详情
        path('goods/detail', goods_detail),

        # 查询购物车Badge角标数量
        path('cart/getBadge', get_cart_badge),

        # 查询购物车列表
        path('cart/getList', get_cart_list),

        # 把商品加入购物车（数量+1 or add new）
        path('cart/addToCart', add_to_cart),

        # 把商品从购物车移除（数量-1）
        path('cart/deleteItem', delete_cart_item),

        # 查询领券中心
        path('coupon/getList', get_coupon_list),

        # 领取优惠券
        path('coupon/receive', receive_coupon),

        # 查询我领取的优惠券
        path('coupon/getMyList', get_my_coupon_list),


    # 分割线-----------------------


        #AI问答-初始化对话
        path('ai/initChat', init_chat),

        # AI问答-发送
        path('ai/chat', ai_chat),

        # AI年画图片生成页面-生成（数据库保留生成记录）
        path('ai/text2image', text2image),

        # AI图像风格迁移页面-生成（数据库保留生成记录）
        path('ai/imageedit', imageedit),


    # 分割线-----------------------

        # 语音转文字
        path('ai/voiceToText', voice_to_text),


        # 上传图片/视频
        path('file/upload', upload_file),


    # 分割线-----------------------


        # 我的积分页面-查询积分任务+积分记录
        path('points/getMainData', get_points_main_data),

        # 完成积分任务
        path('points/completeTask', complete_points_task),

        # 查询积分商品分类
        path('points/getGoodsCategoryList', get_points_goods_category_list),

        # 查询积分商品列表
        path('points/getGoodsList', get_points_goods_list),

        # 查询积分商品详情
        path('points/goodsDetail', points_goods_detail),

        # 查询积分商品评价列表
        path('points/getGoodsCommentList', get_points_goods_comment_list),


    # 分割线-----------------------

        # 查询我的收货地址列表
        path('address/getList', get_address_list),

        # 添加收货地址列表
        path('address/create', create_address),

        # 查询收货地址详情
        path('address/detail', address_detail),

        # 编辑收货地址列表
        path('address/edit', edit_address),

        # 删除收货地址列表
        path('address/delete', delete_address),


        # 查询下单页面数据（积分抵扣设置+优惠券列表+运费）
        path('order/prepareData', prepare_order_data),

        # 普通商城-立即购买
        path('order/buyNow', buy_now_order),

        # 普通商城-购物车
        path('order/cart', cart_order),

        # 积分商城-兑换商品
        path('order/exchange', exchange_order),

        # 查询我的订单列表
        path('order/getList', get_order_list),

        # 查询我的订单详情（已发货状态带查询物流）
        path('order/detail', order_detail),

        # 确认收货订单
        path('order/receive', receive_order),
        # 评价订单商品
        path('order/commentGoods', comment_order_goods),

        # 申请退款订单或订单商品
        path('orderRefund/apply', apply_order_refund),

        # 取消申请退款订单
        path('orderRefund/cancel', cancel_order_refund),

        # 填写退货快递信息（确认收货后 申请退货退款）
        path('orderRefund/submitExpress', submit_express_order_refund),

        # 查询退款订单列表
        path('orderRefund/getList', get_order_refund_list),

        # 查询退款订单详情
        path('orderRefund/detail', order_refund_detail),

        # 查询许愿列表
        path('wish/getList', get_wish_list),

        # 查询提交许愿页面的随机年画列表
        path('wish/getPaintingList', get_painting_list_in_wish_page),

        # 提交许愿
        path('wish/submit', submit_wish),

        # 提交许愿
        path('paintingCalendar/getData', get_painting_calendar_data),

        # 查询轮播图列表
        path('banner/getList', get_banner_list),

        # 查询轮播图文章内容
        path('banner/getArticleContent', get_banner_article_content),
    ]))
]