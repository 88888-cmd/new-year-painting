import json
import uuid
import decimal
from typing import List, Dict, Any
import requests

from django.utils import timezone
from django.views.decorators.http import require_GET, require_POST
from django.db import transaction
from django.db.models import F
from django.conf import settings
from django.utils.translation import gettext, gettext_lazy

from ..models import User, UserCoupon, UserAddress, UserPointsLog, Goods, GoodsSku, GoodsCart, GoodsComment, PointsGoods, PointsGoodsComment, PointsGoodsSku, PointsConfig, FreightTemp, Order, OrderAddress, OrderGoods, OrderRefund
from api_r import APIResponse
from myapp.utils import check_amount

@require_POST
def comment(request):
    body = json.loads(request.body)

    order_id = int(body.get('order_id', 0))
    order_goods_id = int(body.get('order_goods_id', 0))
    star_num = body.get('star_num', 5)
    content = body.get('content', '')

    try:
        order = Order.objects.get(id=order_id, user_id=request.user.id)
        order_goods = OrderGoods.objects.get(id=order_goods_id, order_id=order.id)
    except Order.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    if order_goods.is_comment:
        return APIResponse(code=1, msg=gettext_lazy('Please refresh the page and try again'))

    OrderGoods.objects.filter(id=order_goods_id).update(is_comment=1)

    if order.order_type == 1:
        GoodsComment.objects.create(
            goods_id=order_goods.goods_id,
            star_num=star_num,
            content=content,
            user_id=request.user.id
        )
    else:
        PointsGoodsComment.objects.create(
            goods_id=order_goods.goods_id,
            star_num=star_num,
            content=content,
            user_id=request.user.id
        )

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))


@require_POST
def receive(request):
    body = json.loads(request.body)

    order_id = int(body.get('order_id', 0))

    try:
        Order.objects.get(id=order_id, user_id=request.user.id)
    except Order.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    try:
        with transaction.atomic():
            order = Order.objects.select_for_update().get(
                id=order_id
            )
            if order.order_status != 2:
                raise ValueError(gettext_lazy('Query successful'))

            has_refunding = OrderRefund.objects.filter(
                order_id=order_id,
                status=1
            ).exists()
            if has_refunding:
                raise ValueError('该订单存在未处理的售后')

            order.receipt_time = timezone.now()
            order.order_status = 3
            order.save()

            if order.give_normal_points > 0 and order.give_normal_points_granted == 0:
                updated_give_points = User.objects.filter(
                    id=request.user.id,
                    is_delete=0
                ).update(normal_points=F('normal_points') + order.give_normal_points)
                if not updated_give_points:
                    raise ValueError(gettext_lazy('Operation failed'))

                UserPointsLog.objects.create(
                    scene=UserPointsLog.SCENE_GIVE,
                    point_type=UserPointsLog.POINT_TYPE_NORMAL,
                    point_num=order.give_normal_points,
                    user_id=request.user.id,
                )
                order.give_normal_points_granted = 1
                order.save()

    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception:
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))


@require_GET
def detail(request):
    order_id = int(request.GET.get('order_id'))

    try:
        order = Order.objects.get(id=order_id, user_id=request.user.id)
        address = OrderAddress.objects.get(order_id=order.id)
        order_goods_list = OrderGoods.objects.filter(order_id=order.id)
    except (Order.DoesNotExist, OrderAddress.DoesNotExist):
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    wuliu = []
    # 查物流
    if order.order_status == 2 and order.express_no:
        url = 'https://wuliu.market.alicloudapi.com/kdi'
        url += "?no=" + order.express_no
        try:
            res = requests.get(url, headers={
                'Authorization': f'APPCODE {settings.ALI_WULIU_APPCODE}'
            })
            if res.status_code == 200:
                wuliu = res.json().get('result').get('list')
        except Exception as e:
            print(e)

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
        'order': order.to_dict(),
        'address': address.to_dict(),
        'order_goods_list': [order_goods.to_dict() for order_goods in order_goods_list],
        'wuliu': wuliu
    })


