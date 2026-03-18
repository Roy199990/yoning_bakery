import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://opijjfdtyqxtjidtkbrv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9waWpqZmR0eXF4dGppZHRrYnJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM4MDg4NzQsImV4cCI6MjA4OTM4NDg3NH0.FKkPLzEHxru2yCmKs6KMrLNQDutvrLwgmPILj82lPN4',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoning Bakery',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
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

  void _login() async {
    String idStr = _idController.text.trim();
    String pw = _pwController.text.trim();

    if (idStr.length != 4 || !RegExp(r'^\d{4}$').hasMatch(idStr)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID는 4자리 숫자여야 해요')));
      return;
    }

    int id = int.parse(idStr);

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('없는 아이디입니다')));
        return;
      }

      if (response['password'] != pw) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호가 틀렸어요')));
        return;
      }

      int role = response['role'] ?? 0;
      Widget nextScreen;
      if (role == 1) nextScreen = const CustomerScreen();
      else if (role == 2) nextScreen = const StaffScreen();
      else nextScreen = const AdminScreen();

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('없는 아이디입니다')));
    }
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

// ==================== 직원 화면 ====================
class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ElevatedButton(onPressed: () {}, child: const Text('My account')), ElevatedButton(onPressed: () {}, child: const Text('Information'))]),
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
          ],
        ),
      ),
    );
  }
}

// ==================== 고객 화면 ====================
class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객 화면'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())))],
      ),
      body: Center(child: const Text('고객 화면입니다', style: TextStyle(fontSize: 24))),
    );
  }
}

// ==================== 관리자 화면 (직각형 버튼) ====================
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 패널'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _adminButton(context, '제품 관리', Icons.shopping_basket, const ProductManagementScreen()),
          _adminButton(context, '레시피 관리', Icons.book, null),
          _adminButton(context, '원료 재고', Icons.inventory, null),
          _adminButton(context, '직원 관리', Icons.people, const EmployeeManagementScreen()),
          _adminButton(context, '고객 관리', Icons.person, const CustomerManagementScreen()),
          _adminButton(context, '오늘 일정', Icons.calendar_today, null),
          _adminButton(context, '채팅방', Icons.chat, null),
          _adminButton(context, '매출 통계', Icons.bar_chart, null),
          _adminButton(context, '원료 단가 관리', Icons.price_change, const MaterialPriceManagementScreen()),
          _adminButton(context, '설정', Icons.settings, null),
        ],
      ),
    );
  }

  Widget _adminButton(BuildContext context, String label, IconData icon, Widget? nextScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: nextScreen != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen)) : null,
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Row(children: [Icon(icon, size: 28), const SizedBox(width: 16), Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
      ),
    );
  }
}

// ==================== 직원 관리 화면 (목록 + 클릭 수정 + 추가 + 삭제) ====================
class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});
  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loading = true);
    final data = await Supabase.instance.client.from('users').select().order('id');
    setState(() {
      _employees = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  void _showForm({Map<String, dynamic>? employee}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeFormScreen(employee: employee))).then((_) => _loadEmployees());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('직원 관리')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                final e = _employees[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('ID: ${e['id']}'),
                    subtitle: Text('역할: ${e['role']} | 비밀번호: ${e['password']}'),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                      await Supabase.instance.client.from('users').delete().eq('id', e['id']);
                      _loadEmployees();
                    }),
                    onTap: () => _showForm(employee: e),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.add)),
    );
  }
}

// ==================== 고객 관리 화면 (목록 + 클릭 수정 + 추가 + 삭제) ====================
class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});
  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  List<Map<String, dynamic>> _customers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _loading = true);
    final data = await Supabase.instance.client.from('users').select().eq('role', 1).order('id');
    setState(() {
      _customers = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  void _showForm({Map<String, dynamic>? customer}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeFormScreen(employee: customer))).then((_) => _loadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('고객 관리')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? const Center(child: Text('등록된 고객이 없습니다'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final c = _customers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('ID: ${c['id']}'),
                        subtitle: Text('역할: 고객 | 비밀번호: ${c['password']}'),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                          await Supabase.instance.client.from('users').delete().eq('id', c['id']);
                          _loadCustomers();
                        }),
                        onTap: () => _showForm(customer: c),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.add)),
    );
  }
}

