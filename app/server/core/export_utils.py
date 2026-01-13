import sqlite3
from typing import List, Dict
import pandas as pd
import json
import io


def generate_csv_from_data(data: List[Dict], columns: List[str]) -> bytes:
    """
    Generate CSV file from data and columns.
    
    Args:
        data: List of dictionaries containing the data
        columns: List of column names
        
    Returns:
        bytes: CSV file content as bytes
    """
    if not data and not columns:
        return b""
    
    if not columns and data:
        columns = list(data[0].keys()) if data else []
    
    df = pd.DataFrame(data, columns=columns)
    
    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False)
    csv_content = csv_buffer.getvalue()
    csv_buffer.close()
    
    return csv_content.encode('utf-8')


def generate_csv_from_table(conn: sqlite3.Connection, table_name: str) -> bytes:
    """
    Generate CSV file from a database table.
    
    Args:
        conn: SQLite database connection
        table_name: Name of the table to export
        
    Returns:
        bytes: CSV file content as bytes
        
    Raises:
        ValueError: If table doesn't exist
    """
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT name FROM sqlite_master 
        WHERE type='table' AND name=?
    """, (table_name,))
    
    if not cursor.fetchone():
        raise ValueError(f"Table '{table_name}' does not exist")
    
    query = f'SELECT * FROM "{table_name}"'
    df = pd.read_sql_query(query, conn)

    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False)
    csv_content = csv_buffer.getvalue()
    csv_buffer.close()

    return csv_content.encode('utf-8')


def generate_json_from_data(data: List[Dict], columns: List[str]) -> bytes:
    """
    Generate JSON file from data and columns.

    Args:
        data: List of dictionaries containing the data
        columns: List of column names

    Returns:
        bytes: JSON file content as bytes
    """
    if not data:
        return b"[]"

    # Ensure data is ordered by columns if provided
    if columns:
        ordered_data = []
        for row in data:
            ordered_row = {col: row.get(col) for col in columns}
            ordered_data.append(ordered_row)
        data = ordered_data

    json_content = json.dumps(data, indent=2, ensure_ascii=False, default=str)
    return json_content.encode('utf-8')


def generate_json_from_table(conn: sqlite3.Connection, table_name: str) -> bytes:
    """
    Generate JSON file from a database table.

    Args:
        conn: SQLite database connection
        table_name: Name of the table to export

    Returns:
        bytes: JSON file content as bytes

    Raises:
        ValueError: If table doesn't exist
    """
    cursor = conn.cursor()

    cursor.execute("""
        SELECT name FROM sqlite_master
        WHERE type='table' AND name=?
    """, (table_name,))

    if not cursor.fetchone():
        raise ValueError(f"Table '{table_name}' does not exist")

    query = f'SELECT * FROM "{table_name}"'
    df = pd.read_sql_query(query, conn)

    # Convert DataFrame to list of dicts
    data = df.to_dict(orient='records')

    json_content = json.dumps(data, indent=2, ensure_ascii=False, default=str)
    return json_content.encode('utf-8')