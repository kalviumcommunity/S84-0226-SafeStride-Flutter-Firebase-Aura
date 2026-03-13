import { SafetyBreakdown } from '@/lib/types';

const clamp = (value: number, min = 0, max = 100) => Math.max(min, Math.min(max, value));

export function computeSafetyScore(
  lighting_score: number,
  crime_score: number,
  crowd_density: number,
  user_reports: number
): SafetyBreakdown {
  const lighting = clamp(lighting_score);
  const crime = clamp(crime_score);
  const crowd = clamp(crowd_density);

  const reportPenalty = clamp(100 - user_reports * 8);

  const total = clamp(
    0.35 * lighting +
      0.35 * crime +
      0.2 * crowd +
      0.1 * reportPenalty
  );

  return {
    lighting,
    crime,
    crowd,
    reportPenalty,
    total: Math.round(total)
  };
}

export function safetyColor(score: number) {
  if (score >= 80) return 'bg-safe-green text-white';
  if (score >= 60) return 'bg-safe-yellow text-white';
  return 'bg-safe-red text-white';
}

export function estimateRunTimeMinutes(distanceKm: number, paceMinPerKm = 6.5) {
  return Math.round(distanceKm * paceMinPerKm);
}
