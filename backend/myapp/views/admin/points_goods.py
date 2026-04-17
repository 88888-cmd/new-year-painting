import json

from django.views.decorators.http import require_GET, require_POST
from django.db import transaction
from myapp.models import PointsGoodsCategory, PointsGoods, PointsGoodsSku, PointsGoodsComment, FreightTemp, MediaFile
from api_r import APIResponse
from myapp.utils import check_amount


@require_GET
def get_list(request):
    result = [item.to_dict() for item in PointsGoods.objects.all()]

    return APIResponse(
        code=0,
        msg='获取成功',
        data=result
    )


@require_POST
def add(request):
    body = json.loads(request.body)

    category_id = int(body.get('category_id', 0))
    image_urls = body.get('image_urls', '')
    name = body.get('name', '')
    detail_url = body.get('detail_url', '')
    freight_type = int(body.get('freight_type', 0))
    freight_price = check_amount(body.get('freight_price') or 0)
    freight_temp_id = int(body.get('freight_temp_id') or 0)
    skus = body.get('skus', [])

    try:
        PointsGoodsCategory.objects.get(id=category_id)
    except PointsGoodsCategory.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    if freight_type == 3 and freight_temp_id:
        try:
            FreightTemp.objects.get(id=freight_temp_id, is_delete=0)
        except FreightTemp.DoesNotExist:
            return APIResponse(code=1, msg='数据不存在')

    try:
        with transaction.atomic():
            goods = PointsGoods.objects.create(
                category_id=category_id,
                image_urls=image_urls,
                name=name,
                detail_url=detail_url,
                freight_type=freight_type,
                freight_price=freight_price if freight_type == 2 else 0,
                freight_temp_id=freight_temp_id
            )

            sku_instances = []
            for sku_data in skus:
                sku_name = sku_data.get('name', '')
                point_num = check_amount(sku_data.get('point_num', '0'))

                sku_instances.append(PointsGoodsSku(
                    goods_id=goods.id,
                    sku_name=sku_name,
                    point_num=point_num
                ))

            if not sku_instances:
                raise Exception('没有规格')

            PointsGoodsSku.objects.bulk_create(sku_instances)
    except Exception as e:
        return APIResponse(
            code=1,
            msg='添加异常'
        )

    return APIResponse(
        code=0,
        msg='添加成功'
    )


@require_POST
def edit(request):
    body = json.loads(request.body)

    goods_id = int(body.get('goods_id', 0))
    category_id = int(body.get('category_id', 0))
    image_urls = body.get('image_urls', '')
    name = body.get('name', '')
    detail_url = body.get('detail_url', '')
    freight_type = int(body.get('freight_type', 0))
    freight_price = check_amount(body.get('freight_price') or 0)
    freight_temp_id = int(body.get('freight_temp_id') or 0)
    skus = body.get('skus', [])

    try:
        PointsGoodsCategory.objects.get(id=category_id)
    except PointsGoodsCategory.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    if freight_type == 3:
        try:
            FreightTemp.objects.get(id=freight_temp_id, is_delete=0)
        except FreightTemp.DoesNotExist:
            return APIResponse(code=1, msg='数据不存在')

    try:
        with transaction.atomic():
            PointsGoods.objects.filter(id=goods_id).update(
                category_id=category_id,
                image_urls=image_urls,
                name=name,
                detail_url=detail_url,
                freight_type=freight_type,
                freight_price=freight_price if freight_type == 2 else 0,
                freight_temp_id=freight_temp_id
            )

            PointsGoodsSku.objects.filter(goods_id=goods_id).delete()
            sku_instances = []
            for sku_data in skus:
                sku_name = sku_data.get('name', '')
                point_num = check_amount(sku_data.get('point_num', '0'))

                sku_instances.append(PointsGoodsSku(
                    goods_id=goods_id,
                    sku_name=sku_name,
                    point_num=point_num
                ))

            if not sku_instances:
                raise Exception('没有规格')

            PointsGoodsSku.objects.bulk_create(sku_instances)
    except Exception as e:
        return APIResponse(
            code=1,
            msg='编辑异常'
        )

    return APIResponse(
        code=0,
        msg='编辑成功'
    )

@require_POST
def delete(request):
    body = json.loads(request.body)

    goods_id = int(body.get('goods_id', 0))

    try:
        PointsGoods.objects.get(id=goods_id, is_delete=0)
    except PointsGoods.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    PointsGoods.objects.filter(id=goods_id).update(is_delete=1)

    return APIResponse(code=0, msg='删除成功')


@require_GET
def detail(request):

    goods_id = int(request.GET.get('goods_id', 0))

    try:
        goods = PointsGoods.objects.get(id=goods_id, is_delete=0)
        skus = PointsGoodsSku.objects.filter(goods_id=goods_id)
    except PointsGoods.DoesNotExist:
        return APIResponse(code=1, msg='商品不存在')

    return APIResponse(code=0, msg='查询成功', data={
        **goods.to_dict(),
        'skus': [sku.to_dict() for sku in skus]
    })