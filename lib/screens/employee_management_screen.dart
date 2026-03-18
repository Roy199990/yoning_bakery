import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'employee_form_screen.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EmployeeFormScreen(employee: employee)),
    ).then((_) => _loadEmployees());
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
                    title: Text(e['name'] ?? 'ID: ${e['id']}'),
                    subtitle: Text(
                      '출생년월일: ${e['birth_date'] ?? ''}\n'
                      '휴대폰: ${e['phone'] ?? ''}\n'
                      '이메일: ${e['email'] ?? ''}\n'
                      '메모: ${e['memo'] ?? ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await Supabase.instance.client.from('users').delete().eq('id', e['id']);
                        _loadEmployees();
                      },
                    ),
                    onTap: () => _showForm(employee: e),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}