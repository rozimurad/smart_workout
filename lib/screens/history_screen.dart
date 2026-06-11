import 'package:flutter/material.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _historyList = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = DatabaseService.savedUserId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kullanıcı kimliği bulunamadı. Lütfen onboarding işlemini tamamlayın.';
      });
      return;
    }

    final rows = await DatabaseService.instance.getHistory(userId);
    if (!mounted) return;

    setState(() {
      _historyList = rows;
      _isLoading = false;
    });
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '-';
    final date = DateTime.tryParse(rawDate);
    if (date == null) return rawDate;
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  int _calculateMinutes(dynamic rawSeconds) {
    if (rawSeconds == null) return 0;
    final int seconds = int.tryParse(rawSeconds.toString()) ?? 0;
    return (seconds / 60).ceil();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F19),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
              ),
              SizedBox(height: 20),
              Text(
                'Antrenman Geçmişin Yükleniyor...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0F19),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3366).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFFF3366),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Geçmiş Yüklenemedi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF87),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _fetchHistory,
                    child: const Text(
                      'Yeniden Dene',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchHistory,
          color: const Color(0xFF00FF87),
          backgroundColor: const Color(0xFF161F30),
          child: _historyList.isEmpty
              ? _buildEmptyState()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 26.0, bottom: 8.0),
                      child: Text(
                        'Antrenman Geçmişi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Toplam ${_historyList.length} antrenman seansı tamamladın.',
                        style: TextStyle(fontSize: 13, color: Colors.blueGrey[300]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        itemCount: _historyList.length,
                        itemBuilder: (context, index) {
                          final item = _historyList[index];
                          final String programName = item['program_name'] as String? ?? 'Bilinmeyen Antrenman';
                          final String completedAt = item['completed_at'] as String? ?? '';
                          final int minutes = _calculateMinutes(item['total_time_seconds']);
                          final int sets = item['total_sets'] as int? ?? 0;
                          final int exercises = item['total_exercises'] as int? ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161F30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00FF87).withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF00FF87).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.check_circle_rounded,
                                          color: Color(0xFF00FF87), size: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          programName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_month_outlined,
                                                color: Colors.white38, size: 13),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatDate(completedAt),
                                              style: const TextStyle(
                                                  fontSize: 12, color: Colors.white54),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _buildMiniBadge(
                                        icon: Icons.timer_outlined,
                                        color: const Color(0xFF00FF87),
                                        text: '$minutes dk',
                                      ),
                                      const SizedBox(height: 6),
                                      _buildMiniBadge(
                                        icon: Icons.fitness_center_outlined,
                                        color: const Color(0xFF6366F1),
                                        text: '$sets Set',
                                      ),
                                      const SizedBox(height: 6),
                                      _buildMiniBadge(
                                        icon: Icons.playlist_add_check_rounded,
                                        color: const Color(0xFF00E5FF),
                                        text: '$exercises Egz.',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 120,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10, width: 1),
              ),
              child: const Center(
                child: Icon(Icons.history_toggle_off_rounded, color: Colors.white30, size: 48),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Henüz antrenman yapmadınız',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Görünüşe göre henüz bir egzersiz seansını tamamlamadınız. Ana sayfa sekmesine giderek bugünün antrenmanına başlayın ve ilk kaydınızı oluşturun!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: Colors.blueGrey[200], height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
