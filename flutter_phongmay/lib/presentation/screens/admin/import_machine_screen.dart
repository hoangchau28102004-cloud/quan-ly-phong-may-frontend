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
  final _ghiChuController = TextEditingController();

  // --- CÁC BIẾN CHO CẤU HÌNH ---
  String? _cpuBrand = 'Intel'; 
  final _cpuDetailController = TextEditingController(); 

  String? _ramCapacity = '8GB';
  final _ramBrandController = TextEditingController(); 

  String? _gpuType = 'Card Onboard';
  final _gpuDetailController = TextEditingController();

  String? _storageType = 'SSD'; 
  String? _storageCapacity = '512GB';
  String? _osVersion = 'Windows 11';

  final _mainboardController = TextEditingController();
  final _monitorController = TextEditingController();
  final _keyboardController = TextEditingController();
  final _mouseController = TextEditingController();

  static const List<String> _dsCpuBrand = ['Intel', 'AMD', 'Apple M'];
  static const List<String> _dsRam = ['4GB', '8GB', '16GB', '32GB', '64GB'];
  static const List<String> _dsGpuType = ['Card Onboard', 'Card Rời'];
  static const List<String> _dsStorageType = ['SSD', 'HDD'];
  static const List<String> _dsStorageCap = ['128GB', '256GB', '512GB', '1TB', '2TB'];
  static const List<String> _dsOS = ['Không có', 'Windows 10', 'Windows 11', 'Ubuntu', 'macOS'];

  DateTime _selectedDate = DateTime.now();
  int? _selectedPhongId; // Lưu ID thật của phòng

  final List<Map<String, dynamic>> _phieuNhaps = [];

  @override
  void initState() {
    super.initState();
    _maPhieuController.text = 'PN-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    
    // GỌI API LẤY DANH SÁCH PHÒNG VÀ TỰ ĐỘNG CHỌN "KHO"
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<ImportViewModel>();
      await vm.fetchRooms();
      
      if (vm.rooms.isNotEmpty && mounted) {
        // Tìm phòng máy nào có chữ 'KHO'
        final khoRoom = vm.rooms.firstWhere(
          (r) => r['ma_phong'].toString().toUpperCase().contains('KHO') || 
                 r['ten_phong'].toString().toUpperCase().contains('KHO'), 
          orElse: () => vm.rooms.first // Nếu không có Kho thì gán phòng đầu tiên
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn phòng máy!'), backgroundColor: Colors.red));
        return;
      }

      final requestData = {
        "ma_phieu_nhap": _maPhieuController.text,
        "ma_phong": _selectedPhongId,
        "ngay_nhap": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "tong_so_luong": int.tryParse(_soLuongController.text) ?? 1,
        "nha_cung_cap": _nhaCungCapController.text,
        "ghi_chu_phieu": _ghiChuController.text,
        "cpu_brand": _cpuBrand,
        "cpu_detail": _cpuDetailController.text.trim(),
        "ram_brand": _ramBrandController.text.trim(),
        "ram_capacity": _ramCapacity,
        "gpu_type": _gpuType,
        "gpu_detail": _gpuDetailController.text.trim(),
        "mainboard": _mainboardController.text.trim(),
        "monitor": _monitorController.text.trim(),
        "keyboard": _keyboardController.text.trim(),
        "mouse": _mouseController.text.trim(),
        "storage_type": _storageType,
        "storage_capacity": _storageCapacity,
        "os": _osVersion
      };

      final vm = Provider.of<ImportViewModel>(context, listen: false);
      final isSuccess = await vm.createImportReceipt(requestData);

      if (isSuccess) {
        final strCPU = '$_cpuBrand ${_cpuDetailController.text.trim()}'.trim();
        final strRAM = '${_ramBrandController.text.trim()} $_ramCapacity'.trim();
        final strGPU = _gpuType == 'Card Rời' ? _gpuDetailController.text.trim() : 'Onboard';
        final strStorage = '$_storageType $_storageCapacity';

        setState(() {
          _phieuNhaps.insert(0, {
            'maPhieu': _maPhieuController.text,
            'ngayNhap': DateFormat('yyyy-MM-dd').format(_selectedDate),
            'soLuong': requestData['tong_so_luong'],
            'ghiChu': 'CPU: $strCPU | RAM: $strRAM | VGA: $strGPU | Lưu trữ: $strStorage', 
          });
          
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
          
          // Giữ nguyên _selectedPhongId để tiếp tục nhập vào Kho nếu muốn
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo phiếu nhập và sinh mã máy thành công!'), backgroundColor: Colors.green));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${vm.errorMessage}'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Widget _buildResponsiveRow(Widget child1, Widget child2) {
    if (ResponsiveLayout.isMobile(context)) {
      return Column(children: [child1, const SizedBox(height: 12), child2, const SizedBox(height: 12)]);
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: child1), const SizedBox(width: 24), Expanded(child: child2)]),
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
              const Text('Tạo và theo dõi phiếu nhập máy vào phòng máy', style: TextStyle(color: Colors.grey)),
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
            Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildFormCard(ImportViewModel vm) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tạo phiếu nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thông tin phiếu nhập', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      _buildTextField('Nhà cung cấp', _nhaCungCapController, hint: 'VD: Công ty TNHH ABC', isRequired: false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildConfigSection(),
                const SizedBox(height: 16),
                _buildTextField('Ghi chú phiếu nhập (Tuỳ chọn)', _ghiChuController, maxLines: 2, isRequired: false),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 20),
                    label: const Text('Tạo phiếu nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // WIDGET DROPDOWN CHỌN PHÒNG MÁY
  Widget _buildRoomDropdown(ImportViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phòng máy (Mặc định: Kho)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          isExpanded: true,
          value: _selectedPhongId,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          items: vm.rooms.map((p) => DropdownMenuItem<int>(
            value: p['id'] as int, 
            child: Text('${p['ma_phong']} - ${p['ten_phong']}', overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: (v) => setState(() => _selectedPhongId = v),
          hint: Text(vm.isLoading ? 'Đang tải phòng...' : (vm.rooms.isEmpty ? '⚠️ DB chưa có phòng!' : 'Chọn phòng máy')),
        ),
      ],
    );
  }

  Widget _buildConfigSection() {
    Widget wCpu = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: ConfigDropdownWidget(label: 'Hãng CPU', value: _cpuBrand, items: _dsCpuBrand, onChanged: (v) => setState(() => _cpuBrand = v))),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: _buildTextField('Thế hệ / Mã CPU', _cpuDetailController, hint: 'VD: Core i5 12400F', isRequired: false)),
      ],
    );
    Widget wRam = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildTextField('Hãng RAM', _ramBrandController, hint: 'VD: Kingston', isRequired: false)),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: ConfigDropdownWidget(label: 'Dung lượng', value: _ramCapacity, items: _dsRam, onChanged: (v) => setState(() => _ramCapacity = v))),
      ],
    );
    Widget wGpu = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: _gpuType == 'Card Rời' ? 2 : 5,
          child: ConfigDropdownWidget(label: 'Card đồ họa', value: _gpuType, items: _dsGpuType, onChanged: (v) => setState(() => _gpuType = v)),
        ),
        if (_gpuType == 'Card Rời') ...[
          const SizedBox(width: 12),
          Expanded(flex: 3, child: _buildTextField('Tên Card Rời', _gpuDetailController, hint: 'VD: RTX 3060', isRequired: false)),
        ]
      ],
    );

    Widget wMainboard = _buildTextField('Bo mạch chủ', _mainboardController, hint: 'VD: H610M', isRequired: false);
    Widget wMonitor = _buildTextField('Màn hình', _monitorController, hint: 'VD: Dell 21.5 inch', isRequired: false);
    Widget wKeyboard = _buildTextField('Bàn phím', _keyboardController, hint: 'VD: Logitech K120', isRequired: false);
    Widget wMouse = _buildTextField('Chuột', _mouseController, hint: 'VD: Logitech B100', isRequired: false);
    
    Widget wStorage = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: ConfigDropdownWidget(label: 'Ổ cứng', value: _storageType, items: _dsStorageType, onChanged: (v) => setState(() => _storageType = v))),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: ConfigDropdownWidget(label: 'Dung lượng', value: _storageCapacity, items: _dsStorageCap, onChanged: (v) => setState(() => _storageCapacity = v))),
      ],
    );
    Widget wOs = ConfigDropdownWidget(label: 'Hệ điều hành', value: _osVersion, items: _dsOS, onChanged: (v) => setState(() => _osVersion = v));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.02), border: Border.all(color: Colors.blue.shade200), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.memory, size: 20, color: Theme.of(context).primaryColor), const SizedBox(width: 8), const Text('Cấu hình chung', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))]),
          const SizedBox(height: 16),
          _buildResponsiveRow(wCpu, wRam),
          _buildResponsiveRow(wGpu, wMainboard),
          _buildResponsiveRow(wMonitor, wStorage),
          _buildResponsiveRow(wKeyboard, wMouse),
          _buildResponsiveRow(wOs, const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildListCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            const Text('Danh sách phiếu nhập', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Flexible( 
              fit: FlexFit.loose, 
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                    dataRowMaxHeight: 60,
                    columns: const [
                      DataColumn(label: Text('MÃ PHIẾU', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                      DataColumn(label: Text('NGÀY NHẬP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                      DataColumn(label: Text('SỐ LƯỢNG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                      DataColumn(label: Text('CẤU HÌNH & GHI CHÚ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                    ],
                    rows: _phieuNhaps.map((p) => DataRow(
                      cells: [
                        DataCell(Text(p['maPhieu'] ?? '')),
                        DataCell(Text(p['ngayNhap'] ?? '')),
                        DataCell(Text('${p['soLuong'] ?? 0}')),
                        DataCell(SizedBox(width: 300, child: Text(p['ghiChu'] ?? '', overflow: TextOverflow.ellipsis))),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, bool enabled = true, String? hint, int maxLines = 1, bool isRequired = true}) {
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
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
            final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
            if (date != null) setState(() => _selectedDate = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
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

  const ConfigDropdownWidget({super.key, required this.label, required this.value, required this.items, required this.onChanged});

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
          value: safeValue, 
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          items: items.map((String i) => DropdownMenuItem<String>(value: i, child: Text(i, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}