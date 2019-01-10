import subprocess
import os.path
from ranger.api.commands import Command


class GitRoot(Command):
    """GitRoot

    """

    def execute(self):
        git_root = subprocess.Popen(
            'git rev-parse --show-toplevel', universal_newlines=True, shell=True,
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        stdout = git_root.communicate()[0]
        if git_root.returncode == 0:
            git_root_path = os.path.abspath(stdout.rstrip('\n'))
            self.fm.cd(git_root_path)
