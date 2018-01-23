defmodule Peer do
  def run(peers, msg) do
    receive do
      {:hello} ->
        if msg == 0 do
          peers = peers -- [self()]
          IO.puts ["#{inspect self()} > hello"]

          Enum.map(peers, fn(node) ->
            send node, { :hello }
          end)
        end
        run(peers, msg + 1)
    after
      1_000 ->
        IO.puts ["#{inspect self()} > msg count: #{msg}"]
    end
  end

  def start do
    receive do
      {:bind, peers} ->
        IO.puts ["#{inspect self()} > bind"]
        run(peers, 0)
    end
  end
end
