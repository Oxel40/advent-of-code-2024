defmodule Main do
  def tokenize(t) do
    case t do
      "do()" -> :do
      "don't()" -> :dont 
      mul_string -> process_mul(mul_string)
    end
  end


  def process_mul(t) do
    Regex.scan(~r/\d{1,3}/, t)
    |> Enum.concat()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(&*/2)
  end

  def reduction(e, {mode, sum}) do
    case {e, mode} do
      {:do, _} -> {:do, sum}
      {:dont, _} -> {:dont, sum}
      {v, :do} -> {:do, v+sum}
      {v, :dont} -> {:dont, sum}
    end
  end

  def main() do
    s = IO.read(:stdio, :eof)

    Regex.scan(~r/do\(\)|don't\(\)|mul\(\d{1,3},\d{1,3}\)/, s)
    |> IO.inspect(label: "0st:")
    |> Enum.concat()
    |> IO.inspect(label: "1st:")
    |> Enum.map(&IO.inspect/1)
    |> Enum.map(&tokenize/1)
    |> IO.inspect(label: "2nd:")
    |> Enum.reduce({:do, 0}, &reduction/2)
    |> IO.inspect(label: "Answer")
  end
end

Main.main()
