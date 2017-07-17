defmodule BmMigration do
  use Hound.Helpers

  @base_url "https://bookmeter.com/"

  def start do
    Hound.start_session
    login()
    Hound.end_session()
  end

  def login do
    unless Mix.env == :prod do
      Envy.auto_load
    end
    user = System.get_env("BM_EMAIL")
    passwd = System.get_env("BM_PASSWORD")

    navigate_to("#{@base_url}/login")
    find_element(:id, "session_email_address") |> fill_field(user)
    find_element(:id, "session_password") |> fill_field(passwd)
    find_element(:name, "button") |> submit_element
    # find_element(:class, "details__name") |> visible_text
  end

  def logout do
    delete_cookies()
  end
end
