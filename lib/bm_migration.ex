defmodule BmMigration do
  use Hound.Helpers
  require Crawler

  def start do
    unless Mix.env == :prod do
      Envy.auto_load
    end

    Hound.start_session()
    Crawler.crawl()
    Hound.end_session()
  end
end
