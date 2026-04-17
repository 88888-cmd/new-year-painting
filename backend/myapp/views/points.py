import json

from django.utils import timezone
from django.views.decorators.http import require_GET, require_POST
from django.db.models import F, Sum, IntegerField
from django.db import transaction
from django.utils.translation import gettext, gettext_lazy

from ..models import User, PointsConfig, PointsTask, UserPointsTaskProgress, UserPointsLog, Painting, UserFavorite, PaintingComment, PointsGoods, PointsGoodsSku, PointsGoodsComment, PointsGoodsCategory

from api_r import APIResponse

@require_GET
def get_main_data(request):
    now = timezone.now()
    today = now.date()

    # 查询用户本月获得积分
    # first_day = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    # last_day = now.replace(day=31, hour=23, minute=59, second=59, microsecond=999999)
    cur_month_total_points = UserPointsLog.objects.filter(
        user_id=request.user.id,
        create_time__year=now.year,
        create_time__month=now.month,
        scene__in=[UserPointsLog.SCENE_BROWSE, UserPointsLog.SCENE_FAVORITE, UserPointsLog.SCENE_COMMENT, UserPointsLog.SCENE_GIVE],
        # create_time__range=(first_day, last_day)
    ).aggregate(Sum('point_num', output_field=IntegerField()))['point_num__sum'] or 0

    # 查询任务列表
    tasks = PointsTask.objects.filter(is_delete=0)
    task_list = []
    for task in tasks:
        if task.painting_id > 0:
            try:
                painting = Painting.objects.get(id=task.painting_id, is_delete=0)
            except Painting.DoesNotExist:
                continue

        try:
            userPointsTaskProgress = UserPointsTaskProgress.objects.get(
                task_id=task.id,
                user_id=request.user.id,
                last_complete_time__date=today
            )
            # completed = progress.today_count >= task.daily_limit
            progress = userPointsTaskProgress.today_count
        except UserPointsTaskProgress.DoesNotExist:
            progress = 0

        task_list.append({**task.to_dict(), **{
            'progress': progress,
            'painting_name': painting.name if task.painting_id else '',
        }})

    logs = UserPointsLog.objects.filter(user_id=request.user.id).order_by('-id')
    log_list = [log.to_dict() for log in logs]

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data={
            'total_points': request.user.normal_points + request.user.cultural_points,
            'normal_points': request.user.normal_points,
            'cultural_points': request.user.cultural_points,
            'cur_month_total_points': cur_month_total_points,
            'tasks': task_list,
            'logs': log_list
        }
    )

@require_POST
def complete(request):
    body = json.loads(request.body)

    task_id = int(body.get('task_id', 0))
    painting_id = int(body.get('painting_id', 0))

    try:
        task = PointsTask.objects.get(id=task_id, is_delete=0)
    except PointsTask.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    if task.painting_id and painting_id != task.painting_id:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    cool_down_seconds = 15 # 任务冷却时间 15秒，如果上一次和本次的任务类型是浏览年画，需间隔至少15秒，防止恶意调用接口获得积分
    scene_mapping = {
        1: UserPointsLog.SCENE_BROWSE,  # 浏览年画
        2: UserPointsLog.SCENE_FAVORITE,  # 收藏内容
        3: UserPointsLog.SCENE_COMMENT,  # 评论内容
    }

    now = timezone.now()
    today = now.date()

    try:
        with transaction.atomic():

            user = User.objects.select_for_update().get(id=request.user.id, is_delete=0)

            progress, created = UserPointsTaskProgress.objects.get_or_create(
                user_id=user.id,
                task_id=task_id,
                progress_date=today,
                defaults={
                    'task_type': task.task_type,
                    'today_count': 0,
                    'painting_ids': list
                }
            )

            if progress.today_count >= task.daily_limit:
                raise ValueError(gettext_lazy('The daily limit has been reached'))
            if painting_id in progress.painting_ids:
                raise ValueError(gettext_lazy('Operation failed'))

            if task.task_type == 1:# 浏览年画
                # 验证冷却时间
                if (progress.last_complete_time and
                        (now - progress.last_complete_time).total_seconds() < cool_down_seconds):
                    raise ValueError(gettext_lazy('Operation failed'))
            elif task.task_type == 2: # 收藏年画
                if task.painting_id:
                    # 验证今天是否收藏了指定年画
                    if not UserFavorite.objects.filter(
                            painting_id=task.painting_id,
                            user_id=request.user.id,
                            create_time__date=today
                    ).exists():
                        raise ValueError(gettext_lazy('Operation failed'))
                else:
                    # 验证今天是否收藏了任意一幅年画
                    if not UserFavorite.objects.filter(
                            user_id=request.user.id,
                            create_time__date=today
                    ).exists():
                        raise ValueError(gettext_lazy('Operation failed'))
            elif task.task_type == 3: # 评论年画
                if task.painting_id:
                    # 验证今天是否评论了指定年画
                    if not PaintingComment.objects.filter(
                            painting_id=task.painting_id,
                            user_id=request.user.id,
                            create_time__date=today
                    ).exists():
                        raise ValueError(gettext_lazy('Operation failed'))
                else:
                    # 验证今天是否评论了任意一幅年画
                    if not PaintingComment.objects.filter(
                            user_id=request.user.id,
                            create_time__date=today
                    ).exists():
                        raise ValueError(gettext_lazy('Operation failed'))


            progress.today_count += 1
            progress.last_complete_time = timezone.now()
            progress.painting_ids.append(painting_id)
            progress.save()

            # 保存用户积分记录
            UserPointsLog.objects.create(
                scene=scene_mapping[task.task_type],
                point_type=UserPointsLog.POINT_TYPE_CULTURAL,
                point_num=task.point_reward,
                user_id=user.id
            )
            # 更新用户积分
            userUpdated = User.objects.filter(
                id=user.id
            ).update(cultural_points=F('cultural_points') + task.point_reward)
            if not userUpdated:
                raise ValueError(gettext_lazy('Operation failed'))
    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception:
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))

    return APIResponse(
        code=0,
        msg=gettext_lazy('Operation successful'),
        data={
            'point_reward': task.point_reward
        }
    )


@require_GET
def get_goods_category_list(request):
    categories = [category.to_dict() for category in PointsGoodsCategory.objects.all()]
    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=categories
    )

@require_GET
def get_goods_list(request):

    category_id = int(request.GET.get('category_id', 0))
    data_v = int(request.GET.get('data_v', 1))

    if category_id == 0:
        goods = PointsGoods.objects.filter(is_delete=0).order_by('-create_time')[:20]
    else:
        goods = PointsGoods.objects.filter(category_id=category_id, is_delete=0).order_by('-create_time')[:20]

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data={
            'goods_list': [goods.to_dict(include_sku=True) for goods in goods],
            'data_v': data_v
        }
    )

@require_GET
def goods_detail(request):

    goods_id = int(request.GET.get('goods_id', 0))

    try:
        goods = PointsGoods.objects.get(id=goods_id, is_delete=0)
        skus = PointsGoodsSku.objects.filter(goods_id=goods_id)
        comments = PointsGoodsComment.objects.filter(goods_id=goods_id).order_by('-create_time')[:2]
    except PointsGoods.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
        'goods': goods.to_dict(),
        'skus': [sku.to_dict() for sku in skus],
        'comments': [comment.to_dict() for comment in comments]
    })

@require_GET
def get_comment_list(request):

    goods_id = int(request.GET.get('goods_id', 0))

    comments = PointsGoodsComment.objects.filter(goods_id=goods_id).order_by('-id')

    result = []
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

        result.append({**comment.to_dict(), **user_info})

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=result
    )