// ==================== 직원/고객 수정 화면 ====================
class EmployeeFormScreen extends StatefulWidget {
  final Map<String, dynamic>? employee;
  const EmployeeFormScreen({super.key, this.employee});
  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  late TextEditingController _passwordController;
  late int _role;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.employee?['password'] ?? '');
    _role = widget.employee?['role'] ?? 1;
  }

  void _save() async {
    try {
      final data = {'password': _passwordController.text, 'role': _role};
      if (widget.employee != null) {
        await Supabase.instance.client.from('users').update(data).eq('id', widget.employee!['id']);
      } else {
        await Supabase.instance.client.from('users').insert(data);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장 성공!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('정보 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('ID: ${widget.employee?['id'] ?? '신규'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
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
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: '비밀번호'), obscureText: true),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('저장하기')),
          ],
        ),
      ),
    );
  }
}

// ==================== 제품 관리 화면 ====================
class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});
  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final data = await Supabase.instance.client.from('products').select().order('created_at', ascending: false);
    setState(() {
      _products = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  void _showForm({Map<String, dynamic>? product}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductFormScreen(product: product))).then((_) => _loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('제품 관리')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('등록된 제품이 없습니다', style: TextStyle(fontSize: 18)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final p = _products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('가격: ${p['price']}원 | 총 원가: ${p['total_cost'] ?? 0}원'),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                          await Supabase.instance.client.from('products').delete().eq('id', p['id']);
                          _loadProducts();
                        }),
                        onTap: () => _showForm(product: p),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.add)),
    );
  }
}

// ==================== 제품 추가/수정 화면 ====================
class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  const ProductFormScreen({super.key, this.product});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();

  List<Map<String, dynamic>> _costs = [];
  List<TextEditingController> _unitPriceControllers = [];

  final List<String> _materials = ['밀가루', '설탕', '버터', '계란', '초코', '우유', '소금'];
  final List<String> _units = ['개', '그램'];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _priceController.text = widget.product!['price']?.toString() ?? '';
      _descriptionController.text = widget.product!['description'] ?? '';
      _stockController.text = widget.product!['stock']?.toString() ?? '';
      _costs = List<Map<String, dynamic>>.from(widget.product!['costs'] ?? []);
    }
    _unitPriceControllers = _costs.map((item) => TextEditingController(text: (item['unitPrice'] ?? 0).toString())).toList();
  }

  @override
  void dispose() {
    for (var c in _unitPriceControllers) c.dispose();
    super.dispose();
  }

  void _addCostItem() {
    setState(() {
      _costs.add({'category': '원료', 'material': _materials[0], 'unit': '그램', 'quantity': 0.0, 'unitPrice': 0.0});
      _unitPriceControllers.add(TextEditingController(text: '0'));
    });
  }

  void _removeCostItem(int index) {
    setState(() {
      _unitPriceControllers[index].dispose();
      _unitPriceControllers.removeAt(index);
      _costs.removeAt(index);
    });
  }

  double get _totalCost => _costs.fold(0.0, (sum, item) => sum + (item['quantity'] * item['unitPrice']));

  void _loadBasePrice(int index, String material, String unit) async {
    final res = await Supabase.instance.client.from('material_prices').select('unit_price').eq('name', material).eq('unit', unit).maybeSingle();
    if (res != null && mounted) {
      setState(() {
        _costs[index]['unitPrice'] = (res['unit_price'] ?? 0).toDouble();
        _unitPriceControllers[index].text = _costs[index]['unitPrice'].toString();
      });
    }
  }

  void _save() async {
    try {
      final data = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'description': _descriptionController.text,
        'stock': int.parse(_stockController.text),
        'costs': _costs,
        'total_cost': _totalCost,
      };
      if (widget.product != null) {
        await Supabase.instance.client.from('products').update(data).eq('id', widget.product!['id']);
      } else {
        await Supabase.instance.client.from('products').insert(data);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장 성공!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? '제품 추가' : '제품 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '제품 이름')),
            const SizedBox(height: 12),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: '판매 가격'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: '설명'), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: _stockController, decoration: const InputDecoration(labelText: '재고 수량'), keyboardType: TextInputType.number),

            const SizedBox(height: 30),
            const Text('원가 항목', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _costs.length,
              itemBuilder: (context, index) {
                final item = _costs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: DropdownButtonFormField<String>(value: item['category'], items: const [DropdownMenuItem(value: '원료', child: Text('원료')), DropdownMenuItem(value: '포장', child: Text('포장'))], onChanged: (v) => setState(() => item['category'] = v!), decoration: const InputDecoration(labelText: '대구분'))),
                            const SizedBox(width: 12),
                            Expanded(child: DropdownButtonFormField<String>(value: item['unit'], items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(), onChanged: (v) => setState(() => item['unit'] = v!), decoration: const InputDecoration(labelText: '단위'))),
                          ],
                        ),
                        if (item['category'] == '원료')
                          DropdownButtonFormField<String>(
                            value: item['material'],
                            items: _materials.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => item['material'] = val);
                                _loadBasePrice(index, val, item['unit']);
                              }
                            },
                            decoration: const InputDecoration(labelText: '원료 선택'),
                          ),
                        Row(
                          children: [
                            Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '수량'), onChanged: (v) => setState(() => item['quantity'] = double.tryParse(v) ?? 0.0))),
                            const SizedBox(width: 12),
                            Expanded(child: TextField(controller: _unitPriceControllers[index], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '단가 (자동 불러옴)'), onChanged: (v) => setState(() => item['unitPrice'] = double.tryParse(v) ?? 0.0))),
                          ],
                        ),
                        Align(alignment: Alignment.centerRight, child: Text('소계: ${(item['quantity'] * item['unitPrice']).toStringAsFixed(0)}원', style: const TextStyle(fontWeight: FontWeight.bold))),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeCostItem(index)),
                      ],
                    ),
                  ),
                );
              },
            ),

            ElevatedButton(onPressed: _addCostItem, child: const Text('원가 항목 추가')),
            const SizedBox(height: 20),
            Text('총 원가: ${_totalCost.toStringAsFixed(0)}원', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('저장하기')),
          ],
        ),
      ),
    );
  }
}

