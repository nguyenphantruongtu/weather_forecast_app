import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_strings.dart';
import 'package:maps_launcher/maps_launcher.dart';
// Removed geocoding import as we use robust REST API now
import '../../data/models/location_model.dart' as AppLocation;
import 'google_maps_integration.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  late MapController _mapController;
  List<Marker> _markers = [];
  
  // TrÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¡ng thÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡i lÃƒÆ’Ã¢â‚¬Â Ãƒâ€šÃ‚Â°u lÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºp bÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â£n ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ hiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡n hÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â nh
  String _currentWeatherLayer = 'none'; 
  
  // LÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¥y API Key tÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â« file .env
  final String _openWeatherApiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? ''; 

  // State cho thanh tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¬m kiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿m nÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢i
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasResult = false;
  String _searchedCityName = '';
  double _searchedLatitude = 0.0;
  double _searchedLongitude = 0.0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _updateMarkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateMarkers() {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    
    // KhÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€¦Ã‚Â¸i tÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¡o danh sÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ch marker rÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Âng
    _markers = [];
    
    // ChÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â° kiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢m tra biÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿n lÃƒÆ’Ã¢â‚¬Â Ãƒâ€šÃ‚Â°u trÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â¯ thÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â nh phÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ang ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã¢â‚¬Â Ãƒâ€šÃ‚Â°ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â£c chÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Ân/tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¬m kiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿m
    if (provider.selectedCity != null) {
      // Add DUY NHÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¤T 1 Marker cÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â§a tÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Âa ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³ vÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â o danh sÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ch _markers
      _markers.add(
        Marker(
          point: LatLng(provider.selectedCity!.latitude, provider.selectedCity!.longitude),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }
    // NÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿u selectedCity bÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¹ null, bÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â£n ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ khÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â´ng hiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡n Marker nÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â o
  }

  // XÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â­ lÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â½ TÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¬m kiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿m: Khi submit thanh tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¬m kiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿m
  Future<void> _handleSearch(String text) async {
    if (text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasResult = false;
    });

    try {
      // SÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â­ dÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â¥ng GoogleMapsIntegration ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢ chuyÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢n text thÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â nh tÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Âa ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢
      final googleMapsIntegration = GoogleMapsIntegration();
      final location = await googleMapsIntegration.getLocationFromAddress(text);

      if (!mounted) return;
      
      if (location != null) {
        _searchedLatitude = location.latitude;
        _searchedLongitude = location.longitude;
        _searchedCityName = text;
        
        // XÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³a danh sÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ch marker cÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â©
        _markers.clear();
        
        // TÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¡o 1 Marker mÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºi tÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¡i tÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Âa ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ vÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â«a tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¬m ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã¢â‚¬Â Ãƒâ€šÃ‚Â°ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â£c
        _markers.add(
          Marker(
            point: LatLng(location.latitude, location.longitude),
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
        
        // CÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â±c kÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â³ quan trÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Âng: GÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Âi _mapController.move ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢ camera bÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â£n ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ tÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â± ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ng bay tÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºi thÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â nh phÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³
        _mapController.move(LatLng(location.latitude, location.longitude), 11.0);
        
        // KiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢m tra xem thÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â nh phÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â£ ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã¢â‚¬Â Ãƒâ€šÃ‚Â°ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â£c lÃƒÆ’Ã¢â‚¬Â Ãƒâ€šÃ‚Â°u yÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âªu thÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­ch chÃƒÆ’Ã¢â‚¬Â Ãƒâ€šÃ‚Â°a
        final provider = Provider.of<LocationProvider>(context, listen: false);
        final searchedLocation = AppLocation.Location(
          id: '${text}_searched',
          name: text,
          latitude: location.latitude,
          longitude: location.longitude,
          country: '', // CÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³ thÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢ lÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¥y tÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â« location nÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿u cÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â§n
        );
        _isFavorite = provider.isFavorite(searchedLocation);

        setState(() {
          _isLoading = false;
          _hasResult = true;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasResult = false;
        });
        final languageCode = context.read<SettingsProvider>().settings.language;
        
        // HiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡n SnackBar thÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â´ng bÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡o khÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â´ng tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¬m thÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¥y ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¹a ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“iÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢m
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.tr(languageCode, en: 'Location not found', vi: 'Không tìm thấy địa điểm này'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasResult = false;
      });
      final languageCode = context.read<SettingsProvider>().settings.language;
      
      // HiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡n SnackBar thÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â´ng bÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡o lÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Âi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.tr(languageCode, en: 'Search error', vi: 'Lỗi tìm kiếm')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // XÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â­ lÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â½ SÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â± kiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡n ThÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â£ tim (OnTap Heart Icon)
  void _handleFavoriteTap() {
    if (!_hasResult) return;
    
    final provider = Provider.of<LocationProvider>(context, listen: false);
    final searchedLocation = AppLocation.Location(
      id: '${_searchedCityName}_searched',
      name: _searchedCityName,
      latitude: _searchedLatitude,
      longitude: _searchedLongitude,
      country: '',
    );
    
    // GÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Âi context.read<LocationProvider>().toggleFavorite(searchedLocation)
    provider.toggleFavorite(searchedLocation);
    
    // CÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â­p nhÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â­t UI icon trÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡i tim thÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â nh mÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â u ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationProvider>(context);
    final settings = context.watch<SettingsProvider>().settings;
    final languageCode = settings.language;

    // XÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â­ lÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â½ selectedCity ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢ thiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿t lÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â­p vÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¹ trÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­ ban ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â§u
    LatLng initialCenter;
    double initialZoom;
    if (provider.selectedCity != null) {
      initialCenter = LatLng(provider.selectedCity!.latitude, provider.selectedCity!.longitude);
      initialZoom = 11.0;
    } else {
      // MÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â·c ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¹nh: HÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â  NÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢i
      initialCenter = const LatLng(21.0285, 105.8542);
      initialZoom = 5.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr(languageCode, en: 'Weather Map', vi: 'Bản đồ thời tiết')),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // BÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â£n ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
              onTap: (_, latLng) {
                // HiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢n thÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¹ popup khi nhÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¥n vÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â o bÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â£n ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ
                _showLocationPopup(latLng);
              },
            ),
            children: [
              // 1. LÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºp bÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â£n ÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ nÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Ân (Base Map)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.weather_forecast_app',
              ),
              
              // 2. LÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºp thÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Âi tiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿t phÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â§ lÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âªn trÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âªn (Overlay Weather Map)
              if (_currentWeatherLayer != 'none')
                TileLayer(
                  urlTemplate: 'https://tile.openweathermap.org/map/$_currentWeatherLayer/{z}/{x}/{y}.png?appid=$_openWeatherApiKey',
                ),

              // 3. Marker cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡c vÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¹ trÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          
          // Thanh tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¬m kiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿m nÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢i (Floating Search Bar)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Thanh tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¬m kiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿m
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppStrings.tr(languageCode, en: 'Search city...', vi: 'Tìm kiếm thành phố...'),
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: _handleSearch,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ThÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â» kÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿t quÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â£ tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¬m kiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¿m nÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢i (Floating Result Card)
                  if (_isLoading)
                    const LinearProgressIndicator(),
                  
                  if (_hasResult && !_isLoading)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _searchedCityName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // NÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âºt TrÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡i Tim (IconButton favorite_border hoÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â·c favorite)
                          IconButton(
                            icon: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? Colors.red : Colors.grey,
                              size: 24,
                            ),
                            onPressed: _handleFavoriteTap,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // NÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âºt "LÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºp dÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Â¯ liÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡u" di chuyÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢n xuÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ng gÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³c phÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â£i
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: _showLayerMenu,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    const Icon(Icons.layers, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      _getLayerName(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  // HÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â m helper lÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚ÂºÃƒâ€šÃ‚Â¥y tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âªn hiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢n thÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¹
  String _getLayerName() {
    final languageCode = context.read<SettingsProvider>().settings.language;
    switch (_currentWeatherLayer) {
      case 'temp_new':
        return AppStrings.tr(languageCode, en: 'Temperature', vi: 'Nhiệt độ');
      case 'precipitation_new':
        return AppStrings.tr(languageCode, en: 'Precipitation', vi: 'Lượng mưa');
      case 'clouds_new':
        return AppStrings.tr(languageCode, en: 'Clouds', vi: 'Mây');
      default:
        return AppStrings.tr(languageCode, en: 'Default', vi: 'Mặc định');
    }
  }

  // HÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â m hiÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€ Ã¢â‚¬â„¢n thÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¹ Menu chÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»Ãƒâ€šÃ‚Ân lÃƒÆ’Ã‚Â¡Ãƒâ€šÃ‚Â»ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºp
  void _showLayerMenu() {
    final languageCode = context.read<SettingsProvider>().settings.language;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  AppStrings.tr(languageCode, en: 'Choose weather layer', vi: 'Chọn lớp dữ liệu thời tiết'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.grey),
                title: Text(AppStrings.tr(languageCode, en: 'Base map (Default)', vi: 'Bản đồ gốc (Mặc định)')),
                trailing: _currentWeatherLayer == 'none' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _currentWeatherLayer = 'none');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.thermostat, color: Colors.orange),
                title: Text(AppStrings.tr(languageCode, en: 'Temperature map', vi: 'Bản đồ nhiệt độ')),
                trailing: _currentWeatherLayer == 'temp_new' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _currentWeatherLayer = 'temp_new');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.blue),
                title: Text(AppStrings.tr(languageCode, en: 'Precipitation / Radar map', vi: 'Bản đồ lượng mưa / Radar')),
                trailing: _currentWeatherLayer == 'precipitation_new' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _currentWeatherLayer = 'precipitation_new');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud, color: Colors.blueGrey),
                title: Text(AppStrings.tr(languageCode, en: 'Cloud coverage map', vi: 'Bản đồ mây che phủ')),
                trailing: _currentWeatherLayer == 'clouds_new' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _currentWeatherLayer = 'clouds_new');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _showLocationPopup(LatLng latLng) {
    final languageCode = context.read<SettingsProvider>().settings.language;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.only(bottom: 20)),
              Text(
                AppStrings.tr(languageCode, en: 'Selected location', vi: 'Vị trí đã chọn'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('${AppStrings.tr(languageCode, en: 'Latitude', vi: 'Vĩ độ')}: ${latLng.latitude.toStringAsFixed(4)}'),
              Text('${AppStrings.tr(languageCode, en: 'Longitude', vi: 'Kinh độ')}: ${latLng.longitude.toStringAsFixed(4)}'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showWeatherAtLocation(latLng);
                    },
                    child: Text(AppStrings.tr(languageCode, en: 'View weather', vi: 'Xem thời tiết')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      MapsLauncher.launchCoordinates(latLng.latitude, latLng.longitude);
                    },
                    child: Text(AppStrings.tr(languageCode, en: 'Open map', vi: 'Mở bản đồ')),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWeatherAtLocation(LatLng latLng) async {
    final provider = Provider.of<LocationProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await provider.fetchWeather(latLng.latitude, latLng.longitude);
    if (mounted) {
      Navigator.pop(context);
      _showWeatherBottomSheet(
        context,
        provider,
        AppStrings.tr(
          context.read<SettingsProvider>().settings.language,
          en: 'Selected location',
          vi: 'Vị trí đã chọn',
        ),
      );
    }
  }

  void _showWeatherBottomSheet(BuildContext context, LocationProvider provider, String cityName) {
    final languageCode = context.read<SettingsProvider>().settings.language;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) {
        final w = provider.currentWeather;
        if (w == null) {
          return SizedBox(
            height: 150,
            child: Center(
              child: Text(AppStrings.tr(languageCode, en: 'No data', vi: 'Không có dữ liệu')),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.only(bottom: 20)),
              Text(cityName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildInfoTile(
                Icons.thermostat,
                AppStrings.tr(languageCode, en: 'Temperature', vi: 'Nhiệt độ'),
                "${w['main']['temp']}°C",
                Colors.orange,
              ),
              _buildInfoTile(
                Icons.water_drop,
                AppStrings.tr(languageCode, en: 'Humidity', vi: 'Độ ẩm'),
                "${w['main']['humidity']}%",
                Colors.blue,
              ),
              _buildInfoTile(
                Icons.air,
                AppStrings.tr(languageCode, en: 'Wind Speed', vi: 'Tốc độ gió'),
                "${w['wind']['speed']} m/s",
                Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

