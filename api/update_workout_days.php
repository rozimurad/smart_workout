<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
require_once 'db.php';

// Hem JSON hem Form-Data formatını kabul eden güvenli okuma
$raw_input = file_get_contents("php://input");
$data = json_decode($raw_input, true);
if (!$data) {
    $data = $_POST;
}

$user_id = !empty($data['user_id']) ? $data['user_id'] : null;
$workout_days = !empty($data['workout_days']) ? $data['workout_days'] : null;

if ($user_id && $workout_days) {
    try {
        $stmt = $pdo->prepare("UPDATE users SET workout_days = ? WHERE id = ?");
        $stmt->execute([$workout_days, $user_id]);
        
        echo json_encode([
            "status" => "success", 
            "message" => "Antrenman günleri başarıyla güncellendi."
        ]);
    } catch(Exception $e) {
        echo json_encode(["status" => "error", "message" => "Veritabanı hatası: " . $e->getMessage()]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Kullanıcı ID veya seçilen günler eksik!"]);
}
?>