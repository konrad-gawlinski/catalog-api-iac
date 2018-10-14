#!/usr/bin/env bash
set -euxo pipefail

apt-get update
apt-get install -y wget unzip ca-certificates apt-transport-https
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O-  | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" | tee -a /etc/apt/sources.list.d/php.list

apt-get update
apt-get -y install supervisor postgresql-10

rm -rf /var/lib/postgresql/10/main
userdel -r postgres

echo 'export PGDATA=/var/pgsql_data' | tee /etc/profile
adduser --disabled-password --gecos "" postgres_admin
mkdir -p /var/pgsql_data && chown postgres_admin:postgres_admin /var/pgsql_data && chmod 770 /var/pgsql_data
mkdir -p /var/log/postgres && chown postgres_admin:postgres_admin /var/log/postgres && chmod 774 /var/log/postgres
chown -R postgres_admin:postgres_admin /var/run/postgresql
sed -i '/en_US\.UTF-8 UTF-8/s/^#//' /etc/locale.gen && locale-gen
su -m postgres_admin -c "/usr/lib/postgresql/10/bin/initdb --encoding=UTF-8 --locale=en_US.utf8 --lc-collate=C.UTF-8 --lc-ctype=C.UTF-8 -D /var/pgsql_data"
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/pgsql_data/postgresql.conf
printf "\nhost\tall\t\tpostgres_admin\tsamehost\t\tpassword\n" | tee -a /var/pgsql_data/pg_hba.conf

apt-get purge -y --auto-remove wget
