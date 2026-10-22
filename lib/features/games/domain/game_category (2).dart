/// The three top-level groupings shown on the Games tab.
enum GameCategory {
  guess('Guess', 'Identify the country from a clue'),
  name('Name', 'Type as many countries as you can'),
  speed('Speed', 'Race the clock');

  const GameCategory(this.label, this.description);

  final String label;
  final String description;
}
