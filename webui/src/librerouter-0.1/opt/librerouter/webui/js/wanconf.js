        window.onload = function()
        {
                document.getElementById('show-me').style.height = '0';
                document.getElementById('show-me').style.transition = 'all 1s ease 0.1s';
                document.getElementById('show-me').style.display = 'table-column';
                document.getElementById('loading').style.display = 'none';
                yesnoCheck();
        }

        function yesnoCheck()
        {
                if (document.getElementById('static').checked)
                {
                        document.getElementById('show-me').style.height = '240px';
                        document.getElementById('show-me').style.opacity = '1';
                        document.getElementById('show-me').style.display = 'block';
                }
                else
                {
                        document.getElementById('show-me').style.height = '0';
                        document.getElementById('show-me').style.opacity = '0';
                        document.getElementById('show-me').style.display = 'table-column';
                }
        }

        function showLoading()
        {
                document.getElementById('loading').style.display = 'block';
        }
