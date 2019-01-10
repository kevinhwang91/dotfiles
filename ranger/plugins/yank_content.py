import os
import subprocess
from ranger.api.commands import Command
from ranger.container.file import File
from ranger.ext.get_executables import get_executables


class YankContent(Command):
    """Copy the content of image file and text file with xclip

    """

    def execute(self):
        if 'xclip' not in get_executables():
            self.fm.notify('xclip is not found.', bad=True)
            return

        arg = self.rest(1)
        if arg:
            if not os.path.isfile(arg):
                self.fm.notify('{} is not a file.'.format(arg))
                return
            file = File(arg)
        else:
            file = self.fm.thisfile
            if not file.is_file:
                self.fm.notify('{} is not a file.'.format(file.relative_path))
                return

        relative_path = file.relative_path
        cmd = ['xclip', '-selection', 'clipboard']
        if not file.is_binary():
            with open(file.path, 'rb') as fd:
                subprocess.check_call(cmd, stdin=fd)
        elif file.image:
            cmd += ['-t', file.mimetype, file.path]
            subprocess.check_call(cmd)
            self.fm.notify('Content of {} is copied to x clipboard'.format(relative_path))
        else:
            self.fm.notify('{} is not an image file or a text file.'.format(relative_path))

    def tab(self, tabnum):
        return self._tab_directory_content()
