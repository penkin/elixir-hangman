defmodule ImplGameTest do
  use ExUnit.Case
  doctest Engine.Impl.Game

  alias Engine.Impl.Game

  test "new game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initialising
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("elixir")
    assert game.letters == ["e", "l", "i", "x", "i", "r"]
  end

  test "new game letters are lower case" do
    game = Game.new_game()
    assert game.letters |> Enum.join() |> String.downcase() == game.letters |> Enum.join()
  end

  test "state doesn't change if a game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("elixir")
      game = Map.put(game, :game_state, state)
      {new_game, _tally} = Game.make_move(game, "z")

      assert game == new_game
    end
  end

  test "records letters used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "a")
    {game, _tally} = Game.make_move(game, "b")
    {game, _tally} = Game.make_move(game, "c")

    assert MapSet.equal?(game.used, MapSet.new(["a", "b", "c"]))
  end

  test "a duplicate letter is reported" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "a")
    assert game.game_state != :already_used

    {game, _tally} = Game.make_move(game, "z")
    assert game.game_state != :already_used

    {game, _tally} = Game.make_move(game, "a")
    assert game.game_state == :already_used
  end

  test "we regognise a letter in the word" do
    game = Game.new_game("elixir")
    {_game, tally} = Game.make_move(game, "l")
    assert tally.game_state == :good_guess

    {_game, tally} = Game.make_move(game, "i")
    assert tally.game_state == :good_guess
  end

  test "we regognise a letter that is not in the word" do
    game = Game.new_game("elixir")
    {_game, tally} = Game.make_move(game, "z")
    assert tally.game_state == :bad_guess

    {_game, tally} = Game.make_move(game, "l")
    assert tally.game_state == :good_guess

    {_game, tally} = Game.make_move(game, "y")
    assert tally.game_state == :bad_guess
  end

  test "can handle a sequence of moves" do
    [
      # guess, state, turns left, letters, used
      ["z", :bad_guess, 6, ["_", "_", "_", "_", "_", "_"], ["z"]],
      ["z", :already_used, 6, ["_", "_", "_", "_", "_", "_"], ["z"]],
      ["e", :good_guess, 6, ["e", "_", "_", "_", "_", "_"], ["z", "e"]],
      ["y", :bad_guess, 5, ["e", "_", "_", "_", "_", "_"], ["z", "e", "y"]]
    ]
    |> test_moves("elixir")
  end

  test "can handle winning" do
    [
      # guess, state, turns left, letters, used
      ["z", :bad_guess, 6, ["_", "_", "_", "_", "_", "_"], ["z"]],
      ["z", :already_used, 6, ["_", "_", "_", "_", "_", "_"], ["z"]],
      ["e", :good_guess, 6, ["e", "_", "_", "_", "_", "_"], ["z", "e"]],
      ["y", :bad_guess, 5, ["e", "_", "_", "_", "_", "_"], ["z", "e", "y"]],
      ["l", :good_guess, 5, ["e", "l", "_", "_", "_", "_"], ["z", "e", "y", "l"]],
      ["i", :good_guess, 5, ["e", "l", "i", "_", "i", "_"], ["z", "e", "y", "l", "i"]],
      ["x", :good_guess, 5, ["e", "l", "i", "x", "i", "_"], ["z", "e", "y", "l", "i", "x"]],
      ["w", :bad_guess, 4, ["e", "l", "i", "x", "i", "_"], ["z", "e", "y", "l", "i", "x", "w"]],
      ["r", :won, 4, ["e", "l", "i", "x", "i", "r"], ["z", "e", "y", "l", "i", "x", "w", "r"]]
    ]
    |> test_moves("elixir")
  end

  test "can handle losing" do
    [
      # guess, state, turns left, letters, used
      ["z", :bad_guess, 6, ["_", "_", "_", "_", "_", "_"], ["z"]],
      ["z", :already_used, 6, ["_", "_", "_", "_", "_", "_"], ["z"]],
      ["e", :good_guess, 6, ["e", "_", "_", "_", "_", "_"], ["z", "e"]],
      ["y", :bad_guess, 5, ["e", "_", "_", "_", "_", "_"], ["z", "e", "y"]],
      ["l", :good_guess, 5, ["e", "l", "_", "_", "_", "_"], ["z", "e", "y", "l"]],
      ["i", :good_guess, 5, ["e", "l", "i", "_", "i", "_"], ["z", "e", "y", "l", "i"]],
      ["x", :good_guess, 5, ["e", "l", "i", "x", "i", "_"], ["z", "e", "y", "l", "i", "x"]],
      ["w", :bad_guess, 4, ["e", "l", "i", "x", "i", "_"], ["z", "e", "y", "l", "i", "x", "w"]],
      [
        "v",
        :bad_guess,
        3,
        ["e", "l", "i", "x", "i", "_"],
        ["z", "e", "y", "l", "i", "x", "w", "v"]
      ],
      [
        "u",
        :bad_guess,
        2,
        ["e", "l", "i", "x", "i", "_"],
        ["z", "e", "y", "l", "i", "x", "w", "v", "u"]
      ],
      [
        "t",
        :bad_guess,
        1,
        ["e", "l", "i", "x", "i", "_"],
        ["z", "e", "y", "l", "i", "x", "w", "v", "u", "t"]
      ],
      [
        "s",
        :lost,
        0,
        ["e", "l", "i", "x", "i", "_"],
        ["z", "e", "y", "l", "i", "x", "w", "v", "u", "t", "s"]
      ]
    ]
    |> test_moves("elixir")
  end

  def test_moves(moves, word) do
    game = Game.new_game(word)
    Enum.reduce(moves, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns_left, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)

    assert tally.game_state == state
    assert tally.turns_left == turns_left
    assert tally.letters == letters
    assert MapSet.equal?(game.used, MapSet.new(used))

    game
  end
end
