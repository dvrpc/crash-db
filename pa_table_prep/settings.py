import os
import urllib.parse
from dotenv import find_dotenv, load_dotenv

load_dotenv(find_dotenv())

crash_db_engine = os.environ.get("crash_db_engine")
access_file = os.environ.get("access_file")
