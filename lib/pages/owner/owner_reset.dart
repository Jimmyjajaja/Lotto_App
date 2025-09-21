import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_application/config/api_endpoints.dart';
import 'package:lotto_application/pages/login.dart';
import 'package:lotto_application/services/user_session.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool _isLoading = false;
  // int _selectedIndex = 1;
  // String url = '';
  bool _isResetting = false; // ← ย้ายออกมาไว้ตรงนี้
  final TextEditingController _adminCodeCtl = // ← ย้ายออกมาไว้ตรงนี้
      TextEditingController();

  @override
  void dispose() {
    _adminCodeCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), // ไอคอนลูกศรย้อนกลับ
          onPressed: () {
            Navigator.pop(context); // กลับไปยังหน้าจอก่อนหน้า
          },
        ),
        backgroundColor: const Color(0xFFE1F5FE),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 30, 0, 0),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.asset('assets/images/proflie1.png'),
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 10, 50),
                  child: Text(
                    'Admin',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 35,
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 10, 0),
                  child: Text(
                    'ลบข้อมูลระบบทั้งหมด',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 10, 0),
                  child: Text(
                    'จำลองระบบใหม่ เหลือแค่เจ้าของ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: SingleChildScrollView(
                    child: FilledButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (ctx, setStateDialog) {
                                return AlertDialog(
                                  title: const Text(
                                    "ยืนยันการลบข้อมูลทั้งหมด",
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "พิมพ์รหัสแอดมินเพื่อยืนยันการรีเซ็ตระบบ",
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _adminCodeCtl,
                                        obscureText: true,
                                        textInputAction: TextInputAction.done,
                                        decoration: const InputDecoration(
                                          labelText: 'รหัสแอดมิน',
                                          hintText: 'ใส่รหัสแอดมิน',
                                          prefixIcon: Icon(Icons.lock_outline),
                                          border: OutlineInputBorder(),
                                        ),
                                        onSubmitted: (_) async {
                                          if (_isResetting) return;
                                          final code = _adminCodeCtl.text
                                              .trim();
                                          if (code.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'กรุณากรอกรหัสแอดมิน',
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          setStateDialog(
                                            () => _isResetting = true,
                                          );
                                          final ok = await resetSystem(code);
                                          if (ctx.mounted) {
                                            setStateDialog(
                                              () => _isResetting = false,
                                            );
                                            if (ok) Navigator.of(ctx).pop();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  actionsPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: _isResetting
                                          ? null
                                          : () => Navigator.of(ctx).pop(),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color(
                                          0xFFD80000,
                                        ),
                                        minimumSize: const Size(100, 40),
                                      ),
                                      child: const Text("ยกเลิก"),
                                    ),
                                    TextButton(
                                      onPressed: _isResetting
                                          ? null
                                          : () async {
                                              final code = _adminCodeCtl.text
                                                  .trim();
                                              if (code.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'กรุณากรอกรหัสแอดมิน',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              setStateDialog(
                                                () => _isResetting = true,
                                              );
                                              final ok = await resetSystem(
                                                code,
                                              );
                                              if (ctx.mounted) {
                                                setStateDialog(
                                                  () => _isResetting = false,
                                                );
                                                if (ok)
                                                  Navigator.of(
                                                    ctx,
                                                  ).pop(); // ปิด dialog เมื่อสำเร็จ
                                              }
                                              if (ok) {
                                                _adminCodeCtl.clear();
                                                // (ออปชัน) logout/push ไปหน้า Login ถ้าต้องการ
                                              }
                                            },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        backgroundColor: const Color(
                                          0xFFFFEB85,
                                        ),
                                        minimumSize: const Size(100, 40),
                                      ),
                                      child: _isResetting
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text("ยืนยันการลบ"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFD80000),
                        minimumSize: const Size(150, 40),
                      ),
                      child: const Text('Reset All'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show a loading indicator if the process is running
                _isLoading
                    ? CircularProgressIndicator()
                    : FilledButton(
                        onPressed: generateTickets,
                        style: FilledButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 216, 122, 0),
                          minimumSize: const Size(150, 40),
                        ),
                        child: const Text('เพิ่มลอตโต'),
                      ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 10, 0),
                  child: FilledButton(
                    onPressed: () {
                      // Clear the session on logout
                      UserSession().currentUser = null;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false, // Removes all previous routes
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 4),
                      minimumSize: const Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> resetSystem(String adminCode) async {
    // อนุญาตเฉพาะผู้ใช้ role = admin
    final user = UserSession().currentUser;
    if (user == null || (user.role?.toLowerCase() != 'admin')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('คุณไม่มีสิทธิ์ทำรายการนี้')),
        );
      }
      return false;
    }

    if (adminCode.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('กรุณากรอกรหัสยืนยัน')));
      }
      return false;
    }

    try {
      final res = await http.post(
        Uri.parse(ApiEndpoints.resetSystem), // ให้ใช้ชื่อเดียวกันทุกที่
        headers: {'Content-Type': 'application/json'},
        // ถ้า backend ใช้ตรวจสอบรหัส ให้ส่งไปด้วย
        body: jsonEncode({
          'adminUserId': user.userId,
          'adminCode': adminCode,
          'confirm': true,
        }),
      );

      final msg = _extractMessage(res.body) ?? 'รีเซ็ตระบบสำเร็จ';
      if (!mounted) return res.statusCode >= 200 && res.statusCode < 300;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ล้มเหลว: ${res.statusCode} - $msg')),
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้: $e')),
        );
      }
      return false;
    }
  }

  // ถ้ายังไม่มี helper นี้ในไฟล์ ให้ใส่เพิ่ม (สั้น ๆ)
  String? _extractMessage(String body) {
    try {
      final j = jsonDecode(body);
      return (j['message'] ?? j['error'] ?? j['detail'] ?? j['status'])
          ?.toString();
    } catch (_) {
      return null;
    }
  }

  void generateTickets() async {
    // 1. Get the adminId directly from the UserSession singleton.
    // The '?.userId' is a null-aware operator. It will be null if currentUser is null.
    final adminId = UserSession().currentUser?.userId;

    // 2. Add a check to ensure the adminId was found.
    // This is important in case the user session is somehow cleared.
    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not find user information. Please log in again.',
          ),
        ),
      );
      return; // Stop the function if no adminId is found.
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.generateTickets),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // 3. Use the adminId retrieved from the session.
          'adminUserId': adminId,
          'count': 100,
          'price': 80.00,
        }),
      );

      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      final String message =
          responseData['message'] ?? 'An unknown error occurred.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      log('Generate tickets error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to the server.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
