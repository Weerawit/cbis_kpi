use cbis_kpi;
alter table cbis_virsh_stat_raw add column clock_delta bigint unsigned DEFAULT '0'  NOT NULL;

CREATE TABLE `cbis_virsh_meta` (
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`hostname`                  varchar(128)    DEFAULT ''                NOT NULL,
	`domain_name`               varchar(128)    DEFAULT ''                NOT NULL,
	`meta_key`                  varchar(128)    DEFAULT ''                NOT NULL,
	`meta_value`                varchar(128)    DEFAULT ''                NOT NULL
) ENGINE=InnoDB;
CREATE INDEX `cbis_virsh_meta_1` ON `cbis_virsh_meta` (`cbis_pod_id`,`hostname`, `domain_name`, `meta_key`);

alter table cbis_virsh_list add column project_name varchar(128)  DEFAULT '' NOT NULL;
