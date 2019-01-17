defmodule Argon2.StatsTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  alias Argon2.Stats

  test "print report with default options" do
    report = capture_io(fn -> Stats.report() end)
    assert report =~ "Iterations:\t1\n"
    assert report =~ "Memory:\t\t1024 MiB\n"
    assert report =~ "Parallelism:\t4\n"
    assert report =~ "Verification OK"
  end

  test "use custom options" do
    opts = [t_cost: 4, m_cost: 18, parallelism: 8]
    report = capture_io(fn -> Stats.report(opts) end)
    assert report =~ "Iterations:\t4\n"
    assert report =~ "Memory:\t\t256 MiB\n"
    assert report =~ "Parallelism:\t8\n"
    assert report =~ "Verification OK"
  end
end
