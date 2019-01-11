defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Identicon.hello()
      :world

  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_even_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do 
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) -> 
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({ _code, index }) ->  
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def filter_even_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn({code, _index}) -> 
      rem(code, 2) == 0 
    end)

    %Identicon.Image{image | grid: grid}
  end

  def build_grid(%Identicon.Image{seed: seed} = image ) do
    grid = 
      seed
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    # Update grid property with an array of index tuples.
    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Picks first three numbers out of the array. They will represent R, G, B values.

  """
  def pick_color(%Identicon.Image{seed: [r, g, b | _tail]} = image) do
    # Updating color property in Image struct
    %Identicon.Image{image | color: {r, g, b}}
  end

  def hash_input(input) do
    seed = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    # seed is an array of 16 hex numbers;
    # we'll feed it into the Image struct
    %Identicon.Image{seed: seed}
  end

  #========= Helpers ===========

  def mirror_row([first, second | _tail] = row) do
    # [145, 46, 200]
    # [first, second | _tail] = row

    # [145, 46, 200, 46, 145]
    # row ++ [second, first]

    # [first, second | _tail] = row
    [first, second] ++ Enum.reverse(row)
  end

end
