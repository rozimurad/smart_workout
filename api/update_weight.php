<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once 'db.php';

// Flutter'dan gelen JSON veya Form-Data'yı güvenli yakalama
$raw_input = file_get_contents("php://input");
$data = json_decode($raw_input, true);

if (!$data) {
    $data = $_POST;
}

$user_id = !empty($data['user_id']) ? $data['user_id'] : null;
$weight = !empty($data['weight']) ? floatval($data['weight']) : null;

if (!$user_id || !$weight) {
    // 200 OK dönüyoruz ki Flutter HTTP hatası fırlatmak yerine kendi içinde "Eksik parametre" uyarısını işleyebilsin
    http_response_code(200); 
    echo json_encode(["status" => "error", "message" => "user_id ve weight alanları zorunludur."]);
    exit;
}

try {
    // Sadece güncel kiloyu yazar (Hedef hesaplamaları arkada devam eder)
    $query = "UPDATE users SET weight = ? WHERE id = ?";
    $stmt = $pdo->prepare($query);
    $stmt->execute([$weight, $user_id]);

    http_response_code(200);
    echo json_encode(["status" => "success", "message" => "Kilo başarıyla güncellendi."]);
} catch (Exception $e) {
    http_response_code(200);
    echo json_encode(["status" => "error", "message" => "Veritabanı hatası: " . $e->getMessage()]);
}
?>