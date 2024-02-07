from .models import User
from django.forms import ModelForm, TextInput, DateInput, IntegerField, NumberInput, Form


class UserSearchForm(ModelForm):
    class Meta:
        model = User
        fields = ["name"]
        widgets = {
            "name": TextInput(attrs={
                'placeholder': 'Введите имя',
                'class': 'form-control'
            })
        }


class UserEditForm(ModelForm):
    class Meta:
        model = User
        fields = ["name", "phone", "birthday"]
        widgets = {
            "name": TextInput(attrs={
                'placeholder': 'Введите имя',
                'class': 'form-control'
            }),
            "phone": TextInput(attrs={
                'placeholder': 'Введите номер',
                'class': 'form-control'
            }),
            "birthday": DateInput(attrs={
                'placeholder': 'Введите дату рождения',
                'class': 'form-control'
            })
        }


class UserFindForm(Form):
    user_id = IntegerField(
        widget=NumberInput(attrs={'class': 'form-control', 'placeholder': 'Введите ID'}),
        required=True
    )
