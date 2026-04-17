import json

from django.views.decorators.http import require_GET, require_POST

from myapp.models import PaintingStyle, PaintingTheme, PaintingDynasty, PaintingAuthor, Painting, MediaFile
from api_r import APIResponse


@require_GET
def get_list(request):
    result = [painting.to_dict() for painting in Painting.objects.all()]

    return APIResponse(
        code=0,
        msg='获取成功',
        data=result
    )

@require_GET
def get_filter_options(request):
    styles = [style.to_dict() for style in PaintingStyle.objects.all()]
    themes = [theme.to_dict() for theme in PaintingTheme.objects.all()]
    dynasties = [dynasty.to_dict() for dynasty in PaintingDynasty.objects.all()]
    authors = [author.to_dict() for author in PaintingAuthor.objects.all()]

    return APIResponse(
        code=0,
        msg='获取成功',
        data={
            'styles': styles,
            'themes': themes,
            'dynasties': dynasties,
            'authors': authors
        }
    )

@require_POST
def add(request):
    body = json.loads(request.body)

    image_url = body.get('image_url', '')
    bg_mp3_url = body.get('bg_mp3_url', '')
    name = body.get('name', '')
    style_id = int(body.get('style_id') or 0)
    theme_id = int(body.get('theme_id') or 0)
    dynasty_id = int(body.get('dynasty_id') or 0)
    author_id = int(body.get('author_id') or 0)
    content = body.get('content', '')

    Painting.objects.create(
        image_url=image_url,
        bg_mp3_url=bg_mp3_url,
        name=name,
        style_id=style_id,
        theme_id=theme_id,
        dynasty_id=dynasty_id,
        author_id=author_id,
        content=content
    )

    return APIResponse(
        code=0,
        msg='添加成功'
    )


@require_POST
def edit(request):
    body = json.loads(request.body)

    painting_id = int(body.get('painting_id', 0))
    image_url = body.get('image_url', '')
    bg_mp3_url = body.get('bg_mp3_url', '')
    name = body.get('name', '')
    style_id = int(body.get('style_id') or 0)
    theme_id = int(body.get('theme_id') or 0)
    dynasty_id = int(body.get('dynasty_id') or 0)
    author_id = int(body.get('author_id') or 0)
    content = body.get('content', '')

    Painting.objects.filter(id=painting_id).update(
        image_url=image_url,
        bg_mp3_url=bg_mp3_url,
        name=name,
        style_id=style_id,
        theme_id=theme_id,
        dynasty_id=dynasty_id,
        author_id=author_id,
        content=content
    )

    return APIResponse(
        code=0,
        msg='添加成功'
    )

@require_GET
def detail(request):
    painting_id = int(request.GET.get('painting_id', 0))

    try:
        painting = Painting.objects.get(id=painting_id, is_delete=0)
    except Painting.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')
    return APIResponse(
        code=0,
        msg='查询成功',
        data=painting.to_dict()
    )

@require_POST
def delete(request):
    body = json.loads(request.body)

    painting_id = int(body.get('painting_id', 0))

    try:
        painting = Painting.objects.get(id=painting_id, is_delete=0)
    except Painting.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    Painting.objects.filter(id=painting_id).update(is_delete=1)

    return APIResponse(code=0, msg='删除成功')