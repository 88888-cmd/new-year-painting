import json
import uuid

from django.utils import timezone
from django.views.decorators.http import require_GET, require_POST
from django.db import transaction
from django.utils.translation import gettext, gettext_lazy

from ..models import Order, OrderAddress, OrderGoods, OrderRefund, MediaFile
from api_r import APIResponse

@require_GET
def detail(request):
    order_refund_id = int(request.GET.get('order_refund_id'))

    try:
        order_refund = OrderRefund.objects.get(id=order_refund_id, user_id=request.user.id)
        order = Order.objects.get(id=order_refund.order_id)

        relation_order_no = order.order_no
        relation_order_type = order.order_type

        if order_refund.order_goods_id:
            order_goods_list = OrderGoods.objects.filter(id=order_refund.order_goods_id)
        else:
            order_goods_list = OrderGoods.objects.filter(order_id=order_refund.order_id, status__in=[1, 2])
    except (Order.DoesNotExist, OrderAddress.DoesNotExist):
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    # relation_order_type = Order.objects.values('order_type').first()['order_type']

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
        'detail': {
            **order_refund.to_dict(),
            'relation_order_no': relation_order_no,
            'relation_order_type': relation_order_type
        },
        'order_goods_list': [order_goods.to_dict() for order_goods in order_goods_list]
    })

@require_GET
def get_list(request):
    data_v = int(request.GET.get('data_v', 1))

    order_refund_list = OrderRefund.objects.filter(user_id=request.user.id).order_by('-id')

    order_refund_dict_list = []
    for order_refund in order_refund_list:

        order = Order.objects.get(id=order_refund.order_id)
        # relation_order_type = Order.objects.values('order_type').first()['order_type']
        relation_order_no = order.order_no
        relation_order_type = order.order_type

        if order_refund.order_goods_id:
            order_goods_list = [order_goods.to_dict() for order_goods in OrderGoods.objects.filter(id=order_refund.order_goods_id)]
            order_refund_dict_list.append({**order_refund.to_dict(), **{
                'order_goods_list': order_goods_list,
                'relation_order_no': relation_order_no,
                'relation_order_type': relation_order_type
            }})
        else:
            order_goods_list = [order_goods.to_dict() for order_goods in
                                OrderGoods.objects.filter(order_id=order_refund.order_id, status__in=[1, 2])]
            order_refund_dict_list.append({**order_refund.to_dict(), **{
                'order_goods_list': order_goods_list,
                'relation_order_no': relation_order_no,
                'relation_order_type': relation_order_type
            }})

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
        'list': order_refund_dict_list,
        'data_v': data_v
    })


