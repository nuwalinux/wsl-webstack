# WSL XAMPP/LAMP-like Setup

This guide explains how to set up **MySQL, Apache, PHP, phpMyAdmin**, and a sample database on **Ubuntu 22.04 WSL**. The MySQL root password will be set to `Student@#321`.

You can either run the provided shell script or follow the manual steps below.

---

## Manual Steps

### 1. Update Ubuntu
```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install MySQL
```bash
sudo apt install mysql-server -y
sudo service mysql start
```

### 3. Set MySQL Root Password
```bash
sudo mysql -u root
```
Inside MySQL prompt:
```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'Student@#321';
FLUSH PRIVILEGES;
EXIT;
```
Test login:
```bash
mysql -u root -p
# Enter: Student@#321
```

### 4. Install Apache and PHP
```bash
sudo apt install apache2 php libapache2-mod-php php-mysql -y
```
Check in browser: `http://localhost`

### 5. Install phpMyAdmin
```bash
sudo DEBIAN_FRONTEND=noninteractive apt install -y phpmyadmin
```
- Select **apache2** (press SPACE + ENTER)
- Configure database for phpMyAdmin: Yes
- Set phpMyAdmin password: `Student@#321`

Enable PHP MySQL extension:
```bash
sudo phpenmod mysqli
sudo systemctl restart apache2
```

### 6. Create Apache Symlink for phpMyAdmin
```bash
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
sudo systemctl restart apache2
```
Access in browser: `http://localhost/phpmyadmin`

### 7. Create Sample Database and Table
```bash
mysql -u root -pStudent@#321
```
Inside MySQL:
```sql
CREATE DATABASE studentdb;
USE studentdb;
CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));
INSERT INTO users (name) VALUES ('Alice'), ('Bob'), ('Charlie');
EXIT;
```

### 8. Create Test PHP File
```bash
sudo nano /var/www/html/dbtest.php
```
Paste the following code:
```php
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
```
Save and exit.

### 9. Test in Browser
- Apache default page: `http://localhost`
- phpMyAdmin: `http://localhost/phpmyadmin` (login: root / Student@#321)
- PHP test file: `http://localhost/dbtest.php`

---

## Using the Script
You can also use the provided script `setup_wsl.sh` to automate all steps. Just make it executable and run:
```bash
chmod +x setup_wsl.sh
./setup_wsl.sh
```

This will set up Apache, PHP, MySQL, phpMyAdmin, the sample database, and the test PHP file automatically.

