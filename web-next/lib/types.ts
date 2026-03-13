export type RouteType = 'Runner' | 'Walk' | 'Cycle';
export type FilterType = 'Trending' | 'Safest' | 'Top Rated' | 'Nearby';

export interface Coordinates {
  lat: number;
  lng: number;
}

export interface RouteEntity {
  route_id: string;
  name: string;
  image: string;
  distance: number;
  route_type: RouteType;
  coordinates: Coordinates[];
  lighting_score: number;
  crime_score: number;
  crowd_density: number;
  user_reports: number;
  rating: number;
  reviews_count: number;
  total_runs: number;
  runs_last_24h: number;
  elevation_gain: number;
  well_lit: boolean;
  cctv_coverage: boolean;
  popular_route: boolean;
  nearby_police_stations: number;
  user_reported_issues: string[];
  created_at: string;
}

export interface SafetyBreakdown {
  lighting: number;
  crime: number;
  crowd: number;
  reportPenalty: number;
  total: number;
}
