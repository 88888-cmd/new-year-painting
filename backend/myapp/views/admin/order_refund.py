import json

from django.utils import timezone
from django.views.decorators.http import require_GET, require_POST
from django.db import transaction
from django.db.models import F, Sum, IntegerField, DecimalField

from myapp.models import User, UserCoupon, UserAddress, UserPointsLog, Goods, GoodsSku, GoodsCart, GoodsComment, PointsGoods, PointsGoodsSku, PointsConfig, FreightTemp, Order, OrderAddress, OrderGoods, OrderRefund
from api_r import APIResponse

@require_GET
def get_list(request):
    status = int(request.GET.get('status'))
    data_v = int(request.GET.get('data_v', 1))

    if status == 0:
        order_refund_list = OrderRefund.objects.filter(status=1).order_by('-id')
    else:
        order_refund_list = OrderRefund.objects.filter(status__in=[2,3,4]).order_by('-id')

    order_refund_dict_list = []
    for order_refund in order_refund_list:
        order = Order.objects.get(id=order_refund.order_id)
        # relation_order_type = Order.objects.values('order_type').first()['order_type']
        relation_order_no = order.order_no
        relation_order_type = order.order_type

        order_refund_dict_list.append({**order_refund.to_dict(), **{
            'relation_order_no': relation_order_no,
            'relation_order_type': relation_order_type
        }})

    return APIResponse(code=0, msg='查询成功', data={
        'list': order_refund_dict_list,
        'data_v': data_v
    })

@require_GET
def detail(request):
    order_refund_id = int(request.GET.get('order_refund_id'))
    data_v = int(request.GET.get('data_v', 1))

    try:
        order_refund = OrderRefund.objects.get(id=order_refund_id)
        order = Order.objects.get(id=order_refund.order_id)

        relation_order_no = order.order_no
        relation_order_type = order.order_type

        if order_refund.order_goods_id:
            order_goods_list = OrderGoods.objects.filter(id=order_refund.order_goods_id)
        else:
            order_goods_list = OrderGoods.objects.filter(order_id=order_refund.order_id, status__in=[1, 2])
    except (Order.DoesNotExist, OrderAddress.DoesNotExist):
        return APIResponse(code=1, msg='数据不存在')

    return APIResponse(code=0, msg='查询成功', data={
        'detail': {
            **order_refund.to_dict(),
            'relation_order_no': relation_order_no,
            'relation_order_type': relation_order_type
        },
        'order_goods_list': [order_goods.to_dict() for order_goods in order_goods_list],
        'data_v': data_v
    })



