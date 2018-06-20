create database cbis_kpi character set utf8 collate utf8_bin;
grant all privileges on cbis_kpi.* to cbis_kpi@localhost identified by 'cbis_kpi';

use cbis_kpi;

CREATE TABLE `config` (
    `config_key`       varchar(128)    DEFAULT ''                NOT NULL,
    `config_value`     varchar(128)    DEFAULT ''                NOT NULL
) ENGINE=InnoDB;
CREATE INDEX `config_1` ON `config` (`config_key`);

insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-all,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-all,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-all]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-ex,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-ex,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-ex]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-int,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-int,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-int]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-tun,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-tun,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[br-tun]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[eno1,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[eno1,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[eno1]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[eno2,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[eno2,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[eno2]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens3f0,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens3f0,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens3f0]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens3f1,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens3f1,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens3f1]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens6f0,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens6f0,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens6f0]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens6f1,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens6f1,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[ens6f1]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan110,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan110,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan110]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan150,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan150,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan150]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan160,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan160,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan160]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan170,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan170,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.in[vlan170]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-all,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-all,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-all]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-ex,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-ex,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-ex]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-int,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-int,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-int]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-tun,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-tun,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[br-tun]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[eno1,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[eno1,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[eno1]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[eno2,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[eno2,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[eno2]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens3f0,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens3f0,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens3f0]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens3f1,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens3f1,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens3f1]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens6f0,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens6f0,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens6f0]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens6f1,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens6f1,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[ens6f1]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan110,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan110,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan110]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan150,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan150,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan150]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan160,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan160,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan160]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan170,dropped]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan170,errors]');
insert into config (config_key, config_value) values('zabbix_item_key', 'net.if.out[vlan170]');
insert into config (config_key, config_value) values('zabbix_item_key', 'system.cpu.util[,idle]');
insert into config (config_key, config_value) values('zabbix_item_key', 'system.cpu.util[,interrupt]');
insert into config (config_key, config_value) values('zabbix_item_key', 'system.cpu.util[,iowait]');
insert into config (config_key, config_value) values('zabbix_item_key', 'system.cpu.util[,nice]');
insert into config (config_key, config_value) values('zabbix_item_key', 'system.cpu.util[,softirq]');
insert into config (config_key, config_value) values('zabbix_item_key', 'system.cpu.util[,steal]');
insert into config (config_key, config_value) values('zabbix_item_key', 'system.cpu.util[,system]');
insert into config (config_key, config_value) values('zabbix_item_key', 'system.cpu.util[,user]');
insert into config (config_key, config_value) values('zabbix_item_key', 'vm.memory.size[available]');
insert into config (config_key, config_value) values('zabbix_item_key', 'vm.memory.size[total]');

insert into config (config_key, config_value) values('zabbix_query_interval', '15');


CREATE TABLE `cbis_pod` (
	`cbis_pod_id`               bigint unsigned PRIMARY KEY AUTO_INCREMENT,
	`cbis_pod_name`             varchar(128)    DEFAULT ''                NOT NULL,
	`cbis_undercloud_addr`      varchar(255)    DEFAULT ''                NOT NULL,
	`cbis_undercloud_username`  varchar(255)    DEFAULT ''                NOT NULL,
	`cbis_undercloud_last_sync` decimal         DEFAULT '0'               NOT NULL,
	`cbis_zabbix_url`           varchar(255)    DEFAULT ''                NOT NULL,
	`cbis_zabbix_username`      varchar(128)    DEFAULT ''                NOT NULL,
	`cbis_zabbix_password`      varchar(128)    DEFAULT ''                NOT NULL,
	`cbis_zabbix_last_sync`     decimal         DEFAULT '0'               NOT NULL,
	`enable`                    integer         DEFAULT '0'               NOT NULL
) ENGINE=InnoDB;
CREATE INDEX `cbis_pod_1` ON `cbis_pod` (`cbis_pod_name`,`enable`);

