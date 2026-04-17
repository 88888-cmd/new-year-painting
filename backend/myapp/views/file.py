import os

from django.views.decorators.http import require_POST
from django.utils.translation import gettext, gettext_lazy

from ..models import MediaFile

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

    media = MediaFile(user_id=request.user.id, file=upload)
    media.save()

    return APIResponse(code=0, msg=gettext_lazy('Upload successful'), data={
        'id': media.id,
        'file_url': media.file.url
    })


# import os
# import uuid
#
# from django.core.files.storage import default_storage
# from django.core.files.base import ContentFile
# from django.views.decorators.http import require_POST
# from django.http import HttpResponse, Http404
# # from ..models import MediaFile
#
# from api_r import APIResponse
#
# @require_POST
# def upload_file(request):
#
#     upload = request.FILES.get('file')
#     if not upload:
#         return APIResponse(code=1, msg='未提供文件')
#
#     # 限制文件大小（最大 50MB）
#     max_size = 50 * 1024 * 1024
#     if upload.size > max_size:
#         return APIResponse(code=1, msg='文件超过最大限制 50MB')
#
#
#     allowed_types = ['image/png', 'image/jpeg', 'video/mp4', 'video/quicktime']
#     if upload.content_type not in allowed_types:
#         return APIResponse(code=1, msg='文件类型不允许')
#
#     allowed_extensions = ['.png', '.jpg', '.jpeg', '.mp4', '.mov']
#     ext = os.path.splitext(upload.name)[1].lower()
#     if ext not in allowed_extensions:
#         return APIResponse(code=1, msg='文件类型不允许')
#
#     # media = MediaFile(file=upload)
#     # media.save()
#
#     local_filename = f"{request.user.id}{uuid.uuid4()}{ext}"
#     default_storage.save(local_filename, ContentFile(upload.read()))
#     file_url = default_storage.url(local_filename)
#
#     return APIResponse(code=0, msg='上传成功', data={
#         'file_url': file_url
#     })
