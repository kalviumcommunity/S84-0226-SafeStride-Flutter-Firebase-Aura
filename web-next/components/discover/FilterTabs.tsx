import { FilterType } from '@/lib/types';

const filters: FilterType[] = ['Trending', 'Safest', 'Top Rated', 'Nearby'];

export function FilterTabs({
  active,
  onChange
}: {
  active: FilterType;
  onChange: (value: FilterType) => void;
}) {
  return (
    <div className="mt-4 flex gap-2 overflow-x-auto pb-1">
      {filters.map((filter) => {
        const isActive = filter === active;
        return (
          <button
            key={filter}
            onClick={() => onChange(filter)}
            className={`rounded-full px-4 py-2 text-sm font-medium transition ${
              isActive
                ? 'bg-slate-900 text-white'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-100'
            }`}
          >
            {filter}
          </button>
        );
      })}
    </div>
  );
}
