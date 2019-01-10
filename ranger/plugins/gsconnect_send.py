import subprocess
import os.path
from ranger.api.commands import Command


class GsconnectSend(Command):
    """Send files through Gsconnect
    When multiple devices are connected to PC, select the number corresponding to the serial
    number of the device;
    When only single device is connected to PC, send files automatically without selection.

    Example:
    :GsconnectSend 2
    :GsconnectSend

    """

    def execute(self):
        arg = self.rest(1)

        exe_path = os.getenv('GSCONNECT')
        if not exe_path:
            exe_path = ('~/.local/share/gnome-shell/extensions/' +
                        'gsconnect@andyholmes.github.io/service/daemon.js')

        exe = os.path.expanduser(exe_path)
        devices = subprocess.check_output([exe, '-a'], universal_newlines=True).splitlines()
        device_info = []
        i = 0
        for device in devices:
            token = device.split('\t')
            if token[2] == 'true' and token[3] == 'true':
                device_info.append('{:3} | {}\t{}'.format(i, token[0], token[1]))
                i += 1

        if i > 1:
            self.fm.ui.browser.draw_info = device_info

        if len(device_info) == 0:
            self.fm.notify('No Android device is found!')
            return

        self.fm.ui.console.allow_close = False
        selected_num = None
        if len(device_info) == 1:
            selected_num = 0
        elif arg:
            selected_num = int(arg)

        if selected_num is not None and selected_num >= 0:
            dev_info = device_info[selected_num].split('|')[1].split('\t')
            dev_id = dev_info[0].strip()
            dev_name = dev_info[1].strip()
            self.fm.ui.console.allow_close = True
            self._send_files(exe, dev_id)
            self.fm.notify('Sent selected files to {}\t{}'.format(dev_id, dev_name))

    def _send_files(self, exe, dev_id):
        share_file_args = []
        for file in self.fm.thistab.get_selection():
            if not file.is_file:
                continue
            share_file_args.append('--share-file')
            share_file_args.append(file.path)
        cmd_list = [exe, '-d', dev_id] + share_file_args
        subprocess.check_call(cmd_list)
