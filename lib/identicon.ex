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
  end

  def hash_input(input) do
    seed = :crypto.hash(:md5, input)
    |> :binary.bin_to_list
    # seed is an array of 16 hex numbers;
    # we'll feed it into the Image struct
    %Identicon.Image{seed: seed}
  end

  @doc """
  Picks first three numbers out of the array, which will represent R, G, B

  """
  def pick_color(%Identicon.Image{seed: [r, g, b | _tail]} = image) do
    # Not modifing any image; creating a new one by copying 
    # the whole image (which is {seed: seed}), and specifying the "color"
    # property of the struct.
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{seed: seed} = image ) do
    grid = 
      seed
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

      # pipe syntax is updating a struct (like updating a map:
      # "to update the value stored under existing atom keys")

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([first, second | _tail] = row) do
    # [145, 46, 200]
    # [first, second | _tail] = row

    # [145, 46, 200, 46, 145]
    # row ++ [second, first]

    # [first, second | _tail] = row
    [first, second] ++ Enum.reverse(row)
  end

end
