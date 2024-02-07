from django.shortcuts import render, redirect
from .models import User
from .forms import UserSearchForm, UserEditForm, UserFindForm
from django.shortcuts import HttpResponse
from django.db.models import Count


# Create your views here.
def index(request):
    return HttpResponse("Hello world!")


def crud(request):
    return render(request, 'main/crud.html')


def insert(request):
    if request.method == 'POST':
        form = UserEditForm(request.POST)
        form.non_field_errors()
        field_errors = [(field.label, field.errors) for field in form]
        print(field_errors)
        if form.is_valid():
            form.save()
    else:
        form = UserEditForm()
    context = {
        'form': form
    }
    return render(request, 'main/insert.html', context)


def edit(request):
    users = []
    if request.method == 'GET':
        form = UserFindForm(request.GET)
        if form.is_valid():
            user_id = form.cleaned_data['user_id']
            users = User.objects.filter(id__contains=user_id)

    form = UserFindForm()
    context = {
        'form': form,
        'users': users
    }
    return render(request, 'main/edit.html', context)


def edit_user(request, user_id):
    user = User.objects.get(pk=user_id)
    if request.method == 'POST':
        form = UserEditForm(request.POST)
        form.non_field_errors()
        field_errors = [(field.label, field.errors) for field in form]
        print(field_errors)
        if form.is_valid():
            user.name = form.cleaned_data['name']
            user.phone = form.cleaned_data['phone']
            user.birthday = form.cleaned_data['birthday']
            user.save()
            return redirect('edit')
    else:
        initial_data = {
            'name': user.name,
            'phone': user.phone,
            'birthday': user.birthday
        }
        form = UserEditForm(initial=initial_data)

    context = {
        'form': form
    }
    return render(request, 'main/edit-user.html', context)


def delete(request):
    users = []
    if request.method == 'GET':
        form = UserFindForm(request.GET)
        if form.is_valid():
            user_id = form.cleaned_data['user_id']
            users = User.objects.filter(id__contains=user_id)

    form = UserFindForm()
    context = {
        'form': form,
        'users': users
    }
    return render(request, 'main/delete.html', context)


def delete_user(request, user_id):
    user = User.objects.get(pk=user_id)
    user.delete()
    return redirect('delete')


def search(request):
    users = []
    if request.method == 'GET':
        form = UserSearchForm(request.GET)
        if form.is_valid():
            name = form.cleaned_data['name']
            users = User.objects.filter(name__contains=name)

    form = UserSearchForm()
    context = {
        'form': form,
        'users': users
    }
    return render(request, 'main/search.html', context)


def analytics(request):
    data = (User.objects
            .values('birthday')
            .annotate(dcount=Count('birthday'))
            .order_by()
            )
    context = {
        'data': data
    }
    return render(request, 'main/analytics.html', context)
