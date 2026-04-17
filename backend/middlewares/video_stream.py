import os
import re
import mimetypes
from django.conf import settings
from django.http import StreamingHttpResponse, Http404

class VideoStreamMiddleware:

    ALLOWED_VIDEO_EXTENSIONS = {'.mp4', '.mov'}
    MAX_RANGE_SIZE = 1024 * 1024 * 50  # 50MB


    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path.startswith('/upload/'):
            ext = os.path.splitext(request.path)[1].lower()
            if ext in self.ALLOWED_VIDEO_EXTENSIONS:
                return self.stream_video(request)

        response = self.get_response(request)
        return response

    def stream_video(self, request):
        filename = os.path.normpath(request.path.split('/')[-1])
        # if '..' in filename.split(os.sep):
        #     raise Http404("Invalid path")

        path = os.path.join(settings.MEDIA_ROOT, filename)

        if not os.path.exists(path):
            raise Http404("File not found")

        # range_header = request.headers.get('Range')
        range_header = request.META.get('HTTP_RANGE', '').strip()
        range_re = re.compile(r'bytes\s*=\s*(\d+)\s*-\s*(\d*)', re.I)
        range_match = range_re.match(range_header)
        size = os.path.getsize(path)
        content_type, _ = mimetypes.guess_type(path)
        content_type = content_type or 'application/octet-stream'

        if range_match:
            first_byte, last_byte = range_match.groups()
            first_byte = int(first_byte) if first_byte else 0

            print(last_byte)
            if last_byte:
                last_byte = int(last_byte)
                # range_size_mb = (last_byte - first_byte + 1) / (1024 * 1024)
                # print(f"Range请求大小: {range_size_mb:.2f} MB")
                if last_byte - first_byte > self.MAX_RANGE_SIZE:
                    last_byte = self.MAX_RANGE_SIZE
            else:
                last_byte = first_byte + 1024 * 1024

            if last_byte >= size:
                last_byte = size - 1

            length = last_byte - first_byte + 1
            resp = StreamingHttpResponse(self.file_iterator(path, offset=first_byte, length=length), status=206,
                                         content_type=content_type)
            resp['Content-Length'] = str(length)
            resp['Content-Range'] = f'bytes {first_byte}-{last_byte}/{size}'
        else:
            resp = StreamingHttpResponse(self.file_iterator(path), content_type=content_type)
            resp['Content-Length'] = str(size)

        resp['Accept-Ranges'] = 'bytes'

        # resp.status_code = 200
        return resp

    def file_iterator(self, file_name, chunk_size=8192, offset=0, length=None):
        with open(file_name, "rb") as f:
            f.seek(offset, os.SEEK_SET)
            remaining = length
            while True:
                bytes_length = chunk_size if remaining is None else min(remaining, chunk_size)
                data = f.read(bytes_length)
                if not data:
                    break
                if remaining:
                    remaining -= len(data)
                yield data