Rails Chess App Rebuild
======

### Rebuild of an earlier chess portfolio application - [Chess App Rails]()

------

Purpose for this Rebuild
------

I built the original version of this application 7 years ago as a Portfolio Project when I was still green with Software Development generally. The original code is of poor quality and did not leverage patterns or even great practices for modeling the data itself. I originally had considered refactoring the code, but given the poor code quality and the fact I'd need to bump the Rails version through multiple major releases, I decided to just start fresh with a rebuild.

Introduction and Requirements
------

Seven years ago, while still learning programming, I had coded a RoR Chess application as a portfolio item. Looking back, the architecture of the application is not good, neither is the code organization or database design. It works, but just isn’t a very well built application featuring good quality code. It’s time to revisit that, and I think that this exercise will provide a solid litmus for how my skills have improved and provide the opportunity to expand my knowledge of more current Rails technologies like Hotwire et al.

The project will likely be broken into two phases, a prototype/phase 1 that will feature the core functioning components of the application, including the game mechanics and general project structure. Phase two will increase user dashboard functionality, allow multiplayer, and will likely integrate an ML microservice to allow for an adaptable AI that’s user specific.

Phase 1 Requirements
------

- Users can initiate a game of chess, and play until complete or save game for later. Optionally allow for take backs.
- Games should be stored and associated with the User/Player.
- All pieces move according to their basic and special moves (ie castling and en passant)
- The computer should make at least semi-intelligent move decisions.
- The application should feature a well designed UI.

Models
------

![UML Model Diagram.jpeg](https://www.dropbox.com/scl/fi/6eg4ksjdxplb70orud1gi/Jackson-Diagram-Basic-CPU-Moves.jpg)

- #### User/Player
   - Contains account info and display name
   - Has many **Games**
- #### Games
   - Each individual game of chess
   - Multiple states:
      - Complete
      - In Progress
      - Paused/Saved
      - Abandoned
   - Has a black and a white player (In phase 1 there will be a CPU and a User)
   - Will record the winner of the game
   - Has Many Pieces
   - Has Many Turns
- #### Pieces
   - One to one Game and Player
   - Color
   - Will have **type** whose mechanics will be controlled by modules
   - Rank - Integer for weighting piece value
   - Active? - alive or dead
   - Checked? - Mostly king Perhaps this should be in the **Game** module?
   - Moved? - useful for en passant and castle
   - Position
- #### Turn
   - Piece - the piece moved
   - piece_killed - if takes a piece, then this should include the ID of the piece killed, else NULL
   - starting position
   - ending position

Controllers
----

- #### Player
   - index → list all
   - create → create new
   - destroy → delete
   - update → name, email, info, etc…
- #### Game
   - index → lists of games
   - show → directs to game board
   - create → initializes new game, set players
   - update → state, winner
- #### Pieces
   - index → probably not used but generally included, likely scoped to game
   - most actions controlled through model methods and modules
   - move → a POST action where the player moves a piece, update piece position
      - This action will undergo validation in the model and return an error if incorrect
- #### Turn
   - index → returns a list of turns, probably not used much and likely scoped to game

Chess Service
----

For structuring the Game logic itself, I’ll likely generate a service object that will pull in from multiple subdirectory Modules. While this isn’t traditionally what a service pattern would be “for”, it seems to be the best general pattern for housing this logic without fattening up the Models and Controllers. The Chess service will likely feature a main Class that can include various modules and expose specific methods/actions needed for performing tasks such as initializing games and validating piece moves, as well as housing the logic for the CPU to make its moves.

Proposed structure:

- Services/Chess/
   - Chess.rb - Main class/interface
   - Modules/
      - PieceMoves.rb - effectively a switch and includes from subdir
      - Pieces/
         - Pawn.rb
         - Knight.rb
         - Rook.rb
         - Bishop.rb
         - King.rb
         - Queen.rb
      - ChessInitialization.rb
      - Chess.yml - contains data for initializing the game, like pieces and starting pos
      - CPULogic.rb - this module will likely expand significantly

#### CPU Logic

The most essential part of this feature is giving the cpu some visibility into context of the game. It must first analyze all the available moves for it’s pieces, as well as potential moves for the player’s pieces. Each potential move should be assigned a weighted value after the analysis period in order to determine the best move. I am thinking the moves could be stored as an array of hashes that represent the move as key, and the point/weighted value of the move as the value. The move with the highest value should be chosen.

The basic flow is something like an iterative version item that can analyze the moves for each piece, and then analyze possible outcomes of each move to some nth degree:

![Jackson Diagram Basic CPU Moves.jpeg](Chess%20Application%20Refactor.assets/Jackson%20Diagram%20Basic%20CPU%20Moves.jpeg)

First it needs to determine which pieces are currently threatened, and which enemy pieces are available for attack. If the piece is threatened, then this will add weight to the piece’s moves, a constant multiplied by the piece’s rank. More valuable pieces that are threatened need to be prioritized.

**Payoff Matrix**

1. For every piece with available moves, determine whether the piece is threatened and it’s value. If so, moving the piece represents a positive constant to add to the ranting for each move.
2. Calculate the value for each move. If it can attack, then add the value of the piece taken.
3. Then, calculate the value of each enemy move, and average for a general payoff value that will be subtracted from the original rating.
4. Calculate the payoff for each available cpu move, avg then add to the value.
5. Steps 3 and 4 above can be repeated a few times.
6. To get the optimal move, choose the move with the highest rating. If there’s a tie, randomize between the highest ratings.

Views
----

   One major plan for the execution of this application is to experiment with Rails’ Hotwire and Action Cable.

Mockups & Wireframes
----

![ChessApplicationFlow.png](Chess%20Application%20Refactor.assets/ChessApplicationFlow.png)

**Landing Page**

![Landing page mobile.png](Chess%20Application%20Refactor.assets/Landing%20page%20mobile.png)

![Landing Page Desktop.png](Chess%20Application%20Refactor.assets/Landing%20Page%20Desktop.png)

![Game Page Mobile.png](Chess%20Application%20Refactor.assets/Game%20Page%20Mobile.png)

![Game Page Desktop.png](Chess%20Application%20Refactor.assets/Game%20Page%20Desktop.png)

![Games Index Mobile.png](Chess%20Application%20Refactor.assets/Games%20Index%20Mobile.png)

### Style Guide and Branding

![ChessAppMoodboard.png](Chess%20Application%20Refactor.assets/ChessAppMoodboard.png)

General themes:

![ChessAppPalette.jpeg](Chess%20Application%20Refactor.assets/ChessAppPalette.jpeg)

Game States
------

- **Player Turn** → following a player making a move, game state should be updated to reference the next player.
   - after a successful Piece update for positions, then add referenced position change to turn. Then increment Turn State in the game flow. This state should be accessible in the presenter to disable the previous player from making a move. Can probably also add a constraint in the validations to ensure it is the players turn.
   - If one of the players is CPU, this is when it should make a move
- **Game** → the general game state
   - In progress
   - Complete
      - Win → a player’s king is in check and has no available moves
      - Stalemate → Insufficient Material or King not in check but has no moves
      - Abandoned → Likely initiate through a Cron Job.

### Piece State

- **Check** → king specific, is king in check?


