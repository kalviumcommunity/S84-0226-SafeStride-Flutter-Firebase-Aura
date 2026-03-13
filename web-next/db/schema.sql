CREATE TABLE routes (
  route_id UUID PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  distance NUMERIC(5,2) NOT NULL,
  route_type VARCHAR(20) NOT NULL CHECK (route_type IN ('Runner', 'Walk', 'Cycle')),
  coordinates JSONB NOT NULL,
  safety_score NUMERIC(5,2) NOT NULL,
  lighting_score NUMERIC(5,2) NOT NULL,
  crime_score NUMERIC(5,2) NOT NULL,
  crowd_density NUMERIC(5,2) NOT NULL,
  user_reports INTEGER NOT NULL DEFAULT 0,
  rating NUMERIC(2,1) NOT NULL DEFAULT 0,
  total_runs INTEGER NOT NULL DEFAULT 0,
  runs_last_24h INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE user_runs (
  run_id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  route_id UUID NOT NULL REFERENCES routes(route_id) ON DELETE CASCADE,
  time_minutes INTEGER NOT NULL,
  distance NUMERIC(5,2) NOT NULL,
  rating NUMERIC(2,1),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_routes_safety ON routes (safety_score DESC);
CREATE INDEX idx_routes_trending ON routes (runs_last_24h DESC);
CREATE INDEX idx_routes_rating ON routes (rating DESC);
CREATE INDEX idx_user_runs_user ON user_runs (user_id, created_at DESC);
