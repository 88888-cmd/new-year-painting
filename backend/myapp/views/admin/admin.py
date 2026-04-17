import json
import uuid
import hashlib
import time
import secrets

from django.views.decorators.http import require_GET, require_POST

from myapp.models import AdminUser

from api_r import APIResponse


def hash_password(password):
    return hashlib.md5(password.encode()).hexdigest()

def generate_token():
    base_uuid = uuid.uuid4().hex
    timestamp = hex(int(time.time() * 1000))[2:]
    extra_entropy = secrets.token_hex(3)

    combined = f"painting_system_{base_uuid}{timestamp}{extra_entropy}"
    return hashlib.md5(combined.encode()).hexdigest()


@require_POST
def login(request):
    body = json.loads(request.body)

    username = body.get('username', '')
    password = body.get('password', '')

    if not username:
        return APIResponse(code=1, msg='用户名不能为空')
    if not password:
        return APIResponse(code=1, msg='密码不能为空')
    elif len(password) < 6:
        return APIResponse(code=1, msg='密码至少6个字符')

    try:
        user = AdminUser.objects.get(username=username, is_delete=0)
    except AdminUser.DoesNotExist:
        return APIResponse(code=1, msg='用户不存在')

    if user.password != hash_password(password):
        return APIResponse(code=1, msg='密码错误')

    # 更新数据库token
    new_token = generate_token()
    AdminUser.objects.filter(id=user.id).update(token=new_token)

    return APIResponse(code=0, msg='登录成功', data={
        'id': user.id,
        'token': new_token
    })

@require_GET
def profile(request):
    user = request.user

    return APIResponse(code=0, msg='查询成功', data=user.to_dict())


@require_POST
def edit_password(request):
    body = json.loads(request.body)

    old_password = body.get('old_password', '')
    new_password = body.get('new_password', '')

    if not old_password or not new_password:
        return APIResponse(code=1, msg='密码不能为空')
    elif len(old_password) < 6 or len(new_password) < 6:
        return APIResponse(code=1, msg='密码不能少于6个字符')

    old_password = hash_password(old_password)
    new_password = hash_password(new_password)

    if request.user.password != old_password:
        return APIResponse(code=1, msg='旧密码错误')
    if new_password == old_password:
        return APIResponse(code=1, msg='新密码不能与旧密码相同')

    AdminUser.objects.filter(id=request.user.id).update(
        password=new_password
    )

    return APIResponse(code=0, msg='修改成功')
