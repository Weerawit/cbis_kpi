from ConfigParser import SafeConfigParser, NoSectionError, NoOptionError
import logging

import mysql.connector.pooling
from mysql.connector import errorcode


class ConfigError(Exception):
    """Invalid configuration."""
    pass


class Config(object):

    def __init__(self):
        self._config_location = ['/Users/weerawit/Documents/Projects/Nokia/CloudBand/Client_Information/DTAC/workspaces/python/cbis_kpi/src/cbis_kpi.conf',
                                '/tmp/cbis_kpi.conf', '/etc/cbis_kpi/cbis_kpi.conf']
        self._config = SafeConfigParser()
        self._config.read(self._config_location)
        self.log = logging.getLogger(self.__class__.__name__)
        self._db_pool = self._create_db_pool()

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

    def _create_db_pool(self):
        host = self.get('database', 'host')
        port = self.get('database', 'port', '3306')
        user = self.get('database', 'user')
        password = self.get('database', 'password')
        database = self.get('database', 'database')
        pool_name = self.get('database', 'pool_name')
        pool_size = self.get('database', 'pool_size', '20')

        try:
            return mysql.connector.connect(host=host, port=port, database=database, user=user, password=password,
                                           pool_name=pool_name, pool_size=int(pool_size))

        except mysql.connector.Error as err:
            if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
                self.log.exception("Something is wrong with your user name or password")
            elif err.errno == errorcode.ER_BAD_DB_ERROR:
                self.log.exception("Database does not exist")
            else:
                self.log.exception(err)

    def get_db_connect(self):
        return self._db_pool

    def __del__(self):
        self.log.info('closing database connection')
        self._db_pool.close()


if __name__ == '__main__':
    config = Config()
    print config.get('database', 'connection')

    conn = config.get_db_connect()
    cursor = conn.cursor()
    cursor.execute('select * from cbis_pod')
    for row in cursor:
        print row

