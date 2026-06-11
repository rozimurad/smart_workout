<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db.php';

// Saat dilimini Türkiye'ye sabitliyoruz, gece yarısı sapmaları olmasın
date_default_timezone_set('Europe/Istanbul');

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;
if (!$user_id) { echo json_encode(["status" => "error", "message" => "ID eksik."]); exit; }

// 1. KULLANICI PROFİLİNİ ÇEK (height eklendi)
$stmt = $pdo->prepare("SELECT gender, height, weight, goal, environment, level, workout_days, target_muscles FROM users WHERE id = ?");
$stmt->execute([$user_id]);
$user = $stmt->fetch();
if (!$user) { echo json_encode(["status" => "error"]); exit; }

// --- DİNAMİK GÜN VE TAMAMLAMA KONTROLÜ BAŞLIYOR ---

// A. Bugün günlerden ne? (Türkçe eşleştirme)
$days_tr = [1 => 'Pazartesi', 2 => 'Salı', 3 => 'Çarşamba', 4 => 'Perşembe', 5 => 'Cuma', 6 => 'Cumartesi', 7 => 'Pazar'];
$today_index = date('N'); // 1 (Pazartesi) - 7 (Pazar)
$today_name = $days_tr[$today_index];

// B. Kullanıcı bugün zaten antrenman yapmış mı?
$check_stmt = $pdo->prepare("SELECT id FROM user_progress WHERE user_id = ? AND DATE(completed_at) = CURDATE()");
$check_stmt->execute([$user_id]);
if ($check_stmt->rowCount() > 0) {
    // Bugün bitirmiş! Sistemi kilitle.
    echo json_encode([
        "status" => "completed", 
        "today_state" => "already_done",
        "message" => "Bugün yeterince ter döktün! Kaslarının büyümesi için dinlenmeye ihtiyacı var. Yarına kadar antrenman yok."
    ]);
    exit;
}

// C. Bugün adamın seçtiği antrenman günlerinden biri mi?
$selected_days = explode(',', $user['workout_days']); // Örn: array('Pazartesi', 'Cuma')
// Boşlukları temizleyelim (hataya karşı)
$selected_days = array_map('trim', $selected_days);

if (!in_array($today_name, $selected_days)) {
    // Seçili günlerde değil! Sistemi kilitle.
    echo json_encode([
        "status" => "rest_day", 
        "today_state" => "rest",
        "message" => "Bugün ($today_name) dinlenme günün! Kaslarını toparla, zorlamanın alemi yok."
    ]);
    exit;
}
// --- KONTROL BİTTİ. EĞER BURAYA ULAŞTIYSA ADAM SPOR YAPMALI ---

// --- BMI (VÜCUT KİTLE İNDEKSİ) HESAPLAMA VE EKLEM KORUMA ---
$weight = floatval($user['weight']);
$height_m = floatval($user['height']) / 100; // Santimetreyi metreye çevir
$bmi = 0;

if ($height_m > 0) {
    $bmi = $weight / ($height_m * $height_m);
}

// BMI 30 ve üzeriyse adam obezdir, eklemlere yük bindiren hareketler yasaklanır
$is_obese = ($bmi >= 30) ? true : false;

$user_gender = !empty($user['gender']) ? $user['gender'] : 'erkek';
$dynamic_sets = ($user['level'] == 'baslangic') ? 3 : (($user['level'] == 'orta') ? 4 : 5);

if ($user['goal'] == 'kas_kazan') {
    $dynamic_reps = "8-12 Tekrar"; $dynamic_rest = 90; $program_title = "Kişiselleştirilmiş Hipertrofi Planı";
} else if ($user['goal'] == 'kilo_ver') {
    $dynamic_reps = "15-20 Tekrar"; $dynamic_rest = 30; $program_title = "Dinamik Yağ Yakımı ve Kondisyon";
} else {
    $dynamic_reps = "12-15 Tekrar"; $dynamic_rest = 60; $program_title = "Dengeli Form Koruma Rutini";
}

// --- BÖLGESEL DİNAMİK FİLTRELEME ---
// Kullanıcının seçtiği kas gruplarını diziye çevir
$target_muscles = !empty($user['target_muscles']) ? explode(',', $user['target_muscles']) : ['full_body'];
$target_muscles = array_map('trim', $target_muscles);

// Temel sorgu (Çevre ve Cinsiyet her zaman geçerli)
$query = "SELECT id, name, gif_url FROM exercises 
          WHERE (environment = ? OR environment = 'hepsi') 
          AND (gender_target = ? OR gender_target = 'hepsi')";

