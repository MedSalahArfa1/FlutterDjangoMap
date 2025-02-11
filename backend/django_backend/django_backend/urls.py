"""
URL configuration for django_backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from django.urls import path
from api.views import get_markers, add_marker, edit_marker, delete_marker




urlpatterns = [
    path('admin/', admin.site.urls),
    path('get_markers/', get_markers, name='get_markers'),
    path('add_marker/', add_marker, name='add_marker'),
    path('edit_marker/<int:marker_id>/', edit_marker, name='edit_marker'),
    path('delete_marker/<int:marker_id>/', delete_marker, name='delete_marker'),
]