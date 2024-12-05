
s = IO.read(:stdio, :eof)

tmp = 
  Regex.scan(~r/mul\(\d{1,3},\d{1,3}\)/, s)
  |> IO.inspect(label: "tmp")

tmp
|> Enum.map(fn ([e]) -> Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, e) end)
|> IO.inspect()
|> Enum.map(fn ([[_ | rest]]) -> Enum.map(rest, &String.to_integer/1) end)
|> IO.inspect()
|> Enum.map(fn ([a, b]) -> a*b end)
|> Enum.sum()
|> IO.inspect(label: "Answer")
