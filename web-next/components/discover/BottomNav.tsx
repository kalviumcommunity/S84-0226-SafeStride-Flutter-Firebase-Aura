import Link from 'next/link';
import { Compass, Navigation, PlusCircle, Bell, User } from 'lucide-react';

const items = [
  { href: '/discover', label: 'Discover', icon: Compass },
  { href: '/run/r-1', label: 'Navigation', icon: Navigation },
  { href: '#', label: 'Add Route', icon: PlusCircle },
  { href: '#', label: 'Alerts', icon: Bell },
  { href: '#', label: 'Profile', icon: User }
];

export function BottomNav({ active = '/discover' }: { active?: string }) {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-20 mx-auto max-w-3xl border-t border-slate-200 bg-white/90 backdrop-blur">
      <div className="grid grid-cols-5 px-2 py-2">
        {items.map((item) => {
          const isActive = active === item.href || (active.startsWith('/run') && item.href.startsWith('/run'));
          const Icon = item.icon;
          return (
            <Link
              key={item.label}
              href={item.href}
              className={`flex flex-col items-center gap-1 rounded-xl py-2 text-xs transition ${
                isActive ? 'text-safe-green bg-emerald-50' : 'text-slate-500 hover:bg-slate-100'
              }`}
            >
              <Icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
