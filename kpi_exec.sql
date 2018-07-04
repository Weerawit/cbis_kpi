-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.5.52-MariaDB - MariaDB Server
-- Server OS:                    Linux
-- HeidiSQL Version:             9.5.0.5278
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for cbis_kpi
CREATE DATABASE IF NOT EXISTS `cbis_kpi` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;
USE `cbis_kpi`;

-- Dumping structure for view cbis_kpi.ceph_map
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `ceph_map` (
	`cbis_pod_id` BIGINT(20) UNSIGNED NOT NULL,
	`hostname` VARCHAR(128) NOT NULL COLLATE 'utf8_bin',
	`disk` VARCHAR(128) NOT NULL COLLATE 'utf8_bin',
	`journal` VARCHAR(128) NOT NULL COLLATE 'utf8_bin',
	`numosd` VARCHAR(128) NOT NULL COLLATE 'utf8_bin'
) ENGINE=MyISAM;

-- Dumping structure for procedure cbis_kpi.do_virsh_aggregate
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `do_virsh_aggregate`(
	IN `iDate` VARCHAR(50)










)
BEGIN

SET @reqdate = str_to_date(iDate,'%Y%m%d');
SET @enddate = unix_timestamp(DATE_ADD(@reqdate, INTERVAL 1 DAY));
SET @startdate = unix_timestamp(@reqdate);

DROP TABLE IF EXISTS virshraw;
CREATE TEMPORARY TABLE virshraw AS (
select
cbis_pod_id,
sdate,
stime,
sminute,
domain_name,
case
 when item_key = 'net.rx[bytes]' then 'net.rx[Bps]'
 when item_key = 'net.tx[bytes]' then 'net.tx[Bps]'
 when item_key = 'storage.read[bytes]' then 'storage.read[Bps]'
 when item_key = 'storage.write[bytes]' then 'storage.write[Bps]'
 else item_key
end as item_key,
case 
when item_key = 'vcpu[used]' then IFNULL(((sum(item_value) / (sum(clock_delta) * 1000000000)) * 100),0)
when item_key = 'vcpu[wait]' then IFNULL(((sum(item_value) / (sum(clock_delta) * 1000000000)) * 100),0)
when item_key = 'net.tx[bytes]' then IFNULL((sum(item_value) / sum(clock_delta)),0)
when item_key = 'net.rx[bytes]' then IFNULL((sum(item_value) / sum(clock_delta)),0)
when item_key = 'storage.read[bytes]' then IFNULL(((sum(item_value) / sum(clock_delta))),0)
when item_key = 'storage.write[bytes]' then IFNULL(((sum(item_value) / sum(clock_delta))),0)
when item_key = 'storage.read[busy]' then IFNULL(((sum(item_value) / (sum(clock_delta) * 1000000000)) * 100),0)
when item_key = 'storage.write[busy]' then IFNULL(((sum(item_value) / (sum(clock_delta) * 1000000000)) * 100),0)
else item_value
end as val
from
(
	select
	b.cbis_pod_id,
	date_format(from_unixtime(floor(b.clock)),'%Y%m%d') as sdate,
	date_format(from_unixtime(floor(b.clock)),'%H') as stime,
	date_format(from_unixtime(floor(b.clock)),'%i') as sminute,
	from_unixtime(floor(b.clock)) as clock,
	b.domain_name,
	case
	 WHEN b.item_key like 'vcpu.%.time' THEN 'vcpu[used]'
	 WHEN b.item_key like 'vcpu.%.wait' THEN 'vcpu[wait]'
	 WHEN b.item_key like 'net.%.tx.bytes' THEN 'net.tx[bytes]'
	 WHEN b.item_key like 'net.%.tx.drop' THEN 'net.tx[drop]'
	 WHEN b.item_key like 'net.%.tx.errs' THEN 'net.tx[error]'
	 WHEN b.item_key like 'net.%.tx.pkts' THEN 'net.tx[packet]'
	 WHEN b.item_key like 'net.%.rx.bytes' THEN 'net.rx[bytes]'
	 WHEN b.item_key like 'net.%.rx.drop' THEN 'net.rx[drop]'
	 WHEN b.item_key like 'net.%.rx.errs' THEN 'net.rx[error]'
	 WHEN b.item_key like 'net.%.rx.pkts' THEN 'net.rx[packet]'
	 WHEN b.item_key like 'block.%.rd.bytes' THEN 'storage.read[bytes]'
	 WHEN b.item_key like 'block.%.rd.times' THEN 'storage.read[busy]'
	 WHEN b.item_key like 'block.%.wr.bytes' THEN 'storage.write[bytes]'
	 WHEN b.item_key like 'block.%.wr.times' THEN 'storage.write[busy]' 
	 ELSE b.item_key
	END AS item_key,
	case
	 WHEN b.item_key like 'vcpu%' THEN cast( if(b.item_delta > (b.clock_delta * 1000000000),b.clock_delta * 1000000000,b.item_delta)  as decimal(20,3))
	 WHEN b.item_key like 'net%' THEN cast(b.item_delta as decimal(20,3))
	 WHEN b.item_key like 'block.%.times' THEN cast(b.item_delta as decimal(20,3))
	 ELSE IFNULL(cast(b.item_value as decimal(20,3)),0)
	END AS item_value,
	b.clock_delta
	from cbis_virsh_stat_raw b
	where b.clock between @startdate and @enddate
	and ( 
		item_key like 'vcpu.%.time' 
		or item_key like 'vcpu.%.wait' 
		or item_key like 'net.%.bytes' 
		or item_key like 'net.%.drop' 
		or item_key like 'net.%.errs' 
		or item_key like 'net.%.pkts' 
		or item_key like 'block.%.bytes' 
		or item_key like 'block.%.times' 
		or item_key like 'vcpu.maximum' 
		or item_key like 'balloon.current' 
		or item_key like 'net.count' 
		or item_key like 'memory.%' 
	)
) a
group by a.cbis_pod_id, a.clock, a.domain_name, a.item_key );


delete from virsh_raw_hourly where sdate = @reqdate;

