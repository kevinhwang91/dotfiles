import os
import ranger.api
from shutil import which

if which('z.lua'):
    OLD_HOOK_READY = ranger.api.hook_ready

    def hook_ready(fm):

        def update_zlua(signal):
            fm.execute_command(['z.lua', '--add', signal.new.path], flags='s', wait=False)
        fm.signal_bind('cd', update_zlua)
        fm.execute_command(['z.lua', '--add', fm.thisdir.path], flags='s', wait=False)
        return OLD_HOOK_READY(fm)

    ranger.api.hook_ready = hook_ready


class Z(ranger.api.commands.Command):

    def execute(self):
        if not which('z.lua'):
            self.fm.notify('z.lua is not found.', bad=True)
            return
        arg1 = self.arg(1)
        if not arg1:
            return
        mode = None
        fzf_cmd = ['fzf', '--height=100%', '--layout=default', '--info=default', '--tac']
        if arg1 in ('--', '-l', '-t'):
            mode = arg1
        cmd = ['z.lua']
        import subprocess
        if mode:
            cmd += [mode]
            if mode == '--':
                cmd += ['-e']
            elif mode == '-t':
                cmd += ['-l']
            else:
                cmd += self.args[2:]
            with subprocess.Popen(cmd, text=True, stdout=subprocess.PIPE,
                                  stderr=subprocess.STDOUT) as src_pro:
                if mode == '-t':
                    sink_pro = self.fm.execute_command(
                        fzf_cmd, text=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                        wait=False)
                    import re
                    home_pat = '^' + os.getenv('HOME')
                    for line in src_pro.stdout.readlines():
                        path = line.split(None, 1)[1]
                        sink_pro.stdin.write(re.sub(home_pat, '~', path))
                        sink_pro.stdin.flush()
                    sink_pro.stdin.close()
                    sink_pro.wait()
                    path = sink_pro.stdout.readline().rstrip('\n')
                    path = os.path.expanduser(path)
                    if path and os.path.exists(path):
                        self.fm.cd(path)
                else:
                    self.fm.execute_command(['less', '-+FX', '+G'], stdin=src_pro.stdout)
        else:
            path = subprocess.check_output(
                cmd + ['-e'] + self.args[1:],
                env=dict(os.environ, PWD=self.fm.thisdir.path))
            path = path.decode('utf-8', 'ignore').rstrip('\n')
            if path and os.path.exists(path):
                self.fm.cd(path)
            else:
                self.fm.notify('No matching found', bad=True)