@require_GET
def get_list(request):
    status = int(request.GET.get('status'))
    data_v = int(request.GET.get('data_v', 1))

    if status not in (0 ,1, 2, 3):
        return APIResponse(code=1, msg=gettext_lazy('Query failed'))
    if status == 0:
        orders = Order.objects.filter(user_id=request.user.id).order_by('-id')
    elif status in (1, 2, 3):
        orders = Order.objects.filter(user_id=request.user.id).filter(order_status=status).order_by('-id')
    # elif status == 4:
    #     orders = Order.objects.filter(user_id=request.user.id).filter(order_status=3, is_comment=0).order_by('-id')
    # order_list = [order.to_dict() for order in orders]
    order_list = []
    for order in orders:
        order_goods_list = [order_goods.to_dict() for order_goods in OrderGoods.objects.filter(order_id=order.id)]
        order_list.append({**order.to_dict(), **{
            'order_goods_list': order_goods_list
        }})

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
        'list': order_list,
        'data_v': data_v
    })


@require_POST
def prepare_data(request):
    body = json.loads(request.body)

    address_id = int(body.get('address_id', 0))
    source = body.get('source', '')

    if address_id:
        address = UserAddress.objects.get(id=address_id, user_id=request.user.id)

    # 获取用户优惠券列表（未使用、未过期）
    now = timezone.now()
    user_coupons = [coupon.to_dict() for coupon in UserCoupon.objects.filter(
        user_id=request.user.id,
        is_use=0,
        end_time__gt=now
    )]

    points_config = PointsConfig.objects.first()
    points_config_dict = {
        'order_fixed_points': points_config.order_fixed_points if points_config else 0,
        'normal_points_max_num': points_config.normal_points_max_num if points_config else 200,
        'normal_points_per_yuan': points_config.normal_points_per_yuan if points_config else decimal.Decimal('0.00')
    }

    goods_list = []

    if source == 'buy_now':

        goods_id = body.get('goods_id')
        sku_id = body.get('goods_sku_id')
        buy_num = int(body.get('buy_num', 1))
        try:
            goods = Goods.objects.get(id=goods_id, is_delete=0)
            sku = GoodsSku.objects.get(id=sku_id, goods_id=goods_id)
            goods_info = {
                'id': goods.id,
                'name': goods.name,
                'image_url': goods.image_urls[0],
                'buy_num': buy_num,
                'sku_id': sku.id,
                'sku_name': sku.sku_name,
                'sku_price': str(sku.price),
                'freight_type': goods.freight_type,
                'freight_price': str(goods.freight_price),
                'freight_temp_id': goods.freight_temp_id
            }
            goods_list.append(goods_info)
        except (Goods.DoesNotExist, GoodsSku.DoesNotExist):
            return APIResponse(
                code=1,
                msg=gettext_lazy('Please refresh the page and try again')
            )
    elif source == 'cart':
        cart_ids = body.get('cart_ids', '')
        if not cart_ids:
            return APIResponse(code=1, msg=gettext_lazy('Please select items from the cart'))
        cart_id_list = [int(id_str.strip()) for id_str in cart_ids.split(',') if id_str.strip()]

        cart_items = GoodsCart.objects.filter(
            id__in=cart_id_list,
            user_id=request.user.id
        )
        if not cart_items:
            return APIResponse(code=1, msg=gettext_lazy('Please select items from the cart'))

        for item in cart_items:
            try:
                goods = Goods.objects.get(id=item.goods_id, is_delete=0)
                sku = GoodsSku.objects.get(id=item.goods_sku_id, goods_id=item.goods_id)
            except (Goods.DoesNotExist, GoodsSku.DoesNotExist):
                continue

            goods_info = {
                'id': goods.id,
                'name': goods.name,
                'image_url': goods.image_urls[0],
                'buy_num': item.buy_num,
                'sku_id': sku.id,
                'sku_name': sku.sku_name,
                'sku_price': str(sku.price),
                'freight_type': goods.freight_type,
                'freight_price': str(goods.freight_price),
                'freight_temp_id': goods.freight_temp_id,
                'cart_id': item.id,
            }
            goods_list.append(goods_info)
    elif source == 'exchange':
        goods_id = body.get('goods_id')
        sku_id = body.get('goods_sku_id')
        try:
            goods = PointsGoods.objects.get(id=goods_id, is_delete=0)
            sku = PointsGoodsSku.objects.get(id=sku_id, goods_id=goods_id)
            goods_info = {
                'id': goods.id,
                'name': goods.name,
                'image_url': goods.image_urls[0],
                'buy_num': 1,
                'sku_id': sku.id,
                'sku_name': sku.sku_name,
                'point_num': sku.point_num,
                'freight_type': goods.freight_type,
                'freight_price': str(goods.freight_price),
                'freight_temp_id': goods.freight_temp_id,
            }
            goods_list.append(goods_info)
        except (PointsGoods.DoesNotExist, PointsGoodsSku.DoesNotExist):
            return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    total_freight = decimal.Decimal('0.00')
    if address_id:
        for item in goods_list:
            item_freight = calculate_freight({
                'goods': item,
                'buy_num': item['buy_num']
            }, address)
            total_freight += item_freight

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data={
            'user_normal_points': request.user.normal_points,
            'user_cultural_points': request.user.cultural_points,
            'user_coupons': user_coupons,
            'normal_points_max_num': points_config_dict['normal_points_max_num'],
            'normal_points_per_yuan': str(points_config_dict['normal_points_per_yuan']),
            'goods_list': goods_list,
            'total_freight': total_freight,
            'source': source
        }
    )


