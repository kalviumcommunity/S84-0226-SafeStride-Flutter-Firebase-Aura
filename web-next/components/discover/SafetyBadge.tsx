import { Shield } from 'lucide-react';
import { safetyColor } from '@/lib/safety';

export function SafetyBadge({ score }: { score: number }) {
  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-3 py-1 text-xs font-semibold ${safetyColor(
        score
      )}`}
    >
      <Shield size={14} />
      {score}% Safe
    </span>
  );
}
