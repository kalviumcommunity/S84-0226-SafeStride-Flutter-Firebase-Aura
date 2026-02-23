import { Map, Compass, PlusCircle, Bell, User } from 'lucide-react';

interface BottomNavProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
  isDarkMode: boolean;
}

export function BottomNav({ activeTab, onTabChange, isDarkMode }: BottomNavProps) {
  const tabs = [
    { id: 'map', icon: Map, label: 'Map' },
    { id: 'discover', icon: Compass, label: 'Discover' },
    { id: 'add', icon: PlusCircle, label: 'Add', isFab: true },
    { id: 'alerts', icon: Bell, label: 'Alerts' },
    { id: 'profile', icon: User, label: 'Profile' },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 flex justify-center pb-6 px-4 pointer-events-none">
      <div className="max-w-md w-full pointer-events-auto">
        <div 
          className={`
            rounded-[28px] px-6 py-4 
            ${isDarkMode 
              ? 'bg-[#1a2a42] shadow-[0_-4px_24px_rgba(0,0,0,0.3)]' 
              : 'bg-white shadow-[0_-4px_24px_rgba(0,0,0,0.08)]'
            }
            backdrop-blur-lg
          `}
        >
          <div className="flex items-center justify-between relative">
            {tabs.map((tab, index) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;
              
              if (tab.isFab) {
                return (
                  <button
                    key={tab.id}
                    onClick={() => onTabChange(tab.id)}
                    className="relative -mt-8"
                  >
                    <div 
                      className={`
                        w-14 h-14 rounded-full flex items-center justify-center
                        bg-gradient-to-br from-[#7df258] to-[#4ade80]
                        shadow-[0_4px_16px_rgba(125,242,88,0.4)]
                        ${isActive ? 'shadow-[0_4px_24px_rgba(125,242,88,0.6)] scale-110' : ''}
                        transition-all duration-300
                      `}
                    >
                      <Icon className="w-6 h-6 text-[#0a1628]" strokeWidth={2.5} />
                    </div>
                  </button>
                );
              }

              return (
                <button
                  key={tab.id}
                  onClick={() => onTabChange(tab.id)}
                  className="flex flex-col items-center gap-1 relative min-w-[60px]"
                >
                  <div className="relative">
                    <Icon 
                      className={`
                        w-6 h-6 transition-all duration-300
                        ${isActive 
                          ? 'text-[#7df258] drop-shadow-[0_0_8px_rgba(125,242,88,0.6)]' 
                          : isDarkMode 
                            ? 'text-gray-400' 
                            : 'text-gray-500'
                        }
                      `}
                      strokeWidth={isActive ? 2.5 : 2}
                    />
                    {isActive && (
                      <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-1 h-1 rounded-full bg-[#7df258] shadow-[0_0_8px_rgba(125,242,88,0.8)]" />
                    )}
                  </div>
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}
