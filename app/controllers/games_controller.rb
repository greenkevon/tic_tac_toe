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
    @game.play(session[:player_name], params[:x].to_i, params[:y].to_i)

    redirect_to game_path(@game.name)
  rescue Game::SpotTaken
    redirect_to game_path(@game.name), error: 'Spot taken'
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

  attr_reader :players, :name, :data

  def initialize(name)
    @name = name
    @players = []
    @data = 3.times.map { 3.times.map { '' } }
  end

  def join(player_name)
    players << player_name
  end

  def play(player_name, x, y)
    if data[x][y].present?
      raise SpotTaken
    else
      data[x][y] = player_name
    end

    # check if someone has won the game
  end

end
