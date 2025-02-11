from django.contrib.gis.geos import Point
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Marker
from .serializers import MarkerSerializer

@api_view(['GET'])
def get_markers(request):
    markers = Marker.objects.all()
    serializer = MarkerSerializer(markers, many=True)
    return Response(serializer.data)

@api_view(['POST'])
def add_marker(request):
    data = request.data
    marker = Marker.objects.create(
        name=data.get("name", "New Marker"),
        location="POINT({} {})".format(data['lng'], data['lat'])
    )
    return Response(MarkerSerializer(marker).data, status=status.HTTP_201_CREATED)

@api_view(['PUT'])
def edit_marker(request, marker_id):
    try:
        marker = Marker.objects.get(id=marker_id)
        data = request.data
        marker.name = data.get('name', marker.name)
        lat = data.get('lat')
        lng = data.get('lng')
        if lat and lng:
            marker.location = Point(float(lng), float(lat))
        marker.save()
        return Response({"message": "Marker updated successfully"})
    except Marker.DoesNotExist:
        return Response({"error": "Marker not found"}, status=404)

@api_view(['DELETE'])
def delete_marker(request, marker_id):
    try:
        marker = Marker.objects.get(id=marker_id)
        marker.delete()
        return Response({"message": "Marker deleted successfully"})
    except Marker.DoesNotExist:
        return Response({"error": "Marker not found"}, status=404)
