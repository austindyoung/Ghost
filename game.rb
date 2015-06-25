require_relative 'trie'
require 'byebug'

class Game

  attr_accessor :current_dictionary, :starting_dictionary, :fragment, :num_players, :fragment, :current_player_index, :previous_player_index, :players, :player_status
  def initialize
    @players = {}
    player_initialization
    @previous_player_index
    @current_player_index = 1
    @starting_dictionary = Trie.new
    @player_status = (1..players.size).to_a.map { |i| [players[i], 0] }.to_h
    (File.readlines("ghost-dictionary.txt").map(&:chomp)).each do |word|
      starting_dictionary.insert(word)
    end
    @current_dictionary = starting_dictionary.dup
  end

  def reset_dictionary
    self.current_dictionary = starting_dictionary.dup
  end

  def player_initialization
    players_prompt
    num_players = gets.chomp.to_i
    (1..num_players).each do |i|
      name_prompt
      players[i] = HumanPlayer.new(gets.chomp)
    end
  end

  def players_prompt
    puts "How many players?"
  end

  def name_prompt
    puts "What's your name?"
  end

  def update_dictionary(letter)
    self.current_dictionary = current_dictionary.root.subtrees[letter]
  end

  def is_word?
    current_dictionary.root.is_word
  end

  def fragment
    current_dictionary.root.word
  end

  def game
    until is_word?
      p player_status
      prompt
      input = players[current_player_index].enter_letter
      validate(input)
      update_dictionary(input)
      display
      next_player!
    end
    update_loser_status
    display_loser_status
    display_game_status
    reset_dictionary
  end

  def set
    until current_player_loses?
      game
    end
    puts "#{players[previous_player_index]} is out of the match!"
    get_new_first_player
    reassign_player_index
  end

  def match
      until match_over?
        set
      end
      puts "#{player_status.keys[0].name} wins!"
  end

  def match_over?
    self.player_status = player_status.select { |idx, status| status != 5 }
    player_status.size == 1
  end

  def current_player_loses?
    player_status[players[previous_player_index]] == 5
  end

  def get_new_first_player
    self.current_player_index = self.previous_player_index % (players.size - 1)
  end

  def reassign_player_index
    next_index = 1
    new_players_hash = {}
    players.each do |idx, player|
      next if idx == previous_player_index
       new_players_hash[next_index] = player
       next_index += 1
     end
     self.players = new_players_hash
  end

  def update_loser_status
    player_status[players[previous_player_index]] += 1
  end

  def display_loser_status
    puts "#{players[previous_player_index]} loses. They now have #{to_ghost_string(player_status[players[previous_player_index]])}"
  end

  def to_ghost_string(status)
    "GHOST"[0...status]
  end

  def display_game_status
    puts "Current scores: "
    player_status.each do |k, v|
      puts "#{k.name} score : #{to_ghost_string(v)}"
    end
  end


  def validate(input)
    until valid_syntax?(input) && fragment_is_prefix?(input)
      if !valid_syntax?(input)
        puts "Not a letter"
      else
        puts "#{fragment} is not a prefix"
      end
      input = players[current_player_index].enter_letter
    end
  end

  def valid_syntax?(input)
    ("a".."z").to_a.include?(input)
  end

  def fragment_is_prefix?(letter)
    !!current_dictionary.root.subtrees[letter]
  end

  def prompt
    puts "#{players[current_player_index].name}, what letter do you want to add to the fragment?"
  end

  def next_player!
    self.previous_player_index = current_player_index
    self.current_player_index = (current_player_index) % players.size + 1
  end

  def display
    system("clear")
    print "Current word is: "
    puts fragment
  end

end

class HumanPlayer
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def enter_letter
    gets.chomp
  end

end

if __FILE__ == $PROGRAM_NAME
  Game.new.match
end
