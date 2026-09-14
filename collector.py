import io
import zipfile
import requests
import pandas as pd
import mysql.connector
import os
import sys

from dotenv import load_dotenv
from datetime import datetime, timedelta, timezone
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter


# ============================================================
# CONFIGURATION
# ============================================================

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "macropulse")
}

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept-Encoding": "gzip, deflate",
    "Connection": "keep-alive"
}


# ============================================================
# GDELT COLUMNS
# ============================================================

COLUMNS = [
    "GlobalEventID",
    "Day",
    "MonthYear",
    "Year",
    "FractionDate",
    "Actor1Code",
    "Actor1Name",
    "Actor1CountryCode",
    "Actor1KnownGroupCode",
    "Actor1EthnicCode",
    "Actor1Religion1Code",
    "Actor1Religion2Code",
    "Actor1Type1Code",
    "Actor1Type2Code",
    "Actor1Type3Code",
    "Actor2Code",
    "Actor2Name",
    "Actor2CountryCode",
    "Actor2KnownGroupCode",
    "Actor2EthnicCode",
    "Actor2Religion1Code",
    "Actor2Religion2Code",
    "Actor2Type1Code",
    "Actor2Type2Code",
    "Actor2Type3Code",
    "IsRootEvent",
    "EventCode",
    "EventBaseCode",
    "EventRootCode",
    "QuadClass",
    "GoldsteinScale",
    "NumMentions",
    "NumSources",
    "NumArticles",
    "AvgTone",
    "Actor1Geo_Type",
    "Actor1Geo_FullName",
    "Actor1Geo_CountryCode",
    "Actor1Geo_ADM1Code",
    "Actor1Geo_Lat",
    "Actor1Geo_Long",
    "Actor1Geo_FeatureID",
    "Actor2Geo_Type",
    "Actor2Geo_FullName",
    "Actor2Geo_CountryCode",
    "Actor2Geo_ADM1Code",
    "Actor2Geo_Lat",
    "Actor2Geo_Long",
    "Actor2Geo_FeatureID",
    "ActionGeo_Type",
    "ActionGeo_FullName",
    "ActionGeo_CountryCode",
    "ActionGeo_ADM1Code",
    "ActionGeo_Lat",
    "ActionGeo_Long",
    "ActionGeo_FeatureID",
    "DATEADDED",
    "SOURCEURL"
]


# ============================================================
# SESSION BUILDER WITH RETRIES & TIMEOUTS
# ============================================================

def get_configured_session():
    session = requests.Session()
    retries = Retry(
        total=5,
        backoff_factor=2,
        status_forcelist=[500, 502, 503, 504]
    )
    session.mount("https://", HTTPAdapter(max_retries=retries))
    return session


# ============================================================
# GET LATEST DAILY FILE
# ============================================================

def get_latest_file():
    today = datetime.now(timezone.utc).date()
    session = get_configured_session()

    for days_back in range(0, 5):
        date = today - timedelta(days=days_back)
        filename = date.strftime("%Y%m%d.export.CSV.zip")
        url = f"https://data.gdeltproject.org/events/{filename}"

        print(f"Checking: {url}")

        try:
            response = session.get(url, headers=HEADERS, stream=True, timeout=20)
            if response.status_code == 200:
                print(f"Using: {filename}")
                return url
        except requests.exceptions.RequestException:
            print(f"تجاوز {filename} بسبب بطء الاتصال بالسيرفر...")
            continue

    raise RuntimeError("No recent GDELT event file found.")


# ============================================================
# DOWNLOAD WITH CHUNKS AND RETRIES
# ============================================================

def download_file(url):
    print("\nDownloading GDELT data...")
    session = get_configured_session()

    max_attempts = 3
    for attempt in range(1, max_attempts + 1):
        try:
            response = session.get(url, headers=HEADERS, stream=True, timeout=(30, 300))
            response.raise_for_status()

            buffer = io.BytesIO()
            downloaded = 0

            for chunk in response.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    buffer.write(chunk)
                    downloaded += len(chunk)
                    sys.stdout.write(f"\rProgress: {downloaded / 1024 / 1024:.2f} MB downloaded...")
                    sys.stdout.flush()

            print(f"\nSuccessfully Downloaded: {downloaded / 1024 / 1024:.2f} MB")
            return buffer.getvalue()

        except (requests.exceptions.RequestException, Exception) as e:
            print(f"\n[محاولة {attempt}/{max_attempts}] فشل التحميل بسباب: {e}")
            if attempt == max_attempts:
                raise RuntimeError("فشل تحميل الملف بعد عدة محاولات بسباب ضعف سيرفر GDELT.")


# ============================================================
# READ FILE
# ============================================================

def read_events(data):
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        files = archive.namelist()
        csv_file = files[0]

        print(f"Reading: {csv_file}")

        with archive.open(csv_file) as file:
            df = pd.read_csv(
                file,
                sep="\t",
                header=None,
                names=COLUMNS,
                dtype=str,
                low_memory=False
            )

    print(f"Total GDELT events: {len(df)}")
    return df


