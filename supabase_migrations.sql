-- ============================================================
-- Tesla Rayos X & Control Biológico — Supabase Migrations
-- Ejecutar en: Supabase Dashboard > SQL Editor > New query
-- ============================================================

-- 1. Tabla profiles (auto-creada al registrarse)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  display_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Función para auto-crear perfil al registrarse
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. Tabla requests (solicitudes de cita)
CREATE TABLE public.requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  servicio TEXT NOT NULL,
  servicio_icon TEXT NOT NULL,
  nombre_cliente TEXT NOT NULL,
  fecha DATE NOT NULL,
  hora TEXT,
  descripcion TEXT,
  estado TEXT NOT NULL DEFAULT 'Pendiente'
    CHECK (estado IN ('Pendiente', 'Aprobado', 'Rechazado')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_requests_user_id ON public.requests(user_id);
CREATE INDEX idx_requests_created_at ON public.requests(created_at DESC);

-- 3. Habilitar Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requests ENABLE ROW LEVEL SECURITY;

-- 4. Políticas para profiles
CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_insert_own" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- 5. Políticas para requests (cada usuario solo ve las suyas)
CREATE POLICY "requests_select_own" ON public.requests
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "requests_insert_own" ON public.requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "requests_update_own" ON public.requests
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "requests_delete_own" ON public.requests
  FOR DELETE USING (auth.uid() = user_id);

-- 6. Permisos
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.requests TO authenticated;

-- ============================================================
-- Verificación: ambas tablas deben mostrar rowsecurity = true
-- ============================================================
-- SELECT tablename, rowsecurity FROM pg_tables
-- WHERE schemaname = 'public' AND tablename IN ('profiles', 'requests');
