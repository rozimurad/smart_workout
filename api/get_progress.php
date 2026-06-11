<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db.php';

date_default_timezone_set('Europe/Istanbul');

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;

if (!$user_id) {
    echo json_encode(["status" => "error", "message" => "Kullanıcı ID eksik."]);
    exit;
}

// 1. Kullanıcı Verilerini Çek (VKİ ve Hedef Günler için)
$u_stmt = $pdo->prepare("SELECT name, weight, height, workout_days FROM users WHERE id = ?");
$u_stmt->execute([$user_id]);
$user = $u_stmt->fetch();

if (!$user) {
    echo json_encode(["status" => "error", "message" => "Kullanıcı bulunamadı."]);
    exit;
}

// 2. VKİ (Vücut Kitle İndeksi) Hesaplaması
$bmi = 0;
$bmi_status = "";
if ($user['height'] > 0) {
    $height_m = $user['height'] / 100;
    $bmi = $user['weight'] / ($height_m * $height_m);
    
    if ($bmi < 18.5) $bmi_status = "Zayıf";
    else if ($bmi < 24.9) $bmi_status = "Normal";
    else if ($bmi < 29.9) $bmi_status = "Kilolu";
    else $bmi_status = "Obez";
}

// 3. Dinamik Aylık Kotayı Hesapla (Haftalık Seçim x 4)
$selected_days = explode(',', $user['workout_days']);
$weekly_target = count(array_filter($selected_days)); 
$monthly_target = $weekly_target * 4; // Örn: 3 gün x 4 = 12 Antrenman/Ay

// 4. Aylık İlerleme (Progress) Hesaplaması (MONTH ve YEAR kullanıyoruz)
$current_month = date('m');
$current_year = date('Y');

// "Kaç kere antrenman yapmış?" sayısını bulmak için COUNT(id) ekledik
$query = "SELECT 
            COUNT(id) as completed_workouts,
            SUM(total_time_spent) as total_time, 
            SUM(total_exercises) as total_exercises, 
            SUM(total_sets) as total_sets
          FROM user_progress 
          WHERE user_id = ? 
          AND MONTH(completed_at) = ? 
          AND YEAR(completed_at) = ?";
          
$stmt = $pdo->prepare($query);
$stmt->execute([$user_id, $current_month, $current_year]);
$result = $stmt->fetch();

$completed_workouts = $result['completed_workouts'] ? (int)$result['completed_workouts'] : 0;
$monthly_time = $result['total_time'] ? $result['total_time'] : 0;
$monthly_exercises = $result['total_exercises'] ? $result['total_exercises'] : 0;
$monthly_sets = $result['total_sets'] ? $result['total_sets'] : 0;

// 5. Yeni Yüzde Hesaplaması: "150 dakika hedefi" yerine "Antrenman Kotası Hedefi"
$percentage = 0;
if ($monthly_target > 0) {
    $percentage = ($completed_workouts / $monthly_target) * 100;
    if ($percentage > 100) $percentage = 100;
}

echo json_encode([
    "status" => "success",
    "user_name" => $user['name'],
    "bmi_value" => number_format($bmi, 1),
    "bmi_status" => $bmi_status,
    
    // YENİ EKLENEN/GÜNCELLENEN AYLIK DEĞİŞKENLER
    "monthly_target" => $monthly_target,            // Örn: 12
    "completed_workouts" => $completed_workouts,    // Örn: 5
    "progress_percentage" => round($percentage, 1), // Örn: 41.6
    
    // Eskiden haftalıktı, şimdi aylık toplamları yolluyor
    "monthly_time_minutes" => round($monthly_time / 60), 
    "monthly_exercises" => $monthly_exercises,
    "monthly_sets" => $monthly_sets
]);
?>