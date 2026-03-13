import { GoogleMap, Polyline } from '@react-google-maps/api';
import { Coordinates } from '@/lib/types';

export function RouteMiniMap({ coordinates }: { coordinates: Coordinates[] }) {
  const center = coordinates[0] ?? { lat: 0, lng: 0 };

  return (
    <div className="h-28 w-full overflow-hidden rounded-xl border border-slate-100">
      <GoogleMap
        mapContainerStyle={{ width: '100%', height: '100%' }}
        center={center}
        zoom={14}
        options={{
          disableDefaultUI: true,
          gestureHandling: 'none',
          clickableIcons: false
        }}
      >
        <Polyline
          path={coordinates}
          options={{
            strokeColor: '#22c55e',
            strokeWeight: 4,
            strokeOpacity: 0.95
          }}
        />
      </GoogleMap>
    </div>
  );
}
