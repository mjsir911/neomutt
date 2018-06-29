#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

from hecate.hecate import Runner


class NeoMuttRunner(Runner):
    def __init__(self):
        from sys import argv
        from os import environ as env
        exe = env["NEOMUTT_BIN"] or "neomutt"
        super().__init__(exe, "-F", "/dev/null")
        self.await_text("NeoMutt")  # wait for initialization

    def command(self, cmd):
        self.write(":" + cmd)
        self.press("Enter")


def test_set_get():
    variable_name = "editor"
    with NeoMuttRunner() as h:
        h.command("set ?{}".format(variable_name))
        with_question_mark = h.screenshot()

        h.command("set {}".format(variable_name))
        without_question_mark = h.screenshot()

        assert with_question_mark == without_question_mark


def test_set_my():
    variable_name = "my_variable"
    variable_data = "yo"
    with NeoMuttRunner() as h:

        def get_val():
            h.command("set ?{}".format(variable_name))
            h.await_text(variable_name)
            return h.screenshot()

        h.command("set {}={}".format(variable_name, variable_data))

        assert '{}="{}'.format(variable_name, variable_data) in get_val()

        h.command("unset {}".format(variable_name))

        assert "unknown variable" in get_val()

        h.command("set {}={}".format(variable_name, variable_data))

        h.command("reset {}".format(variable_name))

        assert "unknown variable" in get_val()


def test_set_boolean():
    variable_name = "allow_8bit"
    with NeoMuttRunner() as h:

        def get_val():
            # Get default state
            h.command("set ?{}".format(variable_name))
            h.await_text(variable_name)
            return h.screenshot()

        def get_set():
            output = get_val()
            if '{} is set'.format(variable_name) in output:
                return True
            elif '{} is unset'.format(variable_name) in output:
                return False
            return None

        default_set = get_set()

        h.command("toggle {}".format(variable_name))  # Test toggle

        assert default_set != get_set()

        h.command("reset {}".format(variable_name))  # Test reset

        assert default_set == get_set()

        h.command("set {}".format(variable_name))
        assert get_set() is True

        h.command("unset {}".format(variable_name))
        assert get_set() is False


def test_set_command():
    variable_name = "editor"
    variable_data = "nano"

    with NeoMuttRunner() as h:

        def get_val():
            h.command("set ?{}".format(variable_name))
            h.await_text(variable_name)
            return h.screenshot()

        def get_set():
            output = get_val()
            set_line = output.split()[-1]
            return set_line[len(variable_name) + len('="'):-1]

        def set_val(val):
            h.command("set {}={}".format(variable_name, val))

        env_default_set = get_set()
        h.command("reset {}".format(variable_name))
        default_set = get_set()

        from os import environ as env
        assert env_default_set == env["EDITOR"] or default_set

        set_val(variable_data)
        assert get_set() == variable_data

        h.command("unset {}".format(variable_name))
        assert get_set() == ""

        set_val(variable_data)
        assert get_set() == variable_data

        h.command("reset {}".format(variable_name))
        assert get_set() == default_set

        import os.path
        homepath = "~/{}".format(variable_data)
        set_val(homepath)
        assert get_set() == homepath

        set_val(os.path.expanduser(homepath))
        assert get_set() == homepath


