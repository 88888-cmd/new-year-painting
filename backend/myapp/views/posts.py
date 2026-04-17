import json

from django.views.decorators.http import require_GET, require_POST
from django.db.models import F
from django.db import IntegrityError
from django.utils.translation import gettext, gettext_lazy

from ..models import Posts, PostsCategory, PostsComment, PostsThumb, Painting, User, MediaFile
from api_r import APIResponse

from ..sensitive_words import has_sensitive_words

# 固定分类ID
CATEGORY_ID_OVERSEAS = 1  # 海外爱好者
CATEGORY_ID_STORY = 2  # 年画故事


@require_GET
def get_category_list(request):
    categories = [category.to_dict() for category in PostsCategory.objects.all()]
    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=categories
    )

@require_GET
def get_list(request):

    category_id = int(request.GET.get('category_id', 0))
    last_id = int(request.GET.get('last_id', -1))
    data_v = int(request.GET.get('data_v', 1))

    query_params = {}

    if category_id > 0:
        query_params['category_id'] = category_id

    try:
        query = Posts.objects.filter(is_delete=0)
        if category_id == 0:
            query = query.exclude(category_id__in=[1, 2])
        if last_id != -1:
            query = query.filter(id__lt=last_id)
        posts = query.filter(**query_params).order_by('-create_time')[:20]
        # if last_id == -1:
        #     posts = Posts.objects.filter(**query_params, is_delete=0).order_by('-create_time')[:20]
        # else:
        #     posts = Posts.objects.filter(id__lt=last_id).filter(**query_params, is_delete=0).order_by('-create_time')[:20]

        # result = [post.to_dict() for post in posts]

        result = []
        for postsItem in posts:
            user_info = {
                'avatar_url': '',
                'nickname': 'None'
            }
            if request.user is not None and postsItem.user_id == request.user.id:
                user_info['avatar_url'] = request.user.avatar_url
                user_info['nickname'] = request.user.nickname
            else:
                try:
                    user = User.objects.get(id=postsItem.user_id)
                    user_info['avatar_url'] = user.avatar_url
                    user_info['nickname'] = user.nickname
                except User.DoesNotExist:
                    continue

            comment_count = PostsComment.objects.filter(posts_id=postsItem.id).count()
            thumb_count = PostsThumb.objects.filter(posts_id=postsItem.id).count()

            result.append({**postsItem.to_dict(), **user_info, **{
                'comment_count': comment_count,
                'thumb_count': thumb_count
            }})

        return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
            'list': result,
            'data_v': data_v
        })
    except Exception as e:
        return APIResponse(code=1, msg=gettext_lazy('Query failed'))


