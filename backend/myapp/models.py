from django.core.cache import cache
from django.db import models
from django.utils.translation import gettext, gettext_lazy

AUDIO_CHOICES = (
    (1, gettext_lazy('Pending audit')),
    (2, gettext_lazy('Accepted')),
    (3, gettext_lazy('Rejected'))
)

class Banner(models.Model):
    """轮播图表"""
    image_url = models.CharField(
        max_length=255
    )
    article_content = models.TextField(
        default='',
        verbose_name="文章内容",
    )
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_banner'

    def to_dict(self):
        data = {
            'id': self.id,
            'image_url': self.image_url,
            'article_content': self.article_content,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }
        return data

class PaintingCalendar(models.Model):
    """年画日历表"""
    date = models.DateField(
        verbose_name="日期",
        unique=True
    )
    festival_name = models.CharField(
        max_length=100,
        verbose_name="节日名称"
    )
    description = models.TextField(
        default='',
        verbose_name="节日描述",
    )
    painting_id = models.IntegerField(default=0, verbose_name="年画ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_painting_calendar'

    def to_dict(self):
        data = {
            'id': self.id,
            'date': self.date,
            'festival_name': self.festival_name,
            'description': self.description,
            'painting_id': self.painting_id,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }
        return data


class Wish(models.Model):
    TYPE_CHOICES = (
        (1, gettext_lazy("Love")),
        (2, gettext_lazy("Wealth")),
        (3, gettext_lazy("Study")),
        (4, gettext_lazy("Health")),
        (5, gettext_lazy("Family")),
        (6, gettext_lazy("Career"))
        # (1, "桃花运"),
        # (2, "招财进宝"),
        # (3, "学业有成"),
        # (4, "身体健康"),
        # (5, "家庭和睦"),
        # (6, "事业顺利")
    )
    wish_type = models.SmallIntegerField(choices=TYPE_CHOICES, default=0, verbose_name="类型")
    painting_id = models.IntegerField(default=0, verbose_name="年画ID")
    content = models.CharField(max_length=255, verbose_name='许愿内容')
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_wish'

    def to_dict(self):
        data = {
            'id': self.id,
            'wish_type': self.wish_type,
            'wish_type_display': self.get_wish_type_display(),
            'painting_id': self.painting_id,
            'content': self.content,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }
        return data

class AdminUser(models.Model):
    username = models.CharField(max_length=200)
    password = models.CharField(max_length=32)
    is_super = models.PositiveSmallIntegerField(default=0, verbose_name='是否超管')
    token = models.CharField(max_length=32, unique=True)
    is_delete = models.PositiveSmallIntegerField(default=0, verbose_name="是否删除")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_admin_user'

    def to_dict(self):
        data = {
            'id': self.id,
            'username': self.username,
            'is_super': self.is_super
        }
        return data

class PointsGoodsCategory(models.Model):
    name = models.CharField(max_length=50, verbose_name="分类名称")
    create_time = models.DateTimeField(auto_now_add=True)
    class Meta:
        db_table = 'myapp_points_goods_category'

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }

class PointsGoods(models.Model):

    FREIGHT_TYPE_CHOICES = (
        (1, "包邮"),
        (2, "固定邮费"),
        (3, "运费模板")
    )

    category_id = models.IntegerField(verbose_name="分类ID")
    image_urls = models.JSONField(verbose_name="图片url列表")
    name = models.CharField(max_length=255, verbose_name="商品名称")
    detail_url = models.CharField(max_length=255, verbose_name="详情图片url")
    freight_type = models.SmallIntegerField(choices=FREIGHT_TYPE_CHOICES, verbose_name="运费类型")
    freight_price = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name="运费金额，0元包邮")
    freight_temp_id = models.IntegerField(default=0, verbose_name="运费模板ID")
    is_delete = models.PositiveSmallIntegerField(default=0, verbose_name="是否删除")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_points_goods'

    def to_dict(self, include_sku=False):
        data = {
            'id': self.id,
            'category_id': self.category_id,
            'image_urls': self.image_urls,
            'name': self.name,
            'detail_url': self.detail_url,
            'freight_type': self.freight_type,
            'freight_price': self.freight_price,
            'freight_temp_id': self.freight_temp_id,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }

        if include_sku:
            default_sku = PointsGoodsSku.objects.filter(goods_id=self.id).first()
            if default_sku:
                data['sku_info'] = default_sku.to_dict()
            else:
                data['sku_info'] = {
                    'id': 0,
                    'goods_id': self.id,
                    'sku_name': 'Sku',
                    'points': 99999
                }

        return data

class PointsGoodsSku(models.Model):
    goods_id = models.IntegerField(verbose_name="商品ID")
    sku_name = models.CharField(max_length=255, verbose_name="SKU名称")
    point_num = models.PositiveIntegerField(default=0, verbose_name='积分数量')
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_points_goods_sku'

    def to_dict(self):
        return {
            'id': self.id,
            'goods_id': self.goods_id,
            'sku_name': self.sku_name,
            'point_num': self.point_num
        }

class PointsGoodsComment(models.Model):
    goods_id = models.IntegerField(verbose_name="商品ID")
    star_num = models.PositiveSmallIntegerField(default=5, verbose_name="评分")
    content = models.CharField(max_length=255, verbose_name="评论内容")
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True, verbose_name="创建时间")

    class Meta:
        db_table = 'myapp_points_goods_comment'

    def to_dict(self):
        data = {
            'id': self.id,
            'goods_id': self.goods_id,
            'star_num': self.star_num,
            'content': self.content,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime("%Y-%m-%d %H:%M")
        }
        return data