insert into virsh_raw_hourly 
(select
a.cbis_pod_name,
b.sdate,
b.stime,
c.hostname,
c.vm_name,
b.domain_name,
c.vm_numa,
c.project_name,
'avg' as 'metrictype',
	cast(avg(case when b.item_key = 'vcpu[used]' then val end) as decimal(6,2)) as 'vcpu[used]',
	cast(avg(case when b.item_key = 'vcpu[wait]' then val end) as decimal(6,2)) as 'vcpu[wait]',
	cast(max(case WHEN b.item_key = 'vcpu.maximum' then val end) as int) as 'vcpu.maximum',
	cast(avg(case WHEN b.item_key = 'balloon.current' then val end)  / (1024 * 1024) as int) as 'memory.allocated',
	cast(avg(case WHEN b.item_key = 'memory.available' then val end)  / (1024 * 1024) as int) as 'memory.available',
	cast(avg(case WHEN b.item_key = 'memory.unused' then val end)  / (1024 * 1024) as int) as 'memory.unused',
	cast(avg(case WHEN b.item_key = 'memory.swap_out' then val end)  / (1024 * 1024) as int) as 'memory.swap_out',
	cast(max(case WHEN b.item_key = 'net.count' then val end) as int) as 'net.count',
	avg(case WHEN b.item_key = 'net.tx[Bps]' then val end) as 'net.tx[Bps]',
	cast(avg(case WHEN b.item_key = 'net.tx[drop]' then val end) as int) as 'net.tx[drop]',
	cast(avg(case WHEN b.item_key = 'net.tx[error]' then val end) as int) as 'net.tx[error]',
	cast(avg(case WHEN b.item_key = 'net.tx[packet]' then val end) as int) as 'net.tx[packet]',
	avg(case WHEN b.item_key = 'net.rx[Bps]' then val end) as 'net.rx[Bps]',
	cast(avg(case WHEN b.item_key = 'net.rx[drop]' then val end) as int) as 'net.rx[drop]',
	cast(avg(case WHEN b.item_key = 'net.rx[error]' then val end) as int) as 'net.rx[error]',
	cast(avg(case WHEN b.item_key = 'net.rx[packet]' then val end) as int) as 'net.rx[packet]',
	cast((avg(case WHEN b.item_key = 'storage.read[Bps]' then val end) / (1024 * 1024 )) as decimal (10,2)) as 'storage.read[MBs]',
	cast((avg(case WHEN b.item_key = 'storage.write[Bps]' then val end) / (1024 * 1024 )) as decimal (10,2)) as 'storage.write[MBs]',
	cast(avg(case WHEN b.item_key = 'storage.read[busy]' then val end) as decimal(6,2)) as 'storage.read[busy]',
	cast(avg(case WHEN b.item_key = 'storage.write[busy]' then val end) as decimal(6,2)) as 'storage.write[busy]'
from virshraw b
left join cbis_pod a on a.cbis_pod_id = b.cbis_pod_id
left join cbis_virsh_list c on b.domain_name = c.domain_name
group by b.cbis_pod_id, b.sdate, b.stime, b.domain_name
);

insert into virsh_raw_hourly
(select
a.cbis_pod_name,
b.sdate,
b.stime,
c.hostname,
c.vm_name,
b.domain_name,
c.vm_numa,
c.project_name,
'max' as 'metrictype',
	cast(max(case when b.item_key = 'vcpu[used]' then val end) as decimal(6,2)) as 'vcpu[used]',
	cast(max(case when b.item_key = 'vcpu[wait]' then val end) as decimal(6,2)) as 'vcpu[wait]',
	cast(max(case WHEN b.item_key = 'vcpu.maximum' then val end) as int) as 'vcpu.maximum',
	cast(max(case WHEN b.item_key = 'balloon.current' then val end)  / (1024 * 1024) as int) as 'memory.allocated',
	cast(max(case WHEN b.item_key = 'memory.available' then val end)  / (1024 * 1024) as int) as 'memory.available',
	cast(max(case WHEN b.item_key = 'memory.unused' then val end)  / (1024 * 1024) as int) as 'memory.unused',
	cast(max(case WHEN b.item_key = 'memory.swap_out' then val end)  / (1024 * 1024) as int) as 'memory.swap_out',
	cast(max(case WHEN b.item_key = 'net.count' then val end) as int) as 'net.count',
	max(case WHEN b.item_key = 'net.tx[Bps]' then val end) as 'net.tx[Bps]',
	cast(max(case WHEN b.item_key = 'net.tx[drop]' then val end) as int) as 'net.tx[drop]',
	cast(max(case WHEN b.item_key = 'net.tx[error]' then val end) as int) as 'net.tx[error]',
	cast(max(case WHEN b.item_key = 'net.tx[packet]' then val end) as int) as 'net.tx[packet]',
	max(case WHEN b.item_key = 'net.rx[Bps]' then val end) as 'net.rx[Bps]',
	cast(max(case WHEN b.item_key = 'net.rx[drop]' then val end) as int) as 'net.rx[drop]',
	cast(max(case WHEN b.item_key = 'net.rx[error]' then val end) as int) as 'net.rx[error]',
	cast(max(case WHEN b.item_key = 'net.rx[packet]' then val end) as int) as 'net.rx[packet]',
	cast((max(case WHEN b.item_key = 'storage.read[Bps]' then val end) / (1024 * 1024 )) as decimal (10,2)) as 'storage.read[MBs]',
	cast((max(case WHEN b.item_key = 'storage.write[Bps]' then val end) / (1024 * 1024 )) as decimal (10,2)) as 'storage.write[MBs]',
	cast(avg(case WHEN b.item_key = 'storage.read[busy]' then val end) as decimal(6,2)) as 'storage.read[busy]',
	cast(max(case WHEN b.item_key = 'storage.write[busy]' then val end) as decimal(6,2)) as 'storage.write[busy]'
from virshraw b
left join cbis_pod a on a.cbis_pod_id = b.cbis_pod_id
left join cbis_virsh_list c on b.domain_name = c.domain_name
group by b.cbis_pod_id, b.sdate, b.stime, b.domain_name
);

END//
DELIMITER ;

