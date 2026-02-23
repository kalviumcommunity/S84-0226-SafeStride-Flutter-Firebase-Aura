import { useState } from 'react';
import { MapScreen } from './components/MapScreen';
import { DiscoverScreen } from './components/DiscoverScreen';
import { AddRouteScreen } from './components/AddRouteScreen';
import { AlertsScreen } from './components/AlertsScreen';
import { ProfileScreen } from './components/ProfileScreen';
import { RouteDetailScreen } from './components/RouteDetailScreen';
import { BottomNav } from './components/BottomNav';

export default function App() {
  const [activeTab, setActiveTab] = useState('map');
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [selectedRoute, setSelectedRoute] = useState<any>(null);

  const handleRouteSelect = (route: any) => {
    setSelectedRoute(route);
  };

  const handleBackToMap = () => {
    setSelectedRoute(null);
  };

  const renderScreen = () => {
    if (selectedRoute) {
      return <RouteDetailScreen route={selectedRoute} onBack={handleBackToMap} isDarkMode={isDarkMode} />;
    }

    switch (activeTab) {
      case 'map':
        return <MapScreen onRouteSelect={handleRouteSelect} isDarkMode={isDarkMode} />;
      case 'discover':
        return <DiscoverScreen onRouteSelect={handleRouteSelect} isDarkMode={isDarkMode} />;
      case 'add':
        return <AddRouteScreen isDarkMode={isDarkMode} />;
      case 'alerts':
        return <AlertsScreen isDarkMode={isDarkMode} />;
      case 'profile':
        return <ProfileScreen isDarkMode={isDarkMode} onToggleDarkMode={() => setIsDarkMode(!isDarkMode)} />;
      default:
        return <MapScreen onRouteSelect={handleRouteSelect} isDarkMode={isDarkMode} />;
    }
  };

  return (
    <div className={`min-h-screen ${isDarkMode ? 'bg-[#0a1628]' : 'bg-gradient-to-b from-[#e8f0fe] via-[#f5f7fa] to-white'} transition-colors duration-300`}>
      <div className="max-w-md mx-auto h-screen relative pb-24">
        {renderScreen()}
        {!selectedRoute && (
          <BottomNav activeTab={activeTab} onTabChange={setActiveTab} isDarkMode={isDarkMode} />
        )}
      </div>
    </div>
  );
}
