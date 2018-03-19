require "crust"
require "pg"

clear_bin_dir

connection_string = "postgres://localhost:5432/test?prepared_statements=false&initial_pool_size=1&max_pool_size=1&max_idle_pool_size=1"

DB.open connection_string do |db|
  db.exec "delete from results"
end
