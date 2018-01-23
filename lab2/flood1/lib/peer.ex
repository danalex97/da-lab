defmodule Peer do
  def count(msg) do
    received = false
    receive do
      {:hello, peers} ->
        if msg == 0 do
          peers = peers -- [self()]
          IO.puts ["#{inspect self()} > hello"]

          Enum.map(peers, fn(node) ->
            send node, { :hello, peers ++ [self()] }
          end)
        end
        count(msg + 1)
    after
      1_000 ->
        IO.puts ["#{inspect self()} > msg count: #{msg}"]
    end
  end

  def start do
    count(0)
  end
end
