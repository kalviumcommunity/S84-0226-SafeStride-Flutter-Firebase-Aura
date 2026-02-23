import { ArrowLeft, Shield, MapPin, Clock, TrendingUp, Star, ThumbsUp, Share2, Bookmark } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface RouteDetailScreenProps {
  route: any;
  onBack: () => void;
  isDarkMode: boolean;
}

const MOCK_REVIEWS = [
  {
    id: 1,
    author: 'Sarah Chen',
    avatar: 'woman portrait professional',
    rating: 5,
    date: 'Feb 14, 2026',
    text: 'Perfect morning run route! Well-lit and very safe. The riverside views are absolutely stunning.',
    helpful: 24
  },
  {
    id: 2,
    author: 'Marcus Johnson',
    avatar: 'man portrait professional',
    rating: 5,
    date: 'Feb 12, 2026',
    text: 'Great for cycling. Smooth path with minimal traffic. Highly recommended for early morning rides.',
    helpful: 18
  },
  {
    id: 3,
    author: 'Emily Rodriguez',
    avatar: 'woman runner portrait',
    rating: 4,
    date: 'Feb 10, 2026',
    text: 'Love this trail! Only minor issue is it can get crowded on weekends. Go early for best experience.',
    helpful: 15
  }
];

export function RouteDetailScreen({ route, onBack, isDarkMode }: RouteDetailScreenProps) {
  const getSafetyColor = (safety: number) => {
    if (safety >= 85) return '#7df258';
    if (safety >= 70) return '#fbbf24';
    return '#ef4444';
  };

  return (
    <div className="h-full overflow-y-auto">
      {/* Hero Section */}
      <div className="relative h-80">
        <ImageWithFallback
          src={`https://source.unsplash.com/800x600/?${route.image}`}
          alt={route.name}
          className="w-full h-full object-cover"
        />
        {/* Gradient Overlay */}
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-black/20 to-black/60" />
        
        {/* Header Actions */}
        <div className="absolute top-0 left-0 right-0 flex items-center justify-between p-6 pt-12">
          <button 
            onClick={onBack}
            className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center shadow-lg"
          >
            <ArrowLeft className="w-5 h-5 text-white" />
          </button>
          <div className="flex items-center gap-3">
            <button className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center shadow-lg">
              <Share2 className="w-5 h-5 text-white" />
            </button>
            <button className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center shadow-lg">
              <Bookmark className="w-5 h-5 text-white" />
            </button>
          </div>
        </div>

        {/* Floating Safety Badge */}
        <div className="absolute bottom-6 right-6">
          <div 
            className="w-20 h-20 rounded-3xl flex flex-col items-center justify-center backdrop-blur-xl"
            style={{
              backgroundColor: `${getSafetyColor(route.safety)}30`,
              boxShadow: `0 8px 24px ${getSafetyColor(route.safety)}40`
            }}
          >
            <Shield className="w-8 h-8 mb-1" style={{ color: getSafetyColor(route.safety) }} />
            <span className="text-sm font-bold text-white">{route.safety}%</span>
            <span className="text-xs text-white/80">Safe</span>
          </div>
        </div>

        {/* Route Info Overlay */}
        <div className="absolute bottom-6 left-6 right-32">
          <h1 className="text-3xl font-bold text-white mb-2">{route.name}</h1>
          <div className="flex items-center gap-2 flex-wrap">
            <span className="px-3 py-1 rounded-full bg-white/20 backdrop-blur-md text-white text-xs font-medium">
              {route.category}
            </span>
            <span className="px-3 py-1 rounded-full bg-white/20 backdrop-blur-md text-white text-xs font-medium">
              {route.distance}
            </span>
            <div className="flex items-center gap-1">
              <Star className="w-4 h-4 text-[#7df258] fill-[#7df258]" />
              <span className="text-white text-sm font-semibold">{route.rating}</span>
              <span className="text-white/70 text-sm">({route.reviews})</span>
            </div>
          </div>
        </div>
      </div>

      {/* Content Section */}
      <div className={`${isDarkMode ? 'bg-[#0a1628]' : 'bg-gradient-to-b from-[#f5f7fa] to-white'} px-6 pb-32`}>
        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-4 -mt-8 mb-8">
          <div 
            className={`
              rounded-3xl p-5
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-[0_8px_24px_rgba(0,0,0,0.3)]' 
                : 'bg-white shadow-[0_8px_24px_rgba(0,0,0,0.08)]'
              }
            `}
          >
            <MapPin className={`w-6 h-6 mb-3 ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
            <p className={`text-2xl font-bold mb-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>{route.distance}</p>
            <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Distance</p>
          </div>

          <div 
            className={`
              rounded-3xl p-5
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-[0_8px_24px_rgba(0,0,0,0.3)]' 
                : 'bg-white shadow-[0_8px_24px_rgba(0,0,0,0.08)]'
              }
            `}
          >
            <Clock className={`w-6 h-6 mb-3 ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
            <p className={`text-2xl font-bold mb-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>{route.lighting}</p>
            <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Lighting</p>
          </div>

          <div 
            className={`
              rounded-3xl p-5
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-[0_8px_24px_rgba(0,0,0,0.3)]' 
                : 'bg-white shadow-[0_8px_24px_rgba(0,0,0,0.08)]'
              }
            `}
          >
            <TrendingUp className={`w-6 h-6 mb-3 ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
            <p className={`text-2xl font-bold mb-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>{route.traffic}</p>
            <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Traffic</p>
          </div>

          <div 
            className={`
              rounded-3xl p-5
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-[0_8px_24px_rgba(0,0,0,0.3)]' 
                : 'bg-white shadow-[0_8px_24px_rgba(0,0,0,0.08)]'
              }
            `}
          >
            <Star className={`w-6 h-6 mb-3 ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
            <p className={`text-2xl font-bold mb-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>{route.crowd}</p>
            <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Crowd Level</p>
          </div>
        </div>

        {/* Reviews Section */}
        <div className="mb-8">
          <h2 className={`text-2xl font-bold mb-4 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
            Reviews
          </h2>
          <div className="space-y-4">
            {MOCK_REVIEWS.map((review) => (
              <div 
                key={review.id}
                className={`
                  rounded-2xl p-5
                  ${isDarkMode 
                    ? 'bg-[#1a2a42] shadow-[0_4px_16px_rgba(0,0,0,0.2)]' 
                    : 'bg-white shadow-[0_4px_16px_rgba(0,0,0,0.06)]'
                  }
                `}
              >
                <div className="flex items-start gap-4 mb-3">
                  <ImageWithFallback
                    src={`https://source.unsplash.com/100x100/?${review.avatar}`}
                    alt={review.author}
                    className="w-12 h-12 rounded-full object-cover"
                  />
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-1">
                      <h3 className={`font-semibold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                        {review.author}
                      </h3>
                      <span className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                        {review.date}
                      </span>
                    </div>
                    <div className="flex items-center gap-1 mb-2">
                      {[...Array(5)].map((_, i) => (
                        <Star 
                          key={i}
                          className={`w-4 h-4 ${i < review.rating ? 'text-[#7df258] fill-[#7df258]' : isDarkMode ? 'text-gray-600' : 'text-gray-300'}`}
                        />
                      ))}
                    </div>
                  </div>
                </div>
                <p className={`text-sm mb-3 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
                  {review.text}
                </p>
                <button className={`flex items-center gap-2 text-sm ${isDarkMode ? 'text-gray-400 hover:text-[#7df258]' : 'text-gray-600 hover:text-[#1e40af]'} transition-colors`}>
                  <ThumbsUp className="w-4 h-4" />
                  <span>Helpful ({review.helpful})</span>
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* CTA Button */}
        <button className="w-full py-5 rounded-2xl bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] text-lg font-bold shadow-[0_8px_24px_rgba(125,242,88,0.3)] hover:shadow-[0_12px_32px_rgba(125,242,88,0.4)] transition-all duration-300">
          Start Navigation
        </button>
      </div>
    </div>
  );
}
