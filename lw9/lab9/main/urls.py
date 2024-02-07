"""lab9 URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.0/topics/http/urls/
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
from django.urls import path
from . import views

urlpatterns = [
    path('', views.index),
    path('crud', views.crud, name='crud'),
    path('crud/insert', views.insert, name='insert'),
    path('crud/edit', views.edit, name='edit'),
    path('crud/edit_user/<user_id>', views.edit_user, name='edit-user'),
    path('crud/delete', views.delete, name='delete'),
    path('crud/delete_user/<user_id>', views.delete_user, name='delete-user'),
    path('search', views.search, name='search'),
    path('analytics', views.analytics, name='analytics')
]
