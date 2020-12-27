defmodule CardsTest do
  use ExUnit.Case
  doctest Cards

  test "create_deck makes 12 cards" do 
    deck_length = length(Cards.create_deck)
    assert deck_length == 12
  end
end
