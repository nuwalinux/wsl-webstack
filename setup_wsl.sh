#!/bin/bash
# Script to set up MySQL, Apache, PHP, phpMyAdmin, and sample DB on Ubuntu 22.04 WSL
# MySQL root password = Student@#321

set -e

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing MySQL Server..."
sudo apt install mysql-server -y
sudo service mysql start

echo "Configuring MySQL root password..."
sudo mysql -u root <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Student@#321';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Root password set to 'Student@#321'"

echo "Installing Apache, PHP, and extensions..."
sudo apt install apache2 php libapache2-mod-php php-mysql -y

echo "Installing phpMyAdmin..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y phpmyadmin

echo "Enabling mysqli extension..."
sudo phpenmod mysqli
sudo systemctl restart apache2

echo "Creating Apache symlink for phpMyAdmin..."
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
sudo systemctl restart apache2

echo "Creating sample database and table..."
mysql -u root -pStudent@#321 <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS studentdb;
USE studentdb;
CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));
INSERT INTO users (name) VALUES ('Alice'), ('Bob'), ('Charlie')
    ON DUPLICATE KEY UPDATE name=VALUES(name);
MYSQL_SCRIPT

echo "Creating sample PHP file..."
sudo tee /var/www/html/dbtest.php > /dev/null <<'EOF'
<?php
$servername = "localhost";
$username = "root";
$password = "Student@#321";
$dbname = "studentdb";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully<br>";

$sql = "SELECT * FROM users";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        echo "ID: " . $row["id"]. " - Name: " . $row["name"]. "<br>";
    }
} else {
    echo "0 results";
}
$conn->close();
?>
EOF

echo "Setup complete!"
echo "Open these URLs in Windows browser:"
echo "   http://localhost/            (Apache test page)"
echo "   http://localhost/phpmyadmin  (phpMyAdmin login: root / Student@#321)"
echo "   http://localhost/dbtest.php  (Test DB connection)"