-- Dumping structure for procedure cbis_kpi.do_zabbix_aggregate
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `do_zabbix_aggregate`(
	IN `iDate` VARCHAR(50)





)
BEGIN
SET @reqdate = str_to_date(iDate,'%Y%m%d');
SET @enddate = unix_timestamp(DATE_ADD(@reqdate, INTERVAL 1 DAY));
SET @startdate = unix_timestamp(@reqdate);

DROP TABLE IF EXISTS zabbixhour;
CREATE TEMPORARY TABLE zabbixhour AS (
select
	date_format(DATE_ADD(from_unixtime(floor(clock)), INTERVAL 1 HOUR),'%Y%m%d') as sDate,
    date_format(DATE_ADD(from_unixtime(floor(clock)), INTERVAL 1 HOUR),'%H') as sTime,
    a.hostname,
    b.cbis_pod_name AS 'cbispod',
    a.cbis_pod_id AS 'cbispodid',
    SUBSTRING_INDEX(SUBSTRING_INDEX(a.hostname, '-', 2), '-', -1) AS 'nodetype',
    REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(a.hostname, '-', 3), '-', -1),".localdomain","") AS 'nodenumber',
    from_unixtime(floor(max(clock))) as 'time',
    count(hostname) as data_available,
	     item_key,
    cast(min(item_value) as decimal(20,2)) as min_value,
    cast(max(item_value) as decimal(20,2)) as max_value,
    cast(avg(item_value) as decimal(20,2)) as avg_value
		
		from cbis_zabbix_raw a
		left join cbis_pod b ON a.cbis_pod_id = b.cbis_pod_id
		where (clock between @startdate and @enddate)
		group by b.cbis_pod_name, a.hostname, sDate, sTime, a.item_key
);

delete from zabbixhour where time >= from_unixtime(floor(@enddate));

delete from rep_platform_hourly where time between from_unixtime(floor(@startdate)) and DATE_ADD(@reqdate, INTERVAL 1 DAY);

