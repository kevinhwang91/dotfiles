import sys
import os
import random
import subprocess
import ranger.api

OLD_HOOK_INIT = ranger.api.hook_init

PATH_LUA = os.environ.get('RANGER_LUA')
PATH_ZLUA = os.environ.get('RANGER_ZLUA')

if not PATH_LUA:
    for path in os.environ.get('PATH', '').split(os.path.pathsep):
        for name in ('lua', 'luajit', 'lua5.3', 'lua5.2', 'lua5.1'):
            test = os.path.join(path, name)
            test = test + (sys.platform[:3] == 'win' and ".exe" or "")
            if os.path.exists(test):
                PATH_LUA = test
                break


def hook_init(fm):

    def update_zlua(signal):
        os.environ['_ZL_RANDOM'] = str(random.randint(0, 0x7fffffff))
        z_p = subprocess.Popen([PATH_LUA, PATH_ZLUA, "--add", signal.new.path])
        z_p.wait()
    if PATH_ZLUA and PATH_LUA and os.path.exists(PATH_ZLUA):
        fm.signal_bind('cd', update_zlua)
    return OLD_HOOK_INIT(fm)


ranger.api.hook_init = hook_init


class Z(ranger.api.commands.Command):

    def execute(self):
        if (not PATH_ZLUA) or (not os.path.exists(PATH_ZLUA)):
            self.fm.notify(
                'Not find z.lua, please set $RANGER_ZLUA to absolute path of z.lua.\n')
            return
        args = self.args[1:]
        if args:
            mode = ''
            for arg in args:
                if arg in ('-l', '-e', '-x', '-h', '--help', '--', '-s', '-g'):
                    mode = arg
                    break
                if arg in ('-I', '-i'):
                    mode = arg
                elif arg[:1] != '-':
                    break
            if mode:
                cmd = '"%s" "%s" ' % (PATH_LUA, PATH_ZLUA)
                if mode in ('-I', '-i', '--'):
                    cmd += ' --cd'
                if mode not in ('-s', '-g'):
                    for arg in args:
                        cmd += ' "%s"' % arg
                if mode in ('-e', '-x'):
                    path = subprocess.check_output(
                        [PATH_LUA, PATH_ZLUA, '--cd'] + args)
                    path = path.decode("utf-8", "ignore")
                    path = path.rstrip('\n')
                    self.fm.notify(path)
                elif mode in ('-h', '-l', '--help'):
                    pro = self.fm.execute_command(
                        cmd + '| less +G', universal_newlines=True)
                    stdout = pro.communicate()[0]
                elif mode in ('-s', '-g'):
                    if mode == '-g':
                        pro = self.fm.execute_command(
                            cmd +
                            r' -l 2>&1 | fzf -n2..,.. --tac +s -e | sed "s/^\s*[0-9,.]* *//"',
                            universal_newlines=True, stdout=subprocess.PIPE)
                        stdout = pro.communicate()[0]
                        path = stdout.rstrip('\n')
                    elif mode == '-s':
                        pro = self.fm.execute_command(
                            cmd +
                            r' --cd -- 2>&1 | fzf | sed "s/^\s*[0-9,.]* *//"',
                            universal_newlines=True, stdout=subprocess.PIPE)
                        stdout = pro.communicate()[0]
                        path = stdout.rstrip('\n')
                    if path and os.path.exists(path):
                        self.fm.cd(path)
                else:
                    if mode == '-I':
                        os.environ['_ZL_FZF_HEIGHT'] = '0'
                        path = subprocess.check_output(
                            [PATH_LUA, PATH_ZLUA, '--cd'] + args)
                        path = path.decode("utf-8", "ignore")
                        self.fm.execute_console('redraw_window')
                    elif mode == '--':
                        pro = self.fm.execute_command(
                            cmd + " 2>&1 | fzf | awk '{print $2}'",
                            universal_newlines=True, stdout=subprocess.PIPE)
                        stdout = pro.communicate()[0]
                        path = stdout.rstrip('\n')
                    else:
                        pro = self.fm.execute_command(
                            cmd, universal_newlines=True, stdout=subprocess.PIPE)
                        stdout = pro.communicate()[0]
                        path = stdout.rstrip('\n')
                    if path and os.path.exists(path):
                        self.fm.cd(path)
            else:
                path = subprocess.check_output(
                    [PATH_LUA, PATH_ZLUA, '--cd'] + args)
                path = path.decode("utf-8", "ignore")
                path = path.rstrip('\n')
                if path and os.path.exists(path):
                    self.fm.cd(path)
                else:
                    self.fm.notify('No matching found', bad=True)
        return True
