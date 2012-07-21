Sequel.migration do
  up do
    DB[:users].update(:votes => 100)
  end

  down do
    DB[:users].update(:votes => 0)
  end
end
