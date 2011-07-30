//@line 1
// ==UserScript==
// @name           opt
// @namespace      opt
// @include        *
// ==/UserScript==


var draw = (function(){
	var container;
	
	var init_container = function() {
		container = document.createElement('div');
		container.style.cssText = 'border:5px solid red; background-color:yellow; color:black; padding:2px; ';
		window.setTimeout(function(){
			document.body.insertBefore(container, document.body.firstChild);
		}, 100);
	};
	
	return function(x) {
		if (!container)
			init_container();
		if (x instanceof Array)
			x = x.join('&nbsp;&nbsp;&nbsp;&nbsp;');
		var div = document.createElement('div');
		div.style.cssText = 'display:inline-block; border:3px solid blue; margin:5px; padding:3px; ';
		
		if (typeof x == 'string')
			div.innerHTML = x;
		else if (x.appendChild) {
			if (x.parentNode)
				x.parentNode.removeChild(x);
			div.appendChild(x);
		}
		container.appendChild(div);
	};
})();


var re_escape=function(x){
    return String(x).replace(/\\/g, "\\\\").replace(/\n/g, "\\n").replace(/([\|\{\}\[\]\$\^\*\(\)\+\-\?\.])/g, '\\$1');
};



var get_style = function(elem, prop) {
	var s = window.getComputedStyle ? window.getComputedStyle(elem, '') : elem.runtimeStyle;
	if (!prop) return s;
	var prop_in_camel_case = prop.replace(/\-(.)/g, function($0, $1){ return $1.toUpperCase() });
	return s[prop_in_camel_case];
};
                


