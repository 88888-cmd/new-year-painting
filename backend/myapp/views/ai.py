import json
import os
import uuid
from http import HTTPStatus
from urllib.parse import urlparse, unquote
from pathlib import PurePosixPath
import requests

from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from django.views.decorators.http import require_GET, require_POST
from django.db import IntegrityError
from django.conf import settings
from dashscope import ImageSynthesis
from dashscope.audio.asr import *
from django.utils.translation import gettext, gettext_lazy

from ..models import UserAISession, UserAIMessage, UserAIText2Image, UserAIImageEdit, MediaFile
from api_r import APIResponse

from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
from ..rag import TongyiRAG

rag_system = TongyiRAG()


@require_POST
def init_chat(request):
    new_session_id = uuid.uuid4()

    try:
        UserAISession.objects.create(
            session_id=new_session_id,
            user_id=request.user.id
        )
    except IntegrityError:
        return APIResponse(code=0, msg=gettext_lazy('Operation successful'), data=new_session_id)

    return APIResponse(code=0, msg=gettext_lazy('Operation successful'), data=new_session_id)

@require_POST
def chat(request):
    body = json.loads(request.body)

    session_id = body.get('session_id', '')
    image_id = int(body.get('image_id', 0))
    text = body.get('text', '')

    if not session_id:
        return APIResponse(code=1, msg=gettext_lazy('Chat failed'))
    if not image_id and not text:
        return APIResponse(code=1, msg=gettext_lazy('Chat failed'))

    try:
        chat_session = UserAISession.objects.get(session_id=session_id, user_id=request.user.id)
    except UserAISession.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Chat failed'))

    if (image_id):
        try:
            media = MediaFile.objects.get(
                id=image_id,
                user_id=request.user.id
            )
            image_url = media.file.url
        except MediaFile.DoesNotExist:
            return APIResponse(code=1, msg=gettext_lazy('Chat failed'))

    # 开启根据历史记录回答会消耗更多的token
    # history = UserAIMessage.objects.filter(session_id=session_id, user_id=request.user.id)
    message_history = []
    # for msg in history:
    #     if msg.role == 'human':
    #         message_history.append(HumanMessage(content=msg.content))
    #     elif msg.role == 'ai':
    #         message_history.append(AIMessage(content=msg.content))
    #     elif msg.role == 'system':
    #         message_history.append(SystemMessage(content=msg.content))

    # 保存用户的提问
    UserAIMessage.objects.create(
        role='human',
        image_url=image_url if image_id else '',
        text=text,
        session_id=session_id,
        user_id=request.user.id,
    )

    # response = rag_system.process_query(content)
    if image_id:
        image_path = f"file://{media.file.path}"
        response = rag_system.query_with_history(text, image_path, message_history)
    else:
        response = rag_system.query_with_history(text, None, message_history)

    # 保存AI的回答
    ai_message = UserAIMessage.objects.create(
        role='ai',
        text=response,
        session_id=session_id,
        user_id=request.user.id,
    )

    return APIResponse(code=0, msg=gettext_lazy('Chat successful'), data=ai_message.to_dict())


class TRCallback(TranslationRecognizerCallback):
    def __init__(self, tag: int) -> None:
        super().__init__()
        self.tag = tag
        self.text = ''

    def on_open(self) -> None:
        print("TranslationRecognizerCallback open.")

    def on_close(self) -> None:
        print("TranslationRecognizerCallback close.")

    def on_event(
            self,
            request_id,
            transcription_result: TranscriptionResult,
            translation_result: TranslationResult,
            usage,
    ) -> None:
        if transcription_result is not None:
            if transcription_result.is_sentence_end:
                self.text = self.text + transcription_result.text

    def on_error(self, message) -> None:
        print('error: {}'.format(message))

    def on_complete(self) -> None:
        print('TranslationRecognizerCallback complete')

def voice_to_text(request):
    body = json.loads(request.body)

    file_id = int(body.get('file_id', 0))

    try:
        media = MediaFile.objects.get(
            id=file_id,
            user_id=request.user.id
        )
    except MediaFile.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Query failed'))

    callback = TRCallback(tag=file_id)

    translator = TranslationRecognizerChat(
        model="gummy-chat-v1",
        sample_rate=16000,
        format="aac",
        callback=callback,
        transcription_enabled=True, # 启用识别
        translation_enabled=False # 关闭翻译
    )

    translator.start()

    try:
        audio_data: bytes = None
        file_path = media.file.path
        print(file_path)
        # file_path = os.path.join(settings.MEDIA_ROOT, 'recording_20250711_193138.m4a')
        if os.path.getsize(file_path):
            with open(file_path, 'rb') as f:
                while True:
                    audio_data = f.read(12800)
                    if not audio_data:
                        break
                    else:
                        if translator.send_audio_frame(audio_data):
                            print("send audio frame success")
                        else:
                            print("sentence end, stop sending")
                            break
        else:
            raise Exception(
                'The supplied file was empty (zero bytes long)')
        f.close()
    except Exception as e:
        raise e

    translator.stop()

    print(callback.text)
    return APIResponse(code=0, msg=gettext_lazy('Query successful'), data=callback.text)


