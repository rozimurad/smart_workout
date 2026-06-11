<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
require_once 'db.php';

$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;
if (!$user_id) { echo json_encode(["status" => "error", "message" => "ID eksik."]); exit; }

// Kullanıcı verilerini çek
$u_stmt = $pdo->prepare("SELECT name, age, weight, target_weight, height, goal, environment, level, workout_days FROM users WHERE id = ?");
$u_stmt->execute([$user_id]);
$user = $u_stmt->fetch();

if (!$user) { echo json_encode(["status" => "error", "message" => "Kullanıcı bulunamadı."]); exit; }

// Eşleşen programı çek
$p_stmt = $pdo->prepare("SELECT title FROM workout_programs WHERE target_goal = ? AND environment = ? AND level = ? LIMIT 1");
$p_stmt->execute([$user['goal'], $user['environment'], $user['level']]);
$program = $p_stmt->fetch();

echo json_encode([
    "status" => "success",
    "profile" => [
        "name" => $user['name'],
        "age" => $user['age'],
        "weight" => $user['weight'],
        "target_weight" => $user['target_weight'],
        "height" => $user['height'],
        "goal" => $user['goal'],
        "environment" => $user['environment'],
        "level" => $user['level'],
        "workout_days" => $user['workout_days']
    ],
    "assigned_program" => $program ? $program['title'] : "Uygun program veritabanına eklenmedi."
]);
?>