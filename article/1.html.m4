m4_define(`ROOT_DIR', `../')m4_dnl
m4_define(`POST_NUMBER', `1')m4_dnl
m4_define(`POST_TITLE', `Hidamari')m4_dnl
m4_define(`POST_DATE', `2018-02-15')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
<p>Since I've never gotten around to doing it, yesderday I decided to implement
a light and fast tetris-clone in C and SDL. It follows the official tetris
guidelines as close as possible, as described
<a href="http://tetris.wikia.com/wiki/Tetris_Guideline">here</a>. The
source code is written in such a way that it mimics the official
guidelines naming conventions, and tries to be as clear as possible. Below is
a gameplay demo:<p>

<video width=100% controls>
  <source src="FILES_DIR/2018-02-15/hidamari_demo.webm">
  Your browser does not support the video tag.
</video>

<p>Current plans to extend this implementation are to add "wall kicks", a
score and line counter display, an ncurses renderer, and networked play for
at least two players. Other modes could also be added on quite easily at some
point later in time.</p>

<p>If you're interested in playing, you can download the source
tarball: <a href="FILES_DIR/2018-02-15/hidamari.tar.gz">hidamari.tar.gz</a>, or
pull the latest version with git: (Unavailable at this time).</p>
POST_FOOTER