class Order(models.Model):
    """订单表"""
    ORDER_TYPE_CHOICES = (
        (1, gettext_lazy('Shop order')),
        (2, gettext_lazy('Points Shop order')),
    )
    ORDER_STATUS_CHOICES = (
        (1, gettext_lazy('To ship')),
        (2, gettext_lazy('To receive')),
        (3, gettext_lazy('Completed')),
        (4, gettext_lazy('Closed')),
    )
    order_type = models.SmallIntegerField(choices=ORDER_TYPE_CHOICES, verbose_name="订单类型")
    order_no = models.CharField(unique=True, max_length=100, verbose_name="订单号")
    total_price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='总金额（普通商城订单）')
    total_points = models.PositiveIntegerField(default=0, verbose_name='总积分（积分商城积分兑换订单）')
    freight_price = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='运费金额')
    coupon_id = models.IntegerField(default=0, verbose_name="优惠券ID（普通商城订单）")
    coupon_money = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='优惠券抵扣金额（普通商城订单）')
    normal_points = models.PositiveIntegerField(default=0, verbose_name='用户输入普通积分数')
    normal_points_deduct = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='普通积分抵扣金额（普通商城订单）')
    normal_points_per_yuan = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="普通积分抵扣金额(1积分抵多少金额)单位：元"
    )
    cultural_points = models.PositiveIntegerField(default=0, verbose_name='用户输入文化积分数')
    pay_price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='付款金额（普通商城订单）')
    give_normal_points = models.PositiveIntegerField(default=0, verbose_name='平台赠送普通积分（仅普通商城订单;确认收货后发）')
    give_normal_points_granted = models.PositiveSmallIntegerField(default=0, verbose_name="平台赠送普通积分是否已发放")
    delivery_time = models.DateTimeField(null=True, blank=True, verbose_name="发货时间")
    express_name = models.CharField(max_length=255, default='', verbose_name="快递公司名称")
    express_no = models.CharField(max_length=255, default='', verbose_name="快递单号")
    receipt_time = models.DateTimeField(null=True, blank=True, verbose_name="收货时间")
    refund_coupon = models.PositiveSmallIntegerField(default=0, verbose_name="优惠券是否已退还（普通商城订单）")
    refund_normal_points = models.PositiveIntegerField(default=0, verbose_name="已退还普通积分")
    refund_cultural_points = models.PositiveIntegerField(default=0, verbose_name="已退还文化积分")
    order_status = models.SmallIntegerField(choices=ORDER_STATUS_CHOICES, default=1, verbose_name="订单状态")
    # is_comment = models.PositiveSmallIntegerField(default=0, verbose_name="是否已评价")
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_order'

    def to_dict(self):
        return {
            'id': self.id,
            'order_type': self.order_type,
            'order_no': self.order_no,
            'total_price': str(self.total_price),
            'total_points': self.total_points,
            'freight_price': str(self.freight_price),
            'coupon_id': self.coupon_id,
            'coupon_money': str(self.coupon_money),
            'normal_points': self.normal_points,
            'normal_points_deduct': str(self.normal_points_deduct),
            'cultural_points': self.cultural_points,
            # 'cultural_points_yuan': str(self.cultural_points_yuan),
            'pay_price': str(self.pay_price),
            'give_normal_points': self.give_normal_points,
            'give_normal_points_granted': self.give_normal_points_granted,
            'delivery_time': self.delivery_time.strftime('%Y-%m-%d %H:%M') if self.delivery_time else '',
            'express_name': self.express_name,
            'express_no': self.express_no,
            'receipt_time': self.receipt_time.strftime('%Y-%m-%d %H:%M') if self.receipt_time else '',
            'refund_coupon': self.refund_coupon,
            'refund_normal_points': self.refund_normal_points,
            'refund_cultural_points': self.refund_cultural_points,
            'order_status': self.order_status,
            'order_status_display': self.get_order_status_display(),
            # 'is_comment': self.is_comment,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }

class OrderAddress(models.Model):
    """订单收货地址表"""
    order_id = models.IntegerField(verbose_name="订单ID")
    name = models.CharField(max_length=255, verbose_name="姓名")
    phone = models.CharField(max_length=255, verbose_name="手机号")
    province = models.CharField(max_length=255, verbose_name="省")
    province_code = models.CharField(max_length=255, verbose_name="省 code")
    city = models.CharField(max_length=255, verbose_name="市")
    city_code = models.CharField(max_length=255, verbose_name="市 code")
    district = models.CharField(max_length=255, verbose_name="区")
    district_code = models.CharField(max_length=255, verbose_name="区 code")
    detail = models.CharField(max_length=500, verbose_name="详细地址")
    user_id = models.IntegerField(verbose_name="用户ID")

    class Meta:
        db_table = 'myapp_order_address'

    def to_dict(self):
        return {
            'name': self.name,
            'phone': self.phone,
            'province': self.province,
            'city': self.city,
            'city_code': self.city_code,
            'district': self.district,
            'district_code': self.district_code,
            'detail': self.detail
        }

class OrderGoods(models.Model):
    """订单商品表"""
    ORDER_GOODS_STATUS_CHOICES = (
        (1, "正常"),
        (2, "申请退款中"),
        (3, "已退款")
    )
    order_id = models.IntegerField(verbose_name="订单ID")
    goods_id = models.IntegerField(verbose_name="商品ID")
    goods_image_url = models.CharField(max_length=255, verbose_name="商品图片url")
    goods_name = models.CharField(max_length=255, verbose_name="商品名称")
    goods_sku_id = models.IntegerField(verbose_name="商品规格ID")
    goods_sku_name = models.CharField(max_length=255, verbose_name="商品规格名称")
    goods_sku_price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="商品规格价格")
    goods_sku_point_num = models.PositiveIntegerField(default=0, verbose_name='商品规格积分数量')
    buy_num = models.PositiveIntegerField(default=1, verbose_name="购买数量")
    # coupon_deduct = models.DecimalField(
    #     max_digits=10,
    #     decimal_places=2,
    #     default=0,
    #     verbose_name="该商品分摊的优惠券抵扣金额（元）"
    # )
    # normal_points_num = models.PositiveIntegerField(default=0, verbose_name='该商品分摊的普通积分数')
    # normal_points_deduct = models.DecimalField(
    #     max_digits=10,
    #     decimal_places=2,
    #     default=0,
    #     verbose_name="该商品分摊的积分抵扣金额（元）"
    # )
    # total_price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="总金额（优惠券+积分抵扣金额后的商品总金额）")
    freight_price = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name="订单商品运费金额，0元包邮")
    normal_order_allocated_data = models.JSONField(verbose_name="普通商城订单商品分配数据（优惠券金额、积分数、积分金额、最后计算出来的总金额）")
    points_order_allocated_data = models.JSONField(verbose_name="积分商城订单商品分配数据（使用的普通积分，文化积分）")
    status = models.SmallIntegerField(choices=ORDER_GOODS_STATUS_CHOICES, default=1, verbose_name="状态")
    is_comment = models.PositiveSmallIntegerField(default=0, verbose_name="是否已评价")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_order_goods'

    def to_dict(self):
        return {
            'id': self.id,
            'order_id': self.order_id,
            'goods_image_url': self.goods_image_url,
            'goods_name': self.goods_name,
            'goods_sku_name': self.goods_sku_name,
            'goods_sku_price': str(self.goods_sku_price),
            'goods_sku_point_num': self.goods_sku_point_num,
            'buy_num': self.buy_num,
            'freight_price': self.freight_price,
            'normal_order_allocated_data': self.normal_order_allocated_data,
            'points_order_allocated_data': self.points_order_allocated_data,
            'status': self.status,
            'is_comment': self.is_comment
        }

