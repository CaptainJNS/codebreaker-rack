class CBGame
  include CodebreakerCaptainjns
  include DataUtils

  TOTAL_SIGNS = 4

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
    start_redirect || start_initialize
  end

  def game
    game_redirect || Rack::Response.new(render('game.html.erb'))
  end

  def show_hint
    return redirect unless @request.session.key?(:game)

    @request.session[:hints] << @request.session[:game].use_hint if @request.session[:game].hints.positive?
    redirect('game')
  end

  def check
    return redirect unless @request.params.key?('number')

    @request.session[:result] = @request.session[:game].check(@request.params['number'])

    return redirect('game') unless @request.session[:game].win

    save(summary) unless @request.session[:save]
    redirect('win')
  end

  def lose
    lose_redirect || Rack::Response.new(render('lose.html.erb'))
  end

  def win
    win_redirect || Rack::Response.new(render('win.html.erb'))
  end

  def render(template)
    path = File.expand_path("../../templates/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def redirect(address = '')
    Rack::Response.new { |response| response.redirect("/#{address}") }
  end

  def summary
    att_total, hints_total = @request.session[:game].calc_attempts_and_hints(@request.session[:game].difficulty).first(2)
    {
      name: @request.session[:game].name,
      difficulty: @request.session[:game].difficulty,
      att_total: att_total,
      att_used: att_total - @request.session[:game].attempts,
      hints_total: hints_total,
      hints_used: hints_total - @request.session[:game].hints,
      date: Time.now
    }
  end

  def stats
    return [] unless File.exist?('SEED.yaml')

    load.sort_by { |row| [row.hints_total, row.att_used] }
  end

  def start_initialize
    default_setting
    @request.session[:game] = Game.new(@request.params.slice('username', 'difficulty'))
    redirect('game')
  end

  def default_setting
    @request.session.merge!(
      result: nil,
      hints: [],
      save: false
    )
  end

  def game_redirect
    return redirect unless @request.session.key?(:game)

    return redirect('lose') unless @request.session[:game].attempts.positive?

    redirect('win') if @request.session[:game].win
  end

  def start_redirect
    return redirect('game') if @request.session.key?(:game)

    redirect unless @request.params.key?('username')
  end

  def lose_redirect
    return redirect unless @request.session.key?(:game)

    redirect('game') if @request.session[:game].attempts.positive?
  end

  def win_redirect
    return redirect unless @request.session.key?(:game)

    redirect('game') unless @request.session[:game].win
  end
end
