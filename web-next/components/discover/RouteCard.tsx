import Link from 'next/link';
import { Star, ShieldCheck, Camera, Users, Lightbulb, Bookmark } from 'lucide-react';
import { RouteEntity } from '@/lib/types';
import { SafetyBadge } from '@/components/discover/SafetyBadge';
import { RouteMiniMap } from '@/components/maps/RouteMiniMap';

export function RouteCard({
  route,
  safetyScore
}: {
  route: RouteEntity & { safety_score: number };
  safetyScore: number;
}) {
  return (
    <article className="card-glass p-4 transition duration-300 hover:-translate-y-1 hover:shadow-xl">
      <div className="mb-3 flex items-start justify-between gap-3">
        <div>
          <h3 className="text-lg font-semibold text-slate-900">{route.name}</h3>
          <div className="mt-1 flex items-center gap-2 text-sm text-slate-600">
            <span>{route.distance.toFixed(1)} km</span>
            <span className="rounded-full bg-slate-100 px-2 py-0.5 text-xs font-medium">
              {route.route_type}
            </span>
          </div>
        </div>
        <SafetyBadge score={safetyScore} />
      </div>

      <RouteMiniMap coordinates={route.coordinates} />

      <div className="mt-3 flex items-center gap-1 text-sm text-slate-700">
        <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
        {route.rating.toFixed(1)} ({route.reviews_count} reviews)
      </div>

      <div className="mt-3 grid grid-cols-3 gap-2 text-xs text-slate-600">
        <span className="rounded-lg bg-emerald-50 px-2 py-1 inline-flex items-center gap-1">
          <Lightbulb className="h-3.5 w-3.5" /> Well lit
        </span>
        <span className="rounded-lg bg-blue-50 px-2 py-1 inline-flex items-center gap-1">
          <Camera className="h-3.5 w-3.5" /> CCTV
        </span>
        <span className="rounded-lg bg-violet-50 px-2 py-1 inline-flex items-center gap-1">
          <Users className="h-3.5 w-3.5" /> Popular
        </span>
      </div>

      <div className="mt-4 grid grid-cols-3 gap-2">
        <Link href={`/routes/${route.route_id}`} className="rounded-xl border border-slate-200 px-3 py-2 text-center text-sm font-medium hover:bg-slate-100">
          View Details
        </Link>
        <Link href={`/run/${route.route_id}`} className="rounded-xl bg-safe-green px-3 py-2 text-center text-sm font-semibold text-white hover:bg-emerald-600 inline-flex items-center justify-center gap-1">
          <ShieldCheck className="h-4 w-4" /> Start Run
        </Link>
        <button className="rounded-xl border border-slate-200 px-3 py-2 text-sm font-medium hover:bg-slate-100 inline-flex items-center justify-center gap-1">
          <Bookmark className="h-4 w-4" /> Save Route
        </button>
      </div>
    </article>
  );
}
