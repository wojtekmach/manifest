# Based on https://github.com/hexpm/hex/blob/v0.17.3/lib/mix/tasks/hex.build.ex

defmodule Manifest do
  @default_files ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                    license* CHANGELOG* changelog* src)

  def write!() do
    string = Enum.join(generate(), "\n")
    File.write!("manifest.txt", string)
  end

  def generate() do
    config = Mix.Project.config()
    package = Enum.into(config[:package] || [], %{})
    expand_paths(package[:files] || @default_files, File.cwd!())
  end

  defp expand_paths(paths, dir) do
    expand_dir = Path.expand(dir)

    paths
    |> Enum.map(&Path.join(dir, &1))
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.flat_map(&dir_files/1)
    |> Enum.map(&Path.expand/1)
    |> Enum.flat_map(&remove_dirs/1)
    |> Enum.uniq()
    |> Enum.map(&Path.relative_to(&1, expand_dir))
  end

  defp dir_files(path) do
    if File.dir?(path) do
      Path.wildcard(Path.join(path, "**"), match_dot: true)
    else
      [path]
    end
  end

  defp remove_dirs(path) do
    if File.dir?(path) do
      []
    else
      [path]
    end
  end
end
