defmodule Flooding do
  @num 10

  def bind(peers, idx, neigh) do
    send Enum.at(peers, idx), { :bind, Enum.to_list(
      for i <- neigh, do: Enum.at(peers, i)
    )}
  end

  def main do
    peers = Enum.to_list(for _ <- 0..(@num-1), do:
      spawn(Peer, :start, [Enum.random(1..5)]))

    bind(peers, 0, [1, 6])
    bind(peers, 1, [0, 2, 3])
    bind(peers, 2, [1, 3, 4])
    bind(peers, 3, [1, 2, 5])
    bind(peers, 4, [2])
    bind(peers, 5, [3])
    bind(peers, 6, [0, 7])
    bind(peers, 7, [6, 8, 9])
    bind(peers, 8, [7, 9])
    bind(peers, 9, [7, 8])

    send Enum.at(peers, 0), { :parent, self() }
  end

  def loop do
    loop()
  end

  def start(_type, _args) do
    main()
    loop()
  end
end