@require_POST
def publish_posts(request):
    body = json.loads(request.body)

    post_type = int(body.get('post_type', 10))  # 10普通帖子 20年画故事
    category_id = int(body.get('category_id', 0))
    title = body.get('title', '').strip()
    content = body.get('content', '').strip()
    # file_ids = body.get('file_ids', [])
    image_urls = body.get('image_urls', [])
    tags = body.get('tags', [])


    if post_type == 10:
        if category_id == 0:
            return APIResponse(code=1, msg=gettext_lazy('Please select a category'))
        if category_id == CATEGORY_ID_OVERSEAS:
            pass
        if category_id == CATEGORY_ID_STORY:
            return APIResponse(code=1, msg=gettext_lazy('Parameter error'))

        # # 验证是否自己上传的图片
        # image_urls = []
        # for file_id in file_ids:
        #     try:
        #         media = MediaFile.objects.get(
        #             id=file_id,
        #             user_id=request.user.id
        #         )
        #         image_urls.append(media.file.url)
        #     except MediaFile.DoesNotExist:
        #         return APIResponse(code=1, msg=f'提交失败')

    elif post_type == 20:
        painting_id = int(body.get('painting_id', 0))
        # video_url = body.get('video_url', '')
        # video_cover_url = body.get('video_cover_url', '')
        video_id = body.get('video_id', 0)
        video_cover_id = body.get('video_cover_id', 0)

        if painting_id == 0:
            return APIResponse(code=1, msg='请选择年画')
        if category_id != CATEGORY_ID_STORY:
            return APIResponse(code=1, msg='必须选择年画故事分类')

        try:
            # 获取年画详情
            painting = Painting.objects.get(id=painting_id, is_delete=0)
        except Painting.DoesNotExist:
            return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

        if video_id:
            try:
                video_media = MediaFile.objects.get(
                    id=video_id,
                    user_id=request.user.id
                )
                video_url = video_media.file.url
            except MediaFile.DoesNotExist:
                return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

        if video_cover_id:
            try:
                cover_media = MediaFile.objects.get(
                    id=video_cover_id,
                    user_id=request.user.id
                )
                video_cover_url = cover_media.file.url
            except MediaFile.DoesNotExist:
                return APIResponse(code=1, msg=gettext_lazy('Operation failed'))
    else:
        return APIResponse(code=1, msg=gettext_lazy('Parameter error'))

    if has_sensitive_words(title) or has_sensitive_words(content):
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    try:
        post = Posts.objects.create(
            category_id=category_id if post_type == 10 else CATEGORY_ID_STORY,
            title=title,
            content=content,
            image_urls=image_urls if post_type == 10 else [],
            tags=tags,
            type=post_type,
            painting_id=painting.id if post_type == 20 else 0,
            painting_name=painting.name if post_type == 20 else '',
            painting_image_url=painting.image_url if post_type == 20 else '',
            video_url=video_url if post_type == 20 and video_id else '',
            video_cover_url=video_cover_url if post_type == 20 and video_cover_id else '',
            user_id=request.user.id
        )
    except Exception as e:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    return APIResponse(
        code=0,
        msg=gettext_lazy('Operation successful'),
        data=post.to_dict()
    )

@require_POST
def delete_posts(request):
    body = json.loads(request.body)

    posts_id = int(body.get('posts_id', 0))

    try:
        posts = Posts.objects.get(id=posts_id, user_id=request.user.id, is_delete=0)
    except Posts.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    Posts.objects.filter(id=posts_id).update(is_delete=1)
    # posts.delete()

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))


@require_GET
def detail(request):
    posts_id = int(request.GET.get('posts_id', 0))

    try:
        posts = Posts.objects.get(id=posts_id, is_delete=0)
    except Posts.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    user_info = {
        'avatar_url': '',
        'nickname': 'None'
    }
    if request.user is not None and posts.user_id == request.user.id:
        user_info['avatar_url'] = request.user.avatar_url
        user_info['nickname'] = request.user.nickname
    else:
        try:
            user = User.objects.get(id=posts.user_id)
            user_info['avatar_url'] = user.avatar_url
            user_info['nickname'] = user.nickname
        except User.DoesNotExist:
            return APIResponse(code=1, msg=gettext_lazy('User does not exist'))

    comment_count = PostsComment.objects.filter(posts_id=posts.id).count()
    thumb_count = PostsThumb.objects.filter(posts_id=posts.id).count()

    comments = PostsComment.objects.filter(posts_id=posts_id).order_by('-create_time')
    comment_list = []
    for comment in comments:
        user_info = {
            'avatar_url': '',
            'nickname': 'None'
        }
        if comment.user_id == request.user.id:
            user_info['avatar_url'] = request.user.avatar_url
            user_info['nickname'] = request.user.nickname
        else:
            try:
                user = User.objects.get(id=comment.user_id)
                user_info['avatar_url'] = user.avatar_url
                user_info['nickname'] = user.nickname
            except User.DoesNotExist:
                continue

        comment_list.append({**comment.to_dict(), **user_info})

    Posts.objects.filter(
        id=posts_id
    ).update(view_count=F('view_count') + 1)


    # 查询点赞状态
    thumbed = False
    if request.user is not None:
        thumbed = PostsThumb.objects.filter(
            posts_id=posts.id,
            user_id=request.user.id
        ).exists()

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data={
            'posts': {**posts.to_dict(), **user_info, **{
                'comment_count': comment_count,
                'thumb_count': thumb_count,
            }},
            'comments': comment_list,
            'thumbed': thumbed
        }
    )


