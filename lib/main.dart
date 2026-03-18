import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoning Bakery',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

// ==================== 로그인 화면 ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  void _login() {
    String id = _idController.text.trim();
    String pw = _pwController.text.trim();

    if (id.length != 4 || !RegExp(r'^\d{4}$').hasMatch(id)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID는 4자리 숫자여야 해요')));
      return;
    }
    if (pw != "0000") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호는 테스트용 "0000"입니다')));
      return;
    }

    int role = int.parse(id[0]);
    Widget nextScreen;

    if (role == 1) nextScreen = const CustomerScreen();
    else if (role == 2) nextScreen = const StaffScreen();
    else if (role == 3) nextScreen = const AdminMenuScreen();
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID가 잘못됐어요')));
      return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _idController, decoration: const InputDecoration(labelText: '사원번호 (ID)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextField(controller: _pwController, decoration: const InputDecoration(labelText: '비밀번호'), obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _login, child: const Text('로그인'), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50))),
          ],
        ),
      ),
    );
  }
}

// ==================== 관리자 메뉴 화면 (원래 4개 메뉴 복구) ====================
class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('관리자 메뉴')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('관리자 메뉴', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen())),
              child: const Text('제품관리'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeManagementScreen())),
              child: const Text('직원관리'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerManagementScreen())),
              child: const Text('고객관리'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RawMaterialCostScreen())),
              child: const Text('원료원가관리'),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 각 메뉴 화면 (플레이스홀더지만 정상 이동) ====================
class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('제품관리')), body: const Center(child: Text('제품 관리 화면\n(제품 등록, 재고, 가격 관리 등)')));
}

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});
  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final List<Map<String, dynamic>> _employees = [];

  void _addEmployee() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeFormScreen()));
    if (result != null) setState(() => _employees.add(result));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('직원관리')),
      body: ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final e = _employees[index];
          return ListTile(
            title: Text('${e['name'] ?? "이름 없음"} (ID: ${e['id']})'),
            subtitle: Text('전화: ${e['phone'] ?? '-'} | 역할: ${e['role']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addEmployee, child: const Icon(Icons.add)),
    );
  }
}

class CustomerManagementScreen extends StatelessWidget {
  const CustomerManagementScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('고객관리')), body: const Center(child: Text('고객 관리 화면\n(포인트, 주문 내역 관리 등)')));
}

class RawMaterialCostScreen extends StatelessWidget {
  const RawMaterialCostScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('원료원가관리')), body: const Center(child: Text('원료원가 관리 화면\n(원가 계산, 재고 원가 관리 등)')));
}

// ==================== 직원 추가 화면 (이름·전화번호 완전 표시) ====================
class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key});
  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  int _role = 2;

  void _save() {
    final data = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _nameController.text,
      'phone': _phoneController.text,
      'password': _passwordController.text,
      'role': _role,
    };
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('신규 직원 등록')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '이름')),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: '전화번호'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 1, child: Text('고객')),
                DropdownMenuItem(value: 2, child: Text('직원')),
                DropdownMenuItem(value: 3, child: Text('관리자')),
              ],
              onChanged: (v) => setState(() => _role = v!),
              decoration: const InputDecoration(labelText: '역할'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: '초기 비밀번호'), obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('저장하기')),
          ],
        ),
      ),
    );
  }
}

// ==================== 나머지 화면 ====================
class StaffScreen extends StatelessWidget { const StaffScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('직원 화면'))); }
class CustomerScreen extends StatelessWidget { const CustomerScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('고객 화면'))); }
class ChangePasswordScreen extends StatelessWidget { const ChangePasswordScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('비밀번호 변경 화면'))); }
