from django.views.decorators.http import require_GET, require_POST

from myapp.models import User
from api_r import APIResponse


@require_GET
def get_list(request):
    result = [user.to_dict() for user in User.objects.all()]

    return APIResponse(
        code=0,
        msg='获取成功',
        data=result
    )