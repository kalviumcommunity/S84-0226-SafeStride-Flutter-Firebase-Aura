'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import { Autocomplete, GoogleMap, useJsApiLoader } from '@react-google-maps/api';
import { Search } from 'lucide-react';
import { FilterTabs } from '@/components/discover/FilterTabs';
import { RouteCard } from '@/components/discover/RouteCard';
import { BottomNav } from '@/components/discover/BottomNav';
import { computeSafetyScore } from '@/lib/safety';
import { FilterType, RouteEntity } from '@/lib/types';
import { googleMapsApiKey, googleMapsLibraries } from '@/lib/googleMaps';

interface DiscoverRoute extends RouteEntity {
  safety_score: number;
  user_distance_km: number | null;
}

export default function DiscoverPage() {
  const [filter, setFilter] = useState<FilterType>('Trending');
  const [routes, setRoutes] = useState<DiscoverRoute[]>([]);
  const [loading, setLoading] = useState(false);
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null);
  const [mapCenter, setMapCenter] = useState<{ lat: number; lng: number }>({ lat: 12.9716, lng: 77.5946 });
  const [autocomplete, setAutocomplete] = useState<google.maps.places.Autocomplete | null>(null);

  const { isLoaded } = useJsApiLoader({
    id: 'discover-map-script',
    googleMapsApiKey,
    libraries: googleMapsLibraries
  });

  useEffect(() => {
    if (!navigator.geolocation) return;
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const loc = { lat: pos.coords.latitude, lng: pos.coords.longitude };
        setUserLocation(loc);
        setMapCenter(loc);
      },
      () => undefined,
      { enableHighAccuracy: true, timeout: 12000 }
    );
  }, []);

  const fetchRoutes = useCallback(async () => {
    setLoading(true);
    const qs = new URLSearchParams({ filter });

    if (filter === 'Nearby' && userLocation) {
      qs.set('lat', String(userLocation.lat));
      qs.set('lng', String(userLocation.lng));
    }

    const response = await fetch(`/api/routes?${qs.toString()}`);
    const data = await response.json();
    setRoutes(data.routes ?? []);
    setLoading(false);
  }, [filter, userLocation]);

  useEffect(() => {
    fetchRoutes();
  }, [fetchRoutes]);

  const onPlaceChanged = () => {
    if (!autocomplete) return;
    const place = autocomplete.getPlace();
    const location = place.geometry?.location;
    if (!location) return;

    const selected = { lat: location.lat(), lng: location.lng() };
    setMapCenter(selected);
    setUserLocation(selected);
    if (filter !== 'Nearby') setFilter('Nearby');
  };

  const titleCount = useMemo(() => routes.length, [routes.length]);

  return (
    <main className="mx-auto min-h-screen w-full max-w-3xl bg-slate-50 pb-24">
      <section className="sticky top-0 z-10 border-b border-slate-200 bg-slate-50/95 px-4 pt-6 pb-4 backdrop-blur">
        <h1 className="text-3xl font-bold text-slate-900">Discover</h1>
        <p className="mt-1 text-slate-600">Find your perfect route</p>

        <div className="mt-4 card-glass px-4 py-3">
          {isLoaded ? (
            <Autocomplete onLoad={setAutocomplete} onPlaceChanged={onPlaceChanged}>
              <div className="flex items-center gap-2">
                <Search className="h-4 w-4 text-slate-400" />
                <input
                  className="w-full bg-transparent text-sm outline-none"
                  placeholder="Search routes or places"
                />
              </div>
            </Autocomplete>
          ) : (
            <div className="text-sm text-slate-500">Loading places search...</div>
          )}
        </div>

        <FilterTabs active={filter} onChange={setFilter} />
      </section>

      <section className="px-4 py-4">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-slate-500">Routes</h2>
          <span className="rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700">
            {titleCount} found
          </span>
        </div>

        {isLoaded && (
          <div className="mb-4 h-44 overflow-hidden rounded-2xl border border-slate-200">
            <GoogleMap
              mapContainerStyle={{ width: '100%', height: '100%' }}
              center={mapCenter}
              zoom={13}
              options={{ disableDefaultUI: true }}
            />
          </div>
        )}

        <div className="space-y-4">
          {loading && <p className="text-sm text-slate-500">Loading routes...</p>}
          {!loading &&
            routes.map((route) => (
              <RouteCard
                key={route.route_id}
                route={route}
                safetyScore={
                  route.safety_score ??
                  computeSafetyScore(
                    route.lighting_score,
                    route.crime_score,
                    route.crowd_density,
                    route.user_reports
                  ).total
                }
              />
            ))}
        </div>
      </section>

      <BottomNav active="/discover" />
    </main>
  );
}
