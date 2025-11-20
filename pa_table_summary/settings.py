import os
from dotenv import find_dotenv, load_dotenv

load_dotenv(find_dotenv())

crash_db_engine = os.environ.get("crash_db_engine")
