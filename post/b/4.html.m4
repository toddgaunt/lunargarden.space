m4_define(`ROOT_DIR', `../../')m4_dnl
m4_define(`POST_NUMBER', `b/4')m4_dnl
m4_define(`POST_TITLE', `An Efficient AI for Hidamari')m4_dnl
m4_define(`POST_DATE', `2018-04-26')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
<p>In my last article, <a href="3.html">A Bit Board Representation for Hidamari</a>,
I discussed the compact bit board format for representing the game state of
Hidamari which would be used in the AI for the game. That AI is nearly
finished, and is already performing surprisingly well for how simple it
actually is.</p>
<p>The plan was to do a depth-first search through all the 
important states of the game, evaluate their value, and then do another search
through the stochastic parts of the tree for further predicted lookahead. The
second stochastic search ended up being unnecessary, as the two pieces of
deterministic lookahead proved to be enough to play well. 
In this context, an "important" state of the game is defined as a state where
a piece is locked into the field as far down as it can possibly be placed. This
is visualized by the image below:</p>

<p>
<img class="img-center" width=100% src="FILES_DIR/2018-04-26/hidamari_state_space_search.png"
	alt="Visualization of a state space search in hidamari">
</p>

<p>The maximum depth used for the current implementation of the AI is a depth
of 2, since both the current piece and next piece are known. Another
feature of the current implementation is that it uses a fixed 180kb of
memory for the entire search. The allocation scheme used is a simple
stack-allocator, so allocations made during the search are very fast. Once
the search is finished, the stack pointer of the 180kb is reset back to
the beginning. This means no additional memory is allocated during the main
game loop past initialization.</p>

<p>Each state at the maximum depth-bound is evaluated for how desirable it is
to be in that state, and the lowest score achieved is the winner. As the AI
searches through the tree it keeps a reference to the lowest scored state,
and compares each new maximum depth-bound state with the reference, and
replaces the reference with it if it has a lower score. Once all states have
been visited, the plan is made from walking back up the tree using the best
scoring reference as the goal. The evaluation function is made up of three
different heuristics used to score a given state.</p>

<p>
<img class="img-center" width=100% src="FILES_DIR/2018-04-26/hidamari_heuristics.png"
	alt="Visualization of the heuristics">
</p>

<p>The first heuristic used is to count the number of "holes" in the playfield.
A hole is defined as any open tile that has a tile above it anywhere in the
same column. Each hole is difficult to fill, since it would require clearing all
the lines above it, they should be avoided whenever possible.</p>

<p>The second heuristic used sums the height of each column.
Keeping the aggregate height of the field is desirable, as once the 20 height
limit is broken the game ends.</p>

<p>The third heuristic used sums the difference in height of each column
and its neighbor. This creates a "bumpiness" value. A bumpy playfield is
undesirable, as it makes fitting most pieces more difficult.</p>

<p>Each of the heuristics is given a weighting deemed on its importance. For
instance, the "holes" heuristic gets a multiplier of 10 times, since holes
are very undesirable, and the other two attributes are less dangerous than
holes. These multipliers can be adjusted to make the AI perform better or
worse. The current multipliers were discovered through a small amount of trial
and error, however a genetic algorithm could be used to adjust the multipliers
until the most suitable could be found. Currently there are no plans to do such
a thing, but it is a possibility in the future to improve performance of the
AI.</p>

<h3 style="text-align: center;">Video Demonstration</h3>
<p>
<video width=100% controls>
  <source src="FILES_DIR/2018-04-26/hidamari_ai_demo.webm">
  Your browser does not support the video tag.
</video>
</p>

<p>If you're interested in running the AI, you can download the source
tarball: <a href="FILES_DIR/2018-04-26/hidamari.tar.gz">hidamari.tar.gz</a>, or
pull the latest version with git: (Unavailable at this time).</p>
POST_FOOTER
