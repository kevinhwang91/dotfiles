from ranger.api.commands import Command
from ranger.ext.direction import Direction


class DisplayMove(Command):
    """Move to file in Pager view

    Example:
    Enter Pager view: display_file
    Move up: DisplayMove up=1
    Move down: DisplayMove down=1
    """

    def execute(self):
        if not self.fm.ui.pager.visible or not self.fm.thisfile or not self.fm.thisfile.is_file:
            return
        try:
            kw = {self.arg(1): int(self.arg(2))}
        except ValueError:
            k, v = self.arg(-1).split('=')
            kw = {k: int(v)}
        kw.setdefault('cycle', self.fm.settings['wrap_scroll'])
        kw.setdefault('one_indexed', self.fm.settings['one_indexed'])
        direction = Direction(kw)
        if not direction.vertical():
            return

        cwd = self.fm.thisdir
        pos_orgin = cwd.pointer
        while True:
            old_thisfile = self.fm.thisfile
            cwd.pointer = direction.move(
                direction=direction.down(),
                maximum=len(cwd),
                current=cwd.pointer,
                pagesize=self.fm.ui.browser.hei)
            cwd.correct_pointer()
            if self.fm.thisfile.is_directory:
                if old_thisfile == self.fm.thisfile:
                    cwd.pointer = pos_orgin
                    cwd.correct_pointer()
                    break
            else:
                break

        if pos_orgin != cwd.pointer:
            self.fm.display_file()
