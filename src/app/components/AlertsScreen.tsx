import { AlertTriangle, CheckCircle, Info, MapPin, Clock, ChevronRight } from 'lucide-react';

interface AlertsScreenProps {
  isDarkMode: boolean;
}

const ALERTS = [
  {
    id: 1,
    type: 'warning',
    title: 'Route Closure Alert',
    message: 'Riverside Trail section temporarily closed due to maintenance.',
    location: 'Riverside Trail',
    time: '2 hours ago',
    icon: AlertTriangle,
    color: '#fbbf24'
  },
  {
    id: 2,
    type: 'success',
    title: 'New Route Added',
    message: 'Check out the newly discovered "Sunset Boulevard Loop" - 95% safety rating!',
    location: 'Downtown Area',
    time: '5 hours ago',
    icon: CheckCircle,
    color: '#7df258'
  },
  {
    id: 3,
    type: 'info',
    title: 'Improved Lighting',
    message: 'Mountain View Loop now has enhanced lighting. Updated safety score: 92%',
    location: 'Mountain View Loop',
    time: '1 day ago',
    icon: Info,
    color: '#3b82f6'
  },
  {
    id: 4,
    type: 'warning',
    title: 'Heavy Traffic Warning',
    message: 'Downtown Circuit experiencing higher than usual traffic. Consider alternative routes.',
    location: 'Downtown Circuit',
    time: '2 days ago',
    icon: AlertTriangle,
    color: '#fbbf24'
  }
];

export function AlertsScreen({ isDarkMode }: AlertsScreenProps) {
  return (
    <div className="h-full overflow-y-auto pb-8">
      {/* Header */}
      <div className={`px-6 pt-16 pb-6 ${isDarkMode ? 'bg-gradient-to-b from-[#0f1f3a] to-transparent' : 'bg-gradient-to-b from-[#e8f0fe] to-transparent'}`}>
        <h1 className={`text-3xl font-bold mb-2 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Alerts</h1>
        <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Stay updated on route conditions</p>
      </div>

      {/* Stats Summary */}
      <div className="px-6 mb-8">
        <div className="grid grid-cols-3 gap-3">
          <div 
            className={`
              rounded-2xl p-4 text-center
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-lg' 
                : 'bg-white shadow-lg'
              }
            `}
          >
            <div className="w-10 h-10 rounded-xl bg-[#7df258]/20 flex items-center justify-center mx-auto mb-2">
              <CheckCircle className="w-5 h-5 text-[#7df258]" />
            </div>
            <p className={`text-xl font-bold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>3</p>
            <p className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Updates</p>
          </div>
          
          <div 
            className={`
              rounded-2xl p-4 text-center
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-lg' 
                : 'bg-white shadow-lg'
              }
            `}
          >
            <div className="w-10 h-10 rounded-xl bg-[#fbbf24]/20 flex items-center justify-center mx-auto mb-2">
              <AlertTriangle className="w-5 h-5 text-[#fbbf24]" />
            </div>
            <p className={`text-xl font-bold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>2</p>
            <p className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Warnings</p>
          </div>
          
          <div 
            className={`
              rounded-2xl p-4 text-center
              ${isDarkMode 
                ? 'bg-[#1a2a42] shadow-lg' 
                : 'bg-white shadow-lg'
              }
            `}
          >
            <div className="w-10 h-10 rounded-xl bg-[#3b82f6]/20 flex items-center justify-center mx-auto mb-2">
              <Info className="w-5 h-5 text-[#3b82f6]" />
            </div>
            <p className={`text-xl font-bold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>1</p>
            <p className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Info</p>
          </div>
        </div>
      </div>

      {/* Recent Alerts */}
      <div className="px-6">
        <h2 className={`text-xl font-bold mb-4 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Recent Alerts</h2>
        <div className="space-y-3">
          {ALERTS.map((alert) => {
            const Icon = alert.icon;
            return (
              <button
                key={alert.id}
                className={`
                  w-full rounded-2xl p-5 text-left
                  ${isDarkMode 
                    ? 'bg-[#1a2a42] shadow-[0_4px_16px_rgba(0,0,0,0.2)] hover:bg-[#0f1f3a]' 
                    : 'bg-white shadow-[0_4px_16px_rgba(0,0,0,0.08)] hover:shadow-[0_6px_20px_rgba(0,0,0,0.12)]'
                  }
                  transition-all duration-300
                `}
              >
                <div className="flex gap-4">
                  {/* Icon */}
                  <div 
                    className="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0"
                    style={{ backgroundColor: `${alert.color}20` }}
                  >
                    <Icon className="w-6 h-6" style={{ color: alert.color }} />
                  </div>

                  {/* Content */}
                  <div className="flex-1">
                    <h3 className={`font-bold mb-1 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                      {alert.title}
                    </h3>
                    <p className={`text-sm mb-3 ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
                      {alert.message}
                    </p>
                    <div className="flex items-center gap-4">
                      <div className="flex items-center gap-1">
                        <MapPin className={`w-4 h-4 ${isDarkMode ? 'text-gray-500' : 'text-gray-400'}`} />
                        <span className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
                          {alert.location}
                        </span>
                      </div>
                      <div className="flex items-center gap-1">
                        <Clock className={`w-4 h-4 ${isDarkMode ? 'text-gray-500' : 'text-gray-400'}`} />
                        <span className={`text-xs ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
                          {alert.time}
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Arrow */}
                  <ChevronRight className={`w-5 h-5 flex-shrink-0 ${isDarkMode ? 'text-gray-600' : 'text-gray-400'}`} />
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Empty State (if no alerts) */}
      {ALERTS.length === 0 && (
        <div className="px-6 py-16 text-center">
          <div className={`w-20 h-20 rounded-full ${isDarkMode ? 'bg-[#1a2a42]' : 'bg-gray-100'} flex items-center justify-center mx-auto mb-4`}>
            <CheckCircle className={`w-10 h-10 ${isDarkMode ? 'text-gray-600' : 'text-gray-400'}`} />
          </div>
          <h3 className={`text-lg font-bold mb-2 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
            All Clear!
          </h3>
          <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
            No alerts for your routes at the moment.
          </p>
        </div>
      )}
    </div>
  );
}
