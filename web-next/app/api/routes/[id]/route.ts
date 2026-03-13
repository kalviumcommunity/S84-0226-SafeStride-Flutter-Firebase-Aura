import { NextResponse } from 'next/server';
import { mockRoutes } from '@/lib/mockData';
import { computeSafetyScore } from '@/lib/safety';

export async function GET(_: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const route = mockRoutes.find((item) => item.route_id === id);

  if (!route) {
    return NextResponse.json({ error: 'Route not found' }, { status: 404 });
  }

  const safety = computeSafetyScore(
    route.lighting_score,
    route.crime_score,
    route.crowd_density,
    route.user_reports
  );

  return NextResponse.json({ route: { ...route, safety_score: safety.total, safety_breakdown: safety } });
}