insert into rep_platform_hourly
(
select
  sDate,
   sTime,
    'avg' as 'metrictype',
    a.hostname,
     cbispod,
    SUBSTRING_INDEX(SUBSTRING_INDEX(a.hostname, '-', 2), '-', -1) AS 'nodetype',
    REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(a.hostname, '-', 3), '-', -1),".localdomain","") AS 'nodenumber',
    time,
    
		avg(case when item_key = 'system.cpu.util[,user]' then avg_value end) as 'system.cpu.util[,user]',
		avg(case when item_key = 'system.cpu.util[,system]' then avg_value end) as 'system.cpu.util[,system]',
		avg(case when item_key = 'system.cpu.util[,nice]' then avg_value end) as 'system.cpu.util[,nice]',
		avg(case when item_key = 'system.cpu.util[,iowait]' then avg_value end) as 'system.cpu.util[,iowait]',
		avg(case when item_key = 'system.cpu.util[,softirq]' then avg_value end) as 'system.cpu.util[,softirq]',
		avg(case when item_key = 'vm.memory.size[total]' then avg_value end) as 'vm.memory.size[total]',
		avg(case when item_key = 'vm.memory.size[available]' then avg_value end) as 'vm.memory.size[available]',
		avg(case when item_key = 'net.if.in[en0]' then avg_value end) as 'net.if.in[en0]',
		avg(case when item_key = 'net.if.out[en0]' then avg_value end) as 'net.if.out[en0]',
		avg(case when item_key = 'net.if.in[en0,errors]' then avg_value end) as 'net.if.in[en0,errors]',
		avg(case when item_key = 'net.if.out[en0,errors]' then avg_value end) as 'net.if.out[en0,errors]',
		avg(case when item_key = 'net.if.in[en0,dropped]' then avg_value end) as 'net.if.in[en0,dropped]',
		avg(case when item_key = 'net.if.out[en0,dropped]' then avg_value end) as 'net.if.out[en0,dropped]',
		avg(case when item_key = 'net.if.in[ens3f0]' then avg_value end) as 'net.if.in[ens3f0]',
		avg(case when item_key = 'net.if.out[ens3f0]' then avg_value end) as 'net.if.out[ens3f0]',
		avg(case when item_key = 'net.if.in[ens3f0,errors]' then avg_value end) as 'net.if.in[ens3f0,errors]',
		avg(case when item_key = 'net.if.out[ens3f0,errors]' then avg_value end) as 'net.if.out[ens3f0,errors]',
		avg(case when item_key = 'net.if.in[ens3f0,dropped]' then avg_value end) as 'net.if.in[ens3f0,dropped]',
		avg(case when item_key = 'net.if.out[ens3f0,dropped]' then avg_value end) as 'net.if.out[ens3f0,dropped]',
		avg(case when item_key = 'net.if.in[ens3f1]' then avg_value end) as 'net.if.in[ens3f1]',
		avg(case when item_key = 'net.if.out[ens3f1]' then avg_value end) as 'net.if.out[ens3f1]',
		avg(case when item_key = 'net.if.in[ens3f1,errors]' then avg_value end) as 'net.if.in[ens3f1,errors]',
		avg(case when item_key = 'net.if.out[ens3f1,errors]' then avg_value end) as 'net.if.out[ens3f1,errors]',
		avg(case when item_key = 'net.if.in[ens3f1,dropped]' then avg_value end) as 'net.if.in[ens3f1,dropped]',
		avg(case when item_key = 'net.if.out[ens3f1,dropped]' then avg_value end) as 'net.if.out[ens3f1,dropped]',
		avg(case when item_key = 'net.if.in[ens6f0]' then avg_value end) as 'net.if.in[ens6f0]',
		avg(case when item_key = 'net.if.out[ens6f0]' then avg_value end) as 'net.if.out[ens6f0]',
		avg(case when item_key = 'net.if.in[ens6f0,errors]' then avg_value end) as 'net.if.in[ens6f0,errors]',
		avg(case when item_key = 'net.if.out[ens6f0,errors]' then avg_value end) as 'net.if.out[ens6f0,errors]',
		avg(case when item_key = 'net.if.in[ens6f0,dropped]' then avg_value end) as 'net.if.in[ens6f0,dropped]',
		avg(case when item_key = 'net.if.out[ens6f0,dropped]' then avg_value end) as 'net.if.out[ens6f0,dropped]',
		avg(case when item_key = 'net.if.in[ens6f1]' then avg_value end) as 'net.if.in[ens6f1]',
		avg(case when item_key = 'net.if.out[ens6f1]' then avg_value end) as 'net.if.out[ens6f1]',
		avg(case when item_key = 'net.if.in[ens6f1,errors]' then avg_value end) as 'net.if.in[ens6f1,errors]',
		avg(case when item_key = 'net.if.out[ens6f1,errors]' then avg_value end) as 'net.if.out[ens6f1,errors]',
		avg(case when item_key = 'net.if.in[ens6f1,dropped]' then avg_value end) as 'net.if.in[ens6f1,dropped]',
		avg(case when item_key = 'net.if.out[ens6f1,dropped]' then avg_value end) as 'net.if.out[ens6f1,dropped]',
		avg(case when item_key = 'net.if.in[vlan110]' then avg_value end) as 'net.if.in[vlan110]',
		avg(case when item_key = 'net.if.out[vlan110]' then avg_value end) as 'net.if.out[vlan110]',
		avg(case when item_key = 'net.if.in[vlan110,errors]' then avg_value end) as 'net.if.in[vlan110,errors]',
		avg(case when item_key = 'net.if.out[vlan110,errors]' then avg_value end) as 'net.if.out[vlan110,errors]',
		avg(case when item_key = 'net.if.in[vlan110,dropped]' then avg_value end) as 'net.if.in[vlan110,dropped]',
		avg(case when item_key = 'net.if.out[vlan110,dropped]' then avg_value end) as 'net.if.out[vlan110,dropped]',
		avg(case when item_key = 'net.if.in[vlan140]' then avg_value end) as 'net.if.in[vlan140]',
		avg(case when item_key = 'net.if.out[vlan140]' then avg_value end) as 'net.if.out[vlan140]',
		avg(case when item_key = 'net.if.in[vlan140,errors]' then avg_value end) as 'net.if.in[vlan140,errors]',
		avg(case when item_key = 'net.if.out[vlan140,errors]' then avg_value end) as 'net.if.out[vlan140,errors]',
		avg(case when item_key = 'net.if.in[vlan140,dropped]' then avg_value end) as 'net.if.in[vlan140,dropped]',
		avg(case when item_key = 'net.if.out[vlan140,dropped]' then avg_value end) as 'net.if.out[vlan140,dropped]',
		avg(case when item_key = 'net.if.in[vlan150]' then avg_value end) as 'net.if.in[vlan150]',
		avg(case when item_key = 'net.if.out[vlan150]' then avg_value end) as 'net.if.out[vlan150]',
		avg(case when item_key = 'net.if.in[vlan150,errors]' then avg_value end) as 'net.if.in[vlan150,errors]',
		avg(case when item_key = 'net.if.out[vlan150,errors]' then avg_value end) as 'net.if.out[vlan150,errors]',
		avg(case when item_key = 'net.if.in[vlan150,dropped]' then avg_value end) as 'net.if.in[vlan150,dropped]',
		avg(case when item_key = 'net.if.out[vlan150,dropped]' then avg_value end) as 'net.if.out[vlan150,dropped]',
		avg(case when item_key = 'net.if.in[vlan160]' then avg_value end) as 'net.if.in[vlan160]',
		avg(case when item_key = 'net.if.out[vlan160]' then avg_value end) as 'net.if.out[vlan160]',
		avg(case when item_key = 'net.if.in[vlan160,errors]' then avg_value end) as 'net.if.in[vlan160,errors]',
		avg(case when item_key = 'net.if.out[vlan160,errors]' then avg_value end) as 'net.if.out[vlan160,errors]',
		avg(case when item_key = 'net.if.in[vlan160,dropped]' then avg_value end) as 'net.if.in[vlan160,dropped]',
		avg(case when item_key = 'net.if.out[vlan160,dropped]' then avg_value end) as 'net.if.out[vlan160,dropped]',
		avg(case when item_key = 'net.if.in[vlan170]' then avg_value end) as 'net.if.in[vlan170]',
		avg(case when item_key = 'net.if.out[vlan170]' then avg_value end) as 'net.if.out[vlan170]',
		avg(case when item_key = 'net.if.in[vlan170,errors]' then avg_value end) as 'net.if.in[vlan170,errors]',
		avg(case when item_key = 'net.if.out[vlan170,errors]' then avg_value end) as 'net.if.out[vlan170,errors]',
		avg(case when item_key = 'net.if.in[vlan170,dropped]' then avg_value end) as 'net.if.in[vlan170,dropped]',
		avg(case when item_key = 'net.if.out[vlan170,dropped]' then avg_value end) as 'net.if.out[vlan170,dropped]'
		from zabbixhour a
	#	where sdate = @iDate
		group by cbispod, hostname, sDate, sTime
		);
		
