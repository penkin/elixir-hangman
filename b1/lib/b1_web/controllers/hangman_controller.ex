defmodule B1Web.HangmanController do
  use B1Web, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def new(conn, _params) do
    game = Engine.new_game()
    conn
    |> put_session(:game, game)
    |> redirect(to: ~p"/hangman/current")
  end

  def update(conn, %{"make_move" => %{"guess" => guess}}) do
    conn
      |> get_session(:game)
      |> Engine.make_move(guess)

    redirect(conn, to: ~p"/hangman/current")
  end

  def show(conn, _params) do
    tally =
      conn
      |> get_session(:game)
      |> Engine.tally()
    render(conn, "game.html", tally: tally)
  end
end
