import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/import_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/layout/responsive_layout.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';

class ImportMachineScreen extends StatefulWidget {
  const ImportMachineScreen({super.key});

  @override
  State<ImportMachineScreen> createState() => _ImportMachineScreenState();
}

class _ImportMachineScreenState extends State<ImportMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maPhieuController = TextEditingController();
  final _soLuongController = TextEditingController(text: '1');
  final _nhaCungCapController = TextEditingController();
  final _ghiChuController = TextEditingController(); // Ghi chú phiếu nhập

  // --- CÁC BIẾN CHO CẤU HÌNH MÁY TÍNH ---
  String? _cpuBrand = 'Intel';
  final _cpuDetailController = TextEditingController();

  String? _ramCapacity = '8GB';
  final _ramBrandController = TextEditingController();

  String? _gpuType = 'Card Onboard';
  final _gpuDetailController = TextEditingController();

  // Lưu trữ (Khớp với logic cột hdd, ssd trong DB)
  String? _storageType = 'SSD';
  String? _storageCapacity = '512GB';

  String? _storageType2 = 'Không';
  String? _storageCapacity2 = '1TB';

  // Thiết bị ngoại vi & linh kiện
  final _mainboardController = TextEditingController();
  final _monitorController = TextEditingController();
  final _keyboardController = TextEditingController();
  final _mouseController = TextEditingController();

  static const List<String> _dsCpuBrand = ['Intel', 'AMD', 'Apple M'];
  static const List<String> _dsRam = ['4GB', '8GB', '16GB', '32GB', '64GB'];
  static const List<String> _dsGpuType = ['Card Onboard', 'Card Rời'];
  static const List<String> _dsStorageType = ['SSD', 'HDD'];
  static const List<String> _dsStorageType2 = ['Không', 'SSD', 'HDD']; 
  static const List<String> _dsStorageCap = ['128GB', '256GB', '512GB', '1TB', '2TB'];

  DateTime _selectedDate = DateTime.now();
  int? _selectedPhongId; // ma_phong trong DB

  final List<Map<String, dynamic>> _phieuNhaps = [];

  @override
  void initState() {
    super.initState();
    _maPhieuController.text =
        'PN-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

    // GỌI API LẤY DANH SÁCH PHÒNG VÀ TỰ ĐỘNG CHỌN "KHO"
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<ImportViewModel>();
      await vm.fetchRooms();

      if (vm.rooms.isNotEmpty && mounted) {
        final khoRoom = vm.rooms.firstWhere(
          (r) =>
              r['ma_phong'].toString().toUpperCase().contains('KHO') ||
              r['ten_phong'].toString().toUpperCase().contains('KHO'),
          orElse: () => vm.rooms.first,
        );

        setState(() {
          _selectedPhongId = khoRoom['id'];
        });
      }
    });
  }

  @override
  void dispose() {
    _maPhieuController.dispose();
    _soLuongController.dispose();
    _nhaCungCapController.dispose();
    _ghiChuController.dispose();
    _cpuDetailController.dispose();
    _ramBrandController.dispose();
    _gpuDetailController.dispose();
    _mainboardController.dispose();
    _monitorController.dispose();
    _keyboardController.dispose();
    _mouseController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPhongId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn phòng máy!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // --- LOGIC PHÂN LOẠI HDD VÀ SSD ---
      String? hddValue;
      String? ssdValue;

      void assignStorage(String type, String capacity) {
        if (type == 'HDD') hddValue = (hddValue == null) ? capacity : '$hddValue + $capacity';
        if (type == 'SSD') ssdValue = (ssdValue == null) ? capacity : '$ssdValue + $capacity';
      }

      assignStorage(_storageType!, _storageCapacity!);
      if (_storageType2 != 'Không') {
        assignStorage(_storageType2!, _storageCapacity2!);
      }

      // --- CHUẨN BỊ PAYLOAD ---
      // Map các key khớp 100% với tên cột trong database ScriptDB_DATN.txt
      final requestData = {
        // Data bảng phieu_nhap_may
        "ma_phieu_nhap": _maPhieuController.text,
        "ngay_nhap": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "so_luong": int.tryParse(_soLuongController.text) ?? 1,
        "nha_cung_cap": _nhaCungCapController.text,
        "ghi_chu_phieu": _ghiChuController.text, // Tách biệt ghi chú phiếu

        // Data để backend sinh ra mảng máy tính (bảng may_tinh)
        "ma_phong": _selectedPhongId,
        "bo_xu_ly": '$_cpuBrand ${_cpuDetailController.text.trim()}'.trim(),
        "ram": '${_ramBrandController.text.trim()} $_ramCapacity'.trim(),
        "card_do_hoa": _gpuType == 'Card Rời' ? _gpuDetailController.text.trim() : 'Onboard',
        "bo_mach_chu": _mainboardController.text.trim(),
        "man_hinh": _monitorController.text.trim(),
        "ban_phim": _keyboardController.text.trim(),
        "chuot": _mouseController.text.trim(),
        "hdd": hddValue ?? '',
        "ssd": ssdValue ?? '',
      };

      final vm = Provider.of<ImportViewModel>(context, listen: false);
      final isSuccess = await vm.createImportReceipt(requestData);

      if (isSuccess) {
        // Ghép chuỗi để hiển thị ở bảng giao diện (không ảnh hưởng Backend)
        String strStorage = '$_storageType $_storageCapacity';
        if (_storageType2 != 'Không') {
          strStorage += ' + $_storageType2 $_storageCapacity2';
        }

        setState(() {
          _phieuNhaps.insert(0, {
            'maPhieu': requestData['ma_phieu_nhap'],
            'ngayNhap': requestData['ngay_nhap'],
            'soLuong': requestData['so_luong'],
            'ghiChu': 'CPU: ${requestData['bo_xu_ly']} | RAM: ${requestData['ram']} | VGA: ${requestData['card_do_hoa']} | Lưu trữ: $strStorage',
          });

          // Reset Form
          _maPhieuController.text = 'PN-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
          _soLuongController.text = '1';
          _nhaCungCapController.clear();
          _ghiChuController.clear();
          _cpuDetailController.clear();
          _ramBrandController.clear();
          _gpuDetailController.clear();
          _mainboardController.clear();
          _monitorController.clear();
          _keyboardController.clear();
          _mouseController.clear();
          _gpuType = 'Card Onboard';
          _storageType = 'SSD';
          _storageCapacity = '512GB';
          _storageType2 = 'Không';
          _storageCapacity2 = '1TB';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo phiếu nhập và sinh mã máy thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${vm.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildResponsiveRow(Widget child1, Widget child2) {
    if (ResponsiveLayout.isMobile(context)) {
      return Column(
        children: [
          child1,
          const SizedBox(height: 12),
          child2,
          const SizedBox(height: 12),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child1),
            const SizedBox(width: 24),
            Expanded(child: child2),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ImportViewModel>(context);

    return AdminLayout(
      title: 'Phiếu nhập máy',
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tạo và theo dõi phiếu nhập máy vào phòng máy',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: _buildFormCard(vm)),
                          const SizedBox(width: 20),
                          Expanded(flex: 6, child: _buildListCard()),
                        ],
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildFormCard(vm),
                          const SizedBox(height: 20),
                          _buildListCard(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (vm.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildFormCard(ImportViewModel vm) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tạo phiếu nhập',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin phiếu nhập',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ResponsiveLayout.isMobile(context)
                          ? Column(
                              children: [
                                _buildTextField('Mã phiếu nhập', _maPhieuController, enabled: false),
                                const SizedBox(height: 16),
                                _buildDatePickerField(),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: _buildTextField('Mã phiếu nhập', _maPhieuController, enabled: false)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDatePickerField()),
                              ],
                            ),
                      const SizedBox(height: 16),
                      ResponsiveLayout.isMobile(context)
                          ? Column(
                              children: [
                                _buildTextField('Số lượng máy mới', _soLuongController, isNumber: true),
                                const SizedBox(height: 16),
                                _buildRoomDropdown(vm),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: _buildTextField('Số lượng máy mới', _soLuongController, isNumber: true)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildRoomDropdown(vm)),
                              ],
                            ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Nhà cung cấp',
                        _nhaCungCapController,
                        hint: 'VD: Công ty TNHH ABC',
                        isRequired: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildConfigSection(),
                const SizedBox(height: 16),
                _buildTextField(
                  'Ghi chú phiếu nhập (Tuỳ chọn)',
                  _ghiChuController,
                  maxLines: 2,
                  isRequired: false,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 20),
                    label: const Text(
                      'Tạo phiếu nhập',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: _submitForm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomDropdown(ImportViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phòng máy (Mặc định: Kho)',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          isExpanded: true,
          initialValue: _selectedPhongId,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: vm.rooms
              .map((p) => DropdownMenuItem<int>(
                    value: p['id'] as int,
                    child: Text('${p['ma_phong']} - ${p['ten_phong']}', overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedPhongId = v),
          hint: Text(
            vm.isLoading
                ? 'Đang tải phòng...'
                : (vm.rooms.isEmpty ? '⚠️ DB chưa có phòng!' : 'Chọn phòng máy'),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigSection() {
    Widget wCpu = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ConfigDropdownWidget(
            label: 'Hãng CPU',
            value: _cpuBrand,
            items: _dsCpuBrand,
            onChanged: (v) => setState(() => _cpuBrand = v),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: _buildTextField('Thế hệ / Mã CPU', _cpuDetailController, hint: 'VD: Core i5 12400F', isRequired: false),
        ),
      ],
    );
    Widget wRam = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildTextField('Hãng RAM', _ramBrandController, hint: 'VD: Kingston', isRequired: false),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ConfigDropdownWidget(
            label: 'Dung lượng',
            value: _ramCapacity,
            items: _dsRam,
            onChanged: (v) => setState(() => _ramCapacity = v),
          ),
        ),
      ],
    );
    Widget wGpu = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: _gpuType == 'Card Rời' ? 2 : 5,
          child: ConfigDropdownWidget(
            label: 'Card đồ họa',
            value: _gpuType,
            items: _dsGpuType,
            onChanged: (v) => setState(() => _gpuType = v),
          ),
        ),
        if (_gpuType == 'Card Rời') ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: _buildTextField('Tên Card Rời', _gpuDetailController, hint: 'VD: RTX 3060', isRequired: false),
          ),
        ],
      ],
    );

    Widget wMainboard = _buildTextField('Bo mạch chủ', _mainboardController, hint: 'VD: H610M', isRequired: false);
    Widget wMonitor = _buildTextField('Màn hình', _monitorController, hint: 'VD: Dell 21.5 inch', isRequired: false);
    Widget wKeyboard = _buildTextField('Bàn phím', _keyboardController, hint: 'VD: Logitech K120', isRequired: false);
    Widget wMouse = _buildTextField('Chuột', _mouseController, hint: 'VD: Logitech B100', isRequired: false);

    Widget wStorage = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ConfigDropdownWidget(
            label: 'Ổ cứng',
            value: _storageType,
            items: _dsStorageType,
            onChanged: (v) => setState(() => _storageType = v),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: ConfigDropdownWidget(
            label: 'Dung lượng',
            value: _storageCapacity,
            items: _dsStorageCap,
            onChanged: (v) => setState(() => _storageCapacity = v),
          ),
        ),
      ],
    );

    Widget wStorage2 = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ConfigDropdownWidget(
            label: 'Ổ cứng 2',
            value: _storageType2,
            items: _dsStorageType2,
            onChanged: (v) => setState(() => _storageType2 = v),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: _storageType2 == 'Không'
              ? const SizedBox()
              : ConfigDropdownWidget(
                  label: 'Dung lượng',
                  value: _storageCapacity2,
                  items: _dsStorageCap,
                  onChanged: (v) => setState(() => _storageCapacity2 = v),
                ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.02),
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.memory, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Cấu hình chung', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          // Sắp xếp lại Row hợp lý sau khi bỏ OS
          _buildResponsiveRow(wCpu, wRam),
          _buildResponsiveRow(wGpu, wMainboard),
          _buildResponsiveRow(wStorage, wStorage2),  // Dòng 3: Gom 2 ổ cứng 
          _buildResponsiveRow(wMonitor, wKeyboard),  // Dòng 4: Màn hình & Phím
          _buildResponsiveRow(wMouse, const SizedBox()), // Dòng 5: Chuột 
        ],
      ),
    );
  }

  Widget _buildListCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Danh sách phiếu nhập',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                    dataRowMaxHeight: 60,
                    columns: const [
                      DataColumn(label: Text('MÃ PHIẾU', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                      DataColumn(label: Text('NGÀY NHẬP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                      DataColumn(label: Text('SỐ LƯỢNG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                      DataColumn(label: Text('CẤU HÌNH & GHI CHÚ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                    ],
                    rows: _phieuNhaps
                        .map((p) => DataRow(cells: [
                              DataCell(Text(p['maPhieu'] ?? '')),
                              DataCell(Text(p['ngayNhap'] ?? '')),
                              DataCell(Text('${p['soLuong'] ?? 0}')),
                              DataCell(
                                SizedBox(
                                  width: 300,
                                  child: Text(p['ghiChu'] ?? '', overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ]))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool enabled = true,
    String? hint,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade200,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          validator: (value) => (isRequired && value!.isEmpty) ? 'Không được trống' : null,
        ),
      ],
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ngày nhập', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), overflow: TextOverflow.ellipsis)),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ConfigDropdownWidget extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  const ConfigDropdownWidget({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = (value != null && items.contains(value)) ? value : (items.isNotEmpty ? items.first : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: safeValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: items
              .map((String i) => DropdownMenuItem<String>(
                    value: i,
                    child: Text(i, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}