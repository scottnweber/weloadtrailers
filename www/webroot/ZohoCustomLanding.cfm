
<cfoutput>
	<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
	<script type="text/javascript">
	$(document).ready(function(){
		window.parent.document.getElementById('top-next').click();
	})
	</script>
	<style type="text/css">
		##loader_new{
			position: fixed;
			top:40%;
			left:30%;
			z-index: 999;
			text-align: center;
		}
		##loadingmsg_new{
			font-weight: bold;
			text-align: center;
			margin-top: 1px;
			background-color: ##fff;
		}
	</style>
	<div id="loader_new">
		<img src="images/loadDelLoader.gif">
		<p id="loadingmsg_new">Signing on progress. Please don't refresh or leave this page.</p>
	</div>
	</cfoutput>