class OrderRefund(models.Model):
    """订单退款表"""
    REFUND_TYPE_CHOICES = (
        (1, gettext_lazy('Only refund')),
        (2, gettext_lazy('Return and refund'))
    )
    STATUS_CHOICES = (
        (1, gettext_lazy('In progress')),
        (2, gettext_lazy('Rejected')),
        (3, gettext_lazy('Completed')),
        (4, gettext_lazy('Cancelled'))
    )
    order_id = models.IntegerField(verbose_name="订单ID")
    order_goods_id = models.IntegerField(default=0, verbose_name="订单商品ID")
    refund_type = models.SmallIntegerField(choices=REFUND_TYPE_CHOICES, verbose_name="退款类型")
    refund_no = models.CharField(unique=True, max_length=100, verbose_name="退款单号")
    apply_desc = models.CharField(max_length=1000, verbose_name="用户申请原因(说明)")
    apply_image_urls = models.JSONField(verbose_name="用户上传的图片")
    audit_status = models.SmallIntegerField(choices=AUDIO_CHOICES, default=1, verbose_name="审核状态")
    audit_time = models.DateTimeField(null=True, blank=True, verbose_name="审核时间")
    is_user_send = models.PositiveSmallIntegerField(default=0, verbose_name="用户是否发货")
    send_time = models.DateTimeField(null=True, blank=True, verbose_name="用户发货时间")
    express_name = models.CharField(max_length=255, default='', verbose_name="用户发货快递公司名称")
    express_no = models.CharField(max_length=255, default='', verbose_name="用户发货快递单号")
    is_receipt = models.PositiveSmallIntegerField(default=0, verbose_name="平台收货状态")
    receipt_time = models.DateTimeField(null=True, blank=True, verbose_name="平台收货时间")
    refund_money = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name="实际退款金额")
    refund_coupon = models.PositiveSmallIntegerField(default=0, verbose_name="本次退款是否退还优惠券")
    refund_normal_points = models.PositiveIntegerField(default=0, verbose_name="退还普通积分数量")
    refund_cultural_points = models.PositiveIntegerField(default=0, verbose_name="退还文化积分数量")
    status = models.SmallIntegerField(choices=STATUS_CHOICES, default=1, verbose_name="售后单状态")
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_order_refund'

    def to_dict(self):
        return {
            'id': self.id,
            'order_id': self.order_id,
            'order_goods_id': self.order_goods_id,
            'refund_type': self.refund_type,
            'refund_type_display': self.get_refund_type_display(),
            'refund_no': self.refund_no,
            'apply_desc': self.apply_desc,
            'apply_image_urls': self.apply_image_urls,
            'audit_status': self.audit_status,
            'audit_status_display': self.get_audit_status_display(),
            'is_user_send': self.is_user_send,
            'send_time': self.send_time.strftime('%Y-%m-%d %H:%M') if self.send_time else '',
            'express_name': self.express_name,
            'express_no': self.express_no,
            'is_receipt': self.is_receipt,
            'refund_money': str(self.refund_money),
            'refund_coupon': self.refund_coupon,
            'refund_normal_points': self.refund_normal_points,
            'refund_cultural_points': self.refund_cultural_points,
            'status': self.status,
            'status_display': self.get_status_display(),
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }


class FreightTemp(models.Model):
    """运费模板表"""
    name = models.CharField(max_length=100, verbose_name="规则名称")
    is_delete = models.PositiveSmallIntegerField(default=0, verbose_name="是否删除")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_freight_temp'

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M'),
            # 'regions': [region.to_dict() for region in self.freight_temp_regions.all()]
        }

