<center><h2>$title</h2></center>
<h3>$instr</h3>
<center><h3>$mainh</h3></center>
<center><form action='index.cgi' method='post'>
<input type="radio" name="conntype" value="dhcp" id="dhcp" onclick="javascript:yesnoCheck();" checked> $dhcp<input type="radio" name="conntype" id="static" value="static" onclick="javascript:yesnoCheck();"> $static<br>
<div id="show-me"><br/>$ipaddr: <input type="text" name="ipaddr" value=""><br/><br/>$nmask: <input type="text" name="netmask" value=""><br/><br/>$gw: <input type="text" name="gw" value=""><br/><br/>$dns1: <input type="text" name="dns1" value=""><br/><br/>$dns2: <input type="text" name="dns2" value=""></div>
<br><br><input type="submit" value="$submit"></form></center>