insert into cbis_pod (cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username, cbis_undercloud_last_sync, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password, cbis_zabbix_last_sync, enable)
values('1','test_pod', 'localhost', 'stack', TRUNCATE(UNIX_TIMESTAMP(NOW()) / 900,0)*900, 'http://10.211.55.25/zabbix', 'metrics-exporter', 'zabbix', UNIX_TIMESTAMP(now()), '0');

CREATE TABLE `cbis_zabbix_raw` (
    `cbis_zabbix_raw_id`        bigint unsigned AUTO_INCREMENT,
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`hostname`                  varchar(128)    DEFAULT ''                NOT NULL,
	`item_key`                  varchar(255)    DEFAULT ''                NOT NULL,
	`item_value`                varchar(255)    DEFAULT ''                NOT NULL,
	`item_unit`                 varchar(255)    DEFAULT ''                NOT NULL,
	`clock`                     bigint unsigned DEFAULT '0'               NOT NULL,
    UNIQUE KEY `cbis_zabbix_raw_id` (`cbis_zabbix_raw_id`, `clock`)

) ENGINE=InnoDB PARTITION BY RANGE (clock) (
    PARTITION p_0 VALUES LESS THAN (0)
);

CREATE INDEX `cbis_zabbix_raw_1` ON `cbis_zabbix_raw` (`cbis_pod_id`, `hostname`, `item_key`, `item_unit`, `clock`);

CREATE TABLE `cbis_zabbix_hour` (
    `cbis_zabbix_hour_id`       bigint unsigned AUTO_INCREMENT,
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`hostname`                  varchar(128)    DEFAULT ''                NOT NULL,
	`item_key`                  varchar(255)    DEFAULT ''                NOT NULL,
    `max_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`min_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`avg_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`item_unit`                 varchar(255)    DEFAULT ''                NOT NULL,
	`clock`                     bigint unsigned DEFAULT '0'               NOT NULL,
	UNIQUE KEY `cbis_zabbix_hour_id` (`cbis_zabbix_hour_id`, `clock`)
) ENGINE=InnoDB PARTITION BY RANGE (clock) (
    PARTITION p_0 VALUES LESS THAN (0)
);

CREATE INDEX `cbis_zabbix_hour_1` ON `cbis_zabbix_hour` (`cbis_pod_id`, `hostname`, `item_key`, `item_unit`, `clock`);


CREATE TABLE `cbis_zabbix_day` (
    `cbis_zabbix_day_id`        bigint unsigned AUTO_INCREMENT,
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`hostname`                  varchar(128)    DEFAULT ''                NOT NULL,
	`item_key`                  varchar(255)    DEFAULT ''                NOT NULL,
    `max_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`min_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`avg_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`item_unit`                 varchar(255)    DEFAULT ''                NOT NULL,
	`clock`                     bigint unsigned DEFAULT '0'               NOT NULL,
	UNIQUE KEY `cbis_zabbix_hour_id` (`cbis_zabbix_day_id`, `clock`)
) ENGINE=InnoDB PARTITION BY RANGE (clock) (
    PARTITION p_0 VALUES LESS THAN (0)
);

CREATE INDEX `cbis_zabbix_day_1` ON `cbis_zabbix_day` (`cbis_pod_id`, `hostname`, `item_key`, `item_unit`, `clock`);


CREATE TABLE `cbis_virsh_list` (
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`hostname`                  varchar(128)    DEFAULT ''                NOT NULL,
	`project_name`              varchar(128)    DEFAULT ''                NOT NULL,
	`domain_name`               varchar(128)    DEFAULT ''                NOT NULL,
	`vm_name`                   varchar(128)    DEFAULT ''                NOT NULL,
	`vm_flavor`                 varchar(128)    DEFAULT ''                NOT NULL,
	`vm_vcpu`                   varchar(128)    DEFAULT ''                NOT NULL,
	`vm_memory`                 varchar(128)    DEFAULT ''                NOT NULL,
	`vm_numa`                   varchar(128)    DEFAULT ''                NOT NULL
) ENGINE=InnoDB;
CREATE INDEX `cbis_virsh_list_1` ON `cbis_virsh_list` (`cbis_pod_id`,`hostname`, `domain_name`);

