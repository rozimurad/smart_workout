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
$goal = !empty($data['goal']) ? $data['goal'] : null;
$target_weight = !empty($data['target_weight']) ? floatval($data['target_weight']) : null;

// Geliştirilmiş Sigorta: Eğer ajan mevcut kiloyu da yollarsa onu da al, yollamazsa es geç.
$current_weight = !empty($data['weight']) ? floatval($data['weight']) : null;

if (!$user_id || !$goal || !$target_weight) {
    http_response_code(200);
    echo json_encode(["status" => "error", "message" => "user_id, goal ve target_weight alanları eksiksiz olmalıdır."]);
    exit;
}

try {
    // Eğer Flutter payload içinde 'weight' de yolladıysa 3 sütunu, yollamadıysa 2 sütunu güncelle (Dinamik SQL)
    if ($current_weight !== null) {
        $query = "UPDATE users SET goal = ?, target_weight = ?, weight = ? WHERE id = ?";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$goal, $target_weight, $current_weight, $user_id]);
    } else {
        $query = "UPDATE users SET goal = ?, target_weight = ? WHERE id = ?";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$goal, $target_weight, $user_id]);
    }

    http_response_code(200);
    echo json_encode(["status" => "success", "message" => "Otonom geçiş sağlandı: Hedef ve projeksiyon başarıyla kilitlendi."]);
} catch (Exception $e) {
    http_response_code(200);
    echo json_encode(["status" => "error", "message" => "Veritabanı hatası: " . $e->getMessage()]);
}
?>