defmodule B1Web.HangmanHTML do
  @moduledoc """
  This module contains pages rendered by HangmanController.

  See the `hangman_html` directory for all templates available.
  """
  use B1Web, :html

  embed_templates("hangman_html/*")

  def continue_or_try_again(assigns) when assigns.game_state in [:won, :lost] do
    ~H"""
    <.form for={%{}} action={~p"/hangman"} method="post">
      <.button type="submit" variant="primary">New game</.button>
    </.form>
    """
  end

  def continue_or_try_again(assigns) do
    ~H"""
    <.form for={%{}} action={~p"/hangman"} method="put" as={:make_move}>
      <div class="flex gap-2">
        <div class="flex-0">
          <.input name="make_move[guess]" type="text" label="Your guess" value="" maxlength="1" />
        </div>
        <div class="flex-1 pt-[26px]">
          <.button type="submit" variant="primary">Make next guess</.button>
        </div>
      </div>
    </.form>
    """
  end

  @status_fields %{
    initialising: {"info", "Guess the word, a letter a a time" },
    good_guess: {"success", "Good guess!"},
    bad_guess: {"error", "Sorry, that's a bad guess"},
    won: {"success", "You won!"},
    lost: {"error", "Sorry, you lost"},
    already_used: {"warning", "You already used that letter"}
  }

  def move_status(assigns) do
    {class, msg} = @status_fields[assigns.game_state]

    assigns = assign(assigns, :alert_class, "alert alert-#{class} mb-4")
    assigns = assign(assigns, :message, msg)

    ~H"""
    <div role="alert" class={@alert_class}>{@message}</div>
    """
  end

  defdelegate figure_for(turns_left), to: B1Web.Helpers.FigureFor
end