insert into rep_platform_hourly
(
  select
  sDate,
   sTime,
    'max' as 'metrictype',
    a.hostname,
     cbispod,
    SUBSTRING_INDEX(SUBSTRING_INDEX(a.hostname, '-', 2), '-', -1) AS 'nodetype',
    REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(a.hostname, '-', 3), '-', -1),".localdomain","") AS 'nodenumber',
    time,
    
		max(case when item_key = 'system.cpu.util[,user]' then max_value end) as 'system.cpu.util[,user]',
		max(case when item_key = 'system.cpu.util[,system]' then max_value end) as 'system.cpu.util[,system]',
		max(case when item_key = 'system.cpu.util[,nice]' then max_value end) as 'system.cpu.util[,nice]',
		max(case when item_key = 'system.cpu.util[,iowait]' then max_value end) as 'system.cpu.util[,iowait]',
		max(case when item_key = 'system.cpu.util[,softirq]' then max_value end) as 'system.cpu.util[,softirq]',
		max(case when item_key = 'vm.memory.size[total]' then max_value end) as 'vm.memory.size[total]',
		max(case when item_key = 'vm.memory.size[available]' then max_value end) as 'vm.memory.size[available]',
		max(case when item_key = 'net.if.in[en0]' then max_value end) as 'net.if.in[en0]',
		max(case when item_key = 'net.if.out[en0]' then max_value end) as 'net.if.out[en0]',
		max(case when item_key = 'net.if.in[en0,errors]' then max_value end) as 'net.if.in[en0,errors]',
		max(case when item_key = 'net.if.out[en0,errors]' then max_value end) as 'net.if.out[en0,errors]',
		max(case when item_key = 'net.if.in[en0,dropped]' then max_value end) as 'net.if.in[en0,dropped]',
		max(case when item_key = 'net.if.out[en0,dropped]' then max_value end) as 'net.if.out[en0,dropped]',
		max(case when item_key = 'net.if.in[ens3f0]' then max_value end) as 'net.if.in[ens3f0]',
		max(case when item_key = 'net.if.out[ens3f0]' then max_value end) as 'net.if.out[ens3f0]',
		max(case when item_key = 'net.if.in[ens3f0,errors]' then max_value end) as 'net.if.in[ens3f0,errors]',
		max(case when item_key = 'net.if.out[ens3f0,errors]' then max_value end) as 'net.if.out[ens3f0,errors]',
		max(case when item_key = 'net.if.in[ens3f0,dropped]' then max_value end) as 'net.if.in[ens3f0,dropped]',
		max(case when item_key = 'net.if.out[ens3f0,dropped]' then max_value end) as 'net.if.out[ens3f0,dropped]',
		max(case when item_key = 'net.if.in[ens3f1]' then max_value end) as 'net.if.in[ens3f1]',
		max(case when item_key = 'net.if.out[ens3f1]' then max_value end) as 'net.if.out[ens3f1]',
		max(case when item_key = 'net.if.in[ens3f1,errors]' then max_value end) as 'net.if.in[ens3f1,errors]',
		max(case when item_key = 'net.if.out[ens3f1,errors]' then max_value end) as 'net.if.out[ens3f1,errors]',
		max(case when item_key = 'net.if.in[ens3f1,dropped]' then max_value end) as 'net.if.in[ens3f1,dropped]',
		max(case when item_key = 'net.if.out[ens3f1,dropped]' then max_value end) as 'net.if.out[ens3f1,dropped]',
		max(case when item_key = 'net.if.in[ens6f0]' then max_value end) as 'net.if.in[ens6f0]',
		max(case when item_key = 'net.if.out[ens6f0]' then max_value end) as 'net.if.out[ens6f0]',
		max(case when item_key = 'net.if.in[ens6f0,errors]' then max_value end) as 'net.if.in[ens6f0,errors]',
		max(case when item_key = 'net.if.out[ens6f0,errors]' then max_value end) as 'net.if.out[ens6f0,errors]',
		max(case when item_key = 'net.if.in[ens6f0,dropped]' then max_value end) as 'net.if.in[ens6f0,dropped]',
		max(case when item_key = 'net.if.out[ens6f0,dropped]' then max_value end) as 'net.if.out[ens6f0,dropped]',
		max(case when item_key = 'net.if.in[ens6f1]' then max_value end) as 'net.if.in[ens6f1]',
		max(case when item_key = 'net.if.out[ens6f1]' then max_value end) as 'net.if.out[ens6f1]',
		max(case when item_key = 'net.if.in[ens6f1,errors]' then max_value end) as 'net.if.in[ens6f1,errors]',
		max(case when item_key = 'net.if.out[ens6f1,errors]' then max_value end) as 'net.if.out[ens6f1,errors]',
		max(case when item_key = 'net.if.in[ens6f1,dropped]' then max_value end) as 'net.if.in[ens6f1,dropped]',
		max(case when item_key = 'net.if.out[ens6f1,dropped]' then max_value end) as 'net.if.out[ens6f1,dropped]',
		max(case when item_key = 'net.if.in[vlan110]' then max_value end) as 'net.if.in[vlan110]',
		max(case when item_key = 'net.if.out[vlan110]' then max_value end) as 'net.if.out[vlan110]',
		max(case when item_key = 'net.if.in[vlan110,errors]' then max_value end) as 'net.if.in[vlan110,errors]',
		max(case when item_key = 'net.if.out[vlan110,errors]' then max_value end) as 'net.if.out[vlan110,errors]',
		max(case when item_key = 'net.if.in[vlan110,dropped]' then max_value end) as 'net.if.in[vlan110,dropped]',
		max(case when item_key = 'net.if.out[vlan110,dropped]' then max_value end) as 'net.if.out[vlan110,dropped]',
		max(case when item_key = 'net.if.in[vlan140]' then max_value end) as 'net.if.in[vlan140]',
		max(case when item_key = 'net.if.out[vlan140]' then max_value end) as 'net.if.out[vlan140]',
		max(case when item_key = 'net.if.in[vlan140,errors]' then max_value end) as 'net.if.in[vlan140,errors]',
		max(case when item_key = 'net.if.out[vlan140,errors]' then max_value end) as 'net.if.out[vlan140,errors]',
		max(case when item_key = 'net.if.in[vlan140,dropped]' then max_value end) as 'net.if.in[vlan140,dropped]',
		max(case when item_key = 'net.if.out[vlan140,dropped]' then max_value end) as 'net.if.out[vlan140,dropped]',
		max(case when item_key = 'net.if.in[vlan150]' then max_value end) as 'net.if.in[vlan150]',
		max(case when item_key = 'net.if.out[vlan150]' then max_value end) as 'net.if.out[vlan150]',
		max(case when item_key = 'net.if.in[vlan150,errors]' then max_value end) as 'net.if.in[vlan150,errors]',
		max(case when item_key = 'net.if.out[vlan150,errors]' then max_value end) as 'net.if.out[vlan150,errors]',
		max(case when item_key = 'net.if.in[vlan150,dropped]' then max_value end) as 'net.if.in[vlan150,dropped]',
		max(case when item_key = 'net.if.out[vlan150,dropped]' then max_value end) as 'net.if.out[vlan150,dropped]',
		max(case when item_key = 'net.if.in[vlan160]' then max_value end) as 'net.if.in[vlan160]',
		max(case when item_key = 'net.if.out[vlan160]' then max_value end) as 'net.if.out[vlan160]',
		max(case when item_key = 'net.if.in[vlan160,errors]' then max_value end) as 'net.if.in[vlan160,errors]',
		max(case when item_key = 'net.if.out[vlan160,errors]' then max_value end) as 'net.if.out[vlan160,errors]',
		max(case when item_key = 'net.if.in[vlan160,dropped]' then max_value end) as 'net.if.in[vlan160,dropped]',
		max(case when item_key = 'net.if.out[vlan160,dropped]' then max_value end) as 'net.if.out[vlan160,dropped]',
		max(case when item_key = 'net.if.in[vlan170]' then max_value end) as 'net.if.in[vlan170]',
		max(case when item_key = 'net.if.out[vlan170]' then max_value end) as 'net.if.out[vlan170]',
		max(case when item_key = 'net.if.in[vlan170,errors]' then max_value end) as 'net.if.in[vlan170,errors]',
		max(case when item_key = 'net.if.out[vlan170,errors]' then max_value end) as 'net.if.out[vlan170,errors]',
		max(case when item_key = 'net.if.in[vlan170,dropped]' then max_value end) as 'net.if.in[vlan170,dropped]',
		max(case when item_key = 'net.if.out[vlan170,dropped]' then max_value end) as 'net.if.out[vlan170,dropped]'
		  from zabbixhour a
	#	  where sdate = @iDate
		   group by cbispod, hostname, sDate, sTime
			)
			;


