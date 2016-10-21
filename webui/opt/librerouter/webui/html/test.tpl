<center><h2>$title</h2></center>
<h3>$instr</h3>
<center><h3>$mainh</h3></center>
<center><form action='index.cgi' method='post'>
<input type="radio" name="conntype" value="dhcp" id="dhcp" onclick="javascript:yesnoCheck();" $dhcpon> $dhcp<input type="radio" name="conntype" id="static" value="static" onclick="javascript:yesnoCheck();" $staticon> $static<br>
<div id="show-me" style="display: none;"><br/>$ipaddr: <input type="text" name="ipaddr" value="$vipaddr"><br/><br/>$nmask: <input type="text" name="netmask" value="$vnetmask"><br/><br/>$gw: <input type="text" name="gw" value="$vgw"><br/><br/>$dns1: <input type="text" name="dns1" value="$vdns1"><br/><br/>$dns2: <input type="text" name="dns2" value="$vdns2"></div>
<br><br><input type="submit" value="$submit" onclick="javascript:showLoading();"></form><progress id="loading"></progress></center>