@require_POST
def first_audit(request):
    body = json.loads(request.body)

    order_refund_id = int(body.get('order_refund_id', 0))
    audit_status = int(body.get('audit_status', 0))

    if audit_status not in (2, 3):
        return APIResponse(code=1, msg='参数错误')

    try:
        order_refund = OrderRefund.objects.get(
            id=order_refund_id,
            audit_status=1,
            status=1
        )
    except OrderRefund.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    try:
        with transaction.atomic():
            order = Order.objects.select_for_update().get(
                id=order_refund.order_id
            )
            if order.order_status != 1 and order.order_status != 2 and order.order_status != 3:
                raise ValueError('订单状态异常')
            order_refund = OrderRefund.objects.get(
                id=order_refund_id
            )
            if order_refund.status != 1:
                raise ValueError('请刷新页面重试')

            if audit_status == 2: # 平台同意

                if order.order_type == 1: # 普通商城订单

                    if order_refund.refund_type == 1: # 仅退款
                        if order_refund.order_goods_id: # 订单商品 退积分

                            order_goods = OrderGoods.objects.get(id=order_refund.order_goods_id)
                            order_goods.status = 3
                            order_goods.save()

                            # 退掉本次订单商品后，此订单是否还有 正常或正在申请退款 的订单商品
                            active_order_goods = OrderGoods.objects.filter(
                                order_id=order.id,
                                status__in=[1, 2]
                            ).exists()

                            # 是否退优惠券（订单未发货，且没有活跃订单商品）
                            is_refund_coupon = 1 if order.order_status == 1 and not active_order_goods else 0



                            order_refund.audit_status = 2
                            order_refund.audit_time = timezone.now()
                            order_refund.status = 3

                            order_refund.refund_money = order_goods.normal_order_allocated_data['total_price']
                            order_refund.refund_normal_points = order_goods.normal_order_allocated_data['normal_points_num']
                            order_refund.refund_coupon = is_refund_coupon

                            order_refund.save()



                            order.refund_coupon = is_refund_coupon
                            order.refund_normal_points += order_goods.normal_order_allocated_data['normal_points_num']

                            updated_user_points = User.objects.filter(
                                id=order.user_id,
                                is_delete=0
                            ).update(normal_points=F('normal_points') + order_goods.normal_order_allocated_data['normal_points_num'])
                            if not updated_user_points:
                                raise ValueError("操作失败")

                            UserPointsLog.objects.create(
                                scene=UserPointsLog.SCENE_REFUND,
                                point_type=UserPointsLog.POINT_TYPE_NORMAL,
                                point_num=order_goods.normal_order_allocated_data['normal_points_num'],
                                user_id=order.user_id
                            )


                            if not active_order_goods:
                                if is_refund_coupon:
                                    # 退优惠券
                                    UserCoupon.objects.filter(
                                        coupon_id=order.coupon_id,
                                        user_id=order.user_id
                                    ).update(is_use=0)

                                # 关闭订单
                                order.order_status = 4

                        else: # 订单 退积分

                            # 退积分
                            # 获取该订单下所有未退款的商品对应的积分总和
                            remaining_points = OrderGoods.objects.filter(
                                order_id=order.id,
                                status=1
                            ).aggregate(
                                total_points=Sum('normal_order_allocated_data__normal_points_num')
                            )['total_points'] or 0

                            if order.refund_normal_points + remaining_points != order.normal_points:
                                raise ValueError("积分数量异常")



                            # 退钱
                            # 获取该订单下所有已退款的商品对应的金额总和
                            refunded_goods_total_price = OrderGoods.objects.filter(
                                order_id=order.id,
                                status=3
                            ).aggregate(
                                total_refund=Sum('normal_order_allocated_data__total_price')
                            )['goods_total_price'] or 0

                            # 获取该订单下所有未退款的商品对应的金额总和
                            remaining_goods_total_price = OrderGoods.objects.filter(
                                order_id=order.id,
                                status=1
                            ).aggregate(
                                total_points=Sum('normal_order_allocated_data__total_price')
                            )['goods_total_price'] or 0


                            if remaining_goods_total_price + refunded_goods_total_price != order.pay_price:
                                raise ValueError("金额异常")



                            order_refund.audit_status = 2
                            order_refund.audit_time = timezone.now()
                            order_refund.status = 3

                            order_refund.refund_money = remaining_goods_total_price
                            order_refund.refund_normal_points = remaining_points
                            order_refund.refund_coupon = 1

                            order_refund.save()


                            order.refund_coupon = 1
                            order.refund_normal_points += remaining_points

                            updated_user_points = User.objects.filter(
                                id=order.user_id,
                                is_delete=0
                            ).update(normal_points=F('normal_points') + remaining_points)
                            if not updated_user_points:
                                raise ValueError("操作失败")

                            UserPointsLog.objects.create(
                                scene=UserPointsLog.SCENE_REFUND,
                                point_type=UserPointsLog.POINT_TYPE_NORMAL,
                                point_num=remaining_points,
                                user_id=order.user_id
                            )

                            if order.order_status == 1:
                                # 退优惠券
                                UserCoupon.objects.filter(
                                    coupon_id=order.coupon_id,
                                    user_id=order.user_id
                                ).update(is_use=0)

                            # 关闭订单
                            order.order_status = 4


                        order.save()

                    elif order_refund.refund_type == 2: # 退货退款
                        order_refund.audit_status = 2
                        order_refund.audit_time = timezone.now()
                        order_refund.save()

                elif order.order_type == 2: # 积分商城积分兑换订单

                    if order_refund.refund_type == 1:  # 仅退款

                        order_goods = OrderGoods.objects.filter(order_id=order.id).first()
                        order_goods.status = 3
                        order_goods.save()


                        order_refund.audit_status = 2
                        order_refund.audit_time = timezone.now()
                        order_refund.status = 3

                        order_refund.refund_normal_points = order_goods.points_order_allocated_data['normal_points']
                        order_refund.refund_cultural_points = order_goods.points_order_allocated_data['cultural_points']

                        order_refund.save()



                        order.refund_normal_points += order_goods.points_order_allocated_data['normal_points']
                        order.refund_cultural_points += order_goods.points_order_allocated_data['cultural_points']

                        updated_user_points = User.objects.filter(
                            id=order.user_id,
                            is_delete=0
                        ).update(
                            normal_points=F('normal_points') + order_goods.points_order_allocated_data['normal_points'],
                            cultural_points=F('cultural_points') + order_goods.points_order_allocated_data['cultural_points']
                        )
                        if not updated_user_points:
                            raise ValueError("操作失败")

                        UserPointsLog.objects.create(
                            scene=UserPointsLog.SCENE_REFUND,
                            point_type=UserPointsLog.POINT_TYPE_NORMAL,
                            point_num=order_goods.points_order_allocated_data['normal_points'],
                            user_id=order.user_id
                        )
                        UserPointsLog.objects.create(
                            scene=UserPointsLog.SCENE_REFUND,
                            point_type=UserPointsLog.POINT_TYPE_CULTURAL,
                            point_num=order_goods.points_order_allocated_data['cultural_points'],
                            user_id=order.user_id
                        )

                        # 关闭订单
                        order.order_status = 4
                        order.save()

                    elif order_refund.refund_type == 2:  # 退货退款
                        order_refund.audit_status = 2
                        order_refund.audit_time = timezone.now()
                        order_refund.save()

            elif audit_status == 3: # 平台拒绝
                order_refund.audit_status = 3
                order_refund.audit_time = timezone.now()
                order_refund.status = 2
                order_refund.save()

                if order_refund.order_goods_id:
                    # 设置此订单商品状态为 正常
                    OrderGoods.objects.filter(id=order_refund.order_goods_id).update(status=1)

    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception as e:
        print(e)
        return APIResponse(code=1, msg='操作失败')

    return APIResponse(code=0, msg='操作成功')

