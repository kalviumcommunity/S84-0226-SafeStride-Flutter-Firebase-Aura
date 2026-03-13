'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { useJsApiLoader } from '@react-google-maps/api';
import { Activity, AlertTriangle, Shield, Users } from 'lucide-react';
import { BottomNav } from '@/components/discover/BottomNav';
import { SafetyBadge } from '@/components/discover/SafetyBadge';
import { RouteFullMap } from '@/components/maps/RouteFullMap';
import { estimateRunTimeMinutes } from '@/lib/safety';
import { googleMapsApiKey, googleMapsLibraries } from '@/lib/googleMaps';

type ApiRoute = {
  route_id: string;
  name: string;
  distance: number;
  elevation_gain: number;
  coordinates: { lat: number; lng: number }[];
  nearby_police_stations: number;
  user_reported_issues: string[];
  well_lit: boolean;
  crowd_density: number;
  safety_score: number;
  safety_breakdown: {
    lighting: number;
    crime: number;
    crowd: number;
    reportPenalty: number;
  };
};

export default function RouteDetailPage() {
  const params = useParams<{ id: string }>();
  const [route, setRoute] = useState<ApiRoute | null>(null);

  const { isLoaded } = useJsApiLoader({
    id: 'detail-map-script',
    googleMapsApiKey,
    libraries: googleMapsLibraries
  });

  useEffect(() => {
    fetch(`/api/routes/${params.id}`)
      .then((res) => res.json())
      .then((data) => setRoute(data.route));
  }, [params.id]);

  const eta = useMemo(() => (route ? estimateRunTimeMinutes(route.distance) : 0), [route]);

  if (!route) return <main className="p-6">Loading route...</main>;

  return (
    <main className="mx-auto min-h-screen w-full max-w-3xl bg-slate-50 pb-24">
      <section className="px-4 pt-6">
        <h1 className="text-2xl font-bold text-slate-900">{route.name}</h1>
        <p className="text-slate-600">Route safety and navigation details</p>
      </section>

      <section className="px-4 pt-4">
        {isLoaded ? (
          <div className="overflow-hidden rounded-2xl border border-slate-200">
            <RouteFullMap coordinates={route.coordinates} />
          </div>
        ) : (
          <div className="card-glass p-4 text-sm text-slate-500">Loading map...</div>
        )}
      </section>

      <section className="grid grid-cols-2 gap-3 px-4 pt-4">
        <div className="card-glass p-4">
          <p className="text-xs text-slate-500">Distance</p>
          <p className="text-xl font-bold">{route.distance.toFixed(1)} km</p>
        </div>
        <div className="card-glass p-4">
          <p className="text-xs text-slate-500">Estimated Run Time</p>
          <p className="text-xl font-bold">~{eta} min</p>
        </div>
        <div className="card-glass p-4">
          <p className="text-xs text-slate-500">Elevation</p>
          <p className="text-xl font-bold">{route.elevation_gain} m</p>
        </div>
        <div className="card-glass p-4 flex items-center justify-between">
          <div>
            <p className="text-xs text-slate-500">Safety Score</p>
            <p className="text-xl font-bold">{route.safety_score}%</p>
          </div>
          <SafetyBadge score={route.safety_score} />
        </div>
      </section>

      <section className="card-glass mx-4 mt-4 p-4">
        <h2 className="text-base font-semibold">Safety Score Breakdown</h2>
        <div className="mt-3 space-y-2 text-sm text-slate-700">
          <p>Lighting: {route.safety_breakdown.lighting}</p>
          <p>Crime: {route.safety_breakdown.crime}</p>
          <p>Crowd Level: {route.safety_breakdown.crowd}</p>
          <p>Report Penalty: {route.safety_breakdown.reportPenalty}</p>
        </div>
      </section>

      <section className="card-glass mx-4 mt-4 p-4">
        <h2 className="text-base font-semibold">Safety Indicators</h2>
        <div className="mt-3 grid grid-cols-2 gap-3 text-sm">
          <div className="rounded-xl bg-slate-100 p-3 inline-flex items-center gap-2"><Shield size={16} /> Lighting: {route.well_lit ? 'Good' : 'Low'}</div>
          <div className="rounded-xl bg-slate-100 p-3 inline-flex items-center gap-2"><Users size={16} /> Crowd: {route.crowd_density}/100</div>
          <div className="rounded-xl bg-slate-100 p-3 inline-flex items-center gap-2"><Activity size={16} /> Police stations: {route.nearby_police_stations}</div>
          <div className="rounded-xl bg-slate-100 p-3 inline-flex items-center gap-2"><AlertTriangle size={16} /> Issues: {route.user_reported_issues.length}</div>
        </div>
      </section>

      <section className="px-4 pt-5">
        <Link
          href={`/run/${route.route_id}`}
          className="block rounded-2xl bg-safe-green px-5 py-4 text-center text-lg font-semibold text-white hover:bg-emerald-600"
        >
          Start Navigation
        </Link>
      </section>

      <BottomNav active="/discover" />
    </main>
  );
}
