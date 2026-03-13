'use client';

import { useEffect, useMemo, useState } from 'react';
import { useParams } from 'next/navigation';
import { useJsApiLoader } from '@react-google-maps/api';
import { AlertOctagon, Navigation, Share2 } from 'lucide-react';
import { BottomNav } from '@/components/discover/BottomNav';
import { RouteFullMap } from '@/components/maps/RouteFullMap';
import { googleMapsApiKey, googleMapsLibraries } from '@/lib/googleMaps';

type RunRoute = {
  route_id: string;
  name: string;
  distance: number;
  coordinates: { lat: number; lng: number }[];
};

function kmBetween(a: { lat: number; lng: number }, b: { lat: number; lng: number }) {
  const toRad = (v: number) => (v * Math.PI) / 180;
  const earth = 6371;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const n = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return earth * 2 * Math.atan2(Math.sqrt(n), Math.sqrt(1 - n));
}

export default function StartRunPage() {
  const params = useParams<{ id: string }>();
  const [route, setRoute] = useState<RunRoute | null>(null);
  const [current, setCurrent] = useState<{ lat: number; lng: number } | undefined>();
  const [deviationAlert, setDeviationAlert] = useState(false);

  const { isLoaded } = useJsApiLoader({
    id: 'run-map-script',
    googleMapsApiKey,
    libraries: googleMapsLibraries
  });

  useEffect(() => {
    fetch(`/api/routes/${params.id}`)
      .then((res) => res.json())
      .then((data) => setRoute(data.route));
  }, [params.id]);

  useEffect(() => {
    if (!navigator.geolocation) return;
    const watchId = navigator.geolocation.watchPosition(
      (pos) => {
        const point = { lat: pos.coords.latitude, lng: pos.coords.longitude };
        setCurrent(point);
      },
      () => undefined,
      { enableHighAccuracy: true, maximumAge: 1000, timeout: 10000 }
    );

    return () => navigator.geolocation.clearWatch(watchId);
  }, []);

  useEffect(() => {
    if (!route || !current) return;
    const first = route.coordinates[0];
    setDeviationAlert(kmBetween(first, current) * 1000 > 50);
  }, [route, current]);

  const remainingDistance = useMemo(() => {
    if (!route || !current) return route?.distance ?? 0;
    const end = route.coordinates[route.coordinates.length - 1];
    return kmBetween(current, end);
  }, [route, current]);

  const handleShare = async () => {
    if (!current) return;
    const message = `Live location: https://maps.google.com/?q=${current.lat},${current.lng}`;
    if (navigator.share) await navigator.share({ title: 'SafeStride Live Run', text: message });
    else await navigator.clipboard.writeText(message);
  };

  if (!route) return <main className="p-6">Preparing run...</main>;

  return (
    <main className="mx-auto min-h-screen w-full max-w-3xl bg-slate-50 pb-24">
      <section className="px-4 pt-6">
        <h1 className="text-2xl font-bold">Live Navigation</h1>
        <p className="text-slate-600">{route.name}</p>
      </section>

      <section className="px-4 pt-4">
        {isLoaded ? (
          <div className="overflow-hidden rounded-2xl border border-slate-200">
            <RouteFullMap coordinates={route.coordinates} current={current} height="460px" />
          </div>
        ) : (
          <div className="card-glass p-4">Loading map...</div>
        )}
      </section>

      <section className="grid grid-cols-2 gap-3 px-4 pt-4">
        <div className="card-glass p-4">
          <p className="text-xs text-slate-500">Current Location</p>
          <p className="text-sm font-semibold">{current ? `${current.lat.toFixed(5)}, ${current.lng.toFixed(5)}` : 'Locating...'}</p>
        </div>
        <div className="card-glass p-4">
          <p className="text-xs text-slate-500">Remaining Distance</p>
          <p className="text-xl font-bold">{remainingDistance.toFixed(2)} km</p>
        </div>
      </section>

      {deviationAlert && (
        <div className="mx-4 mt-4 rounded-xl bg-amber-100 px-4 py-3 text-amber-900">
          Route deviation alert: You are over 50m from expected route.
        </div>
      )}

      <section className="grid grid-cols-3 gap-2 px-4 pt-4">
        <button className="rounded-xl bg-red-600 px-3 py-3 text-sm font-semibold text-white inline-flex items-center justify-center gap-1">
          <AlertOctagon size={16} /> Emergency SOS
        </button>
        <button className="rounded-xl bg-slate-900 px-3 py-3 text-sm font-semibold text-white inline-flex items-center justify-center gap-1">
          <Navigation size={16} /> Re-center
        </button>
        <button onClick={handleShare} className="rounded-xl bg-emerald-600 px-3 py-3 text-sm font-semibold text-white inline-flex items-center justify-center gap-1">
          <Share2 size={16} /> Share
        </button>
      </section>

      <BottomNav active="/run" />
    </main>
  );
}