@require_POST
def apply(request):
    body = json.loads(request.body)

    order_id = int(body.get('order_id', 0))
    order_goods_id = int(body.get('order_goods_id', 0))
    refund_type = int(body.get('refund_type', 0))
    apply_desc = body.get('apply_desc', '')
    file_ids = body.get('apply_images_ids', [])

    if refund_type not in (1, 2):
        return APIResponse(code=1, msg=gettext_lazy('Parameter error'))

    # 验证是否自己上传的图片
    image_urls = []
    for file_id in file_ids:
        try:
            media = MediaFile.objects.get(
                id=file_id,
                user_id=request.user.id
            )
            image_urls.append(media.file.url)
        except MediaFile.DoesNotExist:
            return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    try:
        Order.objects.get(id=order_id, user_id=request.user.id)
    except Order.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    try:
        with transaction.atomic():
            order = Order.objects.select_for_update().get(
                id=order_id
            )
            if refund_type == 2 and order.order_status != 3:
                raise ValueError(gettext_lazy('Please refresh the page and try again'))
            if order.order_status == 4:
                raise ValueError(gettext_lazy('Please refresh the page and try again'))


            # 申请过退款订单（非订单商品）被平台拒绝后 不能再次申请退款
            has_rejected = OrderRefund.objects.filter(
                order_id=order_id,
                order_goods_id=0,
                status=2
            ).exists()
            if has_rejected:
                raise ValueError('该订单已被拒绝退款，无法再次申请')


            if order_goods_id: # 退订单商品
                try:
                    order_goods = OrderGoods.objects.get(id=order_goods_id)
                except OrderGoods.DoesNotExist:
                    raise ValueError(gettext_lazy('Data does not exist'))
                if order_goods.status != 1:
                    raise ValueError(gettext_lazy('Please refresh the page and try again'))
                order_goods.status = 2
                order_goods.save()


                # 是否存在未处理的 退订单
                has_refunding = OrderRefund.objects.filter(
                    order_id=order_id,
                    order_goods_id=0,
                    status=1
                ).exists()
                if has_refunding:
                    raise ValueError(gettext_lazy('There is an unprocessed refund service for this order'))

                # 是否存在未处理的 退当前订单商品
                has_goods_refunding = OrderRefund.objects.filter(
                    order_id=order_id,
                    order_goods_id=order_goods_id,
                    status=1
                ).exists()
                if has_goods_refunding:
                    raise ValueError(gettext_lazy('There is an unprocessed refund service for the products in this order'))

                # 是否存在平台已同意退款的 退当前订单商品
                has_goods_refunded = OrderRefund.objects.filter(
                    order_id=order_id,
                    order_goods_id=order_goods_id,
                    status=3
                ).exists()
                if has_goods_refunded:
                    raise ValueError(gettext_lazy('Please refresh the page and try again'))
            else: # 退订单
                has_refunding = OrderRefund.objects.filter(
                    order_id=order_id,
                    status=1
                ).exists()
                if has_refunding:
                    raise ValueError(gettext_lazy('There is an unprocessed refund service for this order'))

            OrderRefund.objects.create(
                order_id=order.id,
                order_goods_id=order_goods_id,
                refund_type=refund_type,
                refund_no=generate_refund_order_no(request.user.id),
                apply_desc=apply_desc,
                apply_image_urls=image_urls,
                user_id=request.user.id,
            )

            if order_goods_id:
                # 设置此订单商品状态为 正在申请退款中
                OrderGoods.objects.filter(id=order_goods_id).update(status=2)

    except Order.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Order does not exist or status is invalid'))
    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception as e:
        print(e)
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))
    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))



@require_POST
def cancel(request):
    body = json.loads(request.body)

    order_refund_id = int(body.get('order_refund_id', 0))

    try:
        order_refund = OrderRefund.objects.get(
            id=order_refund_id,
            status=1,
            user_id=request.user.id
        )
        Order.objects.get(id=order_refund.order_id, user_id=request.user.id)
    except (OrderRefund.DoesNotExist, Order.DoesNotExist):
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    try:
        with transaction.atomic():
            order = Order.objects.select_for_update().get(
                id=order_refund.order_id
            )
            order_refund = OrderRefund.objects.get(
                id=order_refund_id
            )
            if order_refund.status != 1:
                raise ValueError(gettext_lazy('Please refresh the page and try again'))

            order_refund.status = 4
            order_refund.save()

            if order_refund.order_goods_id:
                # 设置此订单商品状态为 正常
                OrderGoods.objects.filter(id=order_refund.order_goods_id).update(status=1)

    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception:
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))



@require_POST
def submit_express(request):
    body = json.loads(request.body)

    order_refund_id = int(body.get('order_refund_id', 0))
    express_name = body.get('express_name', '')
    express_no = body.get('express_no', '')

    if not all([order_refund_id, express_name, express_no]):
        return APIResponse(code=1, msg=gettext_lazy('Parameter error'))

    try:
        order_refund = OrderRefund.objects.get(
            id=order_refund_id,
            refund_type=2,
            audit_status=2,
            status=1,
            user_id=request.user.id
        )
        Order.objects.get(id=order_refund.order_id, user_id=request.user.id)
    except (OrderRefund.DoesNotExist, Order.DoesNotExist):
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    try:
        with transaction.atomic():
            order = Order.objects.select_for_update().get(
                id=order_refund.order_id
            )
            order_refund = OrderRefund.objects.get(
                id=order_refund_id
            )
            if order_refund.status != 1 or order_refund.is_user_send != 0:
                raise ValueError(gettext_lazy('Please refresh the page and try again'))

            OrderRefund.objects.filter(id=order_refund.id).update(
                is_user_send=1,
                send_time=timezone.now(),
                express_name=express_name,
                express_no=express_no
            )

    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception:
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))



def generate_refund_order_no(user_id: int) -> str:
    """生成唯一的退款单号"""
    now = timezone.now()
    date_part = now.strftime("%Y%m%d%H%M%S")
    unique_part = uuid.uuid4().hex[:6].upper()
    order_no = f"T{date_part}{user_id}{unique_part}"
    return order_no