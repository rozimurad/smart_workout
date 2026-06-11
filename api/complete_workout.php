<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db.php';
$data = json_decode(file_get_contents("php://input"));

if (isset($data->user_id)) {
    $stmt = $pdo->prepare("INSERT INTO user_progress (user_id, total_time_spent, total_sets, total_exercises) VALUES (?, ?, ?, ?)");
    if($stmt->execute([$data->user_id, $data->total_time, $data->total_sets, $data->total_exercises])) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Kaydedilemedi."]);
    }
}
?>