delete from rep_osd_hourly where time between DATE_ADD(from_unixtime(floor(@startdate)), INTERVAL -10 MINUTE) and DATE_ADD(@reqdate, INTERVAL 1 DAY);

insert into rep_osd_hourly
(
select 
sDate,
sTime,
max(time) as time,
cbispod,
b.hostname,
CASE
 WHEN b.item_key like 'ceph.dtac.osd.apply.latency%' THEN REPLACE(REPLACE(b.item_key,'ceph.dtac.osd.apply.latency[',''),']','')
 WHEN b.item_key like 'ceph.dtac.osd.commit.latency%' THEN REPLACE(REPLACE(b.item_key,'ceph.dtac.osd.commit.latency[',''),']','')
 WHEN b.item_key like 'vfs.fs.size%' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(b.item_key, '-', -1), ',', 1)
 when b.item_key like 'iostat%' then c.numosd 
END AS node_number,
'avg' as metrictype,
	avg(case WHEN b.item_key like 'ceph.dtac.osd.apply.latency%' THEN b.avg_value end) as 'ceph.dtac.osd.apply.latency',
	avg(case WHEN b.item_key like 'ceph.dtac.osd.commit.latency%' THEN b.avg_value end) as 'ceph.dtac.osd.commit.latency', 
	sum(case WHEN b.item_key like 'vfs.fs.size%total%' THEN b.avg_value end)/(1024*1024*1024) as 'ceph.dtac.osd.total',
	sum(case WHEN b.item_key like 'vfs.fs.size%used%' THEN b.avg_value end)/(1024*1024*1024) as 'ceph.dtac.osd.used',
	avg(case WHEN b.item_key like 'vfs.fs.size%free%' THEN b.avg_value end) as 'ceph.dtac.osd.free',
	avg(case WHEN b.item_key like 'iostat%await%' THEN b.avg_value end) as 'ceph.dtac.osd.await',
	avg(case WHEN b.item_key like 'iostat%r/s%' THEN b.avg_value end) as 'ceph.dtac.osd.r/s',
	avg(case WHEN b.item_key like 'iostat%rkB/s%' THEN b.avg_value end)/(1024*1024) as 'ceph.dtac.osd.rmB/s',
	avg(case WHEN b.item_key like 'iostat%w/s%' THEN b.avg_value end) as 'ceph.dtac.osd.w/s',
	avg(case WHEN b.item_key like 'iostat%wkB/s%' THEN b.avg_value end)/(1024*1024) as 'ceph.dtac.osd.wmB/s'
from
(
	select
	cbispodid,
	cbispod,
	a.hostname,
	sDate,
	sTime,
	time,
	case when a.item_key like 'iostat%' then REPLACE(SUBSTRING_INDEX(a.item_key, ',', 1),'iostat[','') else NULL end as disknum,
	a.item_key,
	a.avg_value
	from zabbixhour a
	where (a.item_key like 'ceph.dtac.osd%' or a.item_key like 'vfs.fs.size%' or a.item_key like 'iostat%') 
) b 
left join ceph_map c on b.hostname = c.hostname and b.disknum = c.disk and b.cbispodid = c.cbis_pod_id
group by node_number, sDate, sTime
);

insert into rep_osd_hourly
select 
sDate,
sTime,
max(time) as time,
cbispod,
b.hostname,
CASE
 WHEN b.item_key like 'ceph.dtac.osd.apply.latency%' THEN REPLACE(REPLACE(b.item_key,'ceph.dtac.osd.apply.latency[',''),']','')
 WHEN b.item_key like 'ceph.dtac.osd.commit.latency%' THEN REPLACE(REPLACE(b.item_key,'ceph.dtac.osd.commit.latency[',''),']','')
 WHEN b.item_key like 'vfs.fs.size%' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(b.item_key, '-', -1), ',', 1)
 when b.item_key like 'iostat%' then c.numosd 
