defmodule BmMigration do
  require Crawler

  def start do
    unless Mix.env == :prod do
      Envy.auto_load
    end

    result = Crawler.crawl()
    IO.puts result
  end
end