class FreightTempRegion(models.Model):
    """运费模板 - 配送区域关联表"""
    freight_temp = models.ForeignKey(
        FreightTemp,
        on_delete=models.CASCADE,
        related_name='freight_temp_regions',
        verbose_name="所属运费模板"
    )
    region_name = models.CharField(max_length=255, verbose_name="区域名称")
    is_default = models.PositiveSmallIntegerField(default=0, verbose_name="是否为默认全国规则")
    # is_default = models.BooleanField(default=False, verbose_name="是否为默认全国规则")
    province_code = models.TextField(verbose_name="省编码，多个用;分隔", blank=True)
    city_code = models.TextField(verbose_name="市编码，多个用;分隔", blank=True)
    first = models.PositiveIntegerField(default=0, verbose_name="首件")
    first_price = models.DecimalField(max_digits=10, decimal_places=2, default=0.00, verbose_name='首件运费')
    continue_num = models.PositiveIntegerField(default=0, verbose_name="续件")
    continue_price = models.DecimalField(max_digits=10, decimal_places=2, default=0.00, verbose_name='续件运费')

    class Meta:
        db_table = 'myapp_freight_temp_region'

    def to_dict(self):
        return {
            'id': self.id,
            'region_name': self.region_name,
            'is_default': self.is_default,
            'province_code': self.province_code,
            'city_code': self.city_code,
            'first': self.first,
            'first_price': str(self.first_price),
            'continue_num': self.continue_num,
            'continue_price': str(self.continue_price)
        }
# class FreightTemp(models.Model):
#     """运费模板表"""
#     name = models.CharField(max_length=100, verbose_name="规则名称")
#     province_code = models.CharField(max_length=255, verbose_name="省 code")
#     city_code = models.CharField(max_length=255, verbose_name="市 code")
#     first = models.PositiveIntegerField(default=0, verbose_name="首件")
#     first_price = models.DecimalField(max_digits=10, decimal_places=2, default=0.00, verbose_name='首件运费')
#     continue_num = models.PositiveIntegerField(default=0, verbose_name="续件")
#     continue_price = models.DecimalField(max_digits=10, decimal_places=2, default=0.00, verbose_name='续件运费')
#     is_delete = models.PositiveSmallIntegerField(default=0, verbose_name="是否删除")
#     create_time = models.DateTimeField(auto_now_add=True)
#     update_time = models.DateTimeField(auto_now=True)
#
#     class Meta:
#         db_table = 'myapp_freight_temp'
#
#     def to_dict(self):
#         return {
#             'id': self.id,
#             'name': self.name,
#             'province_code': self.province_code,
#             'city_code': self.city_code,
#             'first': self.first,
#             'first_price': str(self.first_price),
#             'continue_num': self.continue_num,
#             'continue_price': str(self.continue_price),
#             'is_delete': self.is_delete,
#             'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
#         }


class PointsConfig(models.Model):
    """积分基础配置表"""
    order_fixed_points = models.PositiveIntegerField(default=0, verbose_name="每笔订单赠送积分")
    normal_points_max_num = models.PositiveIntegerField(default=200, verbose_name="普通商城订单最多可使用普通积分数")
    normal_points_per_yuan = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="普通积分抵扣金额(1积分抵多少金额)单位：元"
    )
    # cultural_points_per_yuan = models.DecimalField(
    #     max_digits=10,
    #     decimal_places=2,
    #     default=0.00,
    #     verbose_name="文化积分抵扣金额(1积分抵多少金额)单位：元"
    # )
    class Meta:
        db_table = 'myapp_points_config'

    # def to_dict(self):
    #     return {
    #         'order_fixed_points': self.order_fixed_points,
    #         'normal_points_per_yuan': str(self.normal_points_per_yuan),
    #         'cultural_points_per_yuan': str(self.cultural_points_per_yuan),
    #     }

class PointsTask(models.Model):
    """积分任务表"""
    TASK_TYPE_CHOICES = (
        (1, "浏览年画"),
        (2, "收藏年画"),
        (3, "评论年画")
    )

    task_type = models.SmallIntegerField(choices=TASK_TYPE_CHOICES, verbose_name="任务类型")
    painting_id = models.IntegerField(default=0, verbose_name="年画ID")
    daily_limit = models.PositiveIntegerField(default=0, verbose_name="每日次数限制")
    point_reward = models.PositiveIntegerField(verbose_name="单次积分奖励")
    is_delete = models.PositiveSmallIntegerField(default=0, verbose_name="是否删除")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_points_task'

    def to_dict(self):
        return {
            'id': self.id,
            'task_type': self.task_type,
            'task_type_display': self.get_task_type_display(),
            'painting_id': self.painting_id,
            'daily_limit': self.daily_limit,
            'point_reward': self.point_reward,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }


class Coupon(models.Model):
    name = models.CharField(max_length=255, verbose_name="优惠券名称")
    reduce_price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="减免金额")
    min_price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="最低消费金额")
    total_num = models.PositiveIntegerField(default=0, verbose_name="发放数量")
    receive_num = models.PositiveIntegerField(default=0, verbose_name="已领取数量")
    expire_day = models.PositiveIntegerField(default=0, verbose_name="领取后有效期天数")
    is_delete = models.PositiveSmallIntegerField(default=0, verbose_name="是否删除")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_coupon'

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'reduce_price': str(self.reduce_price),
            'min_price': str(self.min_price),
            'total_num': self.total_num,
            'receive_num': self.receive_num,
            'expire_day': self.expire_day,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }

class GoodsCategory(models.Model):
    name = models.CharField(max_length=50, verbose_name="分类名称")
    create_time = models.DateTimeField(auto_now_add=True)
    class Meta:
        db_table = 'myapp_goods_category'

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }

