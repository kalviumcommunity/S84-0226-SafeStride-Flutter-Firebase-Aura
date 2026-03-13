import { NextRequest, NextResponse } from 'next/server';
import { mockRoutes } from '@/lib/mockData';
import { computeSafetyScore } from '@/lib/safety';

function distanceKm(lat1: number, lng1: number, lat2: number, lng2: number) {
  const toRad = (v: number) => (v * Math.PI) / 180;
  const earth = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return earth * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export async function GET(request: NextRequest) {
  const params = request.nextUrl.searchParams;
  const filter = params.get('filter') ?? 'Trending';
  const lat = Number(params.get('lat'));
  const lng = Number(params.get('lng'));

  const enriched = mockRoutes.map((route) => {
    const safety = computeSafetyScore(
      route.lighting_score,
      route.crime_score,
      route.crowd_density,
      route.user_reports
    );

    const start = route.coordinates[0];
    const userDistance = !Number.isNaN(lat) && !Number.isNaN(lng)
      ? distanceKm(lat, lng, start.lat, start.lng)
      : null;

    return {
      ...route,
      safety_score: safety.total,
      user_distance_km: userDistance
    };
  });

  enriched.sort((a, b) => {
    if (filter === 'Safest') return b.safety_score - a.safety_score;
    if (filter === 'Top Rated') return b.rating - a.rating;
    if (filter === 'Nearby') {
      if (a.user_distance_km == null && b.user_distance_km == null) return 0;
      if (a.user_distance_km == null) return 1;
      if (b.user_distance_km == null) return -1;
      return a.user_distance_km - b.user_distance_km;
    }
    return b.runs_last_24h - a.runs_last_24h; // Trending
  });

  return NextResponse.json({ routes: enriched });
}
