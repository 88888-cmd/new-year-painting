import json

from django.utils import timezone
from django.views.decorators.http import require_GET, require_POST
from django.db import transaction

from myapp.models import User, UserCoupon, UserAddress, UserPointsLog, Goods, GoodsSku, GoodsCart, GoodsComment, PointsGoods, PointsGoodsSku, PointsConfig, FreightTemp, Order, OrderAddress, OrderGoods, OrderRefund
from api_r import APIResponse

@require_GET
def get_list(request):
    status = int(request.GET.get('status'))
    data_v = int(request.GET.get('data_v', 1))

    if status not in (0 ,1, 2, 3, 4):
        return APIResponse(code=1, msg='查询失败')
    if status == 0:
        orders = Order.objects.order_by('-id')
    else:
        orders = Order.objects.filter(order_status=status).order_by('-id')

    result = [item.to_dict() for item in orders]

    return APIResponse(code=0, msg='查询成功', data={
        'list': result,
        'data_v': data_v
    })

@require_GET
def detail(request):
    order_id = int(request.GET.get('order_id'))
    data_v = int(request.GET.get('data_v', 1))

    try:
        order = Order.objects.get(id=order_id)
        address = OrderAddress.objects.get(order_id=order.id)
        order_goods_list = OrderGoods.objects.filter(order_id=order.id)
    except (Order.DoesNotExist, OrderAddress.DoesNotExist):
        return APIResponse(code=1, msg='数据不存在')

    return APIResponse(code=0, msg='查询成功', data={
        'order': order.to_dict(),
        'address': address.to_dict(),
        'order_goods_list': [order_goods.to_dict() for order_goods in order_goods_list],
        'data_v': data_v
    })

@require_POST
def delivery(request):
    body = json.loads(request.body)

    order_id = int(body.get('order_id', 0))
    express_name = body.get('express_name', '')
    express_no = body.get('express_no', '')

    if not all([order_id, express_name, express_no]):
        return APIResponse(code=1, msg='参数不完整')

    try:
        with transaction.atomic():
            order = Order.objects.select_for_update().get(
                id=order_id
            )
            if order.order_status != 1:
                raise ValueError('该订单状态无需发货')

            has_refunding = OrderRefund.objects.filter(
                order_id=order_id,
                status=1
            ).exists()
            if has_refunding:
                raise ValueError('该订单存在未处理的售后')

            order.order_status = 2
            order.delivery_time = timezone.now()
            order.express_name = express_name
            order.express_no = express_no
            order.save()

    except Order.DoesNotExist:
        return APIResponse(code=1, msg='订单不存在或状态不允许发货')
    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception:
        return APIResponse(code=1, msg='操作失败')

    return APIResponse(code=0, msg='操作成功')