$params = [$user['environment'], $user_gender];

// Eğer adam "full_body" seçmediyse, sadece istediği bölgeleri filtrele!
if (!in_array('full_body', $target_muscles)) {
    // Kaç tane bölge seçtiyse o kadar soru işareti (?) oluştur
    $placeholders = implode(',', array_fill(0, count($target_muscles), '?'));
    $query .= " AND target_muscle IN ($placeholders)";
    
    // Parametreleri sorguya dahil et
    foreach ($target_muscles as $muscle) {
        $params[] = $muscle;
    }
}

// Obezite (BMI >= 30) eklem koruması: Zıplamalı ve dize darbe vuran hareketleri sil
if ($is_obese) {
    $query .= " AND name NOT LIKE '%Jump%' AND name NOT LIKE '%Burpees%' AND name NOT LIKE '%High Knees%'";
}

$ex_stmt = $pdo->prepare($query);
$ex_stmt->execute($params);
$available_exercises = $ex_stmt->fetchAll(PDO::FETCH_ASSOC);

// SADECE BUGÜN İÇİN 1 GÜNLÜK DİNAMİK PROGRAM ÜRET
shuffle($available_exercises);
// Eğer filtreden az hareket döndüyse patlamamak için min() kullanıyoruz
$exercises_to_pull = min(4, count($available_exercises));
$daily_exercises = array_slice($available_exercises, 0, $exercises_to_pull);

$today_schedule = [];
foreach ($daily_exercises as $ex) {
    // --- DİNAMİK MEDYA (FALLBACK) MOTORU ---
    $db_url = $ex['gif_url']; // Örn: http://192.168.1.XX/api/exercises/man/burpees-man.gif
    
    // 1. Sadece dosyanın adını URL'den kopar
    $filename = basename(parse_url($db_url, PHP_URL_PATH)); 
    
    // 2. MÜHENDİSLİK: Çekirdek ismi bul. (Tire veya alt çizgiyle biten man/woman takılarını sil)
    // "burpees-man.gif" -> "burpees" olur.
    $core_name = preg_replace('/[-_](man|woman)\.gif$/i', '', $filename); 
    
    $pref_gender = ($user_gender == 'kadin') ? 'woman' : 'man';
    $fallback_gender = ($user_gender == 'kadin') ? 'man' : 'woman';
    
    // Fiziksel tarama için kök dizini belirliyoruz
    $base_dir = __DIR__ . '/exercises/';
    
    // Uygulamaya gönderilecek dinamik URL'in ana gövdesi
    $url_dir = dirname(dirname($db_url)); 
    
    // 3. Önce kendi cinsiyet klasöründe "çekirdek isimle" başlayan dosya var mı bak (glob taraması)
    $found_pref = glob($base_dir . $pref_gender . '/' . $core_name . "*.gif");
    
    if (!empty($found_pref)) {
        // Kendi cinsiyetinde dosya bulundu! URL'yi ona göre inşa et.
        $final_filename = basename($found_pref[0]);
        $final_gif_url = $url_dir . '/' . $pref_gender . '/' . $final_filename;
    } else {
        // 4. Kendi cinsiyetinde YOKSA, karşı cinsiyetin klasörüne (yedek) bak
        $found_fallback = glob($base_dir . $fallback_gender . '/' . $core_name . "*.gif");
        
        if (!empty($found_fallback)) {
            // Karşı cinsiyette bulundu, kurtarıcı (fallback) olarak onu kullan!
            $final_filename = basename($found_fallback[0]);
            $final_gif_url = $url_dir . '/' . $fallback_gender . '/' . $final_filename;
        } else {
            // İki klasörde de dosya fiziksel olarak yoksa, mecburen veritabanındaki ham linki bas
            $final_gif_url = $db_url;
        }
    }

    $today_schedule[] = [
        "id" => $ex['id'],
        "name" => $ex['name'],
        "gif_url" => $final_gif_url, // Zeki motorun inşa ettiği yeni URL
        "set_count" => $dynamic_sets,
        "rep_count" => $dynamic_reps,
        "rest_duration" => $dynamic_rest
    ];
}

echo json_encode([
    "status" => "success",
    "today_state" => "workout_time",
    "program_title" => $program_title,
    "is_low_impact" => $is_obese,
    "schedule" => ["Bugünün Programı ($today_name)" => $today_schedule]
]);
?>