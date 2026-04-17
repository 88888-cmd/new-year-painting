from django.utils.deprecation import MiddlewareMixin
from django.core.exceptions import ValidationError
from django.db import IntegrityError

from api_r import APIResponse

class ExceptionMiddleware(MiddlewareMixin):

    def process_exception(self, request, exception):
        if isinstance(exception, IntegrityError):
            return APIResponse(code=1, msg="DATABASE_ERROR")
        else:
            # import traceback
            # traceback.print_exc()
            return APIResponse(code=1, msg=str(exception))
            # return APIResponse(code=1, msg="Error")