END AS node_number,
   'max' as metrictype,
	max(case WHEN b.item_key like 'ceph.dtac.osd.apply.latency%' THEN b.max_value end) as 'ceph.dtac.osd.apply.latency',
	max(case WHEN b.item_key like 'ceph.dtac.osd.commit.latency%' THEN b.max_value end) as 'ceph.dtac.osd.commit.latency', 
	sum(case WHEN b.item_key like 'vfs.fs.size%total%' THEN b.max_value end)/(1024*1024*1024) as 'ceph.dtac.osd.total',
	sum(case WHEN b.item_key like 'vfs.fs.size%used%' THEN b.max_value end)/(1024*1024*1024) as 'ceph.dtac.osd.used',
	max(case WHEN b.item_key like 'vfs.fs.size%free%' THEN b.max_value end) as 'ceph.dtac.osd.free',
	max(case WHEN b.item_key like 'iostat%await%' THEN b.max_value end) as 'ceph.dtac.osd.await',
	max(case WHEN b.item_key like 'iostat%r/s%' THEN b.max_value end) as 'ceph.dtac.osd.r/s',
	max(case WHEN b.item_key like 'iostat%rkB/s%' THEN b.max_value end)/(1024*1024) as 'ceph.dtac.osd.rmB/s',
	max(case WHEN b.item_key like 'iostat%w/s%' THEN b.max_value end) as 'ceph.dtac.osd.w/s',
	max(case WHEN b.item_key like 'iostat%wkB/s%' THEN b.max_value end)/(1024*1024) as 'ceph.dtac.osd.wmB/s'
from
(
	select
	cbispodid,
	cbispod,
	a.hostname,
	sDate,
	sTime,
	time,
	case when a.item_key like 'iostat%' then REPLACE(SUBSTRING_INDEX(a.item_key, ',', 1),'iostat[','') else NULL end as disknum,
	a.item_key,
	a.max_value
	from zabbixhour a
	where (a.item_key like 'ceph.dtac.osd%' or a.item_key like 'vfs.fs.size%' or a.item_key like 'iostat%')
) b 
left join ceph_map c on b.hostname = c.hostname and b.disknum = c.disk and b.cbispodid = c.cbis_pod_id
group by node_number, sDate, sTime;
END//
DELIMITER ;

