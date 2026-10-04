#!/bin/bash
set -euo pipefail

# 1. Khởi tạo cấu trúc thư mục
echo "[+] Khởi tạo cấu trúc thư mục bảo mật tại /opt/my-app..."
sudo mkdir -p /opt/my-app/html
sudo mkdir -p /opt/my-app/logs

# 2. Đảm bảo user devops và group www-data tồn tại
if ! id -u devops >/dev/null 2>&1; then
    echo "[+] Đang tạo tài khoản devops..."
    sudo useradd -m -s /bin/bash devops
fi

# 3. Copy file mã nguồn vào đúng vị trí
echo "[+] Triển khai mã nguồn index.html..."
sudo cp index.html /opt/my-app/html/index.html

# 4. Thiết lập phân quyền sở hữu đệ quy
echo "[+] Gán quyền sở hữu devops:www-data..."
sudo chown -R devops:www-data /opt/my-app

# 5. Phân quyền thư mục và file tối ưu bảo mật
echo "[+] Áp dụng phân quyền chi tiết cho thư mục và tệp tin..."
# Thiết lập quyền mặc định: thư mục 750 (rwxr-x---), tệp tin 640 (rw-r-----)
sudo find /opt/my-app -type d -exec chmod 750 {} \;
sudo find /opt/my-app -type f -exec chmod 640 {} \;

# 6. Cấp quyền ghi đặc biệt cho group www-data trên thư mục logs
# Thư mục logs cần quyền 770 (rwxrwx---) để Nginx (chạy dưới user www-data) có thể ghi logs
echo "[+] Cấp quyền ghi thư mục logs cho www-data..."
sudo chmod 770 /opt/my-app/logs

# 7. Triển khai cấu hình Nginx Server Block
echo "[+] Cấu hình Nginx..."
sudo cp my-app.conf /etc/nginx/sites-available/my-app.conf
sudo ln -sf /etc/nginx/sites-available/my-app.conf /etc/nginx/sites-enabled/

# Kiểm tra cấu hình và restart service
sudo nginx -t
sudo systemctl restart nginx
echo "[+] Triển khai hoàn tất thành công!"