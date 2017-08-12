defmodule Crawler do
  use Hound.Helpers

  @result_json "result.json"
  @base_url "https://bookmeter.com"
  @book_status ["read", "reading", "stacked", "wish"]

  def crawl do
    Hound.start_session()
    login()
    %{id: userid, book_nums: book_nums} = get_userdata()

    json =
      book_nums
      |> status_with_num
      |> Enum.flat_map(&(fetch_bookdatas(userid, &1)))
    result = save_json(@result_json, json)

    logout()
    Hound.end_session()
    result
  end

  def status_with_num(book_nums) do
    book_nums
    |> Enum.with_index
    |> Enum.map(fn {k, v} -> {Enum.at(@book_status, v), k} end)
  end

  def login do
    user   = System.get_env("BM_EMAIL")
    passwd = System.get_env("BM_PASSWORD")

    navigate_to("#{@base_url}/login", 5)
    find_element(:id, "session_email_address") |> fill_field(user)
    find_element(:id, "session_password")      |> fill_field(passwd)
    find_element(:name, "button")              |> submit_element

    IO.puts("login successfully")
  end

  def logout do
    delete_cookies()
  end

  def get_userdata do
    home_url = "#{@base_url}/home"
    navigate_to(home_url, 5)

    userid = userid()
    book_nums = book_nums()

    %{id: userid, book_nums: book_nums}
  end

  def userid do
    id_href =
      find_element(:css, ".user-profiles__avatar > a")
      |> attribute_value("href")
    Enum.at(Regex.run(~r/\d+/, id_href), 0)
  end

  def book_nums do
    find_all_elements(:class, "userdata-nav__count")
    |> Enum.map(fn elm ->
         elm
         |> visible_text
         |> delete_satsu
         |> String.to_integer
       end)
    |> Enum.take(4)
  end

  def delete_satsu(text) do
    Regex.replace(~r/冊/, text, "")
  end

  def fetch_bookdatas(userid, status) do
    {stat, all_book_num} = status
    total_pages = total_pages(status, all_book_num)
    total_pages = 1 ## デバッグ用 ##
    xpath = json_xpath(status)
    url = "#{@base_url}/users/#{userid}/books/#{stat}?display_type=list"

    (1..total_pages)
    |> Enum.flat_map(&(fetch_books(&1, url, xpath)))
    |> Enum.map(fn map ->
         map
         |> Map.put("status", stat)
         |> Map.drop(["id", "reload_disabled"])
       end)
  end

  def total_pages(status, all_book_num) do
    books_per_page = books_per_page(status)
    (all_book_num / books_per_page) |> Float.ceil |> Kernel.trunc
  end

  def books_per_page(status) do
    case status do
      {"read", _} -> 20
      _           -> 10
    end
  end

  def json_xpath(status) do
    case status do
      {"read", _} -> "//div[@class='detail__edit']/div"
      _           -> "//div[@class='thumbnail__action']/div"
    end
  end

  def fetch_books(page, booklist_url, xpath) do
    url = "#{booklist_url}&page=#{page}"
    IO.puts "accessing to #{url}"
    :timer.sleep(1000) # 1sec
    navigate_to(url, 5)

    find_all_elements(:xpath, xpath)
    |> Enum.map(fn elm ->
         elm
         |> attribute_value("data-modal")
         |> Poison.decode!
       end)
  end

  def save_json(filename, json) do
    text = Poison.encode!(json)
    File.write(filename, text)
    IO.puts("Saved result to \"#{filename}\"")
  end
end