@require_POST
def text2image(request):
    """文生图-同步版"""
    body = json.loads(request.body)

    prompt = body.get('prompt', '')
    n = int(body.get('n', 0))

    if n > 4 or n < 0:
        return APIResponse(code=1, msg=gettext_lazy('Parameter error'))

    gentle_prompt = f"""生成温柔风格年画，
      关键词：圆润线条勾勒的传统元素，
      温馨场景，
      低饱和度暖光氛围，
      细腻水彩质感，
      关键词补充：{prompt}"""

    rsp = ImageSynthesis.call(api_key=settings.DASHSCOPE_API_KEY,
                              model="wanx2.1-t2i-turbo",
                              prompt=gentle_prompt,
                              # prompt=f'生成年画，关键词：{prompt}',
                              n=n,
                              size='1024*1024')

    try:
        if rsp.status_code == HTTPStatus.OK:
            # for i, result in enumerate(rsp.output.results):
            image_urls = []
            for result in rsp.output.results:
                file_name = PurePosixPath(unquote(urlparse(result.url).path)).parts[-1]
                generated_filename = f"{request.user.id}{file_name}"
                default_storage.save(generated_filename, ContentFile(requests.get(result.url).content))
                image_url = default_storage.url(generated_filename)

                UserAIText2Image.objects.create(
                    task_id=rsp.output.task_id,
                    prompt=prompt,
                    status=f'rsp status_code:{HTTPStatus.OK}',
                    image_url=image_url,
                    user_id=request.user.id
                )

                image_urls.append(image_url)

            return APIResponse(code=0, msg=gettext_lazy('Operation successful'), data=image_urls)
        else:
            UserAIText2Image.objects.create(
                task_id=rsp.output.task_id,
                prompt=prompt,
                status=f'rsp status_code:{rsp.status_code}',
                image_url='',
                user_id=request.user.id
            )

            return APIResponse(code=1, msg=gettext_lazy('Operation failed'))
    except Exception as e:
        UserAIText2Image.objects.create(
            task_id='',
            prompt=prompt,
            status=f'rsp status_code:{rsp.status_code}',
            image_url='',
            user_id=request.user.id
        )

        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))


IMAGEEDIT_TYPES = {
    10: '转换成法国绘本风格',
    20: '转换成金箔艺术风格'
}
@require_POST
def imageedit(request):
    """图生图-同步版"""
    body = json.loads(request.body)

    imageedit_type = int(body.get('imageedit_type', 10))
    image_id = int(body.get('image_id', 0))
    if imageedit_type not in IMAGEEDIT_TYPES or not image_id:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))

    try:
        media = MediaFile.objects.get(
            id=image_id,
            user_id=request.user.id
        )
    except MediaFile.DoesNotExist:
        return APIResponse(code=1, msg=gettext_lazy('Operation failed'))


    try:
        rsp = ImageSynthesis.call(api_key=settings.DASHSCOPE_API_KEY,
                                  model="wanx2.1-imageedit",
                                  function="stylization_all",
                                  # prompt="转换成法国绘本风格",
                                  prompt=IMAGEEDIT_TYPES[imageedit_type],
                                  base_image_url="file://" + media.file.path,
                                  n=1)

        if rsp.status_code == HTTPStatus.OK:
            for result in rsp.output.results:
                file_name = PurePosixPath(unquote(urlparse(result.url).path)).parts[-1]
                generated_filename = f"{request.user.id}{file_name}"
                # save_path = os.path.join(settings.MEDIA_ROOT, f"{request.user.id}{file_name}")
                # with open(save_path, 'wb+') as f:
                #     f.write(requests.get(result.url).content)
                default_storage.save(generated_filename, ContentFile(requests.get(result.url).content))
                # file_path2 = default_storage.path(f"{request.user.id}{file_name}")

                # image_url = f"{settings.MEDIA_URL}{file_path2}"
                image_url = default_storage.url(generated_filename)

                UserAIImageEdit.objects.create(
                    task_id=rsp.output.task_id,
                    prompt=IMAGEEDIT_TYPES[imageedit_type],
                    status=f'rsp status_code:{HTTPStatus.OK}',
                    original_url=media.file.url,
                    image_url=image_url,
                    user_id=request.user.id
                )

            return APIResponse(code=0, msg=gettext_lazy('Operation successful'), data={'image_url': image_url})
        else:
            UserAIImageEdit.objects.create(
                task_id=rsp.output.task_id,
                prompt=IMAGEEDIT_TYPES[imageedit_type],
                status=f'rsp status_code:{rsp.status_code}',
                original_url='',
                image_url='',
                user_id=request.user.id
            )
            return APIResponse(code=1, msg=gettext_lazy('Operation failed'))
    except Exception:
        UserAIImageEdit.objects.create(
            task_id='',
            prompt=IMAGEEDIT_TYPES[imageedit_type],
            status='rsp exception',
            original_url='',
            image_url='',
            user_id=request.user.id
        )
        return APIResponse(code=1, msg='Error')
