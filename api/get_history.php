<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db.php';
$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;

$stmt = $pdo->prepare("SELECT 'Sana Özel Dinamik Seans' as program_name, completed_at, total_time_spent, total_sets, total_exercises FROM user_progress WHERE user_id = ? ORDER BY completed_at DESC");
$stmt->execute([$user_id]);
$history = $stmt->fetchAll();

echo json_encode([
    "status" => "success",
    "total_workouts" => count($history),
    "history" => $history
]);
?>