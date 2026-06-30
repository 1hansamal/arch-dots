import sublime
import sublime_plugin
import threading
import time
import os
import tempfile


class RSendAndCaptureCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        view = self.view
        window = view.window()
        region = view.sel()[0]
        if region.empty():
            return
        code = view.substr(region)

        tmpdir = tempfile.gettempdir()
        result_path = os.path.join(tmpdir, "sublime_r_capture.txt")
        script_path = os.path.join(tmpdir, "sublime_r_script.R")

        r_result_path = result_path.replace("\\", "/")
        r_script_path = script_path.replace("\\", "/")

        term_view = None
        for v in window.views():
            if v.settings().get("terminus_view"):
                term_view = v
                break
        if term_view is None:
            sublime.error_message("No Terminus terminal open.")
            return

        # remove any stale result from a previous run before sending new code,
        # so we don't accidentally read an old result if R fails silently
        if os.path.exists(result_path):
            os.remove(result_path)

        script_content = (
            ".tmp_result <- {\n%s\n}\n"
            'dput(.tmp_result, file="%s")\n'
            "rm(.tmp_result)\n"
        ) % (code.strip(), r_result_path)

        with open(script_path, "w") as f:
            f.write(script_content)

        send_line = 'source("%s")\n' % r_script_path
        window.run_command("terminus_send_string", {"string": send_line})

        def poll():
            timeout = time.time() + 30
            while time.time() < timeout:
                if os.path.exists(result_path) and os.path.getsize(result_path) > 0:
                    time.sleep(0.05)
                    try:
                        with open(result_path, "r") as f:
                            result = f.read().strip()
                    except Exception:
                        time.sleep(0.1)
                        continue
                    sublime.set_timeout(lambda: self.replace(region, result), 0)
                    return
                time.sleep(0.1)
            sublime.set_timeout(
                lambda: sublime.error_message("Timed out waiting for R output."), 0
            )

        threading.Thread(target=poll).start()

    def replace(self, region, text):
        self.view.run_command(
            "do_replace", {"a": region.a, "b": region.b, "text": text}
        )


class DoReplaceCommand(sublime_plugin.TextCommand):
    def run(self, edit, a, b, text):
        self.view.replace(edit, sublime.Region(a, b), text)
