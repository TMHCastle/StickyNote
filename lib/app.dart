import 'packagefluttermaterial.dart';
import 'pagesfloating_overlay.dart';
import 'pagesedit_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner false,
      title 'Floating Log App',
      initialRoute '',
      routes {
        '' (context) = const FloatingOverlay(),
        'edit' (context) = const EditPage(),
      },
    );
  }
}
