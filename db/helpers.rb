require 'pg'

def run_sql(sql, params = [])

  db = PG.connect(ENV['DATABASE_URL']|| {dbname: 'axehunter'})
    res = db.exec_params(sql, params)
  db.close
  return res


end
# function to connect to database

#function to check for an existing email in the database.