class Goods(models.Model):

    FREIGHT_TYPE_CHOICES = (
        (1, "包邮"),
        (2, "固定邮费"),
        (3, "运费模板")
    )

    category_id = models.IntegerField(verbose_name="分类ID")
    image_urls = models.JSONField(verbose_name="图片url列表")
    name = models.CharField(max_length=255, verbose_name="商品名称")
    detail_url = models.CharField(max_length=255, verbose_name="详情图片url")
    freight_type = models.SmallIntegerField(choices=FREIGHT_TYPE_CHOICES, verbose_name="运费类型")
    freight_price = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name="运费金额，0元包邮")
    freight_temp_id = models.IntegerField(default=0, verbose_name="运费模板ID")
    is_delete = models.PositiveSmallIntegerField(default=0, verbose_name="是否删除")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    def to_dict(self, include_sku=False):
        data = {
            'id': self.id,
            'category_id': self.category_id,
            'image_urls': self.image_urls,
            'name': self.name,
            'detail_url': self.detail_url,
            'freight_type': self.freight_type,
            'freight_price': self.freight_price,
            'freight_temp_id': self.freight_temp_id,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }

        if include_sku:
            default_sku = GoodsSku.objects.filter(goods_id=self.id).first()
            if default_sku:
                data['sku_info'] = default_sku.to_dict()
            else:
                data['sku_info'] = {
                    'id': 0,
                    'goods_id': self.id,
                    'sku_name': 'Sku',
                    'price': 99999,
                    'line_price': 99999
                }

        return data

class GoodsSku(models.Model):
    goods_id = models.IntegerField(verbose_name="商品ID")
    sku_name = models.CharField(max_length=255, verbose_name="SKU名称")
    price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="价格")
    line_price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="划线价格")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'myapp_goods_sku'

    def to_dict(self):
        return {
            'id': self.id,
            'goods_id': self.goods_id,
            'sku_name': self.sku_name,
            'price': str(self.price),
            'line_price': str(self.line_price)
        }

class GoodsComment(models.Model):
    goods_id = models.IntegerField(verbose_name="商品ID")
    star_num = models.PositiveSmallIntegerField(default=5, verbose_name="评分")
    content = models.CharField(max_length=255, verbose_name="评论内容")
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True, verbose_name="创建时间")

    class Meta:
        db_table = 'myapp_goods_comment'

    def to_dict(self):
        data = {
            'id': self.id,
            'goods_id': self.goods_id,
            'star_num': self.star_num,
            'content': self.content,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime("%Y-%m-%d %H:%M")
        }
        return data

class GoodsCart(models.Model):
    goods_id = models.IntegerField(verbose_name="商品ID")
    goods_sku_id = models.IntegerField(verbose_name="商品SKU ID")
    buy_num = models.PositiveIntegerField(default=1, verbose_name="购买数量")
    user_id = models.IntegerField(verbose_name="用户ID")

    class Meta:
        db_table = 'myapp_goods_cart'
        unique_together = ('goods_id', 'goods_sku_id', 'user_id')

    def to_dict(self):
        data = {
            'id': self.id,
            'goods_id': self.goods_id,
            'goods_sku_id': self.goods_sku_id,
            'buy_num': self.buy_num,
            'user_id': self.user_id
        }
        return data


class PostsCategory(models.Model):
    """帖子分类表"""
    name = models.CharField(max_length=50, verbose_name="分类名称")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_posts_category'

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name
        }

class Posts(models.Model):
    """帖子表"""

    POST_TYPE_CHOICES = (
        (10, "普通帖子"),
        (20, "我的年画故事"),
    )

    category_id = models.IntegerField(verbose_name="分类ID")
    title = models.CharField(max_length=255, verbose_name="标题")
    content = models.CharField(max_length=1000, verbose_name="内容")
    image_urls = models.JSONField(verbose_name="图片URL列表")
    tags = models.JSONField(verbose_name="标签列表")
    type = models.PositiveSmallIntegerField(choices=POST_TYPE_CHOICES, default=0, verbose_name="类型")
    painting_id = models.IntegerField(default=0, verbose_name="年画ID")
    painting_name = models.CharField(max_length=255, default="", verbose_name="年画名称")
    painting_image_url = models.CharField(max_length=255, default="", verbose_name="年画图片URL")
    video_url = models.CharField(max_length=255, default="", verbose_name="视频URL")
    video_cover_url = models.CharField(max_length=255, default="", verbose_name="视频封面图片URL")
    view_count = models.PositiveIntegerField(default=0, verbose_name="浏览次数")
    user_id = models.IntegerField(verbose_name="用户ID")
    is_delete = models.PositiveSmallIntegerField(default=0, verbose_name="是否删除")
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    def to_dict(self):
        return {
            'id': self.id,
            'category_id': self.category_id,
            'title': self.title,
            'content': self.content,
            'image_urls': self.image_urls,
            'tags': self.tags,
            'type': self.type,
            # 'type_display': self.get_type_display(),
            'painting_id': self.painting_id,
            'painting_name': self.painting_name,
            'painting_image_url': self.painting_image_url,
            'video_url': self.video_url,
            'video_cover_url': self.video_cover_url,
            'view_count': self.view_count,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }

class PostsComment(models.Model):
    """帖子评论表"""
    posts_id = models.IntegerField(verbose_name="帖子ID")
    content = models.CharField(max_length=255, verbose_name="评论内容")
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_posts_comment'

    def to_dict(self):
        return {
            'id': self.id,
            'posts_id': self.posts_id,
            'content': self.content,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }

