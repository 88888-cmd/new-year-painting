import json
from datetime import datetime

from django.utils import timezone
from django.views.decorators.http import require_GET, require_POST

from myapp.models import Painting, PaintingCalendar
from api_r import APIResponse

@require_GET
def get_list(request):
    painting_calendar_list = PaintingCalendar.objects.all().order_by('-date')

    result = []
    for item in painting_calendar_list:

        painting_name = ''
        try:
            painting = Painting.objects.get(id=item.painting_id, is_delete=0)
            painting_name = painting.name
        except Painting.DoesNotExist:
            pass

        result.append({
            **item.to_dict(),
            'painting_name': painting_name,
        })

    return APIResponse(
        code=0,
        msg='查询成功',
        data=result
    )

@require_POST
def add(request):
    body = json.loads(request.body)

    date = datetime.strptime(body.get('date'), '%Y-%m-%d').date()
    festival_name = body.get('festival_name', '')
    description = body.get('description', '')
    painting_id = int(body.get('painting_id', 0))

    PaintingCalendar.objects.create(
        date=date,
        festival_name=festival_name,
        description=description,
        painting_id=painting_id
    )

    return APIResponse(code=0, msg='添加成功')


@require_POST
def delete(request):
    body = json.loads(request.body)

    painting_calendar_id = int(body.get('painting_calendar_id', 0))

    try:
        painting_calendar = PaintingCalendar.objects.get(id=painting_calendar_id)
    except PaintingCalendar.DoesNotExist:
        return APIResponse(code=1, msg='数据不存在')

    painting_calendar.delete()

    return APIResponse(code=0, msg='删除成功')
