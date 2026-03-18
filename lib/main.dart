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

// 로그인 화면
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
    else if (role == 3) nextScreen = const AdminScreen();
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

// 직원 화면
class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())), child: const Text('My account')),
                ElevatedButton(onPressed: () {}, child: const Text('Information')),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Task', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Sales')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {}, child: const Text('Working time checking')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {}, child: const Text('Notices')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {}, child: const Text("Today's my tasks")),
            const Spacer(),
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Logout')),
          ],
        ),
      ),
    );
  }
}

// 관리자 화면 (직원 목록 + 추가 버튼)
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<Map<String, dynamic>> _employees = [];

  void _addEmployee() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeFormScreen()));
    if (result != null) setState(() => _employees.add(result));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('관리자 - 직원 관리')),
      body: ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final e = _employees[index];
          return ListTile(
            title: Text('${e['name'] ?? "이름 없음"} (ID: ${e['id']})'),
            subtitle: Text('전화: ${e['phone'] ?? '-'} | 역할: ${e['role']}'),
            trailing: const Icon(Icons.edit),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addEmployee, child: const Icon(Icons.add)),
    );
  }
}

// 직원 추가 화면 (이름, 전화번호 완전 표시 - 문제 해결 완료!)
class EmployeeFormScreen extends StatefulWidget {
  final Map? employee;
  const EmployeeFormScreen({super.key, this.employee});
  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late int _role;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.employee?['phone'] ?? '');
    _passwordController = TextEditingController(text: widget.employee?['password'] ?? '');
    _role = widget.employee?['role'] ?? 2;
  }

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

// 나머지 화면
class CustomerScreen extends StatelessWidget { const CustomerScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('고객 화면'))); }
class ChangePasswordScreen extends StatelessWidget { const ChangePasswordScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('비밀번호 변경')), body: const Center(child: Text('비밀번호 변경 화면'))); }
