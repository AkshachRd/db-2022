from django.db import models
from phonenumber_field.modelfields import PhoneNumberField


# Create your models here.
class User(models.Model):
    name = models.CharField(max_length=255)
    phone = PhoneNumberField(unique=False, null=False, blank=False)
    birthday = models.DateField()

    def __str__(self):
        return self.name


class Client(models.Model):
    name = models.CharField(max_length=255)
    GENDERS = (
        ('M', 'Male'),
        ('F', 'Female'),
    )
    gender = models.CharField(max_length=1, choices=GENDERS, null=False)
    email = models.EmailField(unique=True, null=False)
    password = models.CharField(max_length=50, null=False)

    def __str__(self):
        return self.name


class Sale(models.Model):
    date = models.DateField(null=False)
    price = models.DecimalField(default=25.00, max_digits=10, decimal_places=2,
                                null=True, blank=True)
    id_client = models.ForeignKey(Client, on_delete=models.CASCADE)

