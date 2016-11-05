	window.onload = function()
	{
		document.getElementById('loading').style.display = 'none';
		document.getElementById('pageloading').style.display = 'none';
		yesnoCheck();
	}

	function yesnoCheck()
	{
		if (document.getElementById('static').checked)
		{
			document.getElementById('show-me').style.display = 'block';
		}
		else
		{
			document.getElementById('show-me').style.display = 'none';
		}
	}

	function showLoading()
	{
		document.getElementById('loading').style.display = 'block';
	}
