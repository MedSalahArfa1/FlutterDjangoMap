from django.contrib.gis.db import models

class Marker(models.Model):
    name = models.CharField(max_length=100)
    location = models.PointField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name
