m4_define(`ROOT_DIR', `../')m4_dnl
m4_define(`POST_NUMBER', `3')m4_dnl
m4_define(`POST_TITLE', `Bit Board Representation for Hidamari')m4_dnl
m4_define(`POST_DATE', `2018-04-17')m4_dnl
m4_define(`POST_AUTHOR', `Todd Gaunt')m4_dnl
m4_include(`site.m4')m4_dnl
POST_HEADER
<p>In order to write an AI for Hidamari, my implementation of Tetris, first a representation of the game
state that could use very little memory had to be devised. While the original
implementation, a 2D array of 8-byte integers, could suffice as it only
measured up to 624 bytes, a smaller footprint could be achieved by changing
the game representation to a bit board of 16-bit integers. That is a binary
representation
of the game state, where an array of 16-bit integers is kept. Each integer
represents one row of the playfield, and each bit represents a tile as either
being occupied or empty. The size of the bit board
implementation being shared in this article measures up to only 108 bytes per
state, about 17% the size of the original representation. This can allow
for a much larger and faster state-space search to be applied to the game,
which in turn allows for better decisions to made by the AI.</p>

<p>Another benefit to switching to a bitboard representation is the
simplification of many of the operations on the board, such as collision
detection and movement being changed to fast bitwise operations instead of
looping and comparing integers over an entire row. The operations performed by
the AI during the state-space search will be faster than before,
allowing for more states to be observed before a decision must be
made on the move to use on the current falling piece.</p>

<p>The downside to representing the game state this way is that it necessitates
additional layers of information to store colors and textures of the tiles
on the playfield. This, however, is also a good thing since it detaches
unnecessary graphical information from the necessary information about the game state.
Rather than implementing two distinct versions of the game, any extra state
information can be added on and used by the graphical implementation seperately.</p>


<h3>Bitboard State Representation</h3>
<pre><code class="C">typedef struct {
	Vec2 pos; /* Top-left position */
	HidamariShape shape : 4;
	uint8_t orientation : 3;
} Hidamari;

typedef struct {
	/* Scoring */
	uint8_t level;
	uint16_t score; 
	uint16_t lines; 
	/* Timing */
	float gravity_timer; 
	uint8_t slide_timer;
	/* Randomization */
	uint8_t bag_pos : 4; /* Current position in the bag */
	HidamariShape bag[7]; /* Random Bag, used for pseudo-random order */
	/* Hidamaries */
	HidamariShape next : 4; /* Lookahead piece for player */
	Hidamari current;
	uint16_t grid[HIDAMARI_HEIGHT]; /* Represents static Hidamaries */
} HidamariPlayField; </code></pre>

<h3>Original State Representation</h3>
<pre><code class="C">typedef struct {
        int x, y; /* Position of the matrix in space */
        uint8_t mlen; /* Length of each side of the matrix */
        uint8_t matrix[4][4]; /* Matrix of current hidamari */
} Hidamari;

typedef struct {
        /* Scoring */
        size_t level;
        size_t score;
        size_t lines;
        /* Timing */
        float gravity_timer;
        uint8_t slide_timer; /* Counts ticks for hidamari sliding */
        uint8_t bag_pos; /* Current position in the bag */
        HidamariShape bag[7]; /* Current random bag, used for generating next pieces */
        HidamariShape next[1]; /* Lookahead piece for player */
        Hidamari current; /* Current piece information */
        /* The grid uses a mailbox representation, with the outer edges being
         * permanently frozen wall pieces */
        uint16_t grid[HIDAMARI_WIDTH][HIDAMARI_HEIGHT];
} Playfield;</code></pre>

POST_FOOTER
