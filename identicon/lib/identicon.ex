defmodule Identicon do
  @moduledoc """
    Documentation for `Identicon`.
  """

  @doc """
    Main function to perform identicon generation 
  """
  def main(input) do
    input 
      |> hash_input
      |> pick_color
      |> build_grid
      |> filter_odd_squares
      |> build_pixel_map
      |> draw_image
      |> save_image(input)
  end

  @doc """
    Hashes the input string into a MD5 hashed series of numbers
  """
  def hash_input(input) do 
    hex = :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end 

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail ]} = image) do 
    # pattern matching with elixir 

    # create a new struct instead of mutating old one 
    # using the pipe symbol, we change the value of the color property. 
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do 
    # break the list in chunks of 3
    # pass the chunks in the mirror_row helper function 
    grid = hex
      |> Enum.chunk(3)
      # same as map filter acc abstracted functionality 
      |> Enum.map(&mirror_row/1)
      # takes a nested list and flattens the list into a 1D list 
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do 
    # use iteration to mirrow rows
    # [145, 46, 200]
    [ first, second | _tail ] = row
    # ++ operation appends lists 
    row ++ [ second, first ]
    # [145, 46, 200, 46, 145]
  end 

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do 
    filtered = Enum.filter grid, fn({val, _index}) -> 
      rem(val, 2) == 0
    end
    %Identicon.Image{image | grid: filtered}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) -> 
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end 

  # dont need to use = image at the end if we dont need a reference to
  # the image in memory 
  def draw_image(%Identicon.Image{color: color, pixel_map: pm}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    # note that this edg function is not immutable 
    Enum.each pm, fn({start, stop}) -> 
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end 

  def save_image(image, filename) do
    # string interpolation syntax
    File.write("#{filename}.png", image)
  end 
end
