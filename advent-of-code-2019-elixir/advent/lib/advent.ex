defmodule Advent do
  @moduledoc """
  Documentation for `Advent`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Advent.hello()
      :world

  """
  def hello(args) do
    IO.puts "hello there"
    {opts,_,_}= OptionParser.parse(args,switches: [file: :string],aliases: [f: :file])
    IO.inspect opts #here I just inspect the options to stdout
  end
end
