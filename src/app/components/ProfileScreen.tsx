import { Settings, Award, MapPin, Star, Heart, ChevronRight, Moon, Sun, LogOut, Bell, Shield } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface ProfileScreenProps {
  isDarkMode: boolean;
  onToggleDarkMode: () => void;
}

const SAVED_ROUTES = [
  {
    id: 1,
    name: 'Riverside Trail',
    distance: '5.2 km',
    safety: 95,
    category: 'Runner',
    image: 'nature running trail',
    emoji: '🏃‍♂️'
  },
  {
    id: 2,
    name: 'Mountain View Loop',
    distance: '8.4 km',
    safety: 88,
    category: 'Runner',
    image: 'mountain trail running',
    emoji: '🏃‍♀️'
  },
  {
    id: 3,
    name: 'Downtown Circuit',
    distance: '12.8 km',
    safety: 78,
    category: 'Cyclist',
    image: 'urban cycling path',
    emoji: '🚴'
  }
];

export function ProfileScreen({ isDarkMode, onToggleDarkMode }: ProfileScreenProps) {
  const getSafetyColor = (safety: number) => {
    if (safety >= 85) return '#7df258';
    if (safety >= 70) return '#fbbf24';
    return '#ef4444';
  };

  return (
    <div className="h-full overflow-y-auto pb-8">
      {/* Premium Gradient Header */}
      <div className="relative h-64 bg-gradient-to-br from-[#1e40af] via-[#3b82f6] to-[#7df258] px-6 pt-16 pb-20">
        {/* Settings Icon */}
        <div className="flex justify-end mb-6">
          <button className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center">
            <Settings className="w-5 h-5 text-white" />
          </button>
        </div>

        {/* Profile Info */}
        <div className="flex flex-col items-center">
          <div className="relative mb-4">
            <ImageWithFallback
              src="https://source.unsplash.com/200x200/?portrait,athlete"
              alt="Profile"
              className="w-24 h-24 rounded-full object-cover border-4 border-white shadow-xl"
            />
            <div className="absolute -bottom-1 -right-1 w-8 h-8 rounded-full bg-[#7df258] border-4 border-white flex items-center justify-center">
              <Award className="w-4 h-4 text-[#0a1628]" />
            </div>
          </div>
          <h2 className="text-2xl font-bold text-white mb-1">Alex Martinez</h2>
          <p className="text-white/80 text-sm">Premium Member</p>
        </div>
      </div>

      {/* Floating Stats Cards */}
      <div className="px-6 -mt-12 mb-8">
        <div className="grid grid-cols-3 gap-3">
          <div 
            className={`
              rounded-2xl p-4 text-center
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-[0_8px_24px_rgba(0,0,0,0.3)]' 
                : 'bg-white shadow-[0_8px_24px_rgba(0,0,0,0.12)]'
              }
            `}
          >
            <MapPin className={`w-6 h-6 mb-2 mx-auto ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
            <p className={`text-2xl font-bold mb-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>24</p>
            <p className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Routes</p>
          </div>
          <div 
            className={`
              rounded-2xl p-4 text-center
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-[0_8px_24px_rgba(0,0,0,0.3)]' 
                : 'bg-white shadow-[0_8px_24px_rgba(0,0,0,0.12)]'
              }
            `}
          >
            <Star className={`w-6 h-6 mb-2 mx-auto ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
            <p className={`text-2xl font-bold mb-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>18</p>
            <p className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Reviews</p>
          </div>
          <div 
            className={`
              rounded-2xl p-4 text-center
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-[0_8px_24px_rgba(0,0,0,0.3)]' 
                : 'bg-white shadow-[0_8px_24px_rgba(0,0,0,0.12)]'
              }
            `}
          >
            <Heart className={`w-6 h-6 mb-2 mx-auto ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
            <p className={`text-2xl font-bold mb-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>12</p>
            <p className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Favorites</p>
          </div>
        </div>
      </div>

      {/* Settings Options */}
      <div className="px-6 mb-8">
        <h3 className={`text-lg font-bold mb-4 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Settings</h3>
        <div className={`rounded-2xl overflow-hidden ${isDarkMode ? 'bg-[#1a2a42]' : 'bg-white shadow-lg'}`}>
          <button 
            onClick={onToggleDarkMode}
            className={`w-full flex items-center justify-between p-4 ${isDarkMode ? 'hover:bg-[#0f1f3a]' : 'hover:bg-gray-50'} transition-colors`}
          >
            <div className="flex items-center gap-3">
              {isDarkMode ? <Moon className="w-5 h-5 text-[#7df258]" /> : <Sun className="w-5 h-5 text-[#1e40af]" />}
              <span className={`font-medium ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                {isDarkMode ? 'Dark Mode' : 'Light Mode'}
              </span>
            </div>
            <div className={`w-12 h-6 rounded-full transition-colors ${isDarkMode ? 'bg-[#7df258]' : 'bg-gray-300'} relative`}>
              <div className={`w-5 h-5 rounded-full bg-white absolute top-0.5 transition-transform ${isDarkMode ? 'translate-x-6' : 'translate-x-0.5'}`} />
            </div>
          </button>

          <div className={`h-px ${isDarkMode ? 'bg-[#0f1f3a]' : 'bg-gray-100'}`} />

          <button className={`w-full flex items-center justify-between p-4 ${isDarkMode ? 'hover:bg-[#0f1f3a]' : 'hover:bg-gray-50'} transition-colors`}>
            <div className="flex items-center gap-3">
              <Bell className={`w-5 h-5 ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`} />
              <span className={`font-medium ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Notifications</span>
            </div>
            <ChevronRight className={`w-5 h-5 ${isDarkMode ? 'text-gray-600' : 'text-gray-400'}`} />
          </button>

          <div className={`h-px ${isDarkMode ? 'bg-[#0f1f3a]' : 'bg-gray-100'}`} />

          <button className={`w-full flex items-center justify-between p-4 ${isDarkMode ? 'hover:bg-[#0f1f3a]' : 'hover:bg-gray-50'} transition-colors`}>
            <div className="flex items-center gap-3">
              <Shield className={`w-5 h-5 ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`} />
              <span className={`font-medium ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Privacy & Safety</span>
            </div>
            <ChevronRight className={`w-5 h-5 ${isDarkMode ? 'text-gray-600' : 'text-gray-400'}`} />
          </button>
        </div>
      </div>

      {/* Saved Routes */}
      <div className="px-6">
        <h3 className={`text-lg font-bold mb-4 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Saved Routes</h3>
        <div className="space-y-3">
          {SAVED_ROUTES.map((route) => (
            <div 
              key={route.id}
              className={`
                rounded-2xl p-4 flex items-center gap-4
                ${isDarkMode 
                  ? 'bg-[#1a2a42] shadow-[0_4px_16px_rgba(0,0,0,0.2)]' 
                  : 'bg-white shadow-[0_4px_16px_rgba(0,0,0,0.08)]'
                }
              `}
            >
              <ImageWithFallback
                src={`https://source.unsplash.com/120x120/?${route.image}`}
                alt={route.name}
                className="w-16 h-16 rounded-xl object-cover"
              />
              <div className="flex-1">
                <h4 className={`font-semibold mb-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                  {route.name}
                </h4>
                <div className="flex items-center gap-2">
                  <span className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
                    {route.distance}
                  </span>
                  <span className="text-gray-400">•</span>
                  <span className={`text-xs px-2 py-0.5 rounded-full ${isDarkMode ? 'bg-[#0f1f3a] text-gray-300' : 'bg-gray-100 text-gray-600'}`}>
                    {route.category}
                  </span>
                </div>
              </div>
              <div className="flex flex-col items-end gap-2">
                <div 
                  className="w-12 h-12 rounded-xl flex flex-col items-center justify-center"
                  style={{
                    backgroundColor: `${getSafetyColor(route.safety)}20`,
                  }}
                >
                  <Shield className="w-5 h-5" style={{ color: getSafetyColor(route.safety) }} />
                  <span className="text-xs font-bold" style={{ color: getSafetyColor(route.safety) }}>
                    {route.safety}%
                  </span>
                </div>
              </div>
              <ChevronRight className={`w-5 h-5 ${isDarkMode ? 'text-gray-600' : 'text-gray-400'}`} />
            </div>
          ))}
        </div>
      </div>

      {/* Logout Button */}
      <div className="px-6 mt-8">
        <button className={`w-full py-4 rounded-2xl flex items-center justify-center gap-2 ${isDarkMode ? 'bg-[#1a2a42] text-red-400' : 'bg-white text-red-500 shadow-lg'} font-semibold`}>
          <LogOut className="w-5 h-5" />
          <span>Log Out</span>
        </button>
      </div>
    </div>
  );
}