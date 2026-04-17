import os

from django.views.decorators.http import require_POST
from myapp.models import MediaFile

from api_r import APIResponse

@require_POST
def upload_file(request):

    upload = request.FILES.get('file')
    if not upload:
        return APIResponse(code=1, msg='未提供文件')

    # 限制文件大小（最大 50MB）
    max_size = 50 * 1024 * 1024
    if upload.size > max_size:
        return APIResponse(code=1, msg='文件超过最大限制 50MB')


    allowed_types = ['image/png', 'image/jpeg', 'video/mp4', 'audio/mp4', 'audio/mpeg', 'audio/aac', 'video/quicktime']
    if upload.content_type not in allowed_types:
        return APIResponse(code=1, msg='文件类型不允许')

    allowed_extensions = ['.png', '.jpg', '.jpeg', '.mp4', '.mov', '.mp3', '.m4a', '.aac']
    ext = os.path.splitext(upload.name)[1].lower()
    if ext not in allowed_extensions:
        return APIResponse(code=1, msg='文件类型不允许')

    media = MediaFile(user_id=0, file=upload)
    media.save()

    return APIResponse(code=0, msg='上传成功', data={
        'id': media.id,
        'file_url': media.file.url
    })