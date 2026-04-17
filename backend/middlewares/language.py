from django.utils import translation
from django.utils.deprecation import MiddlewareMixin

class LanguageMiddleware(MiddlewareMixin):

    LANGUAGE_MAPPING = {
        'en': 'en-us',
        'en-us': 'en-us',
        'en_US': 'en-us',
        'en-US': 'en-us',
        'zh': 'zh-cn',
        'zh-cn': 'zh-cn',
        'zh_CN': 'zh-cn',
        'zh-CN': 'zh-cn'
    }

    def process_request(self, request):
        language = request.META.get('HTTP_ACCEPT_LANGUAGE', '')

        if 'lang' in request.GET:
            language = request.GET['lang']

        language = self.LANGUAGE_MAPPING.get(language)
        if language:
            translation.activate(language)
            request.LANGUAGE_CODE = language
        # supported_languages = ['en-us', 'en_US', 'en-US', 'zh-cn', 'zh_CN', 'zh-CN', 'zh-hans', 'zh-HANS']
        # if language not in supported_languages:
        #     language = 'zh-cn'
        # else:
        #     if language in ['en-us', 'en_US', 'en-US']:
        #         language = 'en-us'
        #     elif language in ['zh-cn', 'zh_CN', 'zh-CN', 'zh-hans', 'zh-HANS']:
        #         language = 'zh-cn'

        return None