# ============================================================
# CLEAN DATA
# ============================================================

def clean_events(df):
    columns = [
        "GlobalEventID",
        "Day",
        "DATEADDED",
        "Actor1Name",
        "Actor1CountryCode",
        "Actor2Name",
        "Actor2CountryCode",
        "EventCode",
        "EventBaseCode",
        "EventRootCode",
        "QuadClass",
        "GoldsteinScale",
        "NumMentions",
        "NumSources",
        "NumArticles",
        "AvgTone",
        "ActionGeo_CountryCode",
        "ActionGeo_Lat",
        "ActionGeo_Long",
        "SOURCEURL"
    ]

    df = df[columns].copy()

    # Convert numeric fields
    numeric_columns = [
        "GlobalEventID",
        "QuadClass",
        "GoldsteinScale",
        "NumMentions",
        "NumSources",
        "NumArticles",
        "AvgTone",
        "ActionGeo_Lat",
        "ActionGeo_Long"
    ]

    for column in numeric_columns:
        df[column] = pd.to_numeric(df[column], errors="coerce")

    # Remove invalid events
    df = df[df["GlobalEventID"].notna()]

    # ========================================================
    # IMPORTANCE FILTER
    # ========================================================
    important = (
        (df["NumSources"] >= 10)
        | (df["NumArticles"] >= 30)
        | (df["NumMentions"] >= 50)
        | (df["QuadClass"].isin([3, 4]))
        | (df["GoldsteinScale"] <= -5)
    )

    df = df[important].copy()

    print(f"Important events selected: {len(df)}")
    return df


# ============================================================
# HELPER TO PARSE GDELT DATES SAFELY
# ============================================================

def parse_gdelt_datetime(val):
    if pd.isna(val):
        return None
    val_str = str(int(val)) if isinstance(val, (int, float)) else str(val).split('.')[0]
    
    try:
        if len(val_str) == 14:
            return datetime.strptime(val_str, "%Y%m%d%H%M%S")
        elif len(val_str) == 8:
            return datetime.strptime(val_str, "%Y%m%d")
    except ValueError:
        return None
    return None


# ============================================================
# MYSQL INSERT (SAFE BATCH SIZE TO PREVENT PACKET OVERFLOW)
# ============================================================

def insert_events(df):
    connection = mysql.connector.connect(**DB_CONFIG)
    cursor = connection.cursor()

    query = """
        INSERT IGNORE INTO raw_events
        (
            global_event_id,
            event_date,
            date_added,
            actor1_name,
            actor1_country_code,
            actor2_name,
            actor2_country_code,
            event_code,
            event_base_code,
            event_root_code,
            quad_class,
            goldstein_scale,
            num_mentions,
            num_sources,
            num_articles,
            avg_tone,
            action_country_code,
            latitude,
            longitude,
            source_url
        )
        VALUES
        (
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s
        )
    """

    print("Formatting data for fast insertion...")
    data_to_insert = []

    for _, row in df.iterrows():
        event_date = parse_gdelt_datetime(row["Day"])
        date_added = parse_gdelt_datetime(row["DATEADDED"])

        values = [
            row["GlobalEventID"],
            event_date.date() if event_date else None,
            date_added,
            row["Actor1Name"],
            row["Actor1CountryCode"],
            row["Actor2Name"],
            row["Actor2CountryCode"],
            row["EventCode"],
            row["EventBaseCode"],
            row["EventRootCode"],
            row["QuadClass"],
            row["GoldsteinScale"],
            row["NumMentions"],
            row["NumSources"],
            row["NumArticles"],
            row["AvgTone"],
            row["ActionGeo_CountryCode"],
            row["ActionGeo_Lat"],
            row["ActionGeo_Long"],
            row["SOURCEURL"]
        ]

        # Replace NaN with None
        values = [None if pd.isna(v) else v for v in values]
        data_to_insert.append(values)

    print("Inserting into MySQL in safe batches (500 rows/batch)...")
    
    # صغرنا الحجم لـ 500 باش ما يتجاوزش max_allowed_packet
    batch_size = 500
    total_inserted = 0

    for i in range(0, len(data_to_insert), batch_size):
        batch = data_to_insert[i:i + batch_size]
        cursor.executemany(query, batch)
        connection.commit()
        total_inserted += cursor.rowcount
        sys.stdout.write(f"\rInserted {min(i + batch_size, len(data_to_insert))}/{len(data_to_insert)} rows...")
        sys.stdout.flush()

    cursor.close()
    connection.close()

    print(f"\nNew events inserted: {total_inserted}")


# ============================================================
# MAIN
# ============================================================

def main():
    print()
    print("=" * 60)
    print("MACROPULSE - REAL GDELT INGESTION")
    print("=" * 60)
    print()

    url = get_latest_file()
    data = download_file(url)
    df = read_events(data)
    df = clean_events(df)
    insert_events(df)

    print()
    print("=" * 60)
    print("MACROPULSE INGESTION COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    main()