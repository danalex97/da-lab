defmodule Peer do
  def run(peers) do
    receive do
        {:hello} ->
          peers = peers -- [self()]
          IO.puts ["#{inspect self()} > hello"]

          Enum.map(peers, fn(node) ->
            send node, { :hello }
          end)
    after
      1_000 ->
        IO.puts ["#{inspect self()} > msg count: #{msg}"]
      end
  end

  def count(msg) do
    receive do
      {:bind, peers} ->
        IO.puts ["#{inspect self()} > hello"]
        run(peers)
    end
  end

  def start do
    count(0)
  end
end
