from ConfigParser import SafeConfigParser, NoSectionError, NoOptionError
import logging
import mysql.connector.pooling
import contextlib
from mysql.connector import errorcode
import re
import subprocess
import uuid

def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in xrange(0, len(l), n):
        yield l[i:i + n]


class Singleton(type):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
        return cls._instances[cls]


class ConfigError(Exception):
    """Invalid configuration."""
    pass


class Config(object):
    __metaclass__ = Singleton

    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)
        self._config_location = ['/Users/weerawit/Documents/Projects/Nokia/CloudBand/Client_Information/DTAC/workspaces/python/cbis_kpi/cbis_kpi/cbis_kpi.conf',
                                '/tmp/cbis_kpi.conf', '/etc/cbis_kpi/cbis_kpi.conf']
        self._config = SafeConfigParser()
        self._config.read(self._config_location)

    def get(self, section, option, default=None):
        try:
            return self._config.get(section, option)
        except NoSectionError:
            if default:
                return default
            self.log.exception('NoSectionError : %s' % section)
            raise ConfigError()
        except NoOptionError:
            if default:
                return default
            self.log.exception('NoOptionError : %s [%s]' % (option, section))
            raise ConfigError()

    def list(self, section):
        try:
            return self._config.items(section)
        except NoSectionError:
            self.log.exception('NoSectionError : %s' % section)
            raise ConfigError()


class DBConnection(object):
    __metaclass__ = Singleton

    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)
        self._config = Config()
        self._db_pool = self._create_db_pool()

    def get_connection(self):
        return contextlib.closing(self._create_db_pool().get_connection())

    def _create_db_pool(self):
        config_dict = {}
        for key, value in self._config.list('database'):
            if 'true' in value.lower() or 'false' in value.lower():
                config_dict[key] = bool(value)
            else:
                config_dict[key] = value

        pool_name = config_dict.pop('pool_name')
        pool_size = config_dict.pop('pool_size')

        try:

            return mysql.connector.pooling.MySQLConnectionPool(pool_name=pool_name,
                                                               pool_size=int(pool_size),
                                                               **config_dict)

        except mysql.connector.Error as err:
            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
                self.log.exception("Something is wrong with your user name or password")
            elif err.errno == errorcode.ER_BAD_DB_ERROR:
                self.log.exception("Database does not exist")
            else:
                self.log.exception(err)


class SshExecutor(object):

    def __init__(self, uc, username, **kwargs):
        self.log = logging.getLogger(self.__class__.__name__)
        self.test_flag = kwargs.pop('test_flag', False)
        self.uc = uc
        self.username = username
        self._kwargs = kwargs

    def _run_shell(self, cmd):

        self.log.info('Executing on %s with command %s' % (self.uc, cmd))

        if self.test_flag:
            ssh_cmd = cmd.split(' ')
        else:
            ssh_cmd = ["ssh", "-o", "LogLevel=error", "%s@%s" % (self.username, self.uc), cmd]

        return subprocess.Popen(ssh_cmd, stdout=subprocess.PIPE)

    def run(self, host_pattern, cmd, callback):

        temp_file_name = '/tmp/ssh_exe_%s' % str(uuid.uuid4())

        if host_pattern == '*':
            host_pattern = 'overcloud-*'
        if self.test_flag:
            cmd = cmd
        elif host_pattern == 'undercloud':
            cmd = 'echo \"hostname: `hostname`\"; %s ' % cmd
        else:
            cmd_host = 'grep -E \'%s\' /etc/hosts > %s' % (host_pattern, temp_file_name)
            self._run_shell(cmd_host).wait()

            cmd = "while read -r name <&3; do ssh -o ConnectTimeout=3 -o LogLevel=error " \
                  "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no " \
                  "cbis-admin@\"$name\" 'echo \"hostname: `hostname`\"; %s ' || true; done 3< %s" % (
                  cmd, temp_file_name)

        hostname_re = re.compile('hostname: ')

        proc = self._run_shell(cmd)
        stdout, stderr = proc.communicate()
        if proc.returncode == 0:
            lines = stdout.splitlines()
            i = 0
            while i < len(lines):
                line = lines[i]
                line_each_node = ''
                if hostname_re.search(line):
                    hostname = line.split(':')[1].strip()
                    i += 1
                    next_line = lines[i]
                    while not hostname_re.search(next_line):
                        line_each_node += '%s\n\r' % next_line
                        i += 1
                        try:
                            next_line = lines[i]
                        except IndexError:
                            break
                    callback(hostname, line_each_node, **self._kwargs)
                else:
                    i += 1

        else:
            self.log.error('Cannot execute command %s ' % cmd)
            raise RuntimeError('Cannot execute command %s ' % cmd)


if __name__ == '__main__':
    config = Config()
    print config.list('database')

    with DBConnection().get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute('select * from cbis_pod')
        for row in cursor:
            print row

