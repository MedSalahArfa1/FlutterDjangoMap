from rest_framework import serializers
from .models import Marker

class MarkerSerializer(serializers.ModelSerializer):
    latitude = serializers.SerializerMethodField()
    longitude = serializers.SerializerMethodField()

    class Meta:
        model = Marker
        fields = ['id', 'name', 'latitude', 'longitude', 'created_at']

    def get_latitude(self, obj):
        return obj.location.y  # GeoDjango stores coordinates as (longitude, latitude)

    def get_longitude(self, obj):
        return obj.location.x
