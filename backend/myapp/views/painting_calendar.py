import json
from datetime import timedelta
from django.utils import timezone
from django.views.decorators.http import require_GET, require_POST
from django.utils.translation import gettext, gettext_lazy

from ..models import User, Painting, PaintingCalendar
from api_r import APIResponse

@require_GET
def get_data(request):
    base_date = timezone.now().date()

    current_month_name = f"{base_date.year}年 {base_date.month}月"

    days_since_monday = base_date.weekday()
    monday = base_date - timedelta(days=days_since_monday)

    week_days = []
    weekday_names = ['一', '二', '三', '四', '五', '六', '日']

    for i in range(7):
        current_date = monday + timedelta(days=i)
        is_today = current_date == timezone.now().date()

        week_days.append({
            'day': current_date.day,
            'date': current_date.strftime('%Y-%m-%d'),
            'weekday': weekday_names[current_date.weekday()],
            'is_today': is_today,
            'month': current_date.month,
            'year': current_date.year
        })

    target_date = base_date.strftime('%Y-%m-%d')
    try:
        calendar_item = PaintingCalendar.objects.get(date=target_date)
    except PaintingCalendar.DoesNotExist:
        return APIResponse(
            code=0,
            msg=gettext_lazy('Query successful'),
            data={
                'current_month_name': current_month_name,
                'week_days': week_days,
                'festival': None,
                'painting': None
            }
        )

    try:
        painting = Painting.objects.get(id=calendar_item.painting_id, is_delete=0)
    except Painting.DoesNotExist:
        return APIResponse(
            code=0,
            msg=gettext_lazy('Query successful'),
            data={
                'current_month_name': current_month_name,
                'week_days': week_days,
                'festival': {
                    'festival_name': calendar_item.festival_name,
                    'description': calendar_item.description
                },
                'painting': None
            }
        )

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data={
            'current_month_name': current_month_name,
            'week_days': week_days,
            'festival': {
                'festival_name': calendar_item.festival_name,
                'description': calendar_item.description
            },
            'painting': painting.to_dict()
        }
    )
