defmodule Peer do
  def build_tree(peers, msg, children) do
    receive do
      { :parent, parent } ->
        if msg == 0 do
          peers = peers -- [self()]
          IO.puts ["#{inspect self()} > hello"]

          Enum.map(peers, fn(node) ->
            send node, { :parent, self() }
          end)

          IO.puts ["#{inspect self()} > ", inspect parent]
          send parent, { :ack, self() }
        end
        build_tree(peers, msg + 1, children)
      { :ack, child } ->
        children = children ++ [child]
        IO.puts ["#{inspect self()} > children:", inspect children]
        build_tree(peers, msg + 1, children)
    after
      1_000 ->
        IO.puts ["#{inspect self()} > msg count: #{msg}"]
    end
  end

  def start do
    receive do
      {:bind, peers} ->
        IO.puts ["#{inspect self()} > bind"]
        build_tree(peers, 0, [])
    end
  end
end
