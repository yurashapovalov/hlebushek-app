/// Конфигурация Supabase - EXAMPLE файл
/// 
/// Скопируйте этот файл в supabase_config.dart и замените значения на реальные:
/// 1. Перейдите на https://supabase.com/dashboard
/// 2. Выберите ваш проект
/// 3. Settings → API → Project URL и anon public key
/// 4. Замените значения ниже
class SupabaseConfig {
  // Замените на ваш реальный URL проекта Supabase
  static const String supabaseUrl = 'https://your-project.supabase.co';
  
  // Замените на ваш реальный anon public key
  static const String supabaseAnonKey = 'your-anon-public-key-here';
  
  // Схема для deep links (можете изменить на свою)
  static const String authCallbackUrlScheme = 'hlebushek';
}
