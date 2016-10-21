#!/bin/bash
echo -e "Content-Type: text/html\n\n"
export QUERY_STRING=`echo "${QUERY_STRING}" | tr -d '$,(,),{,},\`,|,/,<,>,%,#,@,!'`
read POST_STRING
export POST_STRING=`echo "${POST_STRING}" | tr -d '$,(,),{,},\`,|,/,<,>,%,#,@,!'`

export UIPATH="/opt/librerouter/webui"
page=`echo "$QUERY_STRING" | grep -o "page=[[:alnum:]]*" | awk -F '=' '{print $2}'`
lang=`echo "$QUERY_STRING" | grep -o "lang=[[:alnum:]]*" | awk -F '=' '{print $2}'`

[[ -z "$page" ]] && page=test

if [[ -z "$lang" ]] || [[ ! -f "${UIPATH}/lang/${lang}/${page}.dict" ]]
then
	lang=en
fi

if [[ ! -f "${UIPATH}/lang/${lang}/${page}.dict" ]]
then
	echo "<html><head><title>FATAL</title><style>"
	cat "${UIPATH}/css/main.css"
	echo "</style></head><body><div class='error'>Error: Failed to find module template files.</div></body></html>"
	exit
fi

source "${UIPATH}/lang/${lang}/${page}.dict"
export $(cut -d= -f1 "${UIPATH}/lang/${lang}/${page}.dict")

echo "<html>"
echo "<head>"

echo "<title>$title</title>"

echo "<style>"
cat "${UIPATH}/css/main.css"
[[ -f "${UIPATH}/css/${page}.css" ]] && cat "${UIPATH}/css/${page}.css"
echo "</style>"

echo '<script type="text/javascript">'
cat "${UIPATH}/js/main.js"
[[ -f "${UIPATH}/js/${page}.js" ]] && cat "${UIPATH}/js/${page}.js"
echo "</script>"

echo "</head>"

echo "<body>"
if [[ ! -f "${UIPATH}/html/${page}.tpl" ]]
then
	echo "<div class='error'>Error: Failed to find module template files.</div></body></html>"
	exit
fi

inpipe=/tmp/cgi.in
outpipe=/tmp/cgi.out
[[ ! -p "$inpipe" ]] && mkfifo "$inpipe"
if [[ ! -p "$outpipe" ]]
then
        echo "<div class='error'>Error: Failed to find output pipe.</div></body></html>"
        exit
fi

cat "${UIPATH}/html/loading.tpl"

if [[ -n "$POST_STRING" ]]
then
	echo "$page :: $POST_STRING" > "$inpipe"
	read line <"$outpipe"
	retcode=`echo "$line" | awk -F '::' '{print $1}' | tr -d ' '`
	export retmess=`echo "$line" | awk -F '::' '{print $2}'`
	case "$retcode" in
	"0")
		retelem="success"
		;;
	"254")
		retelem="warning"
		;;
	"255")
		retelem="info"
		;;
	*)
		retelem="error"
		;;
	esac
	sigil.`uname -m` -p -f "${UIPATH}/html/${retelem}.tpl"
fi

if [[ -f "/tmp/${page}/main.arg" ]]
then
	source "/tmp/${page}/main.arg"
	export $(cut -d= -f1 "/tmp/${page}/main.arg")
	rm -f "/tmp/${page}/main.arg"
elif [[ -f "${UIPATH}/sh/${page}/main.parm" ]]
then
	source "${UIPATH}/sh/${page}/main.parm"
	export $(cut -d= -f1 "${UIPATH}/sh/${page}/main.parm")
fi
sigil.`uname -m` -p -f "${UIPATH}/html/${page}.tpl"

echo "</body>"
echo "</html>"
