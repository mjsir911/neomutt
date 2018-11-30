#!/usr/bin/env bash

function is_header() {
	grep '{\s*\([^,]*,\)\{4\}\([^,]*\)\s*},$' <<< "$@" > /dev/null
	return $?
}

function type_translate() {
	case "$1" in
   "DT_NONE") echo "-none-";;
   "DT_BOOL") echo "boolean";;
   "DT_NUMBER") echo "number";;
	 "DT_LONG")  echo "number (long)";;
   "DT_STRING") echo "string";;
   "DT_PATH") echo "path";;
   "DT_QUAD") echo "quadoption";;
   "DT_SORT") echo "sort order";;
	 "DT_REGEX") echo "regular expression";;
	 "DT_MAGIC") echo "folder magic";;
	 "DT_ADDRESS") echo "e-mail address";;
	 "DT_MBTABLE") echo "string";;
	 "DT_COMMAND") echo "command";;
		*) echo not found - $1;;
	esac
}

function escape() {
	sed -e "s#'#''#g" <<< "$@"
}

function parse_header() {
	readarray -d '' things < <(sed -n -E 's#\{\s*"([^,]+)",\s*([^,]+),\s*([^,]+),\s*([^,]+),\s*([^,]+)\s*\},$#\1\x00\2\x00\5#p' <<< "$@")
	name="${things[0]}"
	_type="${things[1]}"
	default="$(echo ${things[2]})"
	echo "  - title: $name"
	echo "    datatype: $(type_translate $_type)"
	echo "    default: '$(escape ${default})'"
	echo "    body: |+"
}

function get_title() {
	parse_header "$@" | sed -n -e 's/  - title: \(.*\)$/\1/p'
}

function clean_bodyline() {
	sed -E 's#^((\s)|(\*)|(/))*##' <<< "$@"
}

function get_inline_links() {
	sed -n -E -e 's#(\[\$[^]]*\])#\n\1#gp' <<< "$@" | sed -n -E -e 's#\[[\$]([^]]+)\].*#\1#gp'
}

function parse_body() {
	INLINELINKS=();
	while read -r && grep '*' > /dev/null <<< "$REPLY"; do
		CLEANREPLY="$(clean_bodyline "$REPLY")"
		INLINELINKS+=("$(get_inline_links "$CLEANREPLY")")
		if grep '*/' > /dev/null <<< "$REPLY"; then
			break
		fi
		echo "      $CLEANREPLY"
	done
	#echo "      test: ${INLINELINKS[1]}"
	#for inline_link in "${INLINELINKS[@]}"; do
		#echo "      [\$$inlinelink]: $inlinelink"
	#done
	echo
}

echo '---'
echo "vars:"
while read -r; do
	if is_header "$REPLY"; then
		title=$(get_title $REPLY)
		if [ -z "$title" ]; then
			continue
		fi

		parse_header "$REPLY"
		parse_body
	fi
done
echo '---'
