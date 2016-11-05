<center><h2>$title</h2></center>
<h3>$instr</h3>
<center><h3>$mainh</h3></center>
<center><form action='index.cgi' method='post'>
<label for="dhcp" onclick="javascript:yesnoCheck();"><div class="label-inline">$dhcp</div></label><input class="regular-radio" type="checkbox" name="conntype" id="static" value="static" onclick="javascript:yesnoCheck();" $staticon><label for="static" onclick="javascript:yesnoCheck();"><div class="label-inline">$static</div></label><br>
<div id="show-me" style="display: none;"><br/><div class="block"><label for="ipaddr">$ipaddr </label><input type="text" name="ipaddr" value="$vipaddr"><br/><label for="netmask">$nmask </label><input type="text" name="netmask" value="$vnetmask"><br/><label for="gw">$gw </label><input type="text" name="gw" value="$vgw"><br/><label for="dns1">$dns1 </label><input type="text" name="dns1" value="$vdns1"><br/><label for="dns2">$dns2 </label><input type="text" name="dns2" value="$vdns2"></div></div>
<br><input type="submit" value="$submit"></form></center>
