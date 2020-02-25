module pah_db {
  source       = "./database"

  name        = "pah"
  db_instance = aws_db_instance.db
}
