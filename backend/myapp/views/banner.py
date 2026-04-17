from django.views.decorators.http import require_GET, require_POST
from django.utils.translation import gettext, gettext_lazy

from ..models import Banner
from api_r import APIResponse

@require_GET
def get_list(request):
    banner_list = [item.to_dict() for item in Banner.objects.only('id', 'image_url', 'create_time')]
    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=banner_list
    )

@require_GET
def get_article_content(request):
    banner_id = int(request.GET.get('banner_id'))

    try:
        banner = Banner.objects.get(id=banner_id)
    except Banner.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    return APIResponse(
        code=0,
        msg='获取成功',
        data=banner.article_content
    )