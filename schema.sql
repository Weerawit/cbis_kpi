create database cbis_kpi character set utf8 collate utf8_bin;
grant all privileges on cbis_kpi.* to cbis_kpi@localhost identified by 'cbis_kpi';

use cbis_kpi;

CREATE TABLE `config` (
    `config_key`       varchar(128)    DEFAULT ''                NOT NULL,
    `config_value`     varchar(128)    DEFAULT ''                NOT NULL
) ENGINE=InnoDB;
CREATE INDEX `config_1` ON `config` (`config_key`);

INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[10]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[11]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[12]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[13]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[14]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[15]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[16]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[17]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[18]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[19]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[20]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[21]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[22]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[23]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[24]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[25]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[26]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[27]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[28]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[29]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[2]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[30]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[31]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[32]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[33]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[34]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[35]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[3]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[4]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[5]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[6]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[7]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[8]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.apply.latency[9]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[10]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[11]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[12]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[13]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[14]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[15]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[16]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[17]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[18]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[19]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[1]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[20]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[21]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[22]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[23]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[24]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[25]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[26]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[27]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[28]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[29]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[2]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[30]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[31]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[32]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[33]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[34]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[35]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[3]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[4]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[5]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[6]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[7]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[8]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'ceph.dtac.osd.commit.latency[9]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sda,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sda,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sda,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sda,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdb,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdb,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdb,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdb,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdb,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdb,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdc,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdc,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdc,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdc,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdc,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdc,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdd,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdd,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdd,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdd,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdd,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdd,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sde,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sde,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sde,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sde,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sde,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sde,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdf,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdf,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdf,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdf,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdf,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdf,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdg,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdg,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdg,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdg,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdg,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdg,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdh,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdh,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdh,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdh,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdh,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdh,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdi,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdi,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdi,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdi,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdi,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdi,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdj,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdj,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdj,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdj,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdj,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdj,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdk,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdk,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdk,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdk,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdk,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdk,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdl,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdl,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdl,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdl,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdl,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdl,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdm,avgrq-sz]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdm,await]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdm,r/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdm,rkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdm,w/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'iostat[sdm,wkB/s]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-all,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-all,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-all]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-ex,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-ex,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-ex]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-int,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-int,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-int]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-tun,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-tun,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[br-tun]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[eno1,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[eno1,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[eno1]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[eno2,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[eno2,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[eno2]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens3f0,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens3f0,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens3f0]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens3f1,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens3f1,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens3f1]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens6f0,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens6f0,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens6f0]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens6f1,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens6f1,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[ens6f1]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan110,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan110,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan110]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan150,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan150,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan150]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan160,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan160,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan160]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan170,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan170,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.in[vlan170]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-all,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-all,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-all]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-ex,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-ex,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-ex]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-int,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-int,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-int]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-tun,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-tun,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[br-tun]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[eno1,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[eno1,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[eno1]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[eno2,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[eno2,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[eno2]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens3f0,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens3f0,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens3f0]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens3f1,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens3f1,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens3f1]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens6f0,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens6f0,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens6f0]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens6f1,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens6f1,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[ens6f1]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan110,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan110,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan110]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan150,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan150,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan150]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan160,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan160,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan160]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan170,dropped]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan170,errors]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'net.if.out[vlan170]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'system.cpu.util[,idle]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'system.cpu.util[,interrupt]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'system.cpu.util[,iowait]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'system.cpu.util[,nice]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'system.cpu.util[,softirq]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'system.cpu.util[,steal]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'system.cpu.util[,system]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'system.cpu.util[,user]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-1,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-1,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-1,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-10,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-10,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-10,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-11,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-11,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-11,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-12,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-12,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-12,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-13,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-13,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-13,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-14,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-14,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-14,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-15,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-15,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-15,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-16,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-16,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-16,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-17,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-17,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-17,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-18,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-18,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-18,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-19,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-19,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-19,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-2,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-2,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-2,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-20,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-20,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-20,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-21,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-21,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-21,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-22,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-22,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-22,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-23,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-23,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-23,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-24,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-24,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-24,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-25,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-25,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-25,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-26,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-26,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-26,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-27,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-27,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-27,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-28,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-28,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-28,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-29,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-29,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-29,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-3,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-3,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-3,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-30,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-30,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-30,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-31,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-31,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-31,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-32,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-32,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-32,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-33,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-33,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-33,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-34,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-34,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-34,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-35,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-35,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-35,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-4,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-4,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-4,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-5,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-5,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-5,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-6,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-6,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-6,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-7,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-7,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-7,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-8,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-8,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-8,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-9,pfree]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-9,total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vfs.fs.size[/var/lib/ceph/osd/ceph-9,used]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vm.memory.size[available]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_item_key', 'vm.memory.size[total]');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('zabbix_query_interval', '15');
INSERT INTO `config` (`config_key`, `config_value`) VALUES ('database_export_location', '/home/cbis_kpi/archive_table');


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
CREATE INDEX `cbis_virsh_list_2` ON `cbis_virsh_list` (`cbis_pod_id`,`hostname`);

CREATE TABLE `cbis_virsh_meta` (
	`cbis_pod_id`               bigint unsigned                           NOT NULL,
	`hostname`                  varchar(128)    DEFAULT ''                NOT NULL,
	`domain_name`               varchar(128)    DEFAULT ''                NOT NULL,
	`meta_key`                  varchar(128)    DEFAULT ''                NOT NULL,
	`meta_value`                varchar(128)    DEFAULT ''                NOT NULL
) ENGINE=InnoDB;
CREATE INDEX `cbis_virsh_meta_1` ON `cbis_virsh_meta` (`cbis_pod_id`,`hostname`, `domain_name`, `meta_key`);
CREATE INDEX `cbis_virsh_meta_2` ON `cbis_virsh_meta` (`cbis_pod_id`,`hostname`);


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