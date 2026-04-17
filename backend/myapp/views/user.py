import json
import uuid
import hashlib
import time
import secrets

from django.utils import timezone
from django.views.decorators.http import require_GET, require_POST
from django.utils.translation import gettext, gettext_lazy

from ..models import User, UserTag, TagGroup, Tag, UserCoupon, UserFavorite, Painting, MediaFile

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

    phone = body.get('phone', '')
    email = body.get('email', '')
    password = body.get('password', '')

    if not phone and not email:
        return APIResponse(code=1, msg=gettext_lazy('Phone number or email cannot be empty'))
    if not password:
        return APIResponse(code=1, msg=gettext_lazy('Password cannot be empty'))
    elif len(password) < 6:
        return APIResponse(code=1, msg=gettext_lazy('Password must be at least 6 characters'))

    try:
        if phone:
            user = User.objects.get(phone=phone, is_delete=0)
        else:
            user = User.objects.get(email=email, is_delete=0)
    except User.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('User does not exist'))

    if user.password != hash_password(password):
        return APIResponse(code=1, msg=gettext_lazy('Incorrect password'))

    # 更新数据库token
    new_token = generate_token()
    User.objects.filter(id=user.id).update(token=new_token)
    # user.token = new_token
    # user.save()

    return APIResponse(code=0, msg=gettext_lazy('Login successful'), data={
        'id': user.id,
        'token': new_token
    })


@require_POST
def register(request):
    body = json.loads(request.body)

    phone = body.get('phone', '')
    email = body.get('email', '')
    password = body.get('password', '')

    if not phone and not email:
        return APIResponse(code=1, msg=gettext_lazy('Phone number or email cannot be empty'))
    if not password:
        return APIResponse(code=1, msg=gettext_lazy('Password cannot be empty'))
    elif len(password) < 6:
        return APIResponse(code=1, msg=gettext_lazy('Password must be at least 6 characters'))

    if phone and email:
        return APIResponse(code=1, msg=gettext_lazy('You can only register with either a phone number or an email'))

    if phone:
        if User.objects.filter(phone=phone, is_delete=0).exists():
            return APIResponse(code=1, msg=gettext_lazy('This phone number has already been registered'))

    elif email:
        if User.objects.filter(phone=email, is_delete=0).exists():
            return APIResponse(code=1, msg=gettext_lazy('This email address has already been registered'))

    new_token = generate_token()
    user = User.objects.create(
        phone=phone,
        email=email,
        password=hash_password(password),
        nickname='新用户',
        token=new_token
    )
    return APIResponse(code=0, msg=gettext_lazy('Register successful'), data={
        'id': user.id,
        'token': new_token
    })


@require_GET
def profile(request):
    user = request.user

    coupon_count = UserCoupon.objects.filter(
        user_id=user.id,
        is_use=0,
        end_time__gt=timezone.now()
    ).count()

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
        **user.to_dict(),
        'coupon_count': coupon_count
    })


@require_POST
def update_profile(request):
    user = request.user

    body = json.loads(request.body)

    image_id = int(body.get('image_id', 0))
    # avatar_url = body.get('avatar_url', '')
    nickname = body.get('nickname', '')
    gender = int(body.get('gender', 0))
    birthday = body.get('birthday', '')
    profession = body.get('profession', '')

    try:
        media = MediaFile.objects.get(
            id=image_id,
            user_id=request.user.id
        )
        image_url = media.file.url
    except MediaFile.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))

    # if birthday:
        # birthday = timezone.make_aware(
        #     datetime.fromisoformat(birthday)
        # )

    User.objects.filter(id=user.id).update(
        avatar_url=image_url,
        avatar_file_id=image_id,
        nickname=nickname,
        gender=gender,
        birthday=birthday,
        profession=profession
    )

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))

@require_POST
def change_password(request):
    user = request.user

    body = json.loads(request.body)

    old_password = body.get('old_password', '')
    new_password = body.get('new_password', '')

    if not old_password or not new_password:
        return APIResponse(code=1, msg=gettext_lazy('Password cannot be empty'))
    elif len(old_password) < 6 or len(new_password) < 6:
        return APIResponse(code=1, msg=gettext_lazy('Password must be at least 6 characters'))

    old_password = hash_password(old_password)
    new_password = hash_password(new_password)

    if user.password != old_password:
        return APIResponse(code=1, msg=gettext_lazy('Old password is incorrect'))
    if new_password == old_password:
        return APIResponse(code=1, msg=gettext_lazy('The new password cannot be the same as the old password'))

    User.objects.filter(id=user.id).update(
        password=new_password
    )

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))


@require_POST
def submit_tag(request):
    body = json.loads(request.body)
    tag_ids = body.get('tag_ids', [])

    valid_tags = Tag.objects.filter(id__in=tag_ids).values('id', 'group_id')
    if len(valid_tags) != len(tag_ids):
        return APIResponse(code=1, msg=gettext_lazy('Please refresh the page and try again'))

    try:
        UserTag.objects.filter(user_id=request.user.id).delete()
        for tag in valid_tags:
            UserTag.objects.create(
                tag_group_id=tag['group_id'],
                tag_id=tag['id'],
                user_id=request.user.id
            )
    except Exception as e:
        return APIResponse(code=1, msg=gettext_lazy('Please refresh the page and try again'))

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'))

@require_GET
def get_tag_data(request):
    result = []

    groups = TagGroup.objects.all()
    for group in groups:
        group_dict = group.to_dict()

        tags = Tag.objects.filter(group_id=group.id)

        tags_list = [tag.to_dict() for tag in tags]

        group_dict['tags'] = tags_list

        result.append(group_dict)

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data=result)


