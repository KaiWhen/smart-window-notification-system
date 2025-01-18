# Module Imports
import mariadb
import sys
import os
from dotenv import load_dotenv

load_dotenv()

# Connect to MariaDB Platform
def connect_db():
    try:
        conn = mariadb.connect(
            user="freedb_wangke",
            password=os.getenv('DB_PASS4'),
            host="sql.freedb.tech",
            port=3306,
            database="freedb_enmondb",
        )
        return conn
    except mariadb.Error as e:
        print(f"Error connecting to MariaDB Platform: {e}")
        sys.exit(1)
