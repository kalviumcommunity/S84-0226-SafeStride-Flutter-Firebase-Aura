import { GoogleMap, Marker, Polyline } from '@react-google-maps/api';
import { Coordinates } from '@/lib/types';

export function RouteFullMap({
  coordinates,
  current,
  height = '420px'
}: {
  coordinates: Coordinates[];
  current?: Coordinates;
  height?: string;
}) {
  const center = current ?? coordinates[0] ?? { lat: 0, lng: 0 };

  return (
    <GoogleMap
      mapContainerStyle={{ width: '100%', height }}
      center={center}
      zoom={15}
      options={{
        disableDefaultUI: false,
        zoomControl: true,
        streetViewControl: false,
        mapTypeControl: false
      }}
    >
      <Polyline
        path={coordinates}
        options={{
          strokeColor: '#16a34a',
          strokeWeight: 5,
          strokeOpacity: 0.95
        }}
      />
      {coordinates[0] && <Marker position={coordinates[0]} label="S" />}
      {coordinates[coordinates.length - 1] && (
        <Marker position={coordinates[coordinates.length - 1]} label="E" />
      )}
      {current && <Marker position={current} label="You" />}
    </GoogleMap>
  );
}
