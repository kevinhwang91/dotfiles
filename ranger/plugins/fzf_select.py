import subprocess
import shutil
import os.path
from ranger.api.commands import Command


class FzfSelect(Command):
    """ FzfSelect

    Find a file using fzf.
    With a prefix argument select only directories.
    See: https://github.com/junegunn/fzf
    """

    def execute(self):
        fzf_cmd = 'fzf +m --height=100% --layout=default --info=default'
        if self.quantifier:
            # match only directories
            if shutil.which('fd'):
                command = r"fd -L . --type d | " + fzf_cmd
            else:
                command = r"find -L . -mindepth 1 \( -path '*/\.*' \
                -o -fstype 'dev' -o -fstype 'proc' \) -prune \
                -o -type d -print 2> /dev/null | cut -b3- | " + fzf_cmd
        else:
            # match files and directories
            if shutil.which('fd'):
                command = r"fd -L . | " + fzf_cmd
            else:
                command = r"find -L . -mindepth 1 \( -path '*/\.*' \
                -o -fstype 'dev' -o -fstype 'proc' \) -prune \
                -o -print 2> /dev/null | cut -b3- | " + fzf_cmd
        fzf = self.fm.execute_command(
            command, text=True, stdout=subprocess.PIPE)
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(fzf.stdout.readline().rstrip('\n'))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)
