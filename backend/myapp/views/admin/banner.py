import json

from django.views.decorators.http import require_GET, require_POST

from myapp.models import Banner
from api_r import APIResponse


@require_GET
def get_list(request):
    banner_list = [item.to_dict() for item in Banner.objects.only('id', 'image_url', 'create_time')]

    return APIResponse(
        code=0,
        msg='获取成功',
        data=banner_list
    )

@require_POST
def add(request):
    body = json.loads(request.body)

    image_url = body.get('image_url', '')

    Banner.objects.create(
        image_url=image_url,
        article_content=''
    )

    return APIResponse(code=0, msg='添加成功')


@require_POST
def delete(request):
    body = json.loads(request.body)

    banner_id = int(body.get('banner_id', 0))

    try:
        banner = Banner.objects.get(id=banner_id)
    except Banner.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    banner.delete()

    return APIResponse(code=0, msg='删除成功')

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


@require_POST
def set_article_content(request):
    body = json.loads(request.body)

    banner_id = int(body.get('banner_id', 0))
    article_content = body.get('article_content', '')

    Banner.objects.filter(id=banner_id).update(
        article_content=article_content
    )

    return APIResponse(code=0, msg='操作成功')
