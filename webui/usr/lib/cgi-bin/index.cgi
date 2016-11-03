#!/bin/bash
. /opt/librerouter/webui/sh/lib/parse
mkdir -p /opt/librerouter/webui/db/
mkdir -p /var/lib/librerouter/sess/

ip="$REMOTE_ADDR"

lastfailed=`cat /var/lib/librerouter/sess/failed.list 2> /dev/null | grep -e ":$ip$" | sort -n | tail -n 1`
[[ -z "$block_delay" ]] && block_delay="300"
[[ -z "$max_retries" ]] && max_retries=6

if [[ -n "${lastfailed}" ]]
then
	currtime=`date +%s`
	failedstamp=`echo "${lastfailed}" | awk -F ':' '{print $1}'`
	difftime=$((currtime-failedstamp))
	[[ "${difftime}" -gt "${block_delay}" ]] && sed -i '/'"${ip}"'/d' /var/lib/librerouter/sess/failed.list
	failedno=`cat /var/lib/librerouter/sess/failed.list 2> /dev/null | grep -e "$ip$" | sort -n | wc -l`
fi

if [[ -d "/var/lib/librerouter/sess/$ip" ]]
then
	for i in `ls /var/lib/librerouter/sess/"$ip"/`
	do
		cookiecont=`cookie "$i"`
		if [[ -n "$cookiecont" ]]
		then
			cookiename="$i"
			localcookie=`head -n 1 /var/lib/librerouter/sess/"$ip"/"${cookiename}"`
			secretid=`echo "${localcookie}" | awk -F '===>' '{print $1}'`
			localcont=`echo "${localcookie}" | awk -F '===>' '{print $2}'`
			export LOCAL_CSRF=`echo "${localcookie}" | awk -F '===>' '{print $3}'`
			localcont=`echo "${localcont}" | openssl aes-256-cbc -base64 -A -d -salt -pass pass:"${secretid}"`
			localuser=`echo "${localcont}" | awk -F ':::' '{print $1}'`
			localpass=`echo "${localcont}" | awk -F ':::' '{print $2}'`
			localip=`echo "${localcont}" | awk -F ':::' '{print $3}'`
		fi
	done
fi

if [[ -z "$cookiename" ]] || [[ -z "$secretid" ]]
then
	username=`param username | tr -d ':'`
	password=`param password | tr -d ':'`
	ip="$REMOTE_ADDR"
	if [[ -n "$username" ]] && [[ -n "$password" ]] && [[ -n "$ip" ]]
	then
		userhash=`echo "${username}" | md5sum | awk '{print $1}'`
		passhash=`echo "${password}" | md5sum | awk '{print $1}'`
		gline="${userhash}:::${passhash}:::"
		if [[ -n `cat /opt/librerouter/webui/db/users.db | grep -E "^${gline}"` ]]
		then
			sessid=`makepasswd --chars=32 --string=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`
			secretid=`makepasswd --chars=32 --string=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`
			csrftoken=`makepasswd --chars=32 --string=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`
			cookiecont=`echo "${userhash}:::${passhash}:::${ip}" | openssl aes-256-cbc -base64 -A -salt -pass pass:"${secretid}"`
			set_cookie "${sessid}" "${cookiecont}"
			mkdir -p /var/lib/librerouter/sess/"${ip}"
			echo "$secretid===>${cookiecont}===>${csrftoken}" > /var/lib/librerouter/sess/"${ip}"/"${sessid}"
			export LOCAL_CSRF="${csrftoken}"
			export ERR=0
		else
			echo "`date +%s`:$ip:login_failed" >> /var/log/librerouter/log/fail.log
			echo "`date +%s`:$ip" >> /var/lib/librerouter/sess/failed.list
			export ERR=1
		fi
	else
		export ERR=""
	fi
fi

if [[ -n "$cookiename" ]] && [[ -n "$secretid" ]]
then
	cookiecont=`cookie "$cookiename"`
	cookiecont=`echo "${cookiecont}" | openssl aes-256-cbc -base64 -A -d -salt -pass pass:"${secretid}"`
	cusername=`echo "${cookiecont}" | awk -F ':::' '{print $1}'`
	cpassword=`echo "${cookiecont}" | awk -F ':::' '{print $2}'`
	cip=`echo "${cookiecont}" | awk -F ':::' '{print $3}'`
	if [[ "$cusername" != "$localuser" ]] || [[ "$cpassword" != "$localpass" ]] || [[ "$cip" != "$ip" ]] || [[ "$cip" != "$localip" ]] || [[ "$localip" != "$ip" ]]
	then
		export ERR=1
		rm -f /var/lib/librerouter/sess/"${cip}"/"${cookiename}"
		echo "Set-Cookie: ${cookiename}=deleted; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT"
	else
		gline="${cusername}:::${cpassword}:::"
		if [[ -n `cat /opt/librerouter/webui/db/users.db | grep -E "^${gline}"` ]]
		then
			export ERR=0
			module=`param m`
			clientcsrf=`param csrf`
			[[ `echo "$HTTP_REFERER" | awk -F '/' '{print $3}'` != "$SERVER_NAME" ]] && ERR=1
			[[ "$module" == "logout" ]] && [[ "$clientcsrf" == "$LOCAL_CSRF" ]] && end_session "${cip}" "${cookiename}"
		else
			export ERR=1
			rm -f /var/lib/librerouter/sess/"${cip}"/"${cookiename}"
			echo "Set-Cookie: ${cookiename}=deleted; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT"
			#echo x > /tmp/test
			exit
		fi
        fi
fi

echo -e "Content-Type: text/html\n\n"
export QUERY_STRING=`echo "${QUERY_STRING}" | tr -d '$,(,),{,},\`,|,/,<,>,%,#,@,!'`
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
if [[ "$ERR" != "0" ]]
then
	[[ "$failedno" -gt "$max_retries" ]] && ERR=2
	remfailed=$((max_retries-failedno))
	if [[ "$ERR" != "2" ]]
	then
		sigil.`uname -m` -p -f "${UIPATH}/html/login.tpl"
	fi
	if [[ "$ERR" == "1" ]]
	then
		echo "<div class='error'>Error: Bad credentials or session expired ! ('"$remfailed"' tries remaining).</div></body></html>"
	fi
	if [[ "$ERR" == "2" ]]
	then
		echo "<div class='error'>Error: Blocked for 5 minutes due to too many failed login attempts.</div></body></html>"
	fi
	exit
fi

if [[ ! -f "${UIPATH}/html/${page}.tpl" ]]
then
	echo "<div class='error'>Error: Failed to find module template files.</div></body></html>"
	exit
fi

mkdir -p /tmp/librerouter/sess/"${cip}"/"${cookiename}"/
inpipe=/tmp/librerouter/sess/"${cip}"/"${cookiename}"/cgi.in
outpipe=/tmp/librerouter/sess/"${cip}"/"${cookiename}"/cgi.out
[[ ! -p "$inpipe" ]] && mkfifo "$inpipe"
#if [[ ! -p "$outpipe" ]]
#then
#        echo "<div class='error'>Error: Failed to find output pipe.</div></body></html>"
 #       exit
#fi

cat "${UIPATH}/html/loading.tpl"
if [[ -n "$POST_STRING" ]] && [[ -z `param username | tr -d ':'` ]]
then
	echo "${cip}" > /tmp/librerouter/sess/list/"${cookiename}"
	echo "$page :: $POST_STRING" > "$inpipe"
	read line <"$outpipe"
	rm -f "$outpipe"
#	rm -f /tmp/librerouter/sess/list/"${cookiename}"
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
