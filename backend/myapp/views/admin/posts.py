import json

from django.views.decorators.http import require_GET, require_POST

from myapp.models import PostsCategory, Posts, PostsComment, PostsThumb, User, MediaFile
from api_r import APIResponse


@require_GET
def get_list(request):
    result = [item.to_dict() for item in Posts.objects.all()]

    return APIResponse(
        code=0,
        msg='获取成功',
        data=result
    )

@require_GET
def detail(request):
    posts_id = int(request.GET.get('posts_id', 0))

    try:
        posts = Posts.objects.get(id=posts_id, is_delete=0)
    except Posts.DoesNotExist:
        return APIResponse(code=1, msg='帖子不存在')

    user_info = {
        'avatar_url': '',
        'nickname': 'None'
    }
    try:
        user = User.objects.get(id=posts.user_id)
        user_info['avatar_url'] = user.avatar_url
        user_info['nickname'] = user.nickname
    except User.DoesNotExist:
        pass
        # return APIResponse(code=1, msg='用户不存在')

    return APIResponse(
        code=0,
        msg='查询成功',
        data={**posts.to_dict(), **user_info}
    )

@require_GET
def get_comment_list(request):
    posts_id = int(request.GET.get('posts_id', 0))

    comments = PostsComment.objects.filter(posts_id=posts_id).order_by('-create_time')
    comment_list = []
    for comment in comments:
        user_info = {
            'avatar_url': '',
            'nickname': ''
        }
        try:
            user = User.objects.get(id=comment.user_id)
            user_info['avatar_url'] = user.avatar_url
            user_info['nickname'] = user.nickname
        except User.DoesNotExist:
            continue

        comment_list.append({**comment.to_dict(), **user_info})
    return APIResponse(
        code=0,
        msg='查询成功',
        data=comment_list
    )

@require_POST
def delete(request):
    body = json.loads(request.body)

    posts_id = int(body.get('posts_id', 0))

    try:
        Posts.objects.get(id=posts_id, is_delete=0)
    except Posts.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    Posts.objects.filter(id=posts_id).update(is_delete=1)

    return APIResponse(code=0, msg='删除成功')