-- Dumping structure for table cbis_kpi.rep_osd_hourly
CREATE TABLE IF NOT EXISTS `rep_osd_hourly` (
  `sDate` varchar(10) CHARACTER SET utf8mb4 NOT NULL,
  `sTime` varchar(5) CHARACTER SET utf8mb4 NOT NULL,
  `time` datetime NOT NULL,
  `cbispod` varchar(150) COLLATE utf8_bin NOT NULL,
  `hostname` varchar(150) COLLATE utf8_bin NOT NULL,
  `node_number` varchar(10) COLLATE utf8_bin DEFAULT NULL,
  `metrictype` varchar(5) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `ceph.dtac.osd.apply.latency` float DEFAULT NULL,
  `ceph.dtac.osd.commit.latency` float DEFAULT NULL,
  `ceph.dtac.osd.total` float DEFAULT NULL,
  `ceph.dtac.osd.used` float DEFAULT NULL,
  `ceph.dtac.osd.free` float DEFAULT NULL,
  `ceph.dtac.osd.await` float DEFAULT NULL,
  `ceph.dtac.osd.r/s` float DEFAULT NULL,
  `ceph.dtac.osd.rmB/s` float DEFAULT NULL,
  `ceph.dtac.osd.w/s` float DEFAULT NULL,
  `ceph.dtac.osd.wmB/s` float DEFAULT NULL,
  UNIQUE KEY `uniqTime` (`sDate`,`sTime`,`cbispod`,`node_number`,`metrictype`),
  KEY `sDate` (`sDate`),
  KEY `sTime` (`sTime`,`sDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- Data exporting was unselected.
-- Dumping structure for table cbis_kpi.rep_platform_hourly
CREATE TABLE IF NOT EXISTS `rep_platform_hourly` (
  `sDate` varchar(10) CHARACTER SET utf8mb4 NOT NULL,
  `sTime` varchar(10) CHARACTER SET utf8mb4 NOT NULL,
  `metrictype` varchar(10) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `hostname` varchar(150) COLLATE utf8_bin NOT NULL DEFAULT '',
  `cbispod` varchar(150) COLLATE utf8_bin NOT NULL,
  `nodetype` varchar(150) COLLATE utf8_bin NOT NULL DEFAULT '',
  `nodenumber` varchar(10) COLLATE utf8_bin NOT NULL DEFAULT '',
  `time` datetime DEFAULT NULL,
  `system.cpu.util[,user]` float DEFAULT NULL,
  `system.cpu.util[,system]` float DEFAULT NULL,
  `system.cpu.util[,nice]` float DEFAULT NULL,
  `system.cpu.util[,iowait]` float DEFAULT NULL,
  `system.cpu.util[,softirq]` float DEFAULT NULL,
  `vm.memory.size[total]` float DEFAULT NULL,
  `vm.memory.size[available]` float DEFAULT NULL,
  `net.if.in[en0]` float DEFAULT NULL,
  `net.if.out[en0]` float DEFAULT NULL,
  `net.if.in[en0,errors]` float DEFAULT NULL,
  `net.if.out[en0,errors]` float DEFAULT NULL,
  `net.if.in[en0,dropped]` float DEFAULT NULL,
  `net.if.out[en0,dropped]` float DEFAULT NULL,
  `net.if.in[ens3f0]` float DEFAULT NULL,
  `net.if.out[ens3f0]` float DEFAULT NULL,
  `net.if.in[ens3f0,errors]` float DEFAULT NULL,
  `net.if.out[ens3f0,errors]` float DEFAULT NULL,
  `net.if.in[ens3f0,dropped]` float DEFAULT NULL,
  `net.if.out[ens3f0,dropped]` float DEFAULT NULL,
  `net.if.in[ens3f1]` float DEFAULT NULL,
  `net.if.out[ens3f1]` float DEFAULT NULL,
  `net.if.in[ens3f1,errors]` float DEFAULT NULL,
  `net.if.out[ens3f1,errors]` float DEFAULT NULL,
  `net.if.in[ens3f1,dropped]` float DEFAULT NULL,
  `net.if.out[ens3f1,dropped]` float DEFAULT NULL,
  `net.if.in[ens6f0]` float DEFAULT NULL,
  `net.if.out[ens6f0]` float DEFAULT NULL,
  `net.if.in[ens6f0,errors]` float DEFAULT NULL,
  `net.if.out[ens6f0,errors]` float DEFAULT NULL,
  `net.if.in[ens6f0,dropped]` float DEFAULT NULL,
  `net.if.out[ens6f0,dropped]` float DEFAULT NULL,
  `net.if.in[ens6f1]` float DEFAULT NULL,
  `net.if.out[ens6f1]` float DEFAULT NULL,
  `net.if.in[ens6f1,errors]` float DEFAULT NULL,
  `net.if.out[ens6f1,errors]` float DEFAULT NULL,
  `net.if.in[ens6f1,dropped]` float DEFAULT NULL,
  `net.if.out[ens6f1,dropped]` float DEFAULT NULL,
  `net.if.in[vlan110]` float DEFAULT NULL,
  `net.if.out[vlan110]` float DEFAULT NULL,
  `net.if.in[vlan110,errors]` float DEFAULT NULL,
  `net.if.out[vlan110,errors]` float DEFAULT NULL,
  `net.if.in[vlan110,dropped]` float DEFAULT NULL,
  `net.if.out[vlan110,dropped]` float DEFAULT NULL,
  `net.if.in[vlan140]` float DEFAULT NULL,
  `net.if.out[vlan140]` float DEFAULT NULL,
  `net.if.in[vlan140,errors]` float DEFAULT NULL,
  `net.if.out[vlan140,errors]` float DEFAULT NULL,
  `net.if.in[vlan140,dropped]` float DEFAULT NULL,
  `net.if.out[vlan140,dropped]` float DEFAULT NULL,
  `net.if.in[vlan150]` float DEFAULT NULL,
  `net.if.out[vlan150]` float DEFAULT NULL,
  `net.if.in[vlan150,errors]` float DEFAULT NULL,
  `net.if.out[vlan150,errors]` float DEFAULT NULL,
  `net.if.in[vlan150,dropped]` float DEFAULT NULL,
  `net.if.out[vlan150,dropped]` float DEFAULT NULL,
  `net.if.in[vlan160]` float DEFAULT NULL,
  `net.if.out[vlan160]` float DEFAULT NULL,
  `net.if.in[vlan160,errors]` float DEFAULT NULL,
  `net.if.out[vlan160,errors]` float DEFAULT NULL,
  `net.if.in[vlan160,dropped]` float DEFAULT NULL,
  `net.if.out[vlan160,dropped]` float DEFAULT NULL,
  `net.if.in[vlan170]` float DEFAULT NULL,
  `net.if.out[vlan170]` float DEFAULT NULL,
  `net.if.in[vlan170,errors]` float DEFAULT NULL,
  `net.if.out[vlan170,errors]` float DEFAULT NULL,
  `net.if.in[vlan170,dropped]` float DEFAULT NULL,
  `net.if.out[vlan170,dropped]` float DEFAULT NULL,
  UNIQUE KEY `uniqTime` (`sDate`,`sTime`,`metrictype`,`hostname`,`cbispod`),
  KEY `hostname` (`hostname`),
  KEY `cbispod` (`cbispod`,`hostname`),
  KEY `nodetype` (`nodetype`,`hostname`,`cbispod`),
  KEY `sDate` (`sDate`),
  KEY `sTime` (`sTime`,`sDate`),
  KEY `metrictype` (`metrictype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- Data exporting was unselected.
-- Dumping structure for table cbis_kpi.virsh_raw_hourly
CREATE TABLE IF NOT EXISTS `virsh_raw_hourly` (
  `cbis_pod_name` varchar(128) COLLATE utf8_bin DEFAULT '',
  `sdate` varchar(8) CHARACTER SET utf8mb4 DEFAULT NULL,
  `stime` varchar(7) CHARACTER SET utf8mb4 DEFAULT NULL,
  `hostname` varchar(128) COLLATE utf8_bin DEFAULT '',
  `vm_name` varchar(128) COLLATE utf8_bin DEFAULT '',
  `domain_name` varchar(128) COLLATE utf8_bin NOT NULL DEFAULT '',
  `vm_numa` varchar(128) COLLATE utf8_bin DEFAULT '',
  `project_name` varchar(128) COLLATE utf8_bin DEFAULT '',
  `metrictype` varchar(128) COLLATE utf8_bin DEFAULT '',
  `vcpu[used]` decimal(6,2) DEFAULT NULL,
  `vcpu[wait]` decimal(6,2) DEFAULT NULL,
  `vcpu.maximum` bigint(21) DEFAULT NULL,
  `memory.allocated` bigint(21) DEFAULT NULL,
  `memory.available` bigint(21) DEFAULT NULL,
  `memory.unused` bigint(21) DEFAULT NULL,
  `memory.swap_out` bigint(21) DEFAULT NULL,
  `net.count` bigint(21) DEFAULT NULL,
  `net.tx[Bps]` decimal(53,11) DEFAULT NULL,
  `net.tx[drop]` bigint(21) DEFAULT NULL,
  `net.tx[error]` bigint(21) DEFAULT NULL,
  `net.tx[packet]` bigint(21) DEFAULT NULL,
  `net.rx[Bps]` decimal(53,11) DEFAULT NULL,
  `net.rx[drop]` bigint(21) DEFAULT NULL,
  `net.rx[error]` bigint(21) DEFAULT NULL,
  `net.rx[packet]` bigint(21) DEFAULT NULL,
  `storage.read[MBs]` decimal(10,2) DEFAULT NULL,
  `storage.write[MBs]` decimal(10,2) DEFAULT NULL,
  `storage.read[busy]` decimal(6,2) DEFAULT NULL,
  `storage.write[busy]` decimal(6,2) DEFAULT NULL,
  KEY `sdate` (`sdate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- Data exporting was unselected.
-- Dumping structure for view cbis_kpi.ceph_map
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `ceph_map`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ceph_map` AS select `cbis_ceph_disk`.`cbis_pod_id` AS `cbis_pod_id`,`cbis_ceph_disk`.`hostname` AS `hostname`,replace(substring_index(`cbis_ceph_disk`.`disk`,'/',-(1)),'1','') AS `disk`,substring_index(`cbis_ceph_disk`.`journal`,'/',-(1)) AS `journal`,substring_index(`cbis_ceph_disk`.`osd`,'.',-(1)) AS `numosd` from `cbis_ceph_disk`;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