@require_POST
def buy_now(request):
    body = json.loads(request.body)

    address_id = int(body.get('address_id', 0))
    goods_id = int(body.get('goods_id', 0))
    goods_sku_id = int(body.get('goods_sku_id', 0))
    buy_num = int(body.get('buy_num', 1))
    coupon_id = int(body.get('coupon_id', 0))
    use_normal_points = int(body.get('use_normal_points', 0))  # 使用普通积分数量
    pay_price_from_app = decimal.Decimal(str(body.get('pay_price', 0)))

    points_config = PointsConfig.objects.first()
    points_config_dict = {
        'order_fixed_points': points_config.order_fixed_points if points_config else 0,
        'normal_points_per_yuan': points_config.normal_points_per_yuan if points_config else decimal.Decimal('0.00'),
        'normal_points_max_num': points_config.normal_points_max_num if points_config else 200
    }
    if use_normal_points > points_config_dict['normal_points_max_num']:
        return APIResponse(code=1, msg=gettext_lazy('You can use up to %(max_num)s points at most')% {'max_num': points_config_dict['normal_points_max_num']})
        # return APIResponse(code=1, msg=f"最多可使用{points_config_dict['normal_points_max_num']}个积分")

    try:
        address = UserAddress.objects.get(id=address_id, user_id=request.user.id)
        goods = Goods.objects.get(id=goods_id, is_delete=0)
        goodsSku = GoodsSku.objects.get(id=goods_sku_id, goods_id=goods_id)
        if coupon_id > 0:
            UserCoupon.objects.get(
                coupon_id=coupon_id,
                user_id=request.user.id,
                is_use=0,
                end_time__gt=timezone.now()
            )
    except (UserAddress.DoesNotExist, Goods.DoesNotExist, GoodsSku.DoesNotExist, UserCoupon.DoesNotExist):
        return APIResponse(code=1, msg=gettext_lazy('Please refresh the page and try again'))

    freight_price = calculate_freight({
        'goods': goods,
        'buy_num': buy_num
    }, address)
    freight_price = check_amount(freight_price)

    total_price = goodsSku.price * buy_num
    total_price = check_amount(total_price)

    try:
        with transaction.atomic():
            user = User.objects.select_for_update().get(id=request.user.id, is_delete=0)

            coupon_money = decimal.Decimal('0.00')
            user_coupon = None
            if coupon_id:
                try:
                    user_coupon = UserCoupon.objects.get(
                        coupon_id=coupon_id,
                        user_id=user.id,
                        is_use=0,
                        end_time__gt=timezone.now()
                    )
                    if total_price < user_coupon.min_price:
                        raise ValueError(gettext_lazy('Coupon usage conditions are not met'))
                    coupon_money = user_coupon.reduce_price
                    if coupon_money > total_price:
                        coupon_money = total_price
                    coupon_money = check_amount(coupon_money)

                    if total_price <= 0:
                        raise ValueError(gettext_lazy('Coupon is unavailable'))
                except UserCoupon.DoesNotExist:
                    raise ValueError(gettext_lazy('Coupon is unavailable'))
                    # return APIResponse(code=1, msg='优惠券不可用')

            normal_points_deduct = decimal.Decimal('0.00')
            if points_config_dict['normal_points_per_yuan'] == 0:
                if use_normal_points > 0:
                    raise ValueError(gettext_lazy('The current configuration does not allow the use of points deduction'))
            else:
                if user.normal_points - use_normal_points < 0:
                    raise ValueError(gettext_lazy('Your normal points are insufficient'))
                normal_points_deduct = calculate_points_deduct(use_normal_points, points_config_dict)
                max_discountable = total_price + freight_price - coupon_money
                if normal_points_deduct > max_discountable:
                    max_available_points = int(max_discountable / points_config_dict['normal_points_per_yuan'])
                    # raise ValueError(f'积分抵扣金额不能超过{max_discountable}元，最多可用{max_available_points}个积分')
                    raise ValueError(gettext_lazy('The discount amount cannot exceed %(max)s yuan, and you can use up to %(points)s points') & {'max': max_discountable, 'points': max_available_points})
                normal_points_deduct = check_amount(normal_points_deduct)

            pay_price = (total_price + freight_price - coupon_money - normal_points_deduct)
            pay_price = check_amount(pay_price)
            if pay_price != pay_price_from_app:
                raise ValueError(gettext_lazy('Please refresh the page and try again'))

            order_no = generate_order_no('BN', user.id)
            order = Order.objects.create(
                order_type=1,
                order_no=order_no,
                total_price=total_price,
                coupon_id=coupon_id,
                coupon_money=coupon_money,
                normal_points=use_normal_points,
                normal_points_deduct=normal_points_deduct,
                normal_points_per_yuan=points_config_dict['normal_points_per_yuan'],
                freight_price=freight_price,
                pay_price=pay_price,
                give_normal_points=points_config_dict['order_fixed_points'],
                user_id=user.id
            )

            OrderAddress.objects.create(
                order_id=order.id,
                name=address.name,
                phone=address.phone,
                province=address.province,
                province_code=address.province_code,
                city=address.city,
                city_code=address.city_code,
                district=address.district,
                district_code=address.district_code,
                detail=address.detail,
                user_id=user.id
            )

            goods_total_price = total_price + freight_price - coupon_money - normal_points_deduct
            goods_total_price = check_amount(goods_total_price)

            OrderGoods.objects.create(
                order_id=order.id,
                goods_id=goods.id,
                goods_image_url=goods.image_urls[0] if goods.image_urls else '',
                goods_name=goods.name,
                goods_sku_id=goodsSku.id,
                goods_sku_name=goodsSku.sku_name,
                goods_sku_price=goodsSku.price,
                buy_num=buy_num,
                freight_price=freight_price,
                normal_order_allocated_data={
                    'coupon_deduct': str(coupon_money),
                    'normal_points_num': use_normal_points,
                    'normal_points_deduct': str(normal_points_deduct),
                    'total_price': str(goods_total_price)
                },
                points_order_allocated_data={}
                # coupon_deduct=coupon_money,
                # normal_points_num=use_normal_points,
                # normal_points_deduct=normal_points_deduct,
                # total_price=goods_total_price
            )

            if user_coupon:
                user_coupon.is_use = 1
                user_coupon.use_time = timezone.now()
                user_coupon.save()

            if use_normal_points > 0:
                user.normal_points -= use_normal_points
                user.save()

                UserPointsLog.objects.create(
                    scene=UserPointsLog.SCENE_ORDER,
                    point_type=UserPointsLog.POINT_TYPE_NORMAL,
                    point_num=use_normal_points,
                    user_id=user.id,
                )

    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception as e:
        print(e)
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))

    return APIResponse(
        code=0,
        msg=gettext_lazy('Operation successful')
    )

