import { Search, TrendingUp, Award, Shield, MapPin, Star } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { useState } from 'react';

interface DiscoverScreenProps {
  onRouteSelect: (route: any) => void;
  isDarkMode: boolean;
}

const FEATURED_ROUTES = [
  {
    id: 1,
    name: 'Coastal Sunrise Path',
    distance: '6.8 km',
    safety: 92,
    category: 'Runner',
    rating: 4.9,
    reviews: 156,
    image: 'coastal path sunrise running',
    tag: 'Trending',
    emoji: '🏃‍♀️'
  },
  {
    id: 2,
    name: 'Forest Loop Adventure',
    distance: '15.2 km',
    safety: 85,
    category: 'Cyclist',
    rating: 4.7,
    reviews: 203,
    image: 'forest cycling trail',
    tag: 'Popular',
    emoji: '🚴‍♂️'
  },
  {
    id: 3,
    name: 'Urban Park Circuit',
    distance: '4.5 km',
    safety: 95,
    category: 'Runner',
    rating: 4.8,
    reviews: 312,
    image: 'urban park running',
    tag: 'Safe',
    emoji: '🏃'
  }
];

const CATEGORIES = [
  { id: 'trending', name: 'Trending', icon: TrendingUp },
  { id: 'safe', name: 'Safest', icon: Shield },
  { id: 'top', name: 'Top Rated', icon: Award },
  { id: 'nearby', name: 'Nearby', icon: MapPin }
];

export function DiscoverScreen({ onRouteSelect, isDarkMode }: DiscoverScreenProps) {
  const [selectedCategory, setSelectedCategory] = useState('trending');
  const [searchQuery, setSearchQuery] = useState('');

  const getSafetyColor = (safety: number) => {
    if (safety >= 85) return '#7df258';
    if (safety >= 70) return '#fbbf24';
    return '#ef4444';
  };

  return (
    <div className="h-full overflow-y-auto pb-8">
      {/* Header */}
      <div className={`px-6 pt-16 pb-6 ${isDarkMode ? 'bg-gradient-to-b from-[#0f1f3a] to-transparent' : 'bg-gradient-to-b from-[#e8f0fe] to-transparent'}`}>
        <h1 className={`text-3xl font-bold mb-2 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Discover</h1>
        <p className={`text-sm mb-6 ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Find your perfect route</p>

        {/* Search Bar */}
        <div className={`rounded-2xl p-4 flex items-center gap-3 ${isDarkMode ? 'bg-[#1a2a42] shadow-lg' : 'bg-white shadow-lg'}`}>
          <Search className={`w-5 h-5 ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`} />
          <input
            type="text"
            placeholder="Search routes..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className={`flex-1 bg-transparent outline-none ${isDarkMode ? 'text-white placeholder-gray-500' : 'text-[#0a1628] placeholder-gray-400'}`}
          />
        </div>
      </div>

      {/* Categories */}
      <div className="px-6 mb-8">
        <div className="flex gap-3 overflow-x-auto scrollbar-hide pb-2">
          {CATEGORIES.map((category) => {
            const Icon = category.icon;
            const isActive = selectedCategory === category.id;
            return (
              <button
                key={category.id}
                onClick={() => setSelectedCategory(category.id)}
                className={`
                  flex items-center gap-2 px-5 py-3 rounded-2xl whitespace-nowrap font-medium text-sm transition-all duration-300
                  ${isActive
                    ? 'bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] shadow-[0_4px_16px_rgba(125,242,88,0.3)]'
                    : isDarkMode 
                      ? 'bg-[#1a2a42] text-gray-400 hover:bg-[#0f1f3a]' 
                      : 'bg-white text-gray-600 hover:bg-gray-50 shadow-md'
                  }
                `}
              >
                <Icon className="w-4 h-4" />
                <span>{category.name}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Featured Routes */}
      <div className="px-6">
        <h2 className={`text-xl font-bold mb-4 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Featured Routes</h2>
        <div className="space-y-4">
          {FEATURED_ROUTES.map((route) => (
            <button
              key={route.id}
              onClick={() => onRouteSelect(route)}
              className={`
                w-full rounded-3xl overflow-hidden
                ${isDarkMode 
                  ? 'bg-[#1a2a42] shadow-[0_8px_24px_rgba(0,0,0,0.3)]' 
                  : 'bg-white shadow-[0_8px_24px_rgba(0,0,0,0.08)]'
                }
                transition-transform duration-300 hover:scale-[1.02]
              `}
            >
              {/* Route Image */}
              <div className="relative h-48">
                <ImageWithFallback
                  src={`https://source.unsplash.com/800x600/?${route.image}`}
                  alt={route.name}
                  className="w-full h-full object-cover"
                />
                <div className="absolute inset-0 bg-gradient-to-b from-transparent to-black/40" />
                
                {/* Tag Badge */}
                <div className="absolute top-4 left-4">
                  <span className="px-3 py-1.5 rounded-full bg-white/90 backdrop-blur-sm text-xs font-semibold text-[#0a1628]">
                    {route.tag}
                  </span>
                </div>

                {/* Safety Badge */}
                <div className="absolute top-4 right-4">
                  <div 
                    className="w-14 h-14 rounded-2xl flex flex-col items-center justify-center backdrop-blur-md"
                    style={{
                      backgroundColor: `${getSafetyColor(route.safety)}30`,
                      boxShadow: `0 4px 16px ${getSafetyColor(route.safety)}40`
                    }}
                  >
                    <Shield className="w-5 h-5" style={{ color: getSafetyColor(route.safety) }} />
                    <span className="text-xs font-bold text-white">{route.safety}%</span>
                  </div>
                </div>
              </div>

              {/* Route Info */}
              <div className="p-5">
                <h3 className={`text-lg font-bold mb-2 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                  {route.name}
                </h3>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <span className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
                      {route.distance}
                    </span>
                    <span className={`px-2 py-1 rounded-lg text-xs font-medium ${isDarkMode ? 'bg-[#0f1f3a] text-gray-300' : 'bg-blue-50 text-[#1e40af]'}`}>
                      {route.category}
                    </span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Star className="w-4 h-4 text-[#7df258] fill-[#7df258]" />
                    <span className={`font-semibold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                      {route.rating}
                    </span>
                    <span className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
                      ({route.reviews})
                    </span>
                  </div>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}