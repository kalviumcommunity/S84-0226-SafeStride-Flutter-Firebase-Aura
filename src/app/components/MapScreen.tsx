import { Filter, MapPin, Navigation, Shield } from 'lucide-react';
import { useState } from 'react';
import { FilterModal } from './FilterModal';

interface MapScreenProps {
  onRouteSelect: (route: any) => void;
  isDarkMode: boolean;
}

const MOCK_ROUTES = [
  {
    id: 1,
    name: 'Riverside Trail',
    category: 'Runner',
    distance: '5.2 km',
    safety: 95,
    lighting: 'Excellent',
    traffic: 'Low',
    crowd: 'Moderate',
    reviews: 128,
    rating: 4.8,
    coordinates: { lat: 40.7128, lng: -74.0060 },
    image: 'nature running trail',
    emoji: '🏃‍♂️'
  },
  {
    id: 2,
    name: 'Downtown Circuit',
    category: 'Cyclist',
    distance: '12.8 km',
    safety: 78,
    lighting: 'Good',
    traffic: 'Moderate',
    crowd: 'High',
    reviews: 89,
    rating: 4.5,
    coordinates: { lat: 40.7580, lng: -73.9855 },
    image: 'urban cycling path',
    emoji: '🚴‍♀️'
  },
  {
    id: 3,
    name: 'Mountain View Loop',
    category: 'Runner',
    distance: '8.4 km',
    safety: 88,
    lighting: 'Moderate',
    traffic: 'Very Low',
    crowd: 'Low',
    reviews: 215,
    rating: 4.9,
    coordinates: { lat: 40.7489, lng: -73.9680 },
    image: 'mountain trail running',
    emoji: '🏃‍♀️'
  }
];

