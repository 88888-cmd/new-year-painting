import json

from django.views.decorators.http import require_GET, require_POST

from myapp.models import PointsGoodsCategory
from api_r import APIResponse


@require_GET
def get_list(request):
    categories = [category.to_dict() for category in PointsGoodsCategory.objects.all()]
    return APIResponse(
        code=0,
        msg='获取成功',
        data=categories
    )

@require_POST
def add(request):
    body = json.loads(request.body)

    name = body.get('name', '')

    PointsGoodsCategory.objects.create(name=name)

    return APIResponse(code=0, msg='添加成功')

@require_POST
def edit(request):
    body = json.loads(request.body)

    category_id = int(body.get('category_id', 0))
    name = body.get('name', '')

    PointsGoodsCategory.objects.filter(id=category_id).update(name=name)

    return APIResponse(code=0, msg='编辑成功')

@require_POST
def delete(request):
    body = json.loads(request.body)

    category_id = int(body.get('category_id', 0))

    try:
        category = PointsGoodsCategory.objects.get(id=category_id)
    except PointsGoodsCategory.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    category.delete()

    return APIResponse(code=0, msg='删除成功')