@require_POST
def receipt(request):
    body = json.loads(request.body)

    order_refund_id = int(body.get('order_refund_id', 0))

    try:
        order_refund = OrderRefund.objects.get(
            id=order_refund_id,
            audit_status=2,
            status=1
        )
    except OrderRefund.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    try:
        with transaction.atomic():
            order = Order.objects.select_for_update().get(
                id=order_refund.order_id
            )
            order_refund = OrderRefund.objects.get(
                id=order_refund_id
            )
            if order_refund.status != 1 or order_refund.is_user_send != 1 or order_refund.is_receipt != 0:
                raise ValueError('请刷新页面重试')

            order_refund.is_receipt = 1
            order_refund.receipt_time = timezone.now()
            order_refund.save()
    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception:
        return APIResponse(code=1, msg='操作失败')

    return APIResponse(code=0, msg='操作成功')



@require_POST
def second_audit(request):
    body = json.loads(request.body)

    order_refund_id = int(body.get('order_refund_id', 0))
    audit_status = int(body.get('audit_status', 0))

    if audit_status not in (2, 3):
        return APIResponse(code=1, msg='参数错误')

    try:
        order_refund = OrderRefund.objects.get(
            id=order_refund_id,
            refund_type=2,
            audit_status=2,
            is_user_send=1,
            is_receipt=1,
            status=1
        )
    except OrderRefund.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    try:
        with transaction.atomic():
            order = Order.objects.select_for_update().get(
                id=order_refund.order_id
            )
            if order.order_status != 3: # 确认收货后的订单才有退货退款
                raise ValueError('订单状态异常')
            order_refund = OrderRefund.objects.get(
                id=order_refund_id
            )
            if order_refund.status != 1:
                raise ValueError('请刷新页面重试')

            if audit_status == 2:  # 平台同意

                if order.order_type == 1:  # 普通商城订单

                    if order_refund.order_goods_id:  # 订单商品 退积分

                        order_goods = OrderGoods.objects.get(id=order_refund.order_goods_id)
                        order_goods.status = 3
                        order_goods.save()

                        # 退掉本次订单商品后，此订单是否还有 正常或正在申请退款 的订单商品
                        active_order_goods = OrderGoods.objects.filter(
                            order_id=order.id,
                            status__in=[1, 2]
                        ).exists()

                        # 是否退优惠券（订单未发货，且没有活跃订单商品）
                        is_refund_coupon = 1 if order.order_status == 1 and not active_order_goods else 0

                        order_refund.audit_status = 2
                        order_refund.audit_time = timezone.now()
                        order_refund.status = 3

                        order_refund.refund_money = order_goods.normal_order_allocated_data['total_price']
                        order_refund.refund_normal_points = order_goods.normal_order_allocated_data[
                            'normal_points_num']
                        order_refund.refund_coupon = is_refund_coupon

                        order_refund.save()

                        order.refund_coupon = is_refund_coupon
                        order.refund_normal_points += order_goods.normal_order_allocated_data['normal_points_num']

                        updated_user_points = User.objects.filter(
                            id=order.user_id,
                            is_delete=0
                        ).update(normal_points=F('normal_points') + order_goods.normal_order_allocated_data[
                            'normal_points_num'])
                        if not updated_user_points:
                            raise ValueError("操作失败")

                        UserPointsLog.objects.create(
                            scene=UserPointsLog.SCENE_REFUND,
                            point_type=UserPointsLog.POINT_TYPE_NORMAL,
                            point_num=order_goods.normal_order_allocated_data['normal_points_num'],
                            user_id=order.user_id
                        )

                        if not active_order_goods:
                            if is_refund_coupon:
                                # 退优惠券
                                UserCoupon.objects.filter(
                                    coupon_id=order.coupon_id,
                                    user_id=order.user_id
                                ).update(is_use=0)

                            # 关闭订单
                            order.order_status = 4

                    else:  # 订单 退积分

                        # 退积分
                        # 获取该订单下所有未退款的商品对应的积分总和
                        remaining_points = OrderGoods.objects.filter(
                            order_id=order.id,
                            status=1
                        ).aggregate(
                            total_points=Sum('normal_order_allocated_data__normal_points_num', output_field=IntegerField())
                        )['total_points'] or 0

                        if order.refund_normal_points + remaining_points != order.normal_points:
                            raise ValueError("积分数量异常")

                        # 退钱
                        # 获取该订单下所有已退款的商品对应的金额总和
                        refunded_goods_total_price = OrderGoods.objects.filter(
                            order_id=order.id,
                            status=3
                        ).aggregate(
                            goods_total_price=Sum('normal_order_allocated_data__total_price', output_field=DecimalField())
                        )['goods_total_price'] or 0

                        # 获取该订单下所有未退款的商品对应的金额总和
                        remaining_goods_total_price = OrderGoods.objects.filter(
                            order_id=order.id,
                            status=1
                        ).aggregate(
                            goods_total_price=Sum('normal_order_allocated_data__total_price', output_field=DecimalField())
                        )['goods_total_price'] or 0

                        if remaining_goods_total_price + refunded_goods_total_price != order.pay_price:
                            raise ValueError("金额异常")

                        order_refund.audit_status = 2
                        order_refund.audit_time = timezone.now()
                        order_refund.status = 3

                        order_refund.refund_money = remaining_goods_total_price
                        order_refund.refund_normal_points = remaining_points
                        order_refund.refund_coupon = 1

                        order_refund.save()

                        order.refund_coupon = 1
                        order.refund_normal_points += remaining_points

                        updated_user_points = User.objects.filter(
                            id=order.user_id,
                            is_delete=0
                        ).update(normal_points=F('normal_points') + remaining_points)
                        if not updated_user_points:
                            raise ValueError("操作失败")

                        UserPointsLog.objects.create(
                            scene=UserPointsLog.SCENE_REFUND,
                            point_type=UserPointsLog.POINT_TYPE_NORMAL,
                            point_num=remaining_points,
                            user_id=order.user_id
                        )

                        if order.order_status == 1:
                            # 退优惠券
                            UserCoupon.objects.filter(
                                coupon_id=order.coupon_id,
                                user_id=order.user_id
                            ).update(is_use=0)

                        # 关闭订单
                        order.order_status = 4

                    order.save()

                elif order.order_type == 2:  # 积分商城积分兑换订单

                    order_goods = OrderGoods.objects.filter(order_id=order.id).first()
                    order_goods.status = 3
                    order_goods.save()

                    order_refund.audit_status = 2
                    order_refund.audit_time = timezone.now()
                    order_refund.status = 3

                    order_refund.refund_normal_points = order_goods.points_order_allocated_data['normal_points']
                    order_refund.refund_cultural_points = order_goods.points_order_allocated_data['cultural_points']

                    order_refund.save()

                    order.refund_normal_points += order_goods.points_order_allocated_data['normal_points']
                    order.refund_cultural_points += order_goods.points_order_allocated_data['cultural_points']

                    updated_user_points = User.objects.filter(
                        id=order.user_id,
                        is_delete=0
                    ).update(
                        normal_points=F('normal_points') + order_goods.points_order_allocated_data['normal_points'],
                        cultural_points=F('cultural_points') + order_goods.points_order_allocated_data[
                            'cultural_points']
                    )
                    if not updated_user_points:
                        raise ValueError("操作失败")

                    UserPointsLog.objects.create(
                        scene=UserPointsLog.SCENE_REFUND,
                        point_type=UserPointsLog.POINT_TYPE_NORMAL,
                        point_num=order_goods.points_order_allocated_data['normal_points'],
                        user_id=order.user_id
                    )
                    UserPointsLog.objects.create(
                        scene=UserPointsLog.SCENE_REFUND,
                        point_type=UserPointsLog.POINT_TYPE_CULTURAL,
                        point_num=order_goods.points_order_allocated_data['cultural_points'],
                        user_id=order.user_id
                    )

                    # 关闭订单
                    order.order_status = 4
                    order.save()

            elif audit_status == 3:  # 平台拒绝
                order_refund.audit_status = 3
                order_refund.audit_time = timezone.now()
                order_refund.status = 2
                order_refund.save()

                if order_refund.order_goods_id:
                    # 设置此订单商品状态为 正常
                    OrderGoods.objects.filter(id=order_refund.order_goods_id).update(status=1)

    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception as e:
        print(e)
        import traceback
        traceback.print_exc()
        return APIResponse(code=1, msg='操作失败')

    return APIResponse(code=0, msg='操作成功')
