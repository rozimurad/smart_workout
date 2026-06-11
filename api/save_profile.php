<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db.php';

// Payload Yakalama
$raw_input = file_get_contents("php://input");
$data = json_decode($raw_input, true);
if (!$data) {
    $data = $_POST;
}

// Temel Parametreler
$nickname = !empty($data['nickname']) ? $data['nickname'] : 'Kullanıcı';
$goal = !empty($data['goal']) ? $data['goal'] : 'formda_kal';
$env = !empty($data['environment']) ? $data['environment'] : 'hepsi';
$level = !empty($data['level']) ? $data['level'] : 'baslangic';
$workout_days = !empty($data['workout_days']) ? $data['workout_days'] : 'Pazartesi,Çarşamba,Cuma';
$gender = !empty($data['gender']) ? $data['gender'] : 'erkek';

// Vücut Metrikleri
$weight = !empty($data['weight']) ? $data['weight'] : 70;
$height = !empty($data['height']) ? $data['height'] : 170;
$age = !empty($data['age']) ? $data['age'] : 20;

// OTONOM GEÇİŞ: İstemciden gelen hedef kiloyu hiçbir filtreye sokmadan doğrudan alıyoruz.
$target_weight = !empty($data['target_weight']) ? $data['target_weight'] : $weight;

// Bölgesel Kas Verisi
$target_muscles = !empty($data['target_muscles']) ? $data['target_muscles'] : 'full_body';

try {
    // Veritabanı Enjeksiyonu
    $query = "INSERT INTO users (name, gender, age, weight, target_weight, height, goal, environment, level, workout_days, target_muscles) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $pdo->prepare($query);
    
    $stmt->execute([$nickname, $gender, $age, $weight, $target_weight, $height, $goal, $env, $level, $workout_days, $target_muscles]);
    
    http_response_code(200);
    echo json_encode([
        "status" => "success", 
        "message" => "Profil verileri (hedef kilo dahil) sisteme işlendi.",
        "user_id" => $pdo->lastInsertId()
    ]);
    
} catch(Exception $e) {
    http_response_code(200); 
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>