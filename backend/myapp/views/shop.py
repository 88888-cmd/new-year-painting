import json

from django.views.decorators.http import require_GET, require_POST
from django.db.models import F
from django.db import transaction, IntegrityError
from django.utils import timezone
from django.utils.translation import gettext, gettext_lazy

from ..models import Goods, GoodsCategory, GoodsComment, GoodsSku, GoodsCart, Coupon, User, UserCoupon
from api_r import APIResponse

@require_GET
def get_category_list(request):
    categories = [category.to_dict() for category in GoodsCategory.objects.all()]
    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=categories
    )

@require_GET
def get_list(request):

    category_id = int(request.GET.get('category_id', 0))
    data_v = int(request.GET.get('data_v', 1))

    if category_id == 0:
        goods = Goods.objects.filter(is_delete=0).order_by('-create_time')[:20]
    else:
        goods = Goods.objects.filter(category_id=category_id, is_delete=0).order_by('-create_time')[:20]

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data={
            'goods_list': [goods.to_dict(include_sku=True) for goods in goods],
            'data_v': data_v
        }
    )

@require_GET
def detail(request):

    goods_id = int(request.GET.get('goods_id', 0))

    try:
        goods = Goods.objects.get(id=goods_id, is_delete=0)
    except Goods.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    skus = GoodsSku.objects.filter(goods_id=goods_id)
    comments = GoodsComment.objects.filter(goods_id=goods_id).order_by('-id')[:2]

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

    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data={
        'goods': goods.to_dict(),
        'skus': [sku.to_dict() for sku in skus],
        'comments': comment_list
    })

@require_GET
def get_comment_list(request):

    goods_id = int(request.GET.get('goods_id', 0))

    comments = GoodsComment.objects.filter(goods_id=goods_id).order_by('-id')

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


@require_GET
def get_cart_badge(request):
    cart_count = GoodsCart.objects.filter(user_id=request.user.id).count()

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=cart_count
    )

@require_GET
def get_cart_list(request):
    carts = GoodsCart.objects.filter(user_id=request.user.id)

    cart_list = []
    for cart in carts:
        try:
            goods = Goods.objects.get(id=cart.goods_id, is_delete=0)
            goodsSku = GoodsSku.objects.get(id=cart.goods_sku_id)
        except (Goods.DoesNotExist, GoodsSku.DoesNotExist):
            continue
        cart_list.append({
            **cart.to_dict(),
            **{
            'goods': goods.to_dict(),
            'sku': goodsSku.to_dict(),
        }})

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=cart_list
    )

@require_POST
def add_to_cart(request):
    body = json.loads(request.body)

    goods_id = int(body.get('goods_id', 0))
    goods_sku_id = int(body.get('goods_sku_id', 0))
    buy_num = int(body.get('buy_num', 1))

    try:
        goods = Goods.objects.get(id=goods_id, is_delete=0)
        goodsSku = GoodsSku.objects.get(id=goods_sku_id, goods_id=goods_id)
    except (Goods.DoesNotExist, GoodsSku.DoesNotExist):
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))

    try:
        existing_item = GoodsCart.objects.filter(
            user_id=request.user.id,
            goods_id=goods_id,
            goods_sku_id=goods_sku_id
        ).first()

        if existing_item:
            existing_item.buy_num += buy_num
            existing_item.save()
        else:
            GoodsCart.objects.create(
                user_id=request.user.id,
                goods_id=goods_id,
                goods_sku_id=goods_sku_id,
                buy_num=buy_num
            )
    except IntegrityError:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))
    except Exception:
        return APIResponse(code=1, msg=gettext_lazy('Operation exception'))

    return APIResponse(
        code=0,
        msg=gettext_lazy('Operation successful')
    )


@require_POST
def delete_cart_item(request):
    body = json.loads(request.body)

    goods_id = int(body.get('goods_id', 0))
    goods_sku_id = int(body.get('goods_sku_id', 0))

    try:
        cart_item = GoodsCart.objects.get(
            goods_id=goods_id,
            goods_sku_id=goods_sku_id,
            user_id=request.user.id
        )
    except GoodsCart.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    if cart_item.buy_num - 1 <= 0:
        cart_item.delete()
    else:
        cart_item.buy_num -= 1
        cart_item.save()

    return APIResponse(
        code=0,
        msg=gettext_lazy('Operation successful')
    )


@require_GET
def get_coupon_list(request):
    coupons = Coupon.objects.filter(
        is_delete=0
    ).order_by('-create_time')
    coupon_list = [coupon.to_dict() for coupon in coupons]
    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=coupon_list
    )

@require_POST
def receive(request):
    body = json.loads(request.body)

    coupon_id = int(body.get('coupon_id', 0))

    if UserCoupon.objects.filter(
            coupon_id=coupon_id,
            user_id=request.user.id,
            is_use=0
    ).exists():
        return APIResponse(code=1, msg=gettext_lazy('You have already received this coupon'))

    try:
        with transaction.atomic():
            # 悲观锁
            coupon = Coupon.objects.select_for_update().get(
                id=coupon_id,
                receive_num__lt=F('total_num'),
                is_delete=0
            )

            start_time = timezone.now()
            end_time = start_time + timezone.timedelta(days=coupon.expire_day)

            updated = Coupon.objects.filter(
                id=coupon_id,
                receive_num__lt=F('total_num'),
                is_delete=0
            ).update(receive_num=F('receive_num') + 1)
            if not updated:
                raise ValueError(gettext_lazy('Coupons have been received or deleted'))
                # return APIResponse(code=1, msg='优惠券已领完或已删除')

            UserCoupon.objects.create(
                coupon_id=coupon_id,
                coupon_name=coupon.name,
                reduce_price=coupon.reduce_price,
                min_price=coupon.min_price,
                expire_day=coupon.expire_day,
                start_time=start_time,
                end_time=end_time,
                user_id=request.user.id,
            )

    except Coupon.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Data does not exist'))
    except IntegrityError:
        return APIResponse(code=1, msg=gettext_lazy('Failed to receive: Duplicate receipt'))
    except ValueError as e:
        return APIResponse(code=1, msg=str(e))
    except Exception:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    return APIResponse(
        code=0,
        msg=gettext_lazy('Operation successful')
    )


@require_GET
def get_my_list(request):
    coupons = [coupon.to_dict() for coupon in UserCoupon.objects.filter(user_id=request.user.id)]

    return APIResponse(
        code=0,
        msg=gettext_lazy('Query successful'),
        data=coupons
    )
