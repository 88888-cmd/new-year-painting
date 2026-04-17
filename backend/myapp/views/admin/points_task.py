import json

from django.views.decorators.http import require_GET, require_POST

from myapp.models import PointsTask, Painting
from api_r import APIResponse


@require_GET
def get_list(request):
    result = [item.to_dict() for item in PointsTask.objects.all()]

    return APIResponse(
        code=0,
        msg='获取成功',
        data=result
    )

@require_POST
def add(request):
    body = json.loads(request.body)

    task_type = int(body.get("task_type", 0))
    painting_id = int(body.get("painting_id", 0))
    daily_limit = int(body.get("daily_limit", 0))
    point_reward = int(body.get("point_reward", 0))

    if painting_id:
        try:
            painting = Painting.objects.get(id=painting_id)
        except Painting.DoesNotExist:
            return APIResponse(code=1, msg='数据不存在')

    PointsTask.objects.create(
        task_type=task_type,
        painting_id=painting_id,
        daily_limit=daily_limit,
        point_reward=point_reward
    )

    return APIResponse(code=0, msg='添加成功')


@require_POST
def delete(request):
    body = json.loads(request.body)

    task_id = int(body.get('task_id', 0))

    try:
        PointsTask.objects.get(id=task_id, is_delete=0)
    except PointsTask.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    PointsTask.objects.filter(id=task_id).update(is_delete=1)

    return APIResponse(code=0, msg='删除成功')


@require_GET
def detail(request):
    task_id = int(request.GET.get('task_id', 0))

    try:
        task = PointsTask.objects.get(id=task_id, is_delete=0)
    except PointsTask.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    return APIResponse(code=0, msg='查询成功', data=task.to_dict())

@require_POST
def edit(request):
    body = json.loads(request.body)

    task_id = int(body.get('task_id', 0))
    task_type = int(body.get("task_type", 0))
    painting_id = int(body.get("painting_id", 0))
    daily_limit = int(body.get("daily_limit", 0))
    point_reward = int(body.get("point_reward", 0))

    if painting_id:
        try:
            painting = Painting.objects.get(id=painting_id)
        except Painting.DoesNotExist:
            return APIResponse(code=1, msg='数据不存在')

    PointsTask.objects.filter(id=task_id).update(
        task_type=task_type,
        painting_id=painting_id,
        daily_limit=daily_limit,
        point_reward=point_reward
    )

    return APIResponse(code=0, msg='编辑成功')
