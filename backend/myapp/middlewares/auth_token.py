from api_r import APIResponse
from ..models import AdminUser, User

class AuthTokenMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

        self.client_exact_excluded = {
            '/myapp/api/login',
            '/myapp/api/register',
            '/myapp/api/getTagData',
        }

        self.admin_exact_excluded = {
            '/myapp/admin/login',
        }

        self.prefix_excluded = {
            '/upload/',
        }

    def __call__(self, request):
        path = request.path

        if any(path.startswith(prefix) for prefix in self.prefix_excluded):
            return self.get_response(request)

        is_admin_request = path.startswith('/myapp/admin/')

        excluded_paths = self.admin_exact_excluded if is_admin_request else self.client_exact_excluded
        if path in excluded_paths:
            return self.get_response(request)

        token = request.headers.get('token', None)
        if not token:
            return APIResponse(code=-1, msg='token header required')

        if is_admin_request:
            try:
                user = AdminUser.objects.get(
                    token=token,
                    is_delete=0
                )
                request.user = user
            except User.DoesNotExist:
                return APIResponse(code=-1, msg='Invalid token')
        else:
            try:
                user = User.objects.get(
                    token=token,
                    is_delete=0
                )
                request.user = user
            except User.DoesNotExist:
                return APIResponse(code=-1, msg='Invalid token')

        return self.get_response(request)