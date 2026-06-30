import sublime
import sublime_plugin
import subprocess
import os


def run_air_format(file_path):
    try:
        result = subprocess.run(
            ["/home/ihansamal/.local/bin/air", "format", file_path],
            capture_output=True,
            text=True,
            timeout=15,
        )
    except FileNotFoundError:
        return False, "Air not found. Is it installed and on your PATH?"
    except Exception as e:
        return False, "Error running Air: %s" % e

    if result.returncode != 0:
        return False, result.stderr or result.stdout

    return True, None


class AirFormatCommand(sublime_plugin.TextCommand):
    """Manual format trigger, e.g. via keybinding."""

    def run(self, edit):
        view = self.view
        file_path = view.file_name()
        if not file_path:
            sublime.error_message("Save the file before formatting.")
            return
        if view.is_dirty():
            view.run_command("save")
        ok, err = run_air_format(file_path)
        if not ok:
            sublime.error_message("Air formatting failed:\n%s" % err)
            return
        # no manual reload needed -- Sublime will auto-reload since the
        # buffer is clean (we just saved) and the file changed on disk


class AirFormatOnSaveListener(sublime_plugin.EventListener):
    def on_post_save_async(self, view):
        if not view.match_selector(0, "source.r"):
            return
        file_path = view.file_name()
        if not file_path:
            return
        ok, err = run_air_format(file_path)
        if not ok:
            sublime.set_timeout(
                lambda: sublime.status_message("Air format failed: %s" % err), 0
            )
        # buffer is clean post-save, so Sublime auto-reloads silently


class AirFormatOnPasteListener(sublime_plugin.EventListener):
    def on_post_text_command(self, view, command_name, args):
        if command_name not in ("paste", "paste_and_indent"):
            return
        if not view.match_selector(0, "source.r"):
            return

        file_path = view.file_name()
        if not file_path:
            return

        view.run_command("save")
        ok, err = run_air_format(file_path)
        if not ok:
            sublime.set_timeout(
                lambda: sublime.status_message("Air format failed: %s" % err), 0
            )
        # buffer is clean post-save, so Sublime auto-reloads silently
