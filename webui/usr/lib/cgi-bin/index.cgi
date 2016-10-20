#!/bin/bash

echo -e "Content-Type: text/html\n\n"
export QUERY_STRING=`echo "${QUERY_STRING}" | tr -d '$,(,),{,},\`,|,/,<,>,%,#,@,!'`
export POST_STRING=`echo "${<POST_STRING}" | tr -d '$,(,),{,},\`,|,/,<,>,%,#,@,!'`

export UIPATH="/opt/librerouter/webui"
page=`echo "$QUERY_STRING" | grep -o "page=[[:alnum:]]*" | awk -F '=' '{print $2}'`
lang=`echo "$QUERY_STRING" | grep -o "lang=[[:alnum:]]*" | awk -F '=' '{print $2}'`

[[ -z "$page" ]] && page=test

if [[ -z "$lang" ]] || [[ ! -f "${UIPATH}/lang/${lang}/${page}.dict" ]]
then
	lang=en
fi

source "${UIPATH}/lang/${lang}/${page}.dict"
export $(cut -d= -f1 "${UIPATH}/lang/${lang}/${page}.dict")

echo "<html>"
echo "<head>"
echo "<title>$title</title>"
cat "${UIPATH}/css/${page}.css"
cat "${UIPATH}/js/${page}.js"
echo "</head>"

echo "<body>"
sigil.`uname -m` -p -f "${UIPATH}/html/${page}.tpl"

read POST_STRING
echo $POST_STRING
echo "</body>"
echo "</html>"
