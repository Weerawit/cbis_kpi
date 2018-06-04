from ConfigParser import SafeConfigParser, NoSectionError, NoOptionError
import logging
import mysql.connector.pooling
import contextlib
from mysql.connector import errorcode


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


if __name__ == '__main__':
    config = Config()
    print config.list('database')

    with DBConnection().get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute('select * from cbis_pod')
        for row in cursor:
            print row

