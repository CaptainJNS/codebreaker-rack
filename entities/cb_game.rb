class CBGame
  include CodebreakerCaptainjns
  include DataUtils

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
    when '/' then main
    when '/rules' then Rack::Response.new(render('rules.html.erb'))
    when '/statistics' then Rack::Response.new(render('statistics.html.erb'))
    when '/start' then start
    when '/play_again' then play_again
    when '/check' then check
    when '/lose' then lose
    when '/game' then game
    when '/win' then win
    when '/show_hint' then show_hint
    else Rack::Response.new('Not Found', 404)
    end
  end

  private

  def main
    return redirect('game') if @request.session.key?(:game)

    Rack::Response.new(render('menu.html.erb'))
  end

  def play_again
    @request.session.delete(:game)

    redirect
  end

  def start
    return redirect('game') if @request.session.key?(:game)

    return redirect unless @request.params.key?('player_name')

    @request.session.delete(:result)
    @request.session[:hints] = []
    @request.session[:save] = false
    name = @request.params['player_name']
    difficulty = @request.params['level']
    @request.session[:game] = Game.new(name: name, difficulty: difficulty)
    redirect('game')
  end

  def game
    return redirect unless @request.session.key?(:game)

    return redirect('lose') unless @request.session[:game].attempts.positive?

    return redirect('win') if @request.session[:game].win

    Rack::Response.new(render('game.html.erb'))
  end

  def show_hint
    return redirect unless @request.session.key?(:game)

    @request.session[:hints] << @request.session[:game].use_hint if @request.session[:game].hints.positive?
    redirect('game')
  end

  def check
    return redirect unless @request.params.key?('number')

    @request.session[:result] = @request.session[:game].check(@request.params['number'])

    if @request.session[:game].win
      save_results unless @request.session[:save]
      return redirect('win')
    end

    redirect('game')
  end

  def lose
    return redirect unless @request.session.key?(:game)

    return redirect('game') if @request.session[:game].attempts.positive?

    Rack::Response.new(render('lose.html.erb'))
  end

  def win
    return redirect unless @request.session.key?(:game)

    return redirect('game') unless @request.session[:game].win

    Rack::Response.new(render('win.html.erb'))
  end

  def render(template)
    path = File.expand_path("../../templates/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def redirect(address = '')
    Rack::Response.new { |response| response.redirect("/#{address}") }
  end

  def save_results(path = nil)
    att_total = @request.session[:game].calc_attempts_and_hints(@request.session[:game].difficulty)[0]
    hints_total = @request.session[:game].calc_attempts_and_hints(@request.session[:game].difficulty)[1]
    summary = {
      name: @request.session[:game].name,
      difficulty: @request.session[:game].difficulty,
      att_total: att_total,
      att_used: att_total - @request.session[:game].attempts,
      hints_total: hints_total,
      hints_used: hints_total - @request.session[:game].hints,
      date: Time.now
    }
    save(summary, path)
  end

  def stats(path = nil)
    return [] unless File.exist?('SEED.yaml')

    table = load(path).sort_by { |row| [row.hints_total, row.att_used] }
    table.map { |row| row.difficulty = GameLogic::DIFFICULTY_HASH.key([row.att_total, row.hints_total]) }
    table
  end
end
