from django.urls import include, path
from django.conf.urls.static import static

from server import settings

urlpatterns = [
    path('myapp/', include('myapp.urls'))
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
