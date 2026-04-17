import json

from django.views.decorators.http import require_GET, require_POST
from django.db import transaction

from myapp.models import FreightTemp, FreightTempRegion
from api_r import APIResponse


@require_GET
def get_list(request):
    result = [item.to_dict() for item in FreightTemp.objects.all()]

    return APIResponse(
        code=0,
        msg='获取成功',
        data=result
    )


@require_POST
def add(request):
    body = json.loads(request.body)

    name = body.get('name', '')
    regions = body.get('regions', [])

    if not regions:
        return APIResponse(code=1, msg='未设置区域')

    try:
        with transaction.atomic():
            freight_temp = FreightTemp.objects.create(name=name)

            region_objects = []
            for region in regions:
                region_objects.append(FreightTempRegion(
                    freight_temp=freight_temp,
                    region_name=region.get('region_name', ''),
                    is_default=region.get('is_default', 0),
                    province_code=region.get('province_code', ''),
                    city_code=region.get('city_code', ''),
                    first=region.get('first', 0),
                    first_price=region.get('first_price', 0),
                    continue_num=region.get('continue_num', 0),
                    continue_price=region.get('continue_price', 0),
                ))
            FreightTempRegion.objects.bulk_create(region_objects)
    except Exception as e:
        return APIResponse(
            code=1,
            msg='添加异常'
        )

    return APIResponse(
        code=0,
        msg='添加成功'
    )


@require_GET
def detail(request):
    temp_id = int(request.GET.get('temp_id', 0))

    try:
        freight_temp = FreightTemp.objects.get(id=temp_id, is_delete=0)
        detail = freight_temp.to_dict()
        regions = [
            region.to_dict() for region in freight_temp.freight_temp_regions.all()
        ]
    except FreightTemp.DoesNotExist:
        return APIResponse(code=1, msg='模板不存在')
    return APIResponse(code=0, msg='查询成功', data={
        **detail,
        'regions': regions
    })

@require_POST
def edit(request):
    body = json.loads(request.body)

    temp_id = body.get('temp_id')
    name = body.get('name', '')
    regions = body.get('regions', [])

    if not regions:
        return APIResponse(code=1, msg='未设置区域')

    try:
        FreightTemp.objects.get(id=temp_id, is_delete=0)
    except FreightTemp.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    try:
        with transaction.atomic():
            freight_temp = FreightTemp.objects.get(id=temp_id, is_delete=0)
            freight_temp.name = name
            freight_temp.save()

            FreightTempRegion.objects.filter(freight_temp=freight_temp).delete()

            region_objects = []
            for region in regions:
                region_objects.append(FreightTempRegion(
                    freight_temp=freight_temp,
                    region_name=region.get('region_name', ''),
                    is_default=region.get('is_default', 0),
                    province_code=region.get('province_code', ''),
                    city_code=region.get('city_code', ''),
                    first=region.get('first', 0),
                    first_price=region.get('first_price', 0),
                    continue_num=region.get('continue_num', 0),
                    continue_price=region.get('continue_price', 0),
                ))
            FreightTempRegion.objects.bulk_create(region_objects)

    except Exception as e:
        return APIResponse(code=1, msg='编辑异常')

    return APIResponse(code=0, msg='编辑成功')

@require_POST
def delete(request):
    body = json.loads(request.body)

    temp_id = int(body.get('temp_id', 0))

    try:
        FreightTemp.objects.get(id=temp_id, is_delete=0)
    except FreightTemp.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    FreightTemp.objects.filter(id=temp_id).update(is_delete=1)

    return APIResponse(code=0, msg='删除成功')