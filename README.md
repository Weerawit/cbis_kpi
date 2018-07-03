CBIS KPI Collector and Web GUI
==============

Installation
============


1) Install
    a) install from yum
    yum install mariadb-server.x86_64
    b) reload system daemon
    systemctl daemon-reload

    c) place below content to /etc/my.cnf

    [mysqld]
    datadir=/home/cbis-kpi/db/
    socket=/home/cbis-kpi/db/mysql.sock
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    # Settings user and group are ignored when systemd is used.
    # If you need to run mysqld under a different user or group,
    # customize your systemd unit file for mariadb according to the
    # instructions in http://fedoraproject.org/wiki/Systemd
    max_allowed_packet=128M
    innodb_file_per_table=1

    [mysqld_safe]
    log-error=/var/log/mariadb/mariadb.log
    pid-file=/var/run/mariadb/mariadb.pid

    [client]
    port=3306
    socket=/home/cbis_kpi/mysql/mysql.sock

    #
    # include all files from the config directory
    #
    !includedir /etc/my.cnf.d

    d) enable to start on boot
    systemctl enable mariadb

    e) start mariadb
    systemctl start mariadb

    f) add database schema from schemq.sql

2) Install CBIS KPI
    a) copy library to /root/pip/

    b) install cbis kpi
    pip install cbis_kpi-1.tar.gz --find-link=./pip/

    c) add configuration to /etc/cbis_kpi/cbis_kpi.conf

    [database]

    host=localhost
    port=3306
    user=cbis_kpi
    password=cbis_kpi
    database=cbis_kpi
    pool_name=cbis_kpi_pool
    pool_size=20


    d) add crontab every 15 mins
    */15 * * * * /usr/bin/cbis-kpi-collect >> /var/log/cbis-kpi.log

    f) enable POD to be collected, in database (rst-mgt)

    insert into cbis_pod (cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username, cbis_undercloud_last_sync, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password, cbis_zabbix_last_sync, enable)
    values('1','rst-mgt', 'rst-mgt-uc', 'stack', TRUNCATE(UNIX_TIMESTAMP(NOW()) / 900,0)*900, 'https://10.27.82.134/zabbix', 'metrics-exporter', 'zabbix', UNIX_TIMESTAMP(now()), '1');
