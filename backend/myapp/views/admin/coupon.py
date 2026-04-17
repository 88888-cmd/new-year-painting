import json

from django.views.decorators.http import require_GET, require_POST

from myapp.models import Coupon, UserCoupon
from api_r import APIResponse
from myapp.utils import check_amount


@require_GET
def get_list(request):
    result = [item.to_dict() for item in Coupon.objects.all()]

    return APIResponse(
        code=0,
        msg='获取成功',
        data=result
    )

@require_GET
def get_log_list(request):
    result = [item.to_dict() for item in UserCoupon.objects.all()]

    return APIResponse(
        code=0,
        msg='获取成功',
        data=result
    )

@require_POST
def add(request):
    body = json.loads(request.body)

    name = body.get('name', '')
    reduce_price = check_amount(body.get("reduce_price", '0'))
    min_price = check_amount(body.get("min_price", '0'))
    total_num = int(body.get("total_num", 0))
    expire_day = int(body.get("expire_day", 0))

    if expire_day <= 0:
        return APIResponse(code=1, msg='有效期天数无效')

    Coupon.objects.create(
        name=name,
        reduce_price=reduce_price,
        min_price=min_price,
        total_num=total_num,
        expire_day=expire_day
    )

    return APIResponse(code=0, msg='添加成功')


@require_POST
def delete(request):
    body = json.loads(request.body)

    coupon_id = int(body.get('coupon_id', 0))

    try:
        Coupon.objects.get(id=coupon_id, is_delete=0)
    except Coupon.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    Coupon.objects.filter(id=coupon_id).update(is_delete=1)

    return APIResponse(code=0, msg='删除成功')