@require_GET
def get_comment_list(request):
    posts_id = int(request.GET.get('posts_id', 0))

    try:
        Posts.objects.get(id=posts_id, is_delete=0)
    except Posts.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    comments = PostsComment.objects.filter(posts_id=posts_id).order_by('-id')
    comment_list = []
    for comment in comments:
        user_info = {
            'avatar_url': '',
            'nickname': 'None'
        }
        if comment.user_id == request.user.id:
            user_info['avatar_url'] = request.user.avatar_url
            user_info['nickname'] = request.user.nickname
        else:
            try:
                user = User.objects.get(id=comment.user_id)
                user_info['avatar_url'] = user.avatar_url
                user_info['nickname'] = user.nickname
            except User.DoesNotExist:
                continue

        comment_list.append({**comment.to_dict(), **user_info})

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=comment_list
    )

@require_POST
def add_comment(request):
    body = json.loads(request.body)

    posts_id = int(body.get('posts_id', 0))
    content = body.get('content', '').strip()

    if not content:
        return APIResponse(code=1, msg='评论内容不能为空')
    if has_sensitive_words(content):
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    try:
        post = Posts.objects.get(id=posts_id, is_delete=0)
    except Posts.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    comment = PostsComment.objects.create(
        posts_id=posts_id,
        content=content,
        user_id=request.user.id
    )
    return APIResponse(code=0, msg=gettext_lazy('Operation successful'), data={**comment.to_dict(), **{
        'avatar_url': request.user.avatar_url,
        'nickname': request.user.nickname
    }})


@require_POST
def delete_comment(request):
    body = json.loads(request.body)

    comment_id = int(body.get('comment_id', 0))

    try:
        comment = PostsComment.objects.get(id=comment_id, user_id=request.user.id)
    except PostsComment.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    comment.delete()

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))


@require_POST
def thumb(request):
    body = json.loads(request.body)

    posts_id = int(body.get('posts_id', 0))

    try:
        post = Posts.objects.get(id=posts_id, is_delete=0)
    except Posts.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    try:
        PostsThumb.objects.create(
            posts_id=posts_id,
            user_id=request.user.id
        )
    except IntegrityError:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))


@require_POST
def cancel_thumb(request):
    body = json.loads(request.body)

    posts_id = int(body.get('posts_id', 0))

    try:
        postsThumb = PostsThumb.objects.get(posts_id=posts_id, user_id=request.user.id)
    except PostsThumb.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    postsThumb.delete()

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))



@require_GET
def get_my_list(request):

    try:
        posts = Posts.objects.filter(user_id=request.user.id, is_delete=0).order_by('-id')

        result = []
        for postsItem in posts:
            user_info = {
                'avatar_url': '',
                'nickname': 'None'
            }
            if request.user is not None and postsItem.user_id == request.user.id:
                user_info['avatar_url'] = request.user.avatar_url
                user_info['nickname'] = request.user.nickname
            else:
                try:
                    user = User.objects.get(id=postsItem.user_id)
                    user_info['avatar_url'] = user.avatar_url
                    user_info['nickname'] = user.nickname
                except User.DoesNotExist:
                    continue

            comment_count = PostsComment.objects.filter(posts_id=postsItem.id).count()
            thumb_count = PostsThumb.objects.filter(posts_id=postsItem.id).count()

            result.append({**postsItem.to_dict(), **user_info, **{
                'comment_count': comment_count,
                'thumb_count': thumb_count
            }})

        return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
            'list': result
        })
    except Exception as e:
        return APIResponse(code=1, msg=gettext_lazy('Query exception'))