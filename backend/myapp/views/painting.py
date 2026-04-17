import json

from django.views.decorators.http import require_GET, require_POST
from django.db.models import Avg, IntegerField
from django.db import IntegrityError
from django.conf import settings
from django.utils.translation import gettext, gettext_lazy

from ..models import PaintingStyle, PaintingTheme, PaintingDynasty, PaintingAuthor, Painting, PaintingComment, PaintingStar, User, UserFavorite, UserView
from api_r import APIResponse

from ..sensitive_words import has_sensitive_words

from langchain_community.chat_models.tongyi import ChatTongyi
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
chatLLM = ChatTongyi(
    streaming=False,
    api_key=settings.DASHSCOPE_API_KEY,
    model='qwen-turbo'
)


@require_GET
def get_filter_options(request):
    styles = [style.to_dict() for style in PaintingStyle.objects.all()]
    themes = [theme.to_dict() for theme in PaintingTheme.objects.all()]
    dynasties = [dynasty.to_dict() for dynasty in PaintingDynasty.objects.all()]
    authors = [author.to_dict() for author in PaintingAuthor.objects.all()]

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data={
            'styles': styles,
            'themes': themes,
            'dynasties': dynasties,
            'authors': authors
        }
    )


@require_GET
def get_random_list(request):
    try:
        paintings = Painting.objects.filter(is_delete=0).order_by('?')[:20]

        painting_list = [painting.to_dict(exclude_fields=['bg_mp3_url', 'content', 'create_time']) for painting in
                         paintings]
        return APIResponse(code=0, msg=gettext_lazy('Query successful'), data=painting_list)
    except Exception as e:
        return APIResponse(code=1, msg=gettext_lazy('Query failed'))

@require_GET
def get_list(request):
    # style = request.GET.get('style', 'none')
    # theme = request.GET.get('theme', 'none')
    # dynasty = request.GET.get('dynasty', 'none')
    # author = request.GET.get('author', 'none')
    #
    # last_id = int(request.GET.get('last_id', -1))
    #
    # query_params = {}
    # if style != 'none':
    #     query_params['style'] = style
    # if theme != 'none':
    #     query_params['theme'] = theme
    # if dynasty != 'none':
    #     query_params['dynasty'] = dynasty
    # if author != 'none':
    #     query_params['author'] = author

    style_id = int(request.GET.get('style_id', 0))
    theme_id = int(request.GET.get('theme_id', 0))
    dynasty_id = int(request.GET.get('dynasty_id', 0))
    author_id = int(request.GET.get('author_id', 0))
    last_id = int(request.GET.get('last_id', -1))
    data_v = int(request.GET.get('data_v', 1))

    query_params = {}
    if style_id > 0:
        query_params['style_id'] = style_id
    if theme_id > 0:
        query_params['theme_id'] = theme_id
    if dynasty_id > 0:
        query_params['dynasty_id'] = dynasty_id
    if author_id > 0:
        query_params['author_id'] = author_id

    try:
        if last_id == -1:
            paintings = Painting.objects.filter(**query_params, is_delete=0).order_by('-create_time')[:20]
        else:
            paintings = Painting.objects.filter(id__lt=last_id).filter(**query_params, is_delete=0).order_by('-create_time')[:20]

        painting_list = [painting.to_dict(exclude_fields=['bg_mp3_url', 'content', 'create_time']) for painting in paintings]

        return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
            'painting_list': painting_list,
            'data_v': data_v
        })
    except Exception as e:
        print(e)
        return APIResponse(code=1, msg=gettext_lazy('Query exception'))


@require_GET
def detail(request):
    painting_id = int(request.GET.get('id', 0))

    try:
        # 获取年画详情
        painting = Painting.objects.get(id=painting_id, is_delete=0)
    except Painting.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    # 获取年画评论列表
    comments = PaintingComment.objects.filter(painting_id=painting_id).order_by('-create_time')
    comment_list = []
    for comment in comments:
        user_info = {
            'avatar_url': '',
            'nickname': 'None'
        }
        if request.user is not None and comment.user_id == request.user.id:
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


    # 评分人数
    rating_count =  PaintingStar.objects.filter(painting_id=painting_id).count()

    # 计算平均评分
    avg_rating = PaintingStar.objects.filter(painting_id=painting_id).aggregate(Avg('star_count', output_field=IntegerField()))
    avg_rating = avg_rating['star_count__avg'] or 5

    user_rating = -1
    if request.user is not None:
        try:
            user_rating = PaintingStar.objects.get(
                painting_id=painting_id,
                user_id=request.user.id
            ).star_count
        except PaintingStar.DoesNotExist:
            user_rating = -1  # 用户自己未评分

    # 查询收藏状态
    favorited = False
    if request.user is not None:
        favorited = UserFavorite.objects.filter(
            painting_id=painting_id,
            user_id=request.user.id
        ).exists()

    if request.user is not None:
        UserView.objects.get_or_create(
            painting_id=painting_id,
            user_id=request.user.id,
        )

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
        'painting': painting.to_dict(),
        'comments': comment_list,
        'rating_count': rating_count,  # 评分人数
        'avg_rating': avg_rating,  # 平均评分
        'user_rating': user_rating,  # 用户自己的评分
        'favorited': favorited
    })


@require_GET
def get_comment_list(request):
    painting_id = int(request.GET.get('painting_id', 0))

    try:
        # 获取年画详情
        painting = Painting.objects.get(id=painting_id, is_delete=0)
    except Painting.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    # 获取年画评论列表
    comments = PaintingComment.objects.filter(painting_id=painting_id).order_by('-id')
    comment_list = []
    for comment in comments:
        user_info = {
            'avatar_url': '',
            'nickname': 'None'
        }
        if request.user is not None and comment.user_id == request.user.id:
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

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data=comment_list)