@require_POST
def cart(request):
    body = json.loads(request.body)

    address_id = body.get('address_id')
    coupon_id = body.get('coupon_id', 0)
    use_normal_points = int(body.get('use_normal_points', 0))  # 使用普通积分数量
    cart_ids = body.get('cart_ids', '')
    pay_price_from_app = decimal.Decimal(str(body.get('pay_price', 0)))

    if not cart_ids:
        return APIResponse(code=1, msg='请选择购物车商品')

    points_config = PointsConfig.objects.first()
    points_config_dict = {
        'order_fixed_points': points_config.order_fixed_points if points_config else 0,
        'normal_points_per_yuan': points_config.normal_points_per_yuan if points_config else decimal.Decimal('0.00'),
        'normal_points_max_num': points_config.normal_points_max_num if points_config else 200
    }
    if use_normal_points > points_config_dict['normal_points_max_num']:
        return APIResponse(code=1, msg=gettext_lazy('You can use up to %(max_num)s points at most') % {
            'max_num': points_config_dict['normal_points_max_num']})
        # return APIResponse(code=1, msg=f"最多可使用{points_config_dict['normal_points_max_num']}个积分")

    try:
        address = UserAddress.objects.get(id=address_id, user_id=request.user.id)
        if coupon_id > 0:
            UserCoupon.objects.get(
                coupon_id=coupon_id,
                user_id=request.user.id,
                is_use=0,
                end_time__gt=timezone.now()
            )
    except (UserAddress.DoesNotExist, UserCoupon.DoesNotExist):
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    cart_id_list = [int(id_str.strip()) for id_str in cart_ids.split(',') if id_str.strip()]
    cart_items = GoodsCart.objects.filter(
        id__in=cart_id_list,
        user_id=request.user.id
    )
    if not cart_items:
        return APIResponse(code=1, msg=gettext_lazy('Please select items from the cart'))

    cart_goods_list = []
    total_freight = decimal.Decimal('0.00')
    total_price = decimal.Decimal('0.00')
    for item in cart_items:
        try:
            goods = Goods.objects.get(id=item.goods_id, is_delete=0)
            sku = GoodsSku.objects.get(id=item.goods_sku_id, goods_id=item.goods_id)
            item_freight = calculate_freight({
                'goods': goods,
                'buy_num': item.buy_num
            }, address)
            cart_goods_list.append({
                'cart_item': item,
                'goods': goods,
                'sku': sku,
                'item_freight': item_freight
            })
            total_freight += item_freight
            total_price += sku.price * item.buy_num
        except (Goods.DoesNotExist, GoodsSku.DoesNotExist):
            return APIResponse(code=1, msg=gettext_lazy('Please refresh the page and try again'))
    total_freight = check_amount(total_freight)
    total_price = check_amount(total_price)

    try:
        with transaction.atomic():
            user = User.objects.select_for_update().get(id=request.user.id, is_delete=0)

            coupon_money = decimal.Decimal('0.00')
            user_coupon = None
            if coupon_id:
                try:
                    user_coupon = UserCoupon.objects.get(
                        coupon_id=coupon_id,
                        user_id=user.id,
                        is_use=0,
                        end_time__gt=timezone.now()
                    )
                    if total_price < user_coupon.min_price:
                        raise ValueError(gettext_lazy('Coupon usage conditions are not met'))
                    coupon_money = user_coupon.reduce_price
                    if coupon_money > total_price:
                        coupon_money = total_price
                    coupon_money = check_amount(coupon_money)

                    if total_price <= 0:
                        raise ValueError(gettext_lazy('Coupon is unavailable'))
                except UserCoupon.DoesNotExist:
                    raise ValueError(gettext_lazy('Coupon is unavailable'))

            normal_points_deduct = decimal.Decimal('0.00')
            if points_config_dict['normal_points_per_yuan'] == 0:
                if use_normal_points > 0:
                    raise ValueError(gettext_lazy('The current configuration does not allow the use of points deduction'))
            else:
                if user.normal_points - use_normal_points < 0:
                    raise ValueError(gettext_lazy('Your normal points are insufficient'))
                normal_points_deduct = calculate_points_deduct(use_normal_points, points_config_dict)
                max_discountable = total_price + total_freight - coupon_money
                if normal_points_deduct > max_discountable:
                    max_available_points = int(max_discountable / points_config_dict['normal_points_per_yuan'])
                    raise ValueError(gettext_lazy('The discount amount cannot exceed %(max)s yuan, and you can use up to %(points)s points') & {'max': max_discountable, 'points': max_available_points})
                normal_points_deduct = check_amount(normal_points_deduct)

            pay_price = (total_price + total_freight - coupon_money - normal_points_deduct)
            pay_price = check_amount(pay_price)
            if pay_price != pay_price_from_app:
                raise ValueError(gettext_lazy('Please refresh the page and try again'))

            order_no = generate_order_no('CART', user.id)
            order = Order.objects.create(
                order_type=1,
                order_no=order_no,
                total_price=total_price,
                coupon_id=coupon_id,
                coupon_money=coupon_money,
                normal_points=use_normal_points,
                normal_points_deduct=normal_points_deduct,
                normal_points_per_yuan=points_config_dict['normal_points_per_yuan'],
                freight_price=total_freight,
                pay_price=pay_price,
                give_normal_points=points_config_dict['order_fixed_points'],
                user_id=user.id
            )

            OrderAddress.objects.create(
                order_id=order.id,
                name=address.name,
                phone=address.phone,
                province=address.province,
                province_code=address.province_code,
                city=address.city,
                city_code=address.city_code,
                district=address.district,
                district_code=address.district_code,
                detail=address.detail,
                user_id=user.id,
            )

            allocated_data_list = allocate_normal_order(
                cart_goods_list, coupon_money, use_normal_points, normal_points_deduct
            )
            for i, item in enumerate(cart_goods_list):
                cart_item = item['cart_item']
                goods = item['goods']
                sku = item['sku']
                item_freight = item['item_freight']

                OrderGoods.objects.create(
                    order_id=order.id,
                    goods_id=goods.id,
                    goods_image_url=goods.image_urls[0] if goods.image_urls else '',
                    goods_name=goods.name,
                    goods_sku_id=sku.id,
                    goods_sku_name=sku.sku_name,
                    goods_sku_price=sku.price,
                    buy_num=cart_item.buy_num,
                    freight_price=item_freight,
                    normal_order_allocated_data=allocated_data_list[i],
                    points_order_allocated_data={}
                )

            if user_coupon:
                user_coupon.is_use = 1
                user_coupon.use_time = timezone.now()
                user_coupon.save()

            if use_normal_points > 0:
                user.normal_points -= use_normal_points
                user.save()

                UserPointsLog.objects.create(
                    scene=UserPointsLog.SCENE_ORDER,
                    point_type=UserPointsLog.POINT_TYPE_NORMAL,
                    point_num=use_normal_points,
                    user_id=user.id,
                )

            GoodsCart.objects.filter(id__in=cart_id_list, user_id=user.id).delete()

    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception as e:
        # print(str(e))
        # import traceback
        # traceback.print_exc()
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))

    return APIResponse(
        code=0,
        msg=gettext_lazy('Operation successful')
    )

