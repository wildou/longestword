require 'open-uri'
require 'json'

class LettersController < ApplicationController
  def game
    @start_time = Time.now
    @grid = []
    (1..10).each { @grid << ("A".."Z").to_a.sample(1) }
    @grid
  end

  def score
    @word = params[:word]
    @random_grid = params[:random_grid]
    @time = 0
    @end_time = Time.now
    @time =  @end_time - Time.parse(params[:start_time])
    @time = @time.round
    @translate = attempt_exist(@word)
    @result = run_game(@word, @random_grid, Time.parse(params[:start_time]), @end_time)
  end

  def attempt_in_grid?(grid, attempt)
    result = true
    attempt_array = attempt.upcase.split("")
    attempt_array.each do |letter|
      result &&= grid.count(letter) >= attempt_array.count(letter)
    end
    return result
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time, translation: nil, score: 0, message: "well done" }
    if attempt_in_grid?(grid, attempt) == false
      result[:message] = "not in the grid"
    elsif attempt_exist(attempt).nil?
      result[:message] = "not an english word"
    else
      result[:translation] = attempt_exist(attempt)
      result[:score] = attempt.length - result[:time]
    end
    return result
  end

  def attempt_exist(attempt)
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt.downcase}"
    api_back = JSON.parse(open(api_url).read)
    if api_back["term0"].nil?
      return nil
    else
      return api_back["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
    end
  end

end
