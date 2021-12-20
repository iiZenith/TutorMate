import 'package:flutter/material.dart';
import '../models/location_models.dart';
import '../services/location_service.dart';
import 'app_dropdown.dart';

class LocationSelection {
  final String province;
  final String district;
  final String area;

  const LocationSelection({
    required this.province,
    required this.district,
    required this.area,
  });
}

class DynamicLocationSelector extends StatefulWidget {
  final LocationSelection? value;
  final ValueChanged<LocationSelection> onChanged;

  const DynamicLocationSelector({
    super.key,
    this.value,
    required this.onChanged,
  });

  @override
  State<DynamicLocationSelector> createState() => _DynamicLocationSelectorState();
}

class _DynamicLocationSelectorState extends State<DynamicLocationSelector> {
  final LocationService _locationService = LocationService();
  List<ProvinceDoc> _provinces = [];
  bool _isLoading = true;
  String? _error;

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedArea;

  @override
  void initState() {
    super.initState();
    _selectedProvince = widget.value?.province.isNotEmpty == true ? widget.value?.province : null;
    _selectedDistrict = widget.value?.district.isNotEmpty == true ? widget.value?.district : null;
    _selectedArea = widget.value?.area.isNotEmpty == true ? widget.value?.area : null;
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final data = await _locationService.getLocationsTree();
      if (mounted) {
        setState(() {
          _provinces = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _triggerOnChange() {
    widget.onChanged(LocationSelection(
      province: _selectedProvince ?? '',
      district: _selectedDistrict ?? '',
      area: _selectedArea ?? '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            'Failed to load locations: $_error', 
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    if (_provinces.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('No locations available in database.')),
      );
    }

    final provinceNames = _provinces.map((p) => p.name).toList();
    
    List<String> districtNames = [];
    if (_selectedProvince != null) {
      final province = _provinces.firstWhere((p) => p.name == _selectedProvince, orElse: () => const ProvinceDoc(name: '', districts: {}));
      districtNames = province.districts.keys.toList()..sort();
    }

    List<String> areaNames = [];
    if (_selectedProvince != null && _selectedDistrict != null) {
      final province = _provinces.firstWhere((p) => p.name == _selectedProvince, orElse: () => const ProvinceDoc(name: '', districts: {}));
      areaNames = province.districts[_selectedDistrict] ?? [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDropdown(
          label: 'Province',
          hint: 'Select Province',
          value: _selectedProvince,
          items: provinceNames,
          onChanged: (v) {
            setState(() {
              _selectedProvince = v;
              _selectedDistrict = null;
              _selectedArea = null;
            });
            _triggerOnChange();
          },
        ),
        const SizedBox(height: 16),
        AppDropdown(
          label: 'District',
          hint: 'Select District',
          value: _selectedDistrict,
          items: districtNames,
          onChanged: (v) {
            setState(() {
              _selectedDistrict = v;
              _selectedArea = null;
            });
            _triggerOnChange();
          },
        ),
        const SizedBox(height: 16),
        AppDropdown(
          label: 'Area/Location',
          hint: 'Select Area',
          value: _selectedArea,
          items: areaNames,
          onChanged: (v) {
            setState(() {
              _selectedArea = v;
            });
            _triggerOnChange();
          },
        ),
      ],
    );
  }
}