class PostsThumb(models.Model):
    """帖子点赞表"""
    posts_id = models.IntegerField(verbose_name="帖子ID")
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_posts_thumb'
        unique_together = ('posts_id', 'user_id')

    def to_dict(self):
        return {
            'id': self.id,
            'posts_id': self.posts_id,
            'user_id': self.user_id
        }


class PaintingStyle(models.Model):
    """年画风格表，用于根据风格查询年画"""
    name = models.CharField(max_length=50, verbose_name="风格名称")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_painting_style'

    def to_dict(self):
        data = {
            'id': self.id,
            'name': self.name
        }
        return data

class PaintingTheme(models.Model):
    """年画题材表，用于根据题材查询年画"""
    name = models.CharField(max_length=50, verbose_name="题材名称")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_painting_theme'

    def to_dict(self):
        data = {
            'id': self.id,
            'name': self.name
        }
        return data

class PaintingDynasty(models.Model):
    """年画年代表，用于根据年代查询年画"""
    name = models.CharField(max_length=50, verbose_name="年代名称")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_painting_dynasty'

    def to_dict(self):
        data = {
            'id': self.id,
            'name': self.name
        }
        return data

class PaintingAuthor(models.Model):
    """年画作者表，用于根据作者查询年画"""
    name = models.CharField(max_length=50, verbose_name="作者姓名")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_painting_author'

    def to_dict(self):
        data = {
            'id': self.id,
            'name': self.name
        }
        return data

class Painting(models.Model):
    image_url = models.CharField(max_length=255, verbose_name='年画图片URL')
    bg_mp3_url = models.CharField(max_length=255, default='', verbose_name='背景MP3音乐URL')
    name = models.CharField(max_length=255, verbose_name='年画名称')
    style_id = models.IntegerField(default=0, verbose_name='风格ID')
    theme_id = models.IntegerField(default=0, verbose_name='题材ID')
    dynasty_id = models.IntegerField(default=0, verbose_name='年代ID')
    author_id = models.IntegerField(default=0, verbose_name='作者ID')
    # style = models.CharField(max_length=255, default='none', verbose_name='风格')
    # theme = models.CharField(max_length=255, default='none', verbose_name='题材')
    # dynasty = models.CharField(max_length=255, default='none', verbose_name='年代')
    # author = models.CharField(max_length=255, default='none', verbose_name='作者')
    content = models.CharField(max_length=500, verbose_name='内容')
    is_delete = models.PositiveSmallIntegerField(default=0, verbose_name='是否删除')
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    def to_dict(self, exclude_fields=None):
        if exclude_fields is None:
            exclude_fields = []

        default_fields = [
            'id', 'image_url', 'bg_mp3_url', 'name',
            'style_id', 'theme_id', 'dynasty_id', 'author_id',
            'content', 'create_time'
        ]

        # 过滤需要排除的字段
        fields = [field for field in default_fields if field not in exclude_fields]

        data = {}
        for field in fields:
            if field == 'create_time':
                data[field] = getattr(self, field).strftime('%Y-%m-%d %H:%M')
            else:
                data[field] = getattr(self, field)

        if 'style' not in exclude_fields:
            if self.style_id > 0:
                name = cache.get(f"painting_style:{self.style_id}")
                if name is None:
                    try:
                        style = PaintingStyle.objects.get(id=self.style_id)
                        data['style'] = style.name
                        cache.set(f"painting_style:{self.style_id}", style.name, 300)
                    except PaintingStyle.DoesNotExist:
                        data['style'] = '未知'
                else:
                    data['style'] = name
            else:
                data['style'] = '未知'

        if 'theme' not in exclude_fields:
            if self.theme_id > 0:
                name = cache.get(f"painting_theme:{self.theme_id}")
                if name is None:
                    try:
                        theme = PaintingTheme.objects.get(id=self.theme_id)
                        data['theme'] = theme.name
                        cache.set(f"painting_theme:{self.theme_id}", theme.name, 300)
                    except PaintingTheme.DoesNotExist:
                        data['theme'] = '未知'
                else:
                    data['theme'] = name
            else:
                data['theme'] = '未知'

        if 'dynasty' not in exclude_fields:
            if self.dynasty_id > 0:
                name = cache.get(f"painting_dynasty:{self.dynasty_id}")
                if name is None:
                    try:
                        dynasty = PaintingDynasty.objects.get(id=self.dynasty_id)
                        data['dynasty'] = dynasty.name
                        cache.set(f"painting_dynasty:{self.dynasty_id}", dynasty.name, 300)
                    except PaintingDynasty.DoesNotExist:
                        data['dynasty'] = '未知'
                else:
                    data['dynasty'] = name
            else:
                data['dynasty'] = '未知'

        if 'author' not in exclude_fields:
            if self.author_id > 0:
                name = cache.get(f"painting_author:{self.author_id}")
                if name is None:
                    try:
                        author = PaintingAuthor.objects.get(id=self.author_id)
                        data['author'] = author.name
                        cache.set(f"painting_author:{self.author_id}", author.name, 300)
                    except PaintingAuthor.DoesNotExist:
                        data['author'] = '未知'
                else:
                    data['author'] = name
            else:
                data['author'] = '未知'

        return data

class PaintingComment(models.Model):
    painting_id = models.IntegerField(verbose_name='年画ID')
    content = models.CharField(max_length=255, verbose_name='评论内容')
    user_id = models.IntegerField(verbose_name='用户ID')
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_painting_comment'

    def to_dict(self):
        data = {
            'id': self.id,
            'painting_id': self.painting_id,
            'content': self.content,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }
        return data

class PaintingStar(models.Model):
    painting_id = models.IntegerField(verbose_name='年画ID')
    star_count = models.PositiveSmallIntegerField(default=5, verbose_name='评分')
    user_id = models.IntegerField(verbose_name='用户ID')
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_painting_star'
        unique_together = ('painting_id', 'user_id')