@require_POST
def exchange(request):
    body = json.loads(request.body)

    address_id = body.get('address_id')
    goods_id = body.get('goods_id')
    sku_id = body.get('goods_sku_id')
    use_normal_points = int(body.get('use_normal_points', 0))
    use_cultural_points = int(body.get('use_cultural_points', 0))
    total_points_from_app = int(body.get('total_points', 0))
    pay_price_from_app = decimal.Decimal(str(body.get('pay_price', 0)))

    try:
        address = UserAddress.objects.get(id=address_id, user_id=request.user.id)
        goods = PointsGoods.objects.get(id=goods_id, is_delete=0)
        goodsSku = PointsGoodsSku.objects.get(id=sku_id, goods_id=goods_id)
    except (UserAddress.DoesNotExist, PointsGoods.DoesNotExist, PointsGoodsSku.DoesNotExist):
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    total_points = goodsSku.point_num
    if use_normal_points + use_cultural_points > total_points:
        return APIResponse(code=1, msg=gettext_lazy('Please refresh the page and try again'))
    elif use_normal_points + use_cultural_points < total_points:
        return APIResponse(code=1, msg=gettext_lazy('Please refresh the page and try again'))
    if total_points_from_app != total_points:
        return APIResponse(code=1, msg=gettext_lazy('Please refresh the page and try again'))

    freight_price = calculate_freight({
        'goods': goods,
        'buy_num': 1
    }, address)
    freight_price = check_amount(freight_price)

    if pay_price_from_app != freight_price:
        raise ValueError(gettext_lazy('Please refresh the page and try again'))

    try:
        with transaction.atomic():
            user = User.objects.select_for_update().get(id=request.user.id, is_delete=0)

            if user.normal_points - use_normal_points < 0:
                raise ValueError(gettext_lazy('Your normal points are insufficient'))
            if user.cultural_points - use_cultural_points < 0:
                raise ValueError(gettext_lazy('Your cultural points are insufficient'))

            order_no = generate_order_no('PT', user.id)
            order = Order.objects.create(
                order_type=2,
                order_no=order_no,
                total_price=0,
                total_points=total_points,
                coupon_id=0,
                coupon_money=0,
                normal_points=use_normal_points,  # 使用的普通积分数量
                cultural_points=use_cultural_points,  # 使用的文化积分数量
                freight_price=freight_price,
                pay_price=freight_price,
                give_normal_points=0,  # 积分兑换不赠送积分
                user_id=user.id
            )

            OrderAddress.objects.create(
                order_id=order.id,
                name=address.name,
                phone=address.phone,
                province=address.province,
                province_code=address.province_code,
                city=address.city,
                city_code=address.city_code,
                district=address.district,
                district_code=address.district_code,
                detail=address.detail,
                user_id=user.id,
            )

            OrderGoods.objects.create(
                order_id=order.id,
                goods_id=goods.id,
                goods_image_url=goods.image_urls[0],
                goods_name=goods.name,
                goods_sku_id=goodsSku.id,
                goods_sku_name=goodsSku.sku_name,
                goods_sku_price=decimal.Decimal('0.00'),
                goods_sku_point_num=goodsSku.point_num,
                buy_num=1,
                freight_price=freight_price,
                normal_order_allocated_data={},
                points_order_allocated_data={
                    'normal_points': use_normal_points,
                    'cultural_points': use_cultural_points
                }
            )

            user.normal_points -= use_normal_points
            user.cultural_points -= use_cultural_points
            user.save()

            if use_normal_points > 0:
                UserPointsLog.objects.create(
                    scene=UserPointsLog.SCENE_POINT_ORDER,
                    point_type=UserPointsLog.POINT_TYPE_NORMAL,
                    point_num=use_cultural_points,
                    user_id=user.id,
                )

            if use_cultural_points > 0:
                UserPointsLog.objects.create(
                    scene=UserPointsLog.SCENE_POINT_ORDER,
                    point_type=UserPointsLog.POINT_TYPE_CULTURAL,
                    point_num=use_cultural_points,
                    user_id=user.id,
                )

    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception:
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))

    return APIResponse(
        code=0,
        msg=gettext_lazy('Operation successful')
    )

