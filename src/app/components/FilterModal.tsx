import { X, Sliders } from 'lucide-react';

interface FilterModalProps {
  isOpen: boolean;
  onClose: () => void;
  isDarkMode: boolean;
}

export function FilterModal({ isOpen, onClose, isDarkMode }: FilterModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />
      
      {/* Modal */}
      <div 
        className={`
          relative w-full max-w-md rounded-t-[32px] p-6 pb-8
          ${isDarkMode 
            ? 'bg-[#1a2a42]' 
            : 'bg-white'
          }
          animate-slide-up
        `}
        style={{
          animation: 'slideUp 0.3s ease-out'
        }}
      >
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className={`w-10 h-10 rounded-xl ${isDarkMode ? 'bg-[#7df258]/20' : 'bg-[#7df258]/10'} flex items-center justify-center`}>
              <Sliders className="w-5 h-5 text-[#7df258]" />
            </div>
            <h2 className={`text-xl font-bold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
              Filters
            </h2>
          </div>
          <button 
            onClick={onClose}
            className={`w-9 h-9 rounded-full ${isDarkMode ? 'bg-[#0f1f3a] hover:bg-[#0a1628]' : 'bg-gray-100 hover:bg-gray-200'} flex items-center justify-center transition-colors`}
          >
            <X className={`w-5 h-5 ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`} />
          </button>
        </div>

        {/* Safety Level */}
        <div className="mb-6">
          <label className={`block text-sm font-semibold mb-3 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
            Safety Level
          </label>
          <div className="grid grid-cols-3 gap-3">
            <button className="px-4 py-3 rounded-xl bg-gradient-to-br from-[#7df258] to-[#4ade80] text-[#0a1628] font-semibold text-sm shadow-[0_4px_12px_rgba(125,242,88,0.3)]">
              All
            </button>
            <button className={`px-4 py-3 rounded-xl font-semibold text-sm ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}>
              High 85%+
            </button>
            <button className={`px-4 py-3 rounded-xl font-semibold text-sm ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}>
              Medium
            </button>
          </div>
        </div>

        {/* Distance Range */}
        <div className="mb-6">
          <label className={`block text-sm font-semibold mb-3 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
            Distance
          </label>
          <div className="space-y-3">
            <div className="flex items-center gap-3">
              <input 
                type="range" 
                min="0" 
                max="50" 
                defaultValue="25"
                className="flex-1 h-2 rounded-full appearance-none cursor-pointer"
                style={{
                  background: `linear-gradient(to right, #7df258 0%, #7df258 50%, ${isDarkMode ? '#0f1f3a' : '#e5e7eb'} 50%, ${isDarkMode ? '#0f1f3a' : '#e5e7eb'} 100%)`
                }}
              />
            </div>
            <div className="flex items-center justify-between">
              <span className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>0 km</span>
              <span className={`text-sm font-semibold ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`}>25 km</span>
              <span className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>50 km</span>
            </div>
          </div>
        </div>

        {/* Traffic Level */}
        <div className="mb-6">
          <label className={`block text-sm font-semibold mb-3 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
            Traffic
          </label>
          <div className="grid grid-cols-3 gap-3">
            <button className={`px-4 py-3 rounded-xl font-semibold text-sm ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}>
              Low
            </button>
            <button className={`px-4 py-3 rounded-xl font-semibold text-sm ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}>
              Moderate
            </button>
            <button className={`px-4 py-3 rounded-xl font-semibold text-sm ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}>
              High
            </button>
          </div>
        </div>

        {/* Lighting */}
        <div className="mb-8">
          <label className={`block text-sm font-semibold mb-3 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
            Lighting
          </label>
          <div className="grid grid-cols-2 gap-3">
            <button className={`px-4 py-3 rounded-xl font-semibold text-sm ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}>
              Excellent
            </button>
            <button className={`px-4 py-3 rounded-xl font-semibold text-sm ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}>
              Good
            </button>
            <button className={`px-4 py-3 rounded-xl font-semibold text-sm ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}>
              Moderate
            </button>
            <button className={`px-4 py-3 rounded-xl font-semibold text-sm ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}>
              Poor
            </button>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex gap-3">
          <button 
            onClick={onClose}
            className={`flex-1 py-4 rounded-2xl font-semibold ${isDarkMode ? 'bg-[#0f1f3a] text-gray-400' : 'bg-gray-100 text-gray-600'}`}
          >
            Reset
          </button>
          <button 
            onClick={onClose}
            className="flex-1 py-4 rounded-2xl bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] font-bold shadow-[0_4px_16px_rgba(125,242,88,0.3)]"
          >
            Apply Filters
          </button>
        </div>
      </div>

      <style>{`
        @keyframes slideUp {
          from {
            transform: translateY(100%);
            opacity: 0;
          }
          to {
            transform: translateY(0);
            opacity: 1;
          }
        }
      `}</style>
    </div>
  );
}
