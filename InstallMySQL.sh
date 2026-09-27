#!/bin/bash

# ==========================================================
# Apache + PHP + MariaDB + phpMyAdmin Auto Installer
# Für Ubuntu / Debian
# ==========================================================

set -e

# Root prüfen
if [ "$EUID" -ne 0 ]; then
    echo "Bitte als root ausführen:"
    echo "sudo ./install.sh"
    exit 1
fi

echo "============================================"
echo " Apache + PHP + phpMyAdmin Installer"
echo "============================================"

export DEBIAN_FRONTEND=noninteractive

# Pakete aktualisieren
echo "[1/7] System aktualisieren..."
apt update -y
apt upgrade -y

# Apache installieren
echo "[2/7] Apache installieren..."
apt install -y apache2

systemctl enable apache2
systemctl start apache2

# MariaDB installieren
echo "[3/7] MariaDB installieren..."
apt install -y mariadb-server mariadb-client

systemctl enable mariadb
systemctl start mariadb

# PHP installieren
echo "[4/7] PHP installieren..."
apt install -y \
    php \
    php-cli \
    php-common \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-intl \
    php-bcmath \
    libapache2-mod-php

# phpMyAdmin vorbereiten
echo "[5/7] phpMyAdmin installieren..."

echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" \
    | debconf-set-selections

echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" \
    | debconf-set-selections

apt install -y phpmyadmin

# phpMyAdmin Apache-Konfiguration aktivieren
if [ -f /etc/phpmyadmin/apache.conf ]; then
    ln -sf /etc/phpmyadmin/apache.conf \
        /etc/apache2/conf-available/phpmyadmin.conf

    a2enconf phpmyadmin || true
fi

# Apache Module aktivieren
echo "[6/7] Apache konfigurieren..."

a2enmod rewrite
a2enmod headers

systemctl restart apache2

# Firewall optional öffnen
if command -v ufw >/dev/null 2>&1; then
    ufw allow 80/tcp || true
    ufw allow 443/tcp || true
fi

echo "[7/7] Installation abgeschlossen!"

echo ""
echo "============================================"
echo " INSTALLATION ERFOLGREICH"
echo "============================================"
echo ""
echo "Apache:"
echo "http://DEINE-SERVER-IP/"
echo ""
echo "phpMyAdmin:"
echo "http://DEINE-SERVER-IP/phpmyadmin"
echo ""
echo "PHP Version:"
php -v
echo ""
echo "Apache Status:"
systemctl is-active apache2
echo ""
echo "MariaDB Status:"
systemctl is-active mariadb
echo ""
echo "Web-Verzeichnis:"
echo "/var/www/html"
echo ""
echo "============================================"