defmodule Flooding do
  @num 10

  def main do
    peers = Enum.to_list(for _ <- 0..(@num-1), do: spawn(Peer, :start, []))

    send Enum.at(peers, 0), { :hello, peers }
  end

  def loop do
    loop()
  end

  def start(_type, _args) do
    main()
    loop()
  end
end
