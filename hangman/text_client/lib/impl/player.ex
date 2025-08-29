defmodule TextClient.Impl.Player do
  @typep game :: Engine.game()
  @typep tally :: Engine.tally(game)
  @typep state :: {game, tally}

  @spec start() :: :ok
  def start() do
    game = Engine.new_game()
    tally = Engine.tally(game)
    interact({game, tally})
  end

  @spec interact(state) :: :ok
  def interact({_game, _tally = %{game_state: :won}}) do
    IO.puts("Congratulations, you won!")
  end

  def interact({_game, tally = %{game_state: :lost}}) do
    IO.puts("Sorry you lost. The word was #{tally.letters |> Enum.join()}.")
  end

  def interact({game, tally}) do
    IO.puts(feedback_for(tally))
    IO.puts(display_tally(tally))

    Engine.make_move(game, get_guess())
    |> interact()
  end

  defp feedback_for(tally = %{game_state: :initialising}),
    do: "Welcome! I'm thinking of a word with #{tally.letters |> length} letters..."

  defp feedback_for(_tally = %{game_state: :good_guess}), do: "Yes, that is in the word!"

  defp feedback_for(_tally = %{game_state: :bad_guess}),
    do: "Nope, that's not in the word."

  defp feedback_for(_tally = %{game_state: :already_used}),
    do: "Hey, you already guessed that?!"

  defp display_tally(tally),
    do: [
      "Word: #{tally.letters |> Enum.join(" ")}",
      " | Turns left: #{tally.turns_left}",
      " | Letters used: #{tally.used |> Enum.join(", ")}"
    ]

  defp get_guess() do
    IO.gets("Enter guess: ")
    |> String.trim()
    |> String.downcase()
  end
end
