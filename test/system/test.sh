#!/usr/bin/env bash

function send_keystrokes() {
	screen -p 0 -X stuff "$(cat)"
}
function pop_sent() {
	cat sent
	rm sent
}


header_found() {
	before_colon="${1}"
	after_colon="${2:-.*}"
	grep "^${before_colon}: ${after_colon}$" sent
	return $?
}

function assert() {
	if ! "$@" > /dev/null; then
		cat
	fi
}

function test_send_basic_message() {
	contents=asldhadflkhsf
	send_keystrokes <<-EOF
	mto@example.org
	Subject
	i$contents^[
	:wq^M
	EOF
	sleep 1 # why?
	send_keystrokes <<< "yq"


	sleep 1
	# msg="$(get_and_remove_sent)"
	#header_found "Date" <<< "${msg}"
	assert header_found "Date"                                        <<< "Date header not found"
	assert header_found "From" "Testing Framework <test@example.org>" <<< "From header not found"
	assert header_found "Message-ID"                                  <<< "Message-ID not found"
	assert header_found "MIME-Version"                                <<< "Message-ID not found"
	assert header_found "Content-Type"                                <<< "Message-ID not found"
	assert header_found "Content-Disposition" "inline"                <<< "Message-ID not found"
	assert header_found "User-Agent"                                  <<< "Message-ID not found"
	assert header_found "Content-Length" $(wc -c <<< ${contents})     <<< "Message-ID not found"
	assert header_found "Lines" $(wc -l <<< ${contents})              <<< "Message-ID not found"
	assert grep "${contents}" sent <<< "uhoh"
	rm sent
}

system_test() {
	(sleep 0.5 && "$1") &
	HOME=$PWD EDITOR="vi -u NONE" MAILCAP="" screen ../../neomutt -m mbox -F test.rc
}

GNUPGHOME=$PWD/.gnupg system_test test_send_pgp_message
