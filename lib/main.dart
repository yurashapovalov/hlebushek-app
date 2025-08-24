import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'config/supabase_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

// Глобальный экземпляр Supabase клиента
final supabase = SupabaseClient(
  SupabaseConfig.supabaseUrl,
  SupabaseConfig.supabaseAnonKey,
  authOptions: const AuthClientOptions(
    authFlowType: AuthFlowType.implicit, // Используем implicit flow вместо PKCE
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Хлебушек App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {'/home': (context) => const HomeScreen()},
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isTestingConnection = false;
  String? _connectionResult;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> _testSupabaseConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionResult = null;
    });

    try {
      // Простой тест - проверяем подключение к Supabase
      final session = supabase.auth.currentSession;

      setState(() {
        _connectionResult =
            'Подключение успешно! ✅\n'
            'Статус: ${session != null ? "Авторизован" : "Анонимный пользователь"}\n'
            'Готов к работе!';
      });
    } catch (error) {
      setState(() {
        _connectionResult = 'Ошибка подключения: ❌\n${error.toString()}';
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  Widget _buildSupabaseStatus() {
    final isConnected =
        SupabaseConfig.supabaseUrl != 'YOUR_SUPABASE_URL' &&
        SupabaseConfig.supabaseUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: isConnected ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            isConnected ? 'Supabase подключен! ✅' : 'Supabase не настроен ❌',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isConnected ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isConnected
                ? 'Конфигурация готова'
                : 'Настройте URL и ключи в config/supabase_config.dart',
            style: TextStyle(
              fontSize: 12,
              color: isConnected ? Colors.green.shade600 : Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (isConnected) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isTestingConnection ? null : _testSupabaseConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: _isTestingConnection
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Тестировать подключение'),
            ),
          ],
          if (_connectionResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _connectionResult!.contains('успешно')
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _connectionResult!,
                style: TextStyle(
                  fontSize: 12,
                  color: _connectionResult!.contains('успешно')
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '🍞 Добро пожаловать в Хлебушек App! 🍞',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Количество нажатий на кнопку:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Горячая перезагрузка работает! 🔥',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            _buildSupabaseStatus(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Увеличить счетчик',
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
