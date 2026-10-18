class WorkoutProgram {
  final String programAdi;
  final String aciklama;
  final int haftalikGunSayisi;
  final String hedefKategori;

  WorkoutProgram({
    required this.programAdi,
    required this.aciklama,
    required this.haftalikGunSayisi,
    required this.hedefKategori,
  });

  @override
  String toString() {
    return 'WorkoutProgram(programAdi: $programAdi, aciklama: $aciklama, haftalikGunSayisi: $haftalikGunSayisi, hedefKategori: $hedefKategori)';
  }
}
