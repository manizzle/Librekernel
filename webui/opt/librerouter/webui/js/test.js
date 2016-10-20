<script type="text/javascript">
    window.onload = function() {
        document.getElementById('show-me').style.display = 'none';
    }

    function yesnoCheck() {
        if (document.getElementById('static').checked) {
            document.getElementById('show-me').style.display = 'block';
        }
        else {
            document.getElementById('show-me').style.display = 'none';
        }
    }

</script>
