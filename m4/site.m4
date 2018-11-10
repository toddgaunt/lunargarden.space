m4_define(`HEADER', `m4_dnl
		<head>
		<title>Lunar Garden - $1</title>
		<link href="'ROOT_DIR`css/automata.css" type="text/css" rel="stylesheet"/>
		<link href="'ROOT_DIR`res/favicon.png" rel="icon"/>
		<meta name="viewport" content="initial-scale=1, maximum-scale=1">
		<meta charset="UTF-8"/>
		</head>')m4_dnl
m4_define(`TITLE', `m4_dnl
		<h1 id="title"><a id="titlelink" href="'ROOT_DIR`index.html">⌈LUNAR GARDEN⌋</a></h1>
		<h4 id="email">'EMAIL_ADDRESS`</h4>
		<div id="navbar">
		<p style="text-align: center;">
		|<a href="'ROOT_DIR`about.html">About</a>|
		|<a href="'ROOT_DIR`art.html">Art</a>|
		|<a href="'ROOT_DIR`blog.html">Blog</a>|
		|<a href="'ROOT_DIR`wired.html">Wired</a>|
		</p>
		</div>')m4_dnl
m4_define(`POST', `m4_dnl
		<div style="text-align: center;" class="panel">
		<h2 id="post$1">Post $1</h2>
		<h4>$2</h4>
		<a href="post/$1.html"><h4>$3</h4></a>
		<h5>-$4</h5>
		<h6><a href="#title">• top •</a></h6>
		</div>')m4_dnl
m4_define(`POST_HEADER', `m4_dnl
		<!DOCTYPE html>
		<!--Author: Todd Gaunt-->
		<html>
		HEADER(POST_TITLE())
		<body>
		TITLE
		<div class="column-center">
		<div class="panel">
		<h2 style="text-align: center">POST_TITLE()</h2>
		<h4 style="text-align: center">POST_DATE()</h4>
		')m4_dnl
m4_define(`POST_FOOTER', `m4_dnl
		<h5 style="text-align: center">-POST_AUTHOR()</h5>
		<h6 style="text-align: center"><a href="'ROOT_DIR()`blog.html#post'POST_NUMBER()`">• return •</a></h6>
		</div>
		</div>
		</body>
		</html>')m4_dnl
m4_define(`IMAGE_POST', `m4_dnl
		<div style="text-align:center" class="panel">
		<h2>$1</h2>
		<h4>$2</h4>
		<a href="'ROOT_DIR`res/art/$2_$3.$4"><img alt="$1" class="gallery" src="'ROOT_DIR`res/art/$2_$3.thumb"></a>
		<h6><a href="#title">• top •</a></h6>
		</div>')m4_dnl
m4_define(`FILES_DIR', ROOT_DIR`files')m4_dnl
m4_define(`EMAIL_ADDRESS', `toddgaunt@protonmail.ch')m4_dnl
