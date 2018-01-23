defmodule Peer do
  def build_tree(peers, msg, children) do
    receive do
      { :parent, parent } ->
        IO.puts "Me"
        if msg == 0 do
          peers = peers -- [self()]
          IO.puts ["#{inspect self()} > hello"]

          Enum.map(peers, fn(node) ->
            send node, { :parent, self() }
          end)

          send parent, { :ack, self() }
        end
      {:ack, child} ->
        IO.puts "Yooo"
        children = children ++ [child]
      run(peers, msg + 1)
    # after
    #   1_000 ->
    #     IO.puts ["#{inspect self()} > msg count: #{msg}"]
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