def calculate_freight(goods_info, address):
    """计算单个商品的运费"""

    goods = goods_info['goods']
    buy_num = goods_info['buy_num']

    def get_goods_attr(key):
        if isinstance(goods, dict):
            return goods.get(key)
        else:
            return getattr(goods, key)

    freight_type = get_goods_attr('freight_type')
    freight_price = get_goods_attr('freight_price')
    freight_temp_id = get_goods_attr('freight_temp_id')

    if freight_type == 1: # 包邮
        return decimal.Decimal('0.00')

    if freight_type == 2: # 固定邮费
        return check_amount(freight_price)

    if freight_type == 3 and freight_temp_id > 0: # 运费模板
        try:
            freight_temp = FreightTemp.objects.get(id=freight_temp_id, is_delete=0)
            addr_province_code = address.province_code
            addr_city_code = address.city_code

            regions = freight_temp.freight_temp_regions.all()

            for region in regions:
                if region.is_default == 1:
                    continue

                province_code_list = [region.province_code] if region.province_code else []
                if addr_province_code not in province_code_list:
                    continue

                city_code_list = [region.city_code] if region.city_code else []
                if city_code_list and addr_city_code not in city_code_list:
                    continue

                if buy_num <= region.first:
                    freight = region.first_price
                else:
                    exceed_num = buy_num - region.first
                    continue_count = (exceed_num + region.continue_num - 1) // region.continue_num
                    total_continue = decimal.Decimal(continue_count) * region.continue_price
                    freight = region.first_price + total_continue

                return check_amount(freight)

            for region in regions:
                if region.is_default == 1:
                    if buy_num <= region.first:
                        freight = region.first_price
                    else:
                        exceed_num = buy_num - region.first
                        if region.continue_num == 0:
                            continue_count = 0
                        else:
                            continue_count = (exceed_num + region.continue_num - 1) // region.continue_num
                        # continue_count = (exceed_num + region.continue_num - 1) // region.continue_num
                        total_continue = decimal.Decimal(continue_count) * region.continue_price
                        freight = region.first_price + total_continue

                    return check_amount(freight)
                break

            return decimal.Decimal('999999.99')

        except FreightTemp.DoesNotExist:
            return decimal.Decimal('999999.99')

    return decimal.Decimal('999999.99')


