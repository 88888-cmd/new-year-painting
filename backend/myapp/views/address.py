import json

from django.views.decorators.http import require_GET, require_POST
from django.utils.translation import gettext, gettext_lazy

from ..models import User, UserAddress
from api_r import APIResponse

@require_GET
def get_list(request):
    address_list = [address.to_dict() for address in UserAddress.objects.filter(user_id=request.user.id)]
    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=address_list
    )


@require_POST
def create(request):
    body = json.loads(request.body)

    name = body.get('name', '')
    phone = body.get('phone', '')
    province = body.get('province', '')
    province_code = body.get('province_code', '')
    city = body.get('city', '')
    city_code = body.get('city_code', '')
    district = body.get('district', '')
    district_code = body.get('district_code', '')
    detail = body.get('detail', '')

    UserAddress.objects.create(
        name=name,
        phone=phone,
        province=province,
        province_code=province_code,
        city=city,
        city_code=city_code,
        district=district,
        district_code=district_code,
        detail=detail,
        user_id=request.user.id
    )

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))

@require_GET
def detail(request):
    address_id = int(request.GET.get('address_id', 0))
    try:
        address = UserAddress.objects.get(id=address_id, user_id=request.user.id)
    except UserAddress.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data=address.to_dict())

@require_POST
def edit(request):
    body = json.loads(request.body)

    address_id = int(body.get('address_id', 0))
    name = body.get('name', '')
    phone = body.get('phone', '')
    province = body.get('province', '')
    province_code = body.get('province_code', '')
    city = body.get('city', '')
    city_code = body.get('city_code', '')
    district = body.get('district', '')
    district_code = body.get('district_code', '')
    detail = body.get('detail', '')

    UserAddress.objects.filter(id=address_id, user_id=request.user.id).update(
        name=name,
        phone=phone,
        province=province,
        province_code=province_code,
        city=city,
        city_code=city_code,
        district=district,
        district_code=district_code,
        detail=detail
    )

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))

@require_POST
def delete_address(request):
    body = json.loads(request.body)

    address_id = int(body.get('address_id', 0))

    try:
        userAddress = UserAddress.objects.get(id=address_id, user_id=request.user.id)
    except UserAddress.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    userAddress.delete()

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))