// ==================== 원료 단가 관리 화면 ====================
class MaterialPriceManagementScreen extends StatefulWidget {
  const MaterialPriceManagementScreen({super.key});
  @override
  State<MaterialPriceManagementScreen> createState() => _MaterialPriceManagementScreenState();
}

class _MaterialPriceManagementScreenState extends State<MaterialPriceManagementScreen> {
  List<Map<String, dynamic>> _prices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    setState(() => _loading = true);
    final data = await Supabase.instance.client.from('material_prices').select().order('name');
    setState(() {
      _prices = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  }

  void _showForm({Map<String, dynamic>? item}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MaterialPriceFormScreen(item: item))).then((_) => _loadPrices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('원료 단가 관리')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _prices.isEmpty
              ? const Center(child: Text('등록된 원료가 없습니다'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _prices.length,
                  itemBuilder: (context, index) {
                    final p = _prices[index];
                    return Card(
                      child: ListTile(
                        title: Text(p['name']),
                        subtitle: Text('${p['unit']}당 ${p['unit_price']}원'),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                          await Supabase.instance.client.from('material_prices').delete().eq('id', p['id']);
                          _loadPrices();
                        }),
                        onTap: () => _showForm(item: p),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.add)),
    );
  }
}

// ==================== 원료 단가 추가/수정 화면 ====================
class MaterialPriceFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const MaterialPriceFormScreen({super.key, this.item});
  @override
  State<MaterialPriceFormScreen> createState() => _MaterialPriceFormScreenState();
}

class _MaterialPriceFormScreenState extends State<MaterialPriceFormScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _unit = '그램';

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!['name'] ?? '';
      _priceController.text = widget.item!['unit_price']?.toString() ?? '';
      _unit = widget.item!['unit'] ?? '그램';
    }
  }

  void _save() async {
    try {
      final data = {'name': _nameController.text, 'unit': _unit, 'unit_price': double.parse(_priceController.text)};
      if (widget.item != null) {
        await Supabase.instance.client.from('material_prices').update(data).eq('id', widget.item!['id']);
      } else {
        await Supabase.instance.client.from('material_prices').insert(data);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장 성공!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? '원료 단가 추가' : '원료 단가 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '원료 이름')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _unit,
              items: const [DropdownMenuItem(value: '그램', child: Text('그램')), DropdownMenuItem(value: '개', child: Text('개'))],
              onChanged: (v) => setState(() => _unit = v!),
              decoration: const InputDecoration(labelText: '단위'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: '단가'), keyboardType: TextInputType.number),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('저장하기')),
          ],
        ),
      ),
    );
  }
}