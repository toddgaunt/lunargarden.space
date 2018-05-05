m4_define(`ROOT_DIR', `../')m4_dnl
m4_define(`POST_NUMBER', `5')m4_dnl
m4_define(`POST_TITLE', `Utilizing Particle Swarms to Optimize Hidamari')m4_dnl
m4_define(`POST_DATE', `2018-05-05')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
<p>Now that Hidamari, my implementation of the game Tetris, had a basic
AI that can competently play for 30 minutes to an hour, it was time to optimize
it for indefinite play. After a cursory glance through function optimization
algorithms, particle swarm optimization appealed to me since it seemed fun
to implement, visualize, and easy to parallelize. Correct on all three
marks, my particle swarm was able to discover a highly performant static
evaluation function for Hidamari which allows it to play up to and beyond
500,000 lines cleared.</p>

<p>The particle swarm algorithm used is about the same as the one that can
viewed on <a href="https://en.wikipedia.org/wiki/Particle_swarm_optimization">wikipedia</a>.
Modifications were made to cache the results of the fitness function were possible,
and the particles are processed asynchronously between threads rather than
serially. This modification means that particles will update their velocity based
on incomplete swarm information, since the best global fitness value for the
entire swarm may not be discovered before the iteration completes. In practice
this turns out to not really be an issue. The additional performance in
processing the fitness function in a parallel fashion far outweighs
incomplete particle updates. Especially seeing as the fitness function is the
game of Hidamari itself, which can require minutes to complete in-memory.</p>

<p>This implementation of APSO allows the caller to specify the number of
threads that should divide the work. Each thread is given particles that need
to be processed through a priority queue. The queue is sorted by number of
iterations tracked on the particle, so particles with the fewest iterations
will be prioritized for processing over particles with the most iterations
completed. The calling thread also performs work, so there are no idle threads
waiting around. Finally, the caller can specify the number of iterations to
perform on each particle. If this argument is 0 instead of a positive integer,
iterations will be performed until the process is killed externally.</p>

<p>After writing and testing it, I moved the asynchronous particle swarm
implementation I wrote into a standalone library. This library comes with a
visualization demo, and the download link for the library can be found at the
bottom of this article. The visualization runs until the user closes the
window. The fitness function for the swarm returns the negative distance
between a
particle and where the user last clicked on the window. A negative score is
used here since particle scores are initialized to negative infinity, and
the distance from a particle to the point should be minimized.</p>

<h3 style="text-align: center;">APSO Visualization</h3>
<p>
<video width=100% controls>
  <source src="FILES_DIR/2018-05-05/particle_swarm_visualization_demo.webm">
  Your browser does not support the video tag.
</video>
</p>

<p>This APSO function was used with a non-rendering game of Hidamari as the
fitness function. The visuals were disabled to allow the AI to simulate the
game as fast as possible. The inputs to the fitness function, which were represented
as the three dimensional positions of the particles, were the three
weights for the static evaluation function heuristics. These weights adjusted
how well the AI performed, and the more lines the AI
was able to clear in a given game, the higher the score the fitness function
returned. To be clear, the return value of the fitness function was exactly the
number of lines cleared. This value was capped at 500,000 lines cleared in
order to prevent potentially infinite playtime. Once a particle was able to achieve
a fitness of 500,000 lines cleared, this was considered a maximum score.</p>

<h3>Results of the Swarm Optimizing Hidamari</h3>

<p>A fitness of over 500,000 lines cleared could be considered as playing
indefinitely, since this amounts to a score of around 500,000,000 points in
most Tetris games, where getting 1,000,000 points is considered impressive
amongst even very skilled players. The swarm ended up finding multiple
weights that allowed the AI to play for 500,000 lines. This was expected
as the weights need only be within a certain ratio relative to each other, but
what was unexpected was that completely separate ratios of weights were found
that worked equally well. Among the successful weights that were produced,
I picked to use the following to use:</p>

<table style="margin: auto;">
	<tr>
		<th>Heuristic</th>
		<th>Weight</th>
	</tr>
	<tr>
		<td>H0, total column height</td>
		<td>0.848058</td>
	</tr>
	<tr>
		<td>H1, total column difference</td>
		<td>2.304684</td>
	</tr>
	<tr>
		<td>H3, total number of holes</td>
		<td>1.405450</td>
	</tr>
</table>

<p>With these heuristic weights, the AI now performs much better and can play
for longer periods of time than my previous weights that were discovered
through manual guesswork. Another change that was made to the AI for Hidamari
was to evaluate the board for every single piece dropped rather than every two
pieces. This allowed for more look-ahead per piece, and the additional
computation required is negligible.</p>

<p>These weights were computed with a 200 particle swarm with each
particle performing 100 iterations. Even with 4 threads used to parallelize the
computation it took days to complete. This was due to the
fact that higher fitness scores simply required longer to compute, since a high
fitness meant playing Hidamari for a longer period of time. Although the
particle swarm was able to find fairly good weights early on into the
computation, so much of the duration of the process was simply refining the
particles to converge.</p>

<p>Future plans for Hidamari are to include an in-game menu for selecting and
tuning the AI, as well as an option to disable it so that the game can be
played by the user instead of the AI. As well as solo-play, a versus mode will
be introduced allowing play against another player, as well as being able to
play against the AI. In order to provide a more realistic versus experience,
the AI will have an option to customize how slowly it executes its plan, as well
as how many noisy actions should be included in the plan to worsen how well it
plays.</p>

<h3>Downloads</h3>

<p>If you're interested in running the AI, you can download the source
tarball: <a href="FILES_DIR/2018-05-05/hidamari.tar.gz">hidamari.tar.gz</a>, or
pull the latest version with git: (Unavailable at this time).</p>

<p>The APSO library is also available for download here: <a href="FILES_DIR/2018-05-05/libapso.tar.gz">libapso.tar.gz</a>, or
able to be pulled with git: (Unavailable at this time).</p>

<p>SDL2 is a requirement for both programs. To run the visualizer, simply
run 'make all' and then './apso-tool-vis &lt;number of particles&gt;'. To use
the  library itself, consult the README.md for instructions.</p>
POST_FOOTER