CREATE TABLE `cbis_virsh_meta` (
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`hostname`                  varchar(128)    DEFAULT ''                NOT NULL,
	`domain_name`               varchar(128)    DEFAULT ''                NOT NULL,
	`meta_key`                  varchar(128)    DEFAULT ''                NOT NULL,
	`meta_value`                varchar(128)    DEFAULT ''                NOT NULL
) ENGINE=InnoDB;
CREATE INDEX `cbis_virsh_meta_1` ON `cbis_virsh_meta` (`cbis_pod_id`,`hostname`, `domain_name`, `meta_key`);


CREATE TABLE `cbis_virsh_stat_raw` (
    `cbis_virsh_stat_raw_id`    bigint unsigned  AUTO_INCREMENT,
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`domain_name`               varchar(128)    DEFAULT ''                NOT NULL,
	`item_key`                  varchar(255)    DEFAULT ''                NOT NULL,
	`item_value`                varchar(255)    DEFAULT ''                NOT NULL,
	`item_delta`                varchar(255)    DEFAULT ''                NOT NULL,
	`clock`                     bigint unsigned DEFAULT '0'               NOT NULL,
	`clock_delta`               bigint unsigned DEFAULT '0'               NOT NULL,
	UNIQUE KEY `cbis_virsh_stat_raw_id` (`cbis_virsh_stat_raw_id`, `clock`)
) ENGINE=InnoDB PARTITION BY RANGE (clock) (
    PARTITION p_0 VALUES LESS THAN (0)
);
CREATE INDEX `cbis_virsh_stat_raw_1` ON `cbis_virsh_stat_raw` (`cbis_pod_id`, `domain_name`, `item_key`, `clock`);


CREATE TABLE `cbis_virsh_stat_hour` (
    `cbis_virsh_stat_hour_id`   bigint unsigned AUTO_INCREMENT,
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`domain_name`               varchar(128)    DEFAULT ''                NOT NULL,
	`item_key`                  varchar(255)    DEFAULT ''                NOT NULL,
	`max_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`min_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`avg_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`clock`                     bigint unsigned DEFAULT '0'               NOT NULL,
	UNIQUE KEY `cbis_virsh_stat_hour_id` (`cbis_virsh_stat_hour_id`, `clock`)
) ENGINE=InnoDB PARTITION BY RANGE (clock) (
    PARTITION p_0 VALUES LESS THAN (0)
);
CREATE INDEX `cbis_virsh_stat_hour_1` ON `cbis_virsh_stat_hour` (`cbis_pod_id`, `domain_name`, `item_key`, `clock`);

CREATE TABLE `cbis_virsh_stat_day` (
    `cbis_virsh_stat_day_id`    bigint unsigned AUTO_INCREMENT,
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`domain_name`               varchar(128)    DEFAULT ''                NOT NULL,
	`item_key`                  varchar(255)    DEFAULT ''                NOT NULL,
	`max_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`min_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`avg_value`                 varchar(255)    DEFAULT ''                NOT NULL,
	`clock`                     bigint unsigned DEFAULT '0'               NOT NULL,
	UNIQUE KEY `cbis_virsh_stat_day_id` (`cbis_virsh_stat_day_id`, `clock`)
) ENGINE=InnoDB PARTITION BY RANGE (clock) (
    PARTITION p_0 VALUES LESS THAN (0)
);
CREATE INDEX `cbis_virsh_stat_day_1` ON `cbis_virsh_stat_day` (`cbis_pod_id`, `domain_name`, `item_key`, `clock`);

CREATE TABLE `cbis_ceph_disk` (
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`hostname`                  varchar(128)    DEFAULT ''                NOT NULL,
	`disk`                      varchar(128)    DEFAULT ''                NOT NULL,
	`journal`                   varchar(128)    DEFAULT ''                NOT NULL,
	`osd`                       varchar(128)    DEFAULT ''                NOT NULL
) ENGINE=InnoDB;
CREATE INDEX `cbis_ceph_disk_1` ON `cbis_ceph_disk` (`cbis_pod_id`,`hostname`);