# def load_sensitive_words(file_path):
#     """从本地文本路径中加载敏感词"""
#     try:
#         with open(file_path, 'r', encoding='utf-8') as f:
#             words = [line.strip() for line in f if line.strip()]
#         return words
#     except Exception as e:
#         print(f"加载敏感词文件失败: {e}")
#         return []

@require_POST
def add_comment(request):
    body = json.loads(request.body)

    painting_id = int(body.get('painting_id'))
    content = body.get('content', '').strip()

    if not content:
        return APIResponse(code=1, msg=gettext_lazy('Comment content cannot be empty'))
    if has_sensitive_words(content):
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    # # 检查内容中是否包含敏感词
    # sensitive_words = load_sensitive_words(settings.SENSITIVE_WORDS_PATH)
    # for word in sensitive_words:
    #     if word in content:
    #         return APIResponse(code=1, msg='提交失败')

    try:
        # 获取年画详情
        painting = Painting.objects.get(id=painting_id, is_delete=0)
    except Painting.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    comment = PaintingComment.objects.create(
        painting_id=painting_id,
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

    comment_id = int(body.get('comment_id'))

    try:
        comment = PaintingComment.objects.get(id=comment_id, user_id=request.user.id)
    except PaintingComment.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    comment.delete()

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))


@require_POST
def rate_painting(request):
    body = json.loads(request.body)

    painting_id = int(body.get('painting_id'))
    star_count = int(body.get('star_count'))

    if star_count < 1 or star_count > 5:
        return APIResponse(code=1, msg='评分必须在1-5之间')

    try:
        # 获取年画详情
        painting = Painting.objects.get(id=painting_id, is_delete=0)
    except Painting.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    try:
        PaintingStar.objects.create(
            painting_id=painting_id,
            star_count=star_count,
            user_id=request.user.id
        )
    except IntegrityError:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))


@require_POST
def favorite_painting(request):
    body = json.loads(request.body)

    painting_id = int(body.get('painting_id'))

    try:
        # 获取年画详情
        painting = Painting.objects.get(id=painting_id, is_delete=0)
    except Painting.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    try:
        UserFavorite.objects.create(
            painting_id=painting_id,
            user_id=request.user.id
        )
    except IntegrityError:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))

@require_POST
def cancel_favorite_painting(request):
    body = json.loads(request.body)

    painting_id = int(body.get('painting_id'))

    try:
        userFavorite = UserFavorite.objects.get(painting_id=painting_id, user_id=request.user.id)
    except UserFavorite.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    userFavorite.delete()

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))



AI_STORY_TYPES = {
    10: '民间传说',
    20: '神话故事',
    30: '历史典故',
    40: '寓言',
    50: '现代演绎'
}

@require_POST
def ai_story(request):
    body = json.loads(request.body)

    painting_id = int(body.get('painting_id'))
    story_type = int(body.get('type', 10))

    if story_type not in AI_STORY_TYPES:
        return APIResponse(code=1, msg=gettext_lazy('Parameter error'))

    try:
        # 获取年画详情
        painting = Painting.objects.get(id=painting_id, is_delete=0)
    except Painting.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    res = chatLLM.invoke([
        HumanMessage(
            content=f"""
            # 角色
你是一位精通{AI_STORY_TYPES[story_type]}的说书人，擅长将年画元素转化为引人入胜的故事。你的故事不仅富有文化内涵，还能够生动地展现年画中的细节和寓意。

## 技能
### 技能1: 年画元素解读
- 根据用户提供的年画信息，深入解读年画中的各个元素及其象征意义。
- 识别年画中的主要角色、场景和情节线索。

### 技能2: 故事创作
- 将年画中的元素转化为一个完整的{AI_STORY_TYPES[story_type]}故事。
- 确保故事结构完整，包括开头、发展、高潮和结尾。
- 使故事内容丰富且具有吸引力，能够吸引听众的兴趣。
- 保持故事的文化真实性和历史背景。

### 技能3: 文化背景介绍
- 在故事中适当穿插相关的文化背景和历史知识，增加故事的深度和广度。
- 用简洁明了的语言解释一些复杂的文化概念，使听众易于理解。

## 限制
- 只讨论与年画和故事类型相关的内容。
- 保持故事的真实性和文化准确性，避免引入不准确或虚构的历史信息。
- 在创作过程中，确保故事的连贯性和逻辑性，避免出现矛盾或不合理的部分。
- 语言表达要通俗易懂，适合不同年龄段的听众。
- 输出语言：{request.LANGUAGE_CODE}。

### 输入数据
{painting.to_dict()}

### 故事类型
{AI_STORY_TYPES[story_type]}"""
        ),
    ])
    print(res.content)

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data=res.content)


@require_GET
def get_my_favorited(request):

    ids = UserFavorite.objects.filter(user_id=request.user.id).values_list('painting_id', flat=True)
    paintings = Painting.objects.filter(id__in=ids, is_delete=0)

    painting_list = [painting.to_dict(exclude_fields=['bg_mp3_url', 'content', 'create_time']) for painting in
                     paintings]

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data=painting_list)


@require_GET
def get_my_view(request):

    ids = UserView.objects.filter(user_id=request.user.id).values_list('painting_id', flat=True)
    paintings = Painting.objects.filter(id__in=ids, is_delete=0)

    painting_list = [painting.to_dict(exclude_fields=['bg_mp3_url', 'content', 'create_time']) for painting in
                     paintings]

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data=painting_list)
