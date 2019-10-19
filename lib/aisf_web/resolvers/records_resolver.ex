defmodule AisfWeb.RecordsResolver do
  alias Aisf.Records.Records

  def all(_root, _args, _info) do
    records = Records.list_records()
    {:ok, records}
  end

  def create(args, _info) do
    Records.create_record(args)
  end
end
