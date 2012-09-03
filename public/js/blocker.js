/*
* SVG Blocker 
*
*/

if (!Modernizr.svg){

	$(function(){
       
		
		$("<div>")
			.css({
				'position': 'absolute',
				'top': '0px',
				'left': '0px',				
				'background-color': 'black',
				'opacity': '0.80',
				'width': '100%',
				'height': $(window).height(),
				'zIndex': '5000'
			})
			.appendTo("body");
			
		$('<div class="ie-box"><h2>Your browser is no longer supported.</h2><p>To get the best possible experience using our website we recommend that you upgrade to a newer version or other web browser. A list of the most popular web browsers can be found below.</p><p class="browser-links"><a href="http://www.google.com/chrome/index.html" class="browser-link"><img src="static/images/browsers/browser_chrome.gif" class="chrome-link"><br />Chrome</a><a href="http://www.mozilla.com/?from=sfx&amp;uid=267821&amp;t=449" class="browser-link"><img src="static/images/browsers/browser_firefox.gif" class="firefox-link"><br />FireFox</a><a href="http://www.opera.com/browser/" class="browser-link"><img src="static/images/browsers/browser_opera.gif" class="opera-link"> <br />Opera</a><a href="http://www.apple.com/safari/" class="browser-link"><img src="static/images/browsers/browser_safari.gif" class="safari-link"><br />Safari</a><a href="http://windows.microsoft.com/en-US/internet-explorer/downloads/ie-9/worldwide-languages" class="browser-link"><img src="static/images/browsers/browser_ie.gif" class="ie9-link"><br />IE 9 </a></p><p class="chrome-frame">If you are unable to install a new web browser, you may be able to improve your web browsing capability by installing the <a href="http://code.google.com/chrome/chromeframe/" >"Google Chrome Frame"</a> plugin for Internet Explorer.</p></div>')
			.css({
				'background-color': '#f5f5f5',
				'top': '50%',
				'left': '50%',
				'color': '#666',
				'margin-left': '-300px',
				'margin-top': '-300px',
				'width': '600px',
				'padding': '20px',
				'height': '300px',
				'position': 'absolute',
				'zIndex': '6000'
			})
			.appendTo("body");

	});		
}