(function(){ try {
	if(/about:|file:|https|mozilla|google/.test(''+document.location)) return;

	try {
		if (window.frameElement) return;
	} catch(e) {
		return;
	}
	
	(function(){
		var out = [];			
		var uris = [];
		var assoc = {};
		var files = [];
		var html = document.documentElement.innerHTML;
		html.replace(/["'](http:[^"']*|[^\/'"]+)\.(flv|mp4|f4v)["']/g, function($0) {
			$0 = $0.replace(/'/g, '"');
			try {
				var uri = JSON.parse($0);
			} catch(e){
				alert('выделение flv из страницы не прошло JSON.parse: ' + $0);
				return;
			}
			if (!assoc[uri]) {
				assoc[uri] = 1;
				files[files.length] = uri;
			}
		});
		
		html.replace(/=(http[^'"&=]*\.(flv|mp4|f4v))([^<>"']*)/g, function($0, $1, $2, $3) {
			var vi = decodeURIComponent($1);
			var im = '';
			$3.replace(/=([^'"&=]*\.jpe?g)/, function($0, $1){
				im = decodeURIComponent($1);
			});
			if (im)
				vi += '|' + im;
			
			if (assoc[vi]) return;
			assoc[vi] = 1;			
			files[files.length] = vi;
		});

		var im, vi, mm;
		for (var i = 0, max = files.length; i < max; ++i) {
			out[out.length] = '<div style="font:11px Arial">';
			mm = files[i].split(/ *[\|\n] */);
			vi = mm[0];
			im = mm[1] || null;
			out[out.length] = '<a href="' + vi + '">';

			/*
			if (/url1/.test(vi))
				im = files[i].replace(/[^\/]+$/, '200.jpg');
			else if (/url2/.test(''+document.location))
				im = 'flv0' + (i + 1) + '.jpg';
			*/				
			
			if (im)
				out[out.length] = '<img src="' + im + '">';
			else
				out[out.length] = vi;
			
				
			out[out.length] = '</a>';
			out[out.length] = '</div>';
		}		
		if (out.length > 0) {
			draw(out);			
		}
	})();

	window.setTimeout(function() {
		var cnt = 0;
		var timer, timer_cnt = 0;
		var lock = {};

/*
var style = document.createElement('style');
style.innerHTML = '\
a[href$=mpg] {display:inline-block; background-color:green !important; }\n\
a[href$=mpg] img { opacity:0.5; }\n\
a[href$=mpeg] {display:inline-block; background-color:green !important; }\n\
a[href$=mpeg] img { opacity:0.5; }\n\
a[href$=avi] {display:inline-block; background-color:green !important; }\n\
a[href$=avi] img { opacity:0.5; }\n\
a:visited img { opacity:0.3 !important; border:5px solid magenta !important; }\n\
a[href$=wmv]:visited,\n\
a[href$=avi]:visited,\n\
a[href$=flv]:visited,\n\
a[href$=mp4]:visited { color: #ddd !important  }\n\
';
document.getElementsByTagName('head')[0].appendChild(style);
*/

		var html = '' + document.documentElement.innerHTML;


		/*
		if (/pat1/.test('' + document.location)) {
			var xx = document.getElementsByTagName('div');
			var yy = [];
			for (var i = 0, max = xx.length; i < max; ++i) {
				if (/^pat2$/.test(xx[i].className))
					yy[yy.length] = xx[i];
			}
			for (i = 0, max = yy.length; i < max; ++i) {
				yy[i].parentNode.removeChild(yy[i]);
			}
		}
		*/

		var fixed;
		
		var create_fixed = function() {
			if (!fixed) {
				fixed = document.createElement('div');
				fixed.style.cssText = 'position:fixed; z-index:9999; left:40px; right:40px; top:10px;background-color:yellow;border:3px solid blue;padding:5px;zwidth:auto;display:inline;max-height:900px; overflow-y:scroll'; 
			}
		};
		
		cnt = 0;
		for (var i = 0, max = document.links.length; i < max; ++i) {
			if (/\.(flv|f4v|mp4|wmv|avi|mov|asf)$/.test(document.links[i].href)) {
				if (++cnt > 40) {
					alert('cnt > 40');
					break;
				}
				(function(elem, cnt){
					var uri = elem.href.replace(/[\?#].*$/, '');
				
					if (lock[uri]) return;
					lock[uri] = 1;
					
					var img2, m, re;
					var re_src;
					
					var file = uri.replace(/.*\/([^\/]+)/, '$1');

					var div = document.createElement('div');
					div.style.cssText = 'position:absolute;z-index:9999;background-color:yellow !important;color:black;font:bold 14px Arial;padding:1px;padding:2px 5px;color:black !important';
					
					var img = null;
					if (elem)
						img = elem.getElementsByTagName('img')[0];

					var img2 = '';

					if (img && (img.offsetWidth * img.offsetHeight == 0)) {
						img.style.width = 'auto';
						img.style.height = 'auto';
						draw(elem);
					}
					
					//XXX
					if(0)if (img && (img.offsetWidth * img.offsetHeight < 10000)) {
						if (img.src)
							img2 = img.src;
						img = null;
					}
					
					if (img) {
						div.style.cssText = 'position:absolute;z-index:9999;background-color:yellow !important;color:black;font:bold 16px Arial;padding:1px;padding:2px 8px;';
						img.parentNode.insertBefore(div, img);
						
						if (cnt == 1) {
							div.innerHTML = '<a name=top></a>';
							document.location.replace('#top');
						}
						
					} else {
						if (!fixed)
							create_fixed();
						div.style.position = 'static';
						div.style.display = 'inline-block';
						div.style.verticalAlign = 'top';
						div.style.margin = '10px';
						re_src = '([^\(\)& ="\' \t\r\n]+' + re_escape(file.replace(/\.[^\.]+$/, '.')) + 'jpe?g)';
						re = new RegExp(re_src);
						if (m = html.match(re)) {
							img2 = m[1];
						}						
						if (img2)
							img2 = '<br><img src="' + img2 + '" style="margin:5px;margin-bottom:0;max-height:240px;max-width:360px">';
						
						div.innerHTML = '<a href="' + uri + '">' + file + ' (loading info...)' + img2 + '</a>';
						fixed.appendChild(div);
					}
					
					var f = function(req) {
						var headers = req.responseHeaders || req.getResponseHeaders();
						var m;
						if (headers && (m = headers.match(/Content-Length: (\d+)/))) {							
							var size = +m[1];
							var size_mb = Math.round(10 * size / (1024 * 1024)) / 10;
							if (size_mb < 4) {
								(img || div).style.opacity = '0.5';
								if (img) {
									var p = document.createElement('div');
									p.style.position = 'absolute';
									p.style.width = img.offsetWidth + 'px';
									p.style.height = img.offsetHeight + 'px';
									p.style.backgroundColor = '#fa0';
									img.parentNode.insertBefore(p, img);
								}
								
							} else if (size_mb > 6) {
								if (img)
									img.style.border = '4px solid #f11';
								else
									div.style.border = '4px solid #f11';
							}
							var text = size_mb + 'M';
							if (img) {
								div.innerHTML = '<a name=n' + cnt + ' style="color:black !important">' + text + '</a>';
							} else {
								div.innerHTML = '<a name=n' + cnt + ' href="' + uri + '" style="color:black !important">' + file + ' <b>' + size_mb + 'M</b>' + img2 + '</a>';
							}
						}
					};
					
					GM_xmlhttpRequest({
						method: 'HEAD',
						url: uri,
						onload: function(req) {
							f(req);
						}
					});					
				})(document.links[i], cnt);
			}
		}; // for				
		
		cnt = 0;
		
		var create_overlay_help_div = function(img, text) {
			var div = document.createElement('div');
			div.style.cssText = 'position:absolute; z-index:9999; background-color:yellow !important; color:black !important; font:bold 16px Arial !important; padding:1px; padding:2px 8px;';
			img.parentNode.insertBefore(div, img);
			if (text) {
				div.innerHTML = text;
			}
			return div;
		};
		
		var create_overlay_shit_div = function(elem, text) {
			var div = document.createElement('div');
			div.style.cssText = 'position:absolute; font:bold 12px Arial !important; color:black; background-color:#755;';
			elem.style.opacity = '0.2';
			var h = elem.offsetHeight;
			if (elem.tagName == 'A') {
				var xx, i, _w, _h;
				xx = elem.getElementsByTagName('img');
				if (xx.length > 0) {
					for (i = 0, max = xx.length; i < max; ++i) {
						_w = xx[i].offsetWidth;
						_h = xx[i].offsetHeight;
						if (_h > h)
							h = _h;
					}
				}
				if (xx && xx[0] && xx[0].offsetHeight > h)
					h = xx[0].offsetHeight;
			}			
			div.style.width = elem.offsetWidth + 'px';			
			div.style.height = h + 'px';
			elem.parentNode.insertBefore(div, elem);
			if (text)
				div.innerHTML = text;
			return div;
		};
				
		
		var process_link = function(elem) {
			var img = elem.getElementsByTagName('img')[0];
			if (++cnt > 150) {
				alert('cnt > 150');
				return false;
			}
			var uri = elem.href.replace(/[\?#].*$/, '');
			if (lock[uri]) return;
			lock[uri] = 1;

		uri = uri.replace(/&amp;/g, '&');
		
try{	

			var redirect_count = 0;

			GM_xmlhttpRequest({
				method: 'GET',
				url: uri,
				onload: function(req) {
					if (req.status == 302 || req.status == 303) { //moved 
						if (++redirect_count > 3) {
							alert('number of redirects > 3. returning');
							return;
						}
						var m = req.responseHeaders.match(/Location: ([^\r\n]+)/);
						if (!m) { alert('status is 302 or 303 but location header not found'); return }
						var loc = m[1];
						loc = loc.replace(/(index\.php)?\?.*$/, '');
						GM_xmlhttpRequest({ method: 'GET', url: loc, onload: arguments.callee });
						return;
					}
				
					var html = req.responseText;
					var stat = {};
					var links = [];
					var assoc = {};
					html.replace(/href="([^"]*?\.(mpe?g|wmv|avi))"/g, function($0, $1, $2) {
						if (!assoc[$1]) {
							assoc[$1] = true;
							stat[$2] = 1 + (stat[$2] || 0);
							links[links.length] = $1;
						}
					});
					var out = [];
					for (i in stat)
						out[out.length] = stat[i] + '  ' + i;
					out = out.join('    ');					

					if (!stat.wmv && !stat.avi) {
						create_overlay_shit_div(elem, out + '<br>wmv files not found');
						return;
					}
					
					var l = links[0];
					if (!/^http:\/\//.test(l)) {
						if (l.charAt(0) == '/')
							l = uri.replace(/^(http:\/\/[^\/]+).*/, '$1') + l;
						else
							l = uri.replace(/\?.*$/, '').replace(/#.*$/, '').replace(/[^\/]+$/, '') + l;
					}
					links[0] = l;
					
					var div = create_overlay_help_div(elem, out + ' (getting info...)');
					
					GM_xmlhttpRequest({
						method: 'HEAD',
						url: l,
						onload: function(req) {
							var headers = req.responseHeaders || req.getResponseHeaders();
							if (!headers) return;
							var m = headers.match(/Content-Length: (\d+)/);
							if (!m) {
								div.innerHTML = out + '(???)';
								return;
							}
							
							var size = +m[1];
							var size_mb = Math.round(10 * size / (1024 * 1024)) / 10;
							
							out = out + '&nbsp;&nbsp;&nbsp;' + size_mb + ' MB';
							div.innerHTML = out;
							
							if (size_mb < 4) {
								create_overlay_shit_div(elem, 'Size: ' + size_mb + ' MB');
								div.style.opacity = '0.4';
							} else {
								var goodlinks = document.getElementById('goodlinks');
								if (!goodlinks) {
									goodlinks = document.createElement('textarea');
									goodlinks.setAttribute('id', 'goodlinks');
									document.getElementsByTagName('head')[0].appendChild(goodlinks);									
								}
								goodlinks.value += elem.href + '\n';
							}								
						}
					});
				}
			}); //GM_xmlhttpRequest
}catch(e){
	create_overlay_help_div(elem, 'exception')
}
			
		};
				
		var elem, img, h, m;		
		
		for (var i = 0, max = document.links.length; i < max; ++i) {
			elem = document.links[i];
			h = elem.href;
			
			if (m = h.match(/=(http:\/\/[^&]+)/)) {
				h = decodeURIComponent(m[1]).replace(/[\?#].*/, '');
				elem.href = h;
			}
			if (/mpts/.test(h)) continue;
			
			h = h.replace(/\?.*$/, '');

			if (/(\.(wmv|mpe?g|flv|f4v|avi))$/.test(h)) continue;

			if (/(\.(html?|php)|[0-9]+\/?)$/.test(h) || /galler/.test(h) || /\?nats/.test(elem.href) ) {
				img = elem.getElementsByTagName('img')[0];
				if (!img || (img.offsetWidth * img.offsetHeight < 10000)) continue;
				if (get_style(img, 'opacity') != 1) continue;
				var result = process_link(elem);
				if (result === false)
					break;
			}
		}			
	}, 500);	

	document.addEventListener('keypress', function(e) {
		if (!(e.ctrlKey && e.altKey)) return;
		switch (e.which){
			default: return;
				/* Ctrl-Alt-B */
			case 98: case 1080: case 1048: case 66:
				alert('privet');
				//if (initialized) destroy(); else init();
				break;
		} 
		e.preventDefault();
		e.stopPropagation();
		return false;
	}, true);
	

} catch(e) { 
	var m, text, err = '' + e, line;
	if (m = err.match(/\[Exception\.\.\. "([^\"]+)"/))
		text = m[1];
	if (m = err.match(/\bline (\d+)/))
		line = +m[1] - 359;
	if (text && line)
		err = 'Line ' + line + ': ' + text;
	err = 'greasemonkey script opt.user.js error:\n\n' + err;
	alert(err);
}
})();





