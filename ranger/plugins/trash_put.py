import os
import shlex
from functools import partial
from ranger.api.commands import Command


class TrashPut(Command):
    """Move the selection or the files to the trash

    """

    def __init__(self, line, quantifier=None):
        Command.__init__(self, line, quantifier)
        self.trash_put = None
        try:
            from trashcli import put
            from trashcli import fstab
            #  Make stdout and stderr are None
            self.trash_put = put.TrashPutCmd(
                None, None, os.environ, fstab.volume_of, put.parent_path,
                os.path.realpath)
        except ImportError:
            pass

    def execute(self):

        if not self.trash_put:
            self.fm.notify('Error: no trashcli module found!', bad=True)
            return

        def is_directory_with_files(path):
            return os.path.isdir(path) and not os.path.islink(path) and len(os.listdir(path)) > 0

        args = ['trash']
        if self.rest(1):
            files = shlex.split(self.rest(1))
            many_files = (len(files) > 1 or is_directory_with_files(files[0]))
        else:
            cwd = self.fm.thisdir
            tfile = self.fm.thisfile
            if not cwd or not tfile:
                self.fm.notify('Error: no file selected!', bad=True)
                return

            # relative_path used for a user-friendly output in the confirmation.
            files = [f.relative_path for f in self.fm.thistab.get_selection()]
            many_files = (cwd.marked_items or is_directory_with_files(tfile.path))

        args += files
        confirm = self.fm.settings.confirm_on_delete
        if confirm != 'never' and (confirm != 'multiple' or many_files):
            self.fm.ui.console.ask(
                "Confirm deletion of: %s (y/N)" % ', '.join(files),
                partial(self._question_callback, args), ('n', 'N', 'y', 'Y'),
            )
        else:
            # no need for a confirmation, just delete
            self._trash_delete_files(args)

    def tab(self, tabnum):
        return self._tab_directory_content()

    def _question_callback(self, args, answer):
        if answer in ('y', 'Y'):
            self._trash_delete_files(args)

    def _trash_delete_files(self, args):
        """
        trash_put may output error message but stderr is None,
        so catch the AttributeError and use builtin delete to fallback
        """
        try:
            self.trash_put.run(args)
        except AttributeError:
            self.fm.delete(args[1:])
