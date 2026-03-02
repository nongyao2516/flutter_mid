<?php
include 'condb.php';

header('Content-Type: application/json');

$name = $_POST['name'];
$province = $_POST['province'];
$description = $_POST['description'];
$address = $_POST['address'];

////////////////////////////////////////////////////////////
// ✅ รับรูปภาพ
////////////////////////////////////////////////////////////

$imageName = "";

if (isset($_FILES['image'])) {

    $targetDir = "images/";   // ✅ โฟลเดอร์เก็บรูป
    $imageName = time() . "_" . basename($_FILES["image"]["name"]);
    $targetFile = $targetDir . $imageName;

    if (!move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
        echo json_encode([
            "success" => false,
            "error" => "Upload image failed"
        ]);
        exit;
    }
}

////////////////////////////////////////////////////////////
// ✅ Insert DB
////////////////////////////////////////////////////////////

try {

    $stmt = $conn->prepare("
        INSERT INTO places (name, province, address, description, image)
        VALUES (:name, :province, :address, :description, :image)
    ");

    $stmt->bindParam(":name", $name);
    $stmt->bindParam(":province", $province);
    $stmt->bindParam(":address", $address);
    $stmt->bindParam(":description", $description);
    $stmt->bindParam(":image", $imageName);

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false]);
    }

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}
