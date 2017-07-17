defmodule BmMigrationTest do
  use ExUnit.Case
  use Hound.Helpers
  doctest BmMigration

  hound_session

  test "loggedin user can get username" do
    BmMigration.login()
    username = find_element(:class, "details__name") |> visible_text
    assert username
  end
end