class User(models.Model):
    phone = models.CharField(max_length=200, default='')
    email = models.CharField(max_length=200, default='')
    password = models.CharField(max_length=32)
    avatar_url = models.CharField(max_length=255, default='')
    avatar_file_id = models.IntegerField(default=0)
    nickname = models.CharField(max_length=255, default='')
    gender = models.PositiveSmallIntegerField(default=0, choices=(
        (0, '男'),
        (1, '女'),
    ), verbose_name='性别')
    birthday = models.CharField(max_length=255, default='', verbose_name='出生日期')
    # birthday = models.DateTimeField(null=True, blank=True, verbose_name='出生日期')
    profession = models.CharField(max_length=255, default='', verbose_name='职业')
    # normal_integral = models.PositiveIntegerField(default=0, verbose_name='普通积分')
    # cultural_integral = models.PositiveIntegerField(default=0, verbose_name='文化积分')
    normal_points = models.PositiveIntegerField(default=0, verbose_name='普通积分')
    cultural_points = models.PositiveIntegerField(default=0, verbose_name='文化积分')
    token = models.CharField(max_length=32, unique=True)
    is_delete = models.PositiveSmallIntegerField(default=0, verbose_name='是否删除')
    create_time = models.DateTimeField(auto_now_add=True)
    update_time = models.DateTimeField(auto_now=True)

    def to_dict(self):
        data = {
            'id': self.id,
            'phone': self.phone,
            'email': self.email,
            'avatar_url': self.avatar_url,
            'avatar_file_id': self.avatar_file_id,
            'nickname': self.nickname,
            'gender': self.gender,
            'birthday': self.birthday,
            # 'birthday': self.birthday.strftime('%Y-%m-%d') if self.birthday else '',
            'profession': self.profession,
            'normal_points': self.normal_points,
            'cultural_points': self.cultural_points,
            'create_time': self.create_time.strftime('%Y-%m-%d')
            # 'create_time': self.create_time.isoformat() if self.create_time else None,
        }
        return data

class UserTag(models.Model):
    tag_group_id = models.IntegerField()
    tag_id = models.IntegerField()
    user_id = models.IntegerField()

    class Meta:
        db_table = 'myapp_user_tag'

class UserPointsLog(models.Model):
    SCENE_BROWSE = 10
    SCENE_FAVORITE = 20
    SCENE_COMMENT = 30
    SCENE_ORDER = 40
    SCENE_POINT_ORDER = 50
    SCENE_GIVE = 60
    SCENE_REFUND = 70
    SCENE_CHOICES = (
        (SCENE_BROWSE, gettext_lazy('Browse painting')),
        (SCENE_FAVORITE, gettext_lazy('Favorite painting')),
        (SCENE_COMMENT, gettext_lazy('Comment painting')),
        (SCENE_ORDER, gettext_lazy('Use points for order')),
        (SCENE_POINT_ORDER, gettext_lazy('Use points for order')),
        (SCENE_GIVE, gettext_lazy('Gives points')),
        (SCENE_REFUND, gettext_lazy('Refund points'))
        # (SCENE_BROWSE, '浏览年画'),
        # (SCENE_COLLECT, '收藏年画'),
        # (SCENE_COMMENT, '评论年画'),
        # (SCENE_ORDER, '下单普通商城商品使用积分'),
        # (SCENE_POINT_ORDER, '兑换积分商城商品使用积分'),
        # (SCENE_GIVE, '下单普通商城商品平台赠送积分'),
        # (SCENE_REFUND, '订单退回积分')
    )

    POINT_TYPE_NORMAL = 10
    POINT_TYPE_CULTURAL = 20
    POINT_TYPE_CHOICES = (
        (POINT_TYPE_NORMAL, '普通积分'),
        (POINT_TYPE_CULTURAL, '文化积分'),
    )

    scene = models.PositiveSmallIntegerField(
        default=0,
        choices=SCENE_CHOICES,
        verbose_name='场景'
    )
    point_type = models.PositiveSmallIntegerField(
        default=0,
        choices=POINT_TYPE_CHOICES,
        verbose_name='积分类型'
    )
    point_num = models.PositiveIntegerField(default=0, verbose_name='积分数量')
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_user_points_log'

    def to_dict(self):
        return {
            'scene': self.scene,
            'scene_display': self.get_scene_display(),
            'integral_type': self.point_type,
            # 'integral_type_display': self.get_integral_type_display(),
            'integral_num': self.point_num,
            'create_time': self.create_time.strftime('%Y-%m-%d %H:%M')
        }

