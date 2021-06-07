import os
import sys
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
            self.trash_put = put
        except ImportError:
            pass

    def execute(self):
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
        trash_put may output error message, so catch the Exception and use builtin delete to
        fallback
        """
        argv_b = sys.argv
        out_b = sys.stdout
        err_b = sys.stderr
        try:
            sys.argv = args
            sys.stderr = None
            sys.stdout = None
            self.trash_put.main()
        except Exception:
            self.fm.delete(args[1:])
        finally:
            sys.argv = argv_b
            sys.stdout = out_b
            sys.stderr = err_b