def generate_order_no(prefix: str, user_id: int) -> str:
    """生成唯一的订单号"""
    now = timezone.now()
    date_part = now.strftime("%Y%m%d%H%M%S")
    unique_part = uuid.uuid4().hex[:6].upper()
    order_no = f"{prefix}{date_part}{user_id}{unique_part}"
    return order_no


def calculate_points_deduct(point_num, config):
    """计算积分抵扣金额"""
    if not config or point_num <= 0:
        return decimal.Decimal('0.00')

    points_per_yuan = config['normal_points_per_yuan']

    if points_per_yuan == decimal.Decimal('0.00'):
        return decimal.Decimal('0.00')
    return (decimal.Decimal(point_num) * points_per_yuan).quantize(decimal.Decimal('0.00'))


def allocate_normal_order(goods_list: List[Dict], coupon_money: decimal.Decimal, normal_points: int,
                             normal_points_deduct: decimal.Decimal) -> List[Dict]:
    """分配订单的优惠券金额和积分抵扣到各个商品"""

    total_price = decimal.Decimal('0.00') # 含运费

    for item in goods_list:
        cart_item = item['cart_item']
        sku = item['sku']
        item_freight = item['item_freight']
        total_price += sku.price * cart_item.buy_num + item_freight

    if total_price <= 0:
        return [{
            'coupon_deduct': 0,
            'normal_points_num': 0,
            'normal_points_deduct': 0,
            'total_price': 0
        } for _ in goods_list]

    allocated_data = []
    allocated_coupon_total = decimal.Decimal('0.00')
    allocated_points_total = 0
    allocated_points_deduct_total = decimal.Decimal('0.00')

    for i, item in enumerate(goods_list):
        cart_item = item['cart_item']
        goods = item['goods']
        sku = item['sku']
        item_freight = item['item_freight']

        subtotal = sku.price * cart_item.buy_num + item_freight

        is_last_item = (i == len(goods_list) - 1)
        if is_last_item:
            # 最后一个商品，分配剩余的金额和积分
            goods_coupon_deduct = coupon_money - allocated_coupon_total
            goods_points_num = normal_points - allocated_points_total
            goods_points_deduct = normal_points_deduct - allocated_points_deduct_total
        else:
            # 按比例分配优惠券
            if coupon_money > 0:
                ratio = subtotal / total_price
                goods_coupon_deduct = (coupon_money * ratio).quantize(decimal.Decimal('0.01'))
            else:
                goods_coupon_deduct = decimal.Decimal('0.00')

            # 按比例分配积分数量
            if normal_points > 0:
                points_ratio = subtotal / total_price
                goods_points_num = int(normal_points * points_ratio)
            else:
                goods_points_num = 0

            # 按比例分配积分抵扣金额
            if normal_points_deduct > 0:
                points_deduct_ratio = subtotal / total_price
                goods_points_deduct = (normal_points_deduct * points_deduct_ratio).quantize(decimal.Decimal('0.01'))
            else:
                goods_points_deduct = decimal.Decimal('0.00')

        allocated_data.append({
            'coupon_deduct': str(goods_coupon_deduct),
            'normal_points_num': goods_points_num,
            'normal_points_deduct': str(goods_points_deduct),
            'total_price': str(subtotal - goods_coupon_deduct - goods_points_deduct),
        })

        allocated_coupon_total += goods_coupon_deduct
        allocated_points_total += goods_points_num
        allocated_points_deduct_total += goods_points_deduct

    return allocated_data