class UserPointsTaskProgress(models.Model):
    """用户积分任务进度表"""
    task_id = models.IntegerField(default=0, verbose_name="任务ID")
    task_type = models.PositiveSmallIntegerField(
        choices=PointsTask.TASK_TYPE_CHOICES,
        verbose_name="任务类型"
    )
    progress_date = models.DateField(verbose_name="进度日期")
    today_count = models.PositiveIntegerField(default=0, verbose_name="今日已完成次数")
    last_complete_time = models.DateTimeField(null=True, blank=True, verbose_name="最后完成时间")
    painting_ids = models.JSONField(verbose_name="年画ID列表")
    user_id = models.IntegerField(default=0, verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_user_points_task_progress'
        unique_together = ('user_id', 'task_id', 'progress_date')

    def to_dict(self):
        return {
            'id': self.id,
            'task_id': self.task_id,
            'today_count': self.today_count,
            'last_complete_time': self.last_complete_time
        }


class UserFavorite(models.Model):
    painting_id = models.IntegerField()
    user_id = models.IntegerField()
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_user_favorite'
        unique_together = ('painting_id', 'user_id')

class UserView(models.Model):
    painting_id = models.IntegerField()
    user_id = models.IntegerField()
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_user_view'
        unique_together = ('painting_id', 'user_id')


class UserAddress(models.Model):
    name = models.CharField(max_length=255, verbose_name="姓名")
    phone = models.CharField(max_length=255, verbose_name="手机号")
    province = models.CharField(max_length=255, verbose_name="省")
    province_code = models.CharField(max_length=255, verbose_name="省 code")
    city = models.CharField(max_length=255, verbose_name="市")
    city_code = models.CharField(max_length=255, verbose_name="市 code")
    district = models.CharField(max_length=255, verbose_name="区")
    district_code = models.CharField(max_length=255, verbose_name="区 code")
    detail = models.CharField(max_length=500, verbose_name="详细地址")
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_user_address'

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'phone': self.phone,
            'province': self.province,
            'province_code': self.province_code,
            'city': self.city,
            'city_code': self.city_code,
            'district': self.district,
            'district_code': self.district_code,
            'detail': self.detail
        }

class UserCoupon(models.Model):
    coupon_id = models.IntegerField(verbose_name="优惠券ID")
    coupon_name = models.CharField(max_length=255, verbose_name="优惠券名称")
    reduce_price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="减免金额")
    min_price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name="最低消费金额")
    expire_day = models.PositiveIntegerField(default=0, verbose_name="领取后有效期天数")
    start_time = models.DateTimeField(verbose_name="有效期开始时间")
    end_time = models.DateTimeField(verbose_name="有效期结束时间")
    is_use = models.PositiveSmallIntegerField(default=0, verbose_name='是否使用')
    use_time = models.DateTimeField(null=True, blank=True, verbose_name="使用时间")
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_user_coupon'
        unique_together = ('user_id', 'coupon_id')

    def to_dict(self):
        return {
            'id': self.id,
            'coupon_id': self.coupon_id,
            'coupon_name': self.coupon_name,
            'reduce_price': str(self.reduce_price),
            'min_price': str(self.min_price),
            'expire_day': self.expire_day,
            'start_time': self.create_time.strftime('%Y-%m-%d %H:%M') if self.create_time else '',
            'end_time': self.create_time.strftime('%Y-%m-%d %H:%M') if self.create_time else '',
            'is_use': self.is_use,
            'use_time': self.use_time.strftime('%Y-%m-%d %H:%M') if self.is_use == 1 else '',
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d')
        }


class UserAISession(models.Model):
    session_id = models.CharField(unique=True, max_length=255, verbose_name="会话ID")
    user_id = models.IntegerField(verbose_name="用户ID")
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        db_table = 'myapp_user_ai_session'

class UserAIMessage(models.Model):
    role = models.CharField(max_length=50, verbose_name='角色')
    image_url = models.CharField(max_length=255, default='', verbose_name='图片URL')
    text = models.TextField(verbose_name='内容')
    session_id = models.CharField(max_length=255, verbose_name="会话ID")
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_user_ai_message'

    def to_dict(self):
        return {
            'id': self.id,
            'role': self.role,
            'image_url': self.image_url,
            'text': self.text,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d')
        }

class UserAIText2Image(models.Model):
    task_id = models.CharField(max_length=255, verbose_name="任务ID")
    prompt = models.CharField(max_length=500, verbose_name='提示词')
    status = models.CharField(max_length=50, verbose_name='生成状态')
    image_url = models.CharField(max_length=255, verbose_name='图片URL')
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_user_ai_text2image'

    def to_dict(self):
        return {
            'id': self.id,
            'prompt': self.prompt,
            'status': self.status,
            'image_url': self.image_url,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d')
        }

class UserAIImageEdit(models.Model):
    task_id = models.CharField(max_length=255, verbose_name="任务ID")
    prompt = models.CharField(max_length=500, verbose_name='提示词')
    status = models.CharField(max_length=50, verbose_name='生成状态')
    original_url = models.CharField(max_length=255, verbose_name='原始图片URL')
    image_url = models.CharField(max_length=255, verbose_name='图片URL')
    user_id = models.IntegerField(verbose_name="用户ID")
    create_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'myapp_user_ai_imageedit'

    def to_dict(self):
        return {
            'id': self.id,
            'prompt': self.prompt,
            'status': self.status,
            'original_url': self.original_url,
            'image_url': self.image_url,
            'user_id': self.user_id,
            'create_time': self.create_time.strftime('%Y-%m-%d')
        }

class TagGroup(models.Model):
    cn_name = models.CharField(max_length=255, verbose_name="标签名称")
    en_name = models.CharField(max_length=255, verbose_name="标签名称（英文）")

    class Meta:
        db_table = 'myapp_tag_group'

    def to_dict(self):
        return {
            'id': self.id,
            'cn_name': self.cn_name,
            'en_name': self.en_name
        }
class Tag(models.Model):
    group_id = models.IntegerField(verbose_name="分组ID")
    cn_name = models.CharField(max_length=255, verbose_name="标签名称")
    en_name = models.CharField(max_length=255, verbose_name="标签名称（英文）")

    class Meta:
        db_table = 'myapp_tag'

    def to_dict(self):
        return {
            'id': self.id,
            'group_id': self.group_id,
            'cn_name': self.cn_name,
            'en_name': self.en_name
        }


# def upload_to(instance, filename):
#     return f'uploads/{filename}'
class MediaFile(models.Model):
    user_id = models.IntegerField()
    file = models.FileField()
    # file = models.FileField(upload_to=upload_to)
    uploaded_at = models.DateTimeField(auto_now_add=True)
