import json
import decimal

from django.views.decorators.http import require_GET, require_POST

from myapp.models import PointsConfig
from api_r import APIResponse
from myapp.utils import check_amount


@require_GET
def get_points_config(request):
    points_config = PointsConfig.objects.first()
    points_config_dict = {
        'order_fixed_points': points_config.order_fixed_points if points_config else 0,
        'normal_points_max_num': points_config.normal_points_max_num if points_config else 200,
        'normal_points_per_yuan': points_config.normal_points_per_yuan if points_config else decimal.Decimal('0.00')
    }

    return APIResponse(
        code=0,
        msg='获取成功',
        data=points_config_dict
    )

@require_POST
def set_points_config(request):
    body = json.loads(request.body)

    order_fixed_points = int(body.get("order_fixed_points", 0))
    normal_points_max_num = int(body.get("normal_points_max_num", 0))
    normal_points_per_yuan = check_amount(body.get("normal_points_per_yuan", '0'))

    points_config, created = PointsConfig.objects.get_or_create(
        defaults={
            'order_fixed_points': order_fixed_points,
            'normal_points_max_num': normal_points_max_num,
            'normal_points_per_yuan': normal_points_per_yuan
        }
    )

    if not created:
        points_config.order_fixed_points = order_fixed_points
        points_config.normal_points_max_num = normal_points_max_num
        points_config.normal_points_per_yuan = normal_points_per_yuan
        points_config.save()

    return APIResponse(code=0, msg='设置成功')