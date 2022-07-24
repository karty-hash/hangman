require 'csv'
require 'yaml'

class Game
  attr_accessor :chance, :rand_word, :rand_arr, :blank
  
  def initialize
    @chance
    @rand_word
    @rand_arr
    @blank
    @guess
    @arr_index
    @new_game
  end

  private
  def starter
    CSV.open('google-10000-english.txt')
  end

  def opener
    puts "Please enter 1 to start a new game or 2 to load a saved game."
    gets.chomp.to_i
  end
  
  private
  def arr_of_words
    arr = []
    starter.each do |num|
      num = num.join
      if num.length <= 12 && num.length >= 5
        arr << num
      end
    end
    arr
  end
  
  private
  def random_word
    random = arr_of_words.sample.downcase
    random
  end
  
  private
  def random_word_arr(word)
    arr_word = word.split("")
    arr_word
  end
  
  private
  def blanks(word)
    blank = Array.new(word.length, "-")
    blank
  end
  
  private
  def game_condition(guess)
    guess.match?(/\A[a-zA-Z']*\z/) && guess.length == 1
  end
  
  private
  def game_rule(rand,guess)
    rand.include?(guess)
  end
  
  private
  def find_index_blank(rand_arr, guess)
    rand_arr.each_index.select{|i| rand_arr[i] == guess }
  end
  
  private
  def replace_blank(arr_index, guess, blank)
    arr_index.each{|num| blank[num] = guess}
  end

  private
  def save_game(characters, file)
    yaml = characters
    new_file = File.open(File.join('my_game', file), "w")
    new_file.puts(yaml)
  end

  private
  def load_game(file)
    new_file = File.open(File.join('my_game', file), "r")
    yaml = new_file.read
    data = YAML.load(yaml)
    @chance = data[:chance]
    @rand_word = data[:rand_word]
    @rand_arr = data[:rand_arr]
    @blank = data[:blank]
  end

  private
  def obj_to_yaml
    YAML.dump({
      :chance => @chance,
      :rand_word => @rand_word,
      :rand_arr => @rand_arr,
      :blank => @blank
     })
  end

  private
  def game_loop

    while @chance < 12
      puts "Chance no #{@chance + 1}"
      puts "Please enter an alphabet of your choice or type 'save' to save the progress of your game."
      @guess = gets.chomp
      if @guess == 'save'
        puts "Please enter file name"
        file = gets.chomp
        file = "#{file}.yaml"
        if Dir.exists?(file)
          puts "File name already exists. Please enter alternative name."
          next
        end
        save_game(obj_to_yaml, file)
        break
      end
      if game_condition(@guess)
        if game_rule(@rand_word,@guess)
          @arr_index = find_index_blank(@rand_arr, @guess)
          replace_blank(@arr_index, @guess, @blank)
          puts @blank.join("")
        else 
          puts @blank.join("")
        end
      else
        puts "Invalid entry! Please enter a valid alphabet."
        next
      end
      if @rand_arr == @blank
        puts "Congratulations! You win."
        break
      end
      if @chance == 11
        puts "You lose! The word is #{@rand_word}"
        break
      end
      @chance += 1
      end

  end

  
  public
  def game_play
    @chance = 0
    @new_game = opener
    @rand_word = random_word
    @rand_arr = random_word_arr(@rand_word)
    @blank = blanks(@rand_arr)
    if @new_game == 1
        game_loop
    elsif @new_game == 2
        arr = []
        saved_game = Dir.glob('my_game**/*')
        
        saved_game.select do |h|
          arr << File.basename(h)
        end
        puts "Please enter your file name from the given list of saved games: \n#{arr.join(", ")} "
        file_name = gets.chomp
        if arr.include?(file_name)
          load_game(file_name)
          game_loop
        else
          puts "Invalid file name."
          Game.new.game_play
        end
    else 
      puts "Invalid option"
      Game.new.game_play
    end
  end
end


games = Game.new
games.game_play