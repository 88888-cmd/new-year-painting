import json

from django.views.decorators.http import require_GET, require_POST
from django.utils.translation import gettext, gettext_lazy

from ..models import User, Painting, Wish
from api_r import APIResponse

@require_GET
def get_type_list(request):
    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=Wish.TYPE_CHOICES
    )

@require_GET
def get_painting_list(request):
    paintings = Painting.objects.filter(is_delete=0).order_by('?')[:5]
    painting_list = [painting.to_dict(exclude_fields=['bg_mp3_url', 'content', 'create_time']) for painting in paintings]
    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=painting_list
    )

@require_GET
def get_list(request):

    wishes = Wish.objects.order_by('-id')
    result = []
    for wish in wishes:
        user_info = {
            'avatar_url': '',
            'nickname': 'None'
        }
        if wish.user_id == request.user.id:
            user_info['avatar_url'] = request.user.avatar_url
            user_info['nickname'] = request.user.nickname
        else:
            try:
                user = User.objects.get(id=wish.user_id)
                user_info['avatar_url'] = user.avatar_url
                user_info['nickname'] = user.nickname
            except User.DoesNotExist:
                continue

        try:
            painting = Painting.objects.get(id=wish.painting_id, is_delete=0)
        except Painting.DoesNotExist:
            continue

        result.append({**wish.to_dict(), **user_info, **{
            'painting_image_url': painting.image_url,
        }})

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=result
    )


@require_POST
def submit(request):
    body = json.loads(request.body)

    wish_type = int(body.get('wish_type', 0))
    painting_id = int(body.get('painting_id') or 0)
    content = str(body.get('content', ''))

    if painting_id != 0:
        try:
            # 获取年画详情
            painting = Painting.objects.get(id=painting_id, is_delete=0)
        except Painting.DoesNotExist:
            return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    Wish.objects.create(
        wish_type=wish_type,
        painting_id=painting_id,
        content=content,
        user_id=request.user.id
    )

    return APIResponse(
        code=0,
        msg=gettext_lazy('Operation successful')
    )