export function MapScreen({ onRouteSelect, isDarkMode }: MapScreenProps) {
  const [mode, setMode] = useState<'runner' | 'cyclist'>('runner');
  const [selectedRouteId, setSelectedRouteId] = useState(1);
  const [isFilterOpen, setIsFilterOpen] = useState(false);

  const selectedRoute = MOCK_ROUTES.find(r => r.id === selectedRouteId);

  const getSafetyColor = (safety: number) => {
    if (safety >= 85) return '#7df258';
    if (safety >= 70) return '#fbbf24';
    return '#ef4444';
  };

  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className={`px-6 pt-16 pb-6 ${isDarkMode ? 'bg-gradient-to-b from-[#0f1f3a] to-transparent' : 'bg-gradient-to-b from-[#e8f0fe] to-transparent'}`}>
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className={`text-3xl font-bold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>TrailSync</h1>
            <p className={`text-sm mt-1 ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Sync Your Stride.</p>
          </div>
          <button 
            onClick={() => setIsFilterOpen(true)}
            className={`w-12 h-12 rounded-full ${isDarkMode ? 'bg-[#1a2a42] shadow-lg' : 'bg-white shadow-lg'} flex items-center justify-center relative group`}
          >
            <Filter className={`w-5 h-5 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'} group-hover:text-[#7df258] transition-colors`} />
            <div className="absolute -top-1 -right-1 w-3 h-3 rounded-full bg-[#7df258] shadow-[0_0_8px_rgba(125,242,88,0.6)]" />
          </button>
        </div>

        {/* Mode Toggle */}
        <div className={`inline-flex rounded-full p-1 ${isDarkMode ? 'bg-[#1a2a42]' : 'bg-white/80 backdrop-blur-sm shadow-lg'}`}>
          <button
            onClick={() => setMode('runner')}
            className={`
              px-8 py-2.5 rounded-full font-medium text-sm transition-all duration-300 flex items-center gap-2
              ${mode === 'runner'
                ? 'bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] shadow-[0_2px_12px_rgba(125,242,88,0.4)]'
                : isDarkMode ? 'text-gray-400' : 'text-gray-600'
              }
            `}
          >
            <span className="text-base">🏃</span>
            Runner
          </button>
          <button
            onClick={() => setMode('cyclist')}
            className={`
              px-8 py-2.5 rounded-full font-medium text-sm transition-all duration-300 flex items-center gap-2
              ${mode === 'cyclist'
                ? 'bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] shadow-[0_2px_12px_rgba(125,242,88,0.4)]'
                : isDarkMode ? 'text-gray-400' : 'text-gray-600'
              }
            `}
          >
            <span className="text-base">🚴</span>
            Cyclist
          </button>
        </div>
      </div>

      {/* Map Area */}
      <div className="flex-1 relative">
        <div className={`w-full h-full ${isDarkMode ? 'bg-gradient-to-br from-[#0f1f3a] via-[#1a2a42] to-[#0a1628]' : 'bg-gradient-to-br from-[#dbeafe] via-[#e0e7ff] to-[#f0f9ff]'} relative overflow-hidden`}>
          {/* Grid Lines for Map Effect */}
          <div className="absolute inset-0" style={{
            backgroundImage: `
              linear-gradient(${isDarkMode ? 'rgba(125, 242, 88, 0.03)' : 'rgba(30, 64, 175, 0.05)'} 1px, transparent 1px),
              linear-gradient(90deg, ${isDarkMode ? 'rgba(125, 242, 88, 0.03)' : 'rgba(30, 64, 175, 0.05)'} 1px, transparent 1px)
            `,
            backgroundSize: '50px 50px'
          }} />

          {/* Decorative Map Elements */}
          <div className="absolute top-1/4 left-1/4 w-32 h-32 rounded-full bg-[#7df258]/5 blur-3xl" />
          <div className="absolute bottom-1/3 right-1/4 w-40 h-40 rounded-full bg-[#3b82f6]/5 blur-3xl" />
          
          {/* Simulated Roads/Paths */}
          <svg className="w-full h-full absolute inset-0" viewBox="0 0 400 600" style={{ opacity: isDarkMode ? 0.3 : 0.25 }}>
            {/* Main Routes */}
            <path
              d="M 50 300 Q 150 200 250 250 T 350 300"
              stroke={getSafetyColor(MOCK_ROUTES[0].safety)}
              strokeWidth="6"
              fill="none"
              strokeLinecap="round"
              className="drop-shadow-lg"
            />
            <path
              d="M 80 150 Q 200 100 300 180 T 350 250"
              stroke={getSafetyColor(MOCK_ROUTES[1].safety)}
              strokeWidth="6"
              fill="none"
              strokeLinecap="round"
              className="drop-shadow-lg"
            />
            <path
              d="M 100 450 Q 200 380 300 420 T 380 380"
              stroke={getSafetyColor(MOCK_ROUTES[2].safety)}
              strokeWidth="6"
              fill="none"
              strokeLinecap="round"
              className="drop-shadow-lg"
            />
            {/* Connecting Roads */}
            <path
              d="M 120 200 L 180 350"
              stroke={isDarkMode ? '#2a3f5f' : '#cbd5e1'}
              strokeWidth="3"
              fill="none"
              strokeLinecap="round"
            />
            <path
              d="M 250 150 L 280 380"
              stroke={isDarkMode ? '#2a3f5f' : '#cbd5e1'}
              strokeWidth="3"
              fill="none"
              strokeLinecap="round"
            />
          </svg>

          {/* Route Markers with Emojis */}
          <div className="absolute top-1/2 left-1/3 -translate-x-1/2 -translate-y-1/2">
            <div className="relative group cursor-pointer" onClick={() => setSelectedRouteId(1)}>
              <div className="text-4xl mb-1 transform transition-transform group-hover:scale-125">
                🏃‍♂️
              </div>
              <div className={`absolute -bottom-8 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full text-xs font-semibold whitespace-nowrap ${isDarkMode ? 'bg-[#1a2a42]' : 'bg-white'} shadow-lg opacity-0 group-hover:opacity-100 transition-opacity`}>
                Riverside Trail
              </div>
              <div className="w-6 h-6 rounded-full bg-[#7df258] absolute -bottom-2 left-1/2 -translate-x-1/2 shadow-[0_0_16px_rgba(125,242,88,0.6)] animate-pulse" />
            </div>
          </div>
          <div className="absolute top-1/4 right-1/3">
            <div className="relative group cursor-pointer" onClick={() => setSelectedRouteId(2)}>
              <div className="text-3xl mb-1 transform transition-transform group-hover:scale-125">
                🚴‍♀️
              </div>
              <div className={`absolute -bottom-8 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full text-xs font-semibold whitespace-nowrap ${isDarkMode ? 'bg-[#1a2a42]' : 'bg-white'} shadow-lg opacity-0 group-hover:opacity-100 transition-opacity`}>
                Downtown Circuit
              </div>
              <div className="w-5 h-5 rounded-full bg-[#fbbf24] absolute -bottom-2 left-1/2 -translate-x-1/2 shadow-[0_0_12px_rgba(251,191,36,0.5)]" />
            </div>
          </div>
          <div className="absolute bottom-1/3 left-1/2">
            <div className="relative group cursor-pointer" onClick={() => setSelectedRouteId(3)}>
              <div className="text-3xl mb-1 transform transition-transform group-hover:scale-125">
                🏃‍♀️
              </div>
              <div className={`absolute -bottom-8 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full text-xs font-semibold whitespace-nowrap ${isDarkMode ? 'bg-[#1a2a42]' : 'bg-white'} shadow-lg opacity-0 group-hover:opacity-100 transition-opacity`}>
                Mountain View
              </div>
              <div className="w-5 h-5 rounded-full bg-[#7df258] absolute -bottom-2 left-1/2 -translate-x-1/2 shadow-[0_0_12px_rgba(125,242,88,0.5)]" />
            </div>
          </div>

          {/* Additional Map Markers */}
          <div className="absolute top-1/3 left-1/5 w-2 h-2 rounded-full bg-[#3b82f6] opacity-60" />
          <div className="absolute top-2/3 right-1/4 w-2 h-2 rounded-full bg-[#3b82f6] opacity-60" />
          <div className="absolute bottom-1/4 left-2/5 w-2 h-2 rounded-full bg-[#3b82f6] opacity-60" />

          {/* Floating Compass */}
          <div className="absolute top-4 right-4">
            <div className={`w-12 h-12 rounded-full ${isDarkMode ? 'bg-[#1a2a42]' : 'bg-white'} shadow-lg flex items-center justify-center`}>
              <Navigation className={`w-5 h-5 ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
            </div>
          </div>

          {/* Current Location Indicator */}
          <div className="absolute bottom-1/4 right-1/3">
            <div className="relative">
              <div className="w-4 h-4 rounded-full bg-[#3b82f6] border-2 border-white shadow-lg" />
              <div className="absolute inset-0 w-4 h-4 rounded-full bg-[#3b82f6] opacity-40 animate-ping" />
            </div>
          </div>
        </div>
      </div>

      {/* Bottom Sheet - Floating Card */}
      {selectedRoute && (
        <div className="absolute bottom-28 left-0 right-0 px-6">
          <div 
            className={`
              rounded-3xl p-6
              ${isDarkMode 
                ? 'bg-gradient-to-br from-[#1a2a42] to-[#0f1f3a] shadow-[0_-8px_32px_rgba(0,0,0,0.4)]' 
                : 'bg-white/95 backdrop-blur-xl shadow-[0_-8px_32px_rgba(0,0,0,0.12)]'
              }
              border ${isDarkMode ? 'border-[#7df258]/10' : 'border-[#7df258]/20'}
            `}
          >
            {/* Route Info */}
            <div className="flex items-start justify-between mb-4">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <span className="text-2xl">{selectedRoute.emoji}</span>
                  <h3 className={`text-xl font-bold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                    {selectedRoute.name}
                  </h3>
                </div>
                <div className="flex items-center gap-2 mb-3">
                  <span className={`px-3 py-1 rounded-full text-xs font-medium ${isDarkMode ? 'bg-[#7df258]/20 text-[#7df258]' : 'bg-[#7df258]/10 text-[#0a1628]'}`}>
                    {selectedRoute.category}
                  </span>
                  <span className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
                    {selectedRoute.distance}
                  </span>
                </div>
              </div>

              {/* Safety Badge */}
              <div className="relative">
                <div 
                  className="w-16 h-16 rounded-2xl flex flex-col items-center justify-center"
                  style={{
                    backgroundColor: `${getSafetyColor(selectedRoute.safety)}20`,
                    boxShadow: `0 4px 16px ${getSafetyColor(selectedRoute.safety)}30`
                  }}
                >
                  <Shield className="w-6 h-6 mb-1" style={{ color: getSafetyColor(selectedRoute.safety) }} />
                  <span className="text-xs font-bold" style={{ color: getSafetyColor(selectedRoute.safety) }}>
                    {selectedRoute.safety}%
                  </span>
                </div>
              </div>
            </div>

            {/* Quick Stats */}
            <div className="grid grid-cols-3 gap-3 mb-4">
              <div className={`rounded-xl p-3 ${isDarkMode ? 'bg-[#0f1f3a]' : 'bg-[#7df258]/5'}`}>
                <p className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>Lighting</p>
                <p className={`text-sm font-semibold mt-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>{selectedRoute.lighting}</p>
              </div>
              <div className={`rounded-xl p-3 ${isDarkMode ? 'bg-[#0f1f3a]' : 'bg-[#7df258]/5'}`}>
                <p className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>Traffic</p>
                <p className={`text-sm font-semibold mt-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>{selectedRoute.traffic}</p>
              </div>
              <div className={`rounded-xl p-3 ${isDarkMode ? 'bg-[#0f1f3a]' : 'bg-[#7df258]/5'}`}>
                <p className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>Crowd</p>
                <p className={`text-sm font-semibold mt-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>{selectedRoute.crowd}</p>
              </div>
            </div>

            {/* CTA Button */}
            <button
              onClick={() => onRouteSelect(selectedRoute)}
              className="w-full py-4 rounded-2xl bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] font-bold shadow-[0_4px_16px_rgba(125,242,88,0.3)] hover:shadow-[0_6px_20px_rgba(125,242,88,0.4)] transition-all duration-300"
            >
              View Route Details
            </button>
          </div>
        </div>
      )}

      {/* Filter Modal */}
      <FilterModal isOpen={isFilterOpen} onClose={() => setIsFilterOpen(false)} isDarkMode={isDarkMode} />
    </div>
  );
}