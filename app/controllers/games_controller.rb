class GamesController < ApplicationController

  before_action :set_game, only: [:create, :update, :show]

  def index
    @@games ||= {}
  end

  def create
    @game.join(params[:name])
    session[:player_name] = params[:name]

    redirect_to game_path(@game.name)
  end

  def update

    if @game.players[0].to_s == session[:player_name]
      @game.play(session[:player_name], params[:x].to_i, params[:y].to_i, 'X')
    else
      @game.play(session[:player_name], params[:x].to_i, params[:y].to_i, 'O')
    end

    redirect_to game_path(@game.name)

  rescue Game::SpotTaken, Game::PlayOutOfTurn, Game::GameOver => e
    redirect_to game_path(@game.name), notice: e.class.to_s.demodulize.titleize
  end

  def show
  end

  private

  def set_game
    game_id = params[:id]
    @game = @@games[game_id] ||= Game.new(game_id)
  end

end

class Game
  SpotTaken = Class.new(StandardError)
  PlayOutOfTurn = Class.new(StandardError)
  GameOver = Class.new(StandardError)

  FirstPlayVal = 'X'

  attr_reader :players, :name, :data, :winner, :last_player

  def initialize(name)
    @name = name
    @players = []
    # @data = 3.times.map { 3.times.map { '' } }
    @data = Array.new(3) { Array.new(3) }
  end

  def join(player_name)
    players << player_name
  end

  def play(player_name, x, y, mark)
    raise GameOver if find_winner_play
    raise SpotTaken if data[x][y].present?
    raise PlayOutOfTurn if @last_player == player_name

    data[x][y] = mark.to_s.upcase #player_name
    @last_player = player_name

    # check if someone has won the game
    @winner = @last_player if find_winner_play
  end

  private

  def find_winner_play
    winning_combinations.each do |combination|
      #move to next array if array only contain nils
      next if combination.compact.empty?

      unique_tokens = combination.uniq

      return unique_tokens.first if unique_tokens.size == 1
      # return unique_tokens.size == 1
    end
    nil
  end

  def winning_combinations
    [
        data[0], data[1], data[2], # horizontal
        *3.times.map { |c| [data[0][c], data[1][c], data[2][c]] }, # vertical
        [data[0][0], data[1][1], data[2][2]], # diagonal left to right
        [data[0][2], data[1][1], data[2][0]] # diagonal right to left
    ]
  end
end
