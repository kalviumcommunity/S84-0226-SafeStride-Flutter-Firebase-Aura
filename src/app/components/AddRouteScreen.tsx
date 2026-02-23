import { MapPin, Upload, Camera, Navigation, CheckCircle } from 'lucide-react';
import { useState } from 'react';

interface AddRouteScreenProps {
  isDarkMode: boolean;
}

export function AddRouteScreen({ isDarkMode }: AddRouteScreenProps) {
  const [step, setStep] = useState(1);
  const [routeName, setRouteName] = useState('');
  const [routeType, setRouteType] = useState<'runner' | 'cyclist' | null>(null);
  const [distance, setDistance] = useState('');

  const handleSubmit = () => {
    setStep(4); // Show success
    setTimeout(() => {
      setStep(1);
      setRouteName('');
      setRouteType(null);
      setDistance('');
    }, 2000);
  };

  if (step === 4) {
    return (
      <div className="h-full flex flex-col items-center justify-center px-6">
        <div className="w-24 h-24 rounded-full bg-gradient-to-br from-[#7df258] to-[#4ade80] flex items-center justify-center mb-6 shadow-[0_8px_32px_rgba(125,242,88,0.4)]">
          <CheckCircle className="w-12 h-12 text-white" strokeWidth={3} />
        </div>
        <h2 className={`text-2xl font-bold mb-2 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
          Route Added!
        </h2>
        <p className={`text-center ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
          Your route has been successfully submitted for review.
        </p>
      </div>
    );
  }

  return (
    <div className="h-full overflow-y-auto pb-8">
      {/* Header */}
      <div className={`px-6 pt-16 pb-6 ${isDarkMode ? 'bg-gradient-to-b from-[#0f1f3a] to-transparent' : 'bg-gradient-to-b from-[#e8f0fe] to-transparent'}`}>
        <h1 className={`text-3xl font-bold mb-2 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Add Route</h1>
        <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>Share your favorite route with the community</p>
      </div>

      {/* Progress Steps */}
      <div className="px-6 mb-8">
        <div className="flex items-center justify-between">
          {[1, 2, 3].map((stepNum) => (
            <div key={stepNum} className="flex items-center flex-1">
              <div className="flex items-center gap-3 flex-1">
                <div 
                  className={`
                    w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm transition-all duration-300
                    ${step >= stepNum 
                      ? 'bg-gradient-to-br from-[#7df258] to-[#4ade80] text-[#0a1628] shadow-[0_4px_12px_rgba(125,242,88,0.3)]'
                      : isDarkMode 
                        ? 'bg-[#1a2a42] text-gray-500' 
                        : 'bg-gray-200 text-gray-400'
                    }
                  `}
                >
                  {stepNum}
                </div>
                {stepNum < 3 && (
                  <div className={`flex-1 h-1 rounded-full ${step > stepNum ? 'bg-gradient-to-r from-[#7df258] to-[#4ade80]' : isDarkMode ? 'bg-[#1a2a42]' : 'bg-gray-200'}`} />
                )}
              </div>
            </div>
          ))}
        </div>
        <div className="flex items-center justify-between mt-2">
          <span className={`text-xs ${step >= 1 ? isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]' : isDarkMode ? 'text-gray-500' : 'text-gray-400'}`}>Details</span>
          <span className={`text-xs ${step >= 2 ? isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]' : isDarkMode ? 'text-gray-500' : 'text-gray-400'}`}>Location</span>
          <span className={`text-xs ${step >= 3 ? isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]' : isDarkMode ? 'text-gray-500' : 'text-gray-400'}`}>Media</span>
        </div>
      </div>

      {/* Step Content */}
      <div className="px-6">
        {step === 1 && (
          <div className="space-y-6">
            <div>
              <label className={`block text-sm font-semibold mb-2 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                Route Name
              </label>
              <input
                type="text"
                value={routeName}
                onChange={(e) => setRouteName(e.target.value)}
                placeholder="Enter route name"
                className={`
                  w-full px-4 py-4 rounded-2xl outline-none transition-all duration-300
                  ${isDarkMode 
                    ? 'bg-[#1a2a42] text-white placeholder-gray-500 focus:bg-[#0f1f3a]' 
                    : 'bg-white text-[#0a1628] placeholder-gray-400 shadow-lg focus:shadow-xl'
                  }
                `}
              />
            </div>

            <div>
              <label className={`block text-sm font-semibold mb-3 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                Route Type
              </label>
              <div className="grid grid-cols-2 gap-4">
                <button
                  onClick={() => setRouteType('runner')}
                  className={`
                    p-6 rounded-2xl transition-all duration-300
                    ${routeType === 'runner'
                      ? 'bg-gradient-to-br from-[#7df258] to-[#4ade80] text-[#0a1628] shadow-[0_8px_24px_rgba(125,242,88,0.3)]'
                      : isDarkMode 
                        ? 'bg-[#1a2a42] text-gray-400 hover:bg-[#0f1f3a]' 
                        : 'bg-white text-gray-600 hover:bg-gray-50 shadow-lg'
                    }
                  `}
                >
                  <div className="text-5xl mb-3">🏃‍♂️</div>
                  <p className="font-semibold">Runner</p>
                </button>
                <button
                  onClick={() => setRouteType('cyclist')}
                  className={`
                    p-6 rounded-2xl transition-all duration-300
                    ${routeType === 'cyclist'
                      ? 'bg-gradient-to-br from-[#7df258] to-[#4ade80] text-[#0a1628] shadow-[0_8px_24px_rgba(125,242,88,0.3)]'
                      : isDarkMode 
                        ? 'bg-[#1a2a42] text-gray-400 hover:bg-[#0f1f3a]' 
                        : 'bg-white text-gray-600 hover:bg-gray-50 shadow-lg'
                    }
                  `}
                >
                  <div className="text-5xl mb-3">🚴‍♀️</div>
                  <p className="font-semibold">Cyclist</p>
                </button>
              </div>
            </div>

            <div>
              <label className={`block text-sm font-semibold mb-2 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                Distance (km)
              </label>
              <input
                type="number"
                value={distance}
                onChange={(e) => setDistance(e.target.value)}
                placeholder="0.0"
                className={`
                  w-full px-4 py-4 rounded-2xl outline-none transition-all duration-300
                  ${isDarkMode 
                    ? 'bg-[#1a2a42] text-white placeholder-gray-500 focus:bg-[#0f1f3a]' 
                    : 'bg-white text-[#0a1628] placeholder-gray-400 shadow-lg focus:shadow-xl'
                  }
                `}
              />
            </div>

            <button
              onClick={() => setStep(2)}
              disabled={!routeName || !routeType || !distance}
              className={`
                w-full py-5 rounded-2xl font-bold text-lg transition-all duration-300
                ${!routeName || !routeType || !distance
                  ? isDarkMode 
                    ? 'bg-[#1a2a42] text-gray-600 cursor-not-allowed' 
                    : 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  : 'bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] shadow-[0_8px_24px_rgba(125,242,88,0.3)] hover:shadow-[0_12px_32px_rgba(125,242,88,0.4)]'
                }
              `}
            >
              Continue
            </button>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-6">
            <div 
              className={`
                rounded-3xl p-8 text-center
                ${isDarkMode 
                  ? 'bg-[#1a2a42] border-2 border-dashed border-[#0f1f3a]' 
                  : 'bg-white border-2 border-dashed border-gray-200 shadow-lg'
                }
              `}
            >
              <div className={`w-16 h-16 rounded-full ${isDarkMode ? 'bg-[#0f1f3a]' : 'bg-blue-50'} flex items-center justify-center mx-auto mb-4`}>
                <MapPin className={`w-8 h-8 ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
              </div>
              <h3 className={`text-lg font-bold mb-2 ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>
                Mark Your Route
              </h3>
              <p className={`text-sm mb-4 ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
                Tap on the map to mark the starting point and route path
              </p>
              <button className="px-6 py-3 rounded-xl bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] font-semibold">
                Open Map
              </button>
            </div>

            <button
              onClick={() => setStep(3)}
              className="w-full py-5 rounded-2xl bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] font-bold text-lg shadow-[0_8px_24px_rgba(125,242,88,0.3)] hover:shadow-[0_12px_32px_rgba(125,242,88,0.4)] transition-all duration-300"
            >
              Continue
            </button>
            <button
              onClick={() => setStep(1)}
              className={`w-full py-5 rounded-2xl font-semibold ${isDarkMode ? 'text-gray-400 hover:text-white' : 'text-gray-600 hover:text-[#0a1628]'} transition-colors`}
            >
              Back
            </button>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-6">
            <div className="grid grid-cols-2 gap-4">
              <button 
                className={`
                  rounded-3xl p-8 text-center transition-all duration-300
                  ${isDarkMode 
                    ? 'bg-[#1a2a42] hover:bg-[#0f1f3a] shadow-lg' 
                    : 'bg-white hover:bg-gray-50 shadow-lg hover:shadow-xl'
                  }
                `}
              >
                <div className={`w-16 h-16 rounded-full ${isDarkMode ? 'bg-[#0f1f3a]' : 'bg-blue-50'} flex items-center justify-center mx-auto mb-3`}>
                  <Camera className={`w-8 h-8 ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
                </div>
                <p className={`font-semibold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Take Photo</p>
              </button>
              
              <button 
                className={`
                  rounded-3xl p-8 text-center transition-all duration-300
                  ${isDarkMode 
                    ? 'bg-[#1a2a42] hover:bg-[#0f1f3a] shadow-lg' 
                    : 'bg-white hover:bg-gray-50 shadow-lg hover:shadow-xl'
                  }
                `}
              >
                <div className={`w-16 h-16 rounded-full ${isDarkMode ? 'bg-[#0f1f3a]' : 'bg-blue-50'} flex items-center justify-center mx-auto mb-3`}>
                  <Upload className={`w-8 h-8 ${isDarkMode ? 'text-[#7df258]' : 'text-[#1e40af]'}`} />
                </div>
                <p className={`font-semibold ${isDarkMode ? 'text-white' : 'text-[#0a1628]'}`}>Upload</p>
              </button>
            </div>

            <div className={`rounded-2xl p-4 ${isDarkMode ? 'bg-[#1a2a42]' : 'bg-blue-50'}`}>
              <p className={`text-sm ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
                💡 <span className="font-semibold">Tip:</span> Adding photos helps others discover your route!
              </p>
            </div>

            <button
              onClick={handleSubmit}
              className="w-full py-5 rounded-2xl bg-gradient-to-r from-[#7df258] to-[#4ade80] text-[#0a1628] font-bold text-lg shadow-[0_8px_24px_rgba(125,242,88,0.3)] hover:shadow-[0_12px_32px_rgba(125,242,88,0.4)] transition-all duration-300"
            >
              Submit Route
            </button>
            <button
              onClick={() => setStep(2)}
              className={`w-full py-5 rounded-2xl font-semibold ${isDarkMode ? 'text-gray-400 hover:text-white' : 'text-gray-600 hover:text-[#0a1628]'} transition-colors`}
            >
              Back
            </button>
          </div>
        )}
      </div>
    </div>
  );
}