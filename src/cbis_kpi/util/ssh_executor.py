import logging
import re
import subprocess
import uuid


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
                  "cbis-admin@\"$name\" 'echo \"hostname: `hostname`\"; %s ' || true; done 3< %s" % (cmd, temp_file_name)

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