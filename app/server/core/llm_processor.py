import os
from typing import Dict, Any
import google.generativeai as genai
from core.data_models import QueryRequest

def generate_sql_with_gemini(query_text: str, schema_info: Dict[str, Any]) -> str:
    """
    Generate SQL query using Gemini API
    """
    try:
        # Get API key from environment
        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable not set")

        genai.configure(api_key=api_key)
        model = genai.GenerativeModel("gemini-2.0-flash")

        # Format schema for prompt
        schema_description = format_schema_for_prompt(schema_info)

        # Create prompt
        prompt = f"""You are a SQL expert. Convert natural language to SQL queries.

Given the following database schema:

{schema_description}

Convert this natural language query to SQL: "{query_text}"

Rules:
- Return ONLY the SQL query, no explanations
- Use proper SQLite syntax
- Handle date/time queries appropriately (e.g., "last week" = date('now', '-7 days'))
- Be careful with column names and table names
- If the query is ambiguous, make reasonable assumptions
- For multi-table queries, use proper JOIN conditions to avoid Cartesian products
- Limit results to reasonable amounts (e.g., add LIMIT 100 for large result sets)
- When joining tables, use meaningful relationships between tables
- NEVER include SQL comments (-- or /* */) in the query

SQL Query:"""

        # Call Gemini API
        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.1,
                max_output_tokens=500
            )
        )

        sql = response.text.strip()

        # Clean up the SQL (remove markdown if present)
        if sql.startswith("```sql"):
            sql = sql[6:]
        if sql.startswith("```"):
            sql = sql[3:]
        if sql.endswith("```"):
            sql = sql[:-3]

        return sql.strip()

    except Exception as e:
        raise Exception(f"Error generating SQL with Gemini: {str(e)}")

def generate_sql_with_claude(query_text: str, schema_info: Dict[str, Any]) -> str:
    """
    Generate SQL query using Claude Code subscription (via claude CLI or SDK)
    """
    import subprocess
    import shutil

    try:
        # Format schema for prompt
        schema_description = format_schema_for_prompt(schema_info)

        # Create prompt
        prompt = f"""Given the following database schema:

{schema_description}

Convert this natural language query to SQL: "{query_text}"

Rules:
- Return ONLY the SQL query, no explanations
- Use proper SQLite syntax
- Handle date/time queries appropriately (e.g., "last week" = date('now', '-7 days'))
- Be careful with column names and table names
- If the query is ambiguous, make reasonable assumptions
- For multi-table queries, use proper JOIN conditions to avoid Cartesian products
- Limit results to reasonable amounts (e.g., add LIMIT 100 for large result sets)
- When joining tables, use meaningful relationships between tables
- NEVER include SQL comments (-- or /* */) in the query

SQL Query:"""

        # Get claude path from environment or use default
        claude_path = os.environ.get("CLAUDE_CODE_PATH", "claude")

        # Check if claude CLI is available
        if not shutil.which(claude_path):
            raise ValueError(f"Claude CLI not found at '{claude_path}'. Please install Claude Code or set CLAUDE_CODE_PATH.")

        # Call Claude Code CLI in print mode
        result = subprocess.run(
            [claude_path, "-p", prompt, "--output-format", "text"],
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode != 0:
            raise Exception(f"Claude CLI error: {result.stderr}")

        sql = result.stdout.strip()

        # Clean up the SQL (remove markdown if present)
        if sql.startswith("```sql"):
            sql = sql[6:]
        if sql.startswith("```"):
            sql = sql[3:]
        if sql.endswith("```"):
            sql = sql[:-3]

        return sql.strip()

    except subprocess.TimeoutExpired:
        raise Exception("Claude CLI timed out")
    except Exception as e:
        raise Exception(f"Error generating SQL with Claude: {str(e)}")

def format_schema_for_prompt(schema_info: Dict[str, Any]) -> str:
    """
    Format database schema for LLM prompt
    """
    lines = []
    
    for table_name, table_info in schema_info.get('tables', {}).items():
        lines.append(f"Table: {table_name}")
        lines.append("Columns:")
        
        for col_name, col_type in table_info['columns'].items():
            lines.append(f"  - {col_name} ({col_type})")
        
        lines.append(f"Row count: {table_info['row_count']}")
        lines.append("")
    
    return "\n".join(lines)

def generate_random_query_with_gemini(schema_info: Dict[str, Any]) -> str:
    """
    Generate a random natural language query using Gemini API
    """
    try:
        # Get API key from environment
        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable not set")

        genai.configure(api_key=api_key)
        model = genai.GenerativeModel("gemini-2.0-flash")

        # Format schema for prompt
        schema_description = format_schema_for_prompt(schema_info)

        # Create prompt
        prompt = f"""You are a helpful assistant that generates interesting questions about data.

Given the following database schema:

{schema_description}

Generate an interesting natural language query that someone might ask about this data.
The query should be:
- Contextually relevant to the table structures and columns
- Natural and conversational
- Maximum two sentences
- Something that would demonstrate the capability of natural language to SQL conversion
- Varied in complexity (sometimes simple, sometimes complex with JOINs or aggregations)
- Do NOT include any SQL syntax, comments, or special characters

Examples of good queries:
- "What are the top 5 products by revenue?"
- "Show me all customers who ordered in the last month."
- "Which employees have the highest average sales? List their names and departments."

Natural language query:"""

        # Call Gemini API
        response = model.generate_content(
            prompt,
            generation_config=genai.types.GenerationConfig(
                temperature=0.8,
                max_output_tokens=100
            )
        )

        query = response.text.strip()
        return query

    except Exception as e:
        raise Exception(f"Error generating random query with Gemini: {str(e)}")

def generate_random_query_with_claude(schema_info: Dict[str, Any]) -> str:
    """
    Generate a random natural language query using Claude Code subscription (via claude CLI)
    """
    import subprocess
    import shutil

    try:
        # Format schema for prompt
        schema_description = format_schema_for_prompt(schema_info)

        # Create prompt
        prompt = f"""Given the following database schema:

{schema_description}

Generate an interesting natural language query that someone might ask about this data.
The query should be:
- Contextually relevant to the table structures and columns
- Natural and conversational
- Maximum two sentences
- Something that would demonstrate the capability of natural language to SQL conversion
- Varied in complexity (sometimes simple, sometimes complex with JOINs or aggregations)
- Do NOT include any SQL syntax, comments, or special characters

Examples of good queries:
- "What are the top 5 products by revenue?"
- "Show me all customers who ordered in the last month."
- "Which employees have the highest average sales? List their names and departments."

Natural language query:"""

        # Get claude path from environment or use default
        claude_path = os.environ.get("CLAUDE_CODE_PATH", "claude")

        # Check if claude CLI is available
        if not shutil.which(claude_path):
            raise ValueError(f"Claude CLI not found at '{claude_path}'. Please install Claude Code or set CLAUDE_CODE_PATH.")

        # Call Claude Code CLI in print mode
        result = subprocess.run(
            [claude_path, "-p", prompt, "--output-format", "text"],
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode != 0:
            raise Exception(f"Claude CLI error: {result.stderr}")

        query = result.stdout.strip()
        return query

    except subprocess.TimeoutExpired:
        raise Exception("Claude CLI timed out")
    except Exception as e:
        raise Exception(f"Error generating random query with Claude: {str(e)}")

def generate_random_query(schema_info: Dict[str, Any]) -> str:
    """
    Route to appropriate LLM provider for random query generation
    Priority: 1) Gemini API key exists, 2) Claude Code CLI available
    """
    import shutil

    gemini_key = os.environ.get("GEMINI_API_KEY")
    claude_path = os.environ.get("CLAUDE_CODE_PATH", "claude")
    claude_available = shutil.which(claude_path) is not None

    # Check API key availability (Gemini priority)
    if gemini_key:
        return generate_random_query_with_gemini(schema_info)
    elif claude_available:
        return generate_random_query_with_claude(schema_info)
    else:
        raise ValueError("No LLM available. Please set GEMINI_API_KEY or ensure Claude Code CLI is installed.")

def generate_sql(request: QueryRequest, schema_info: Dict[str, Any]) -> str:
    """
    Route to appropriate LLM provider based on API key availability and request preference.
    Priority: 1) Gemini API key exists, 2) Claude Code CLI available, 3) request.llm_provider
    """
    import shutil

    gemini_key = os.environ.get("GEMINI_API_KEY")
    claude_path = os.environ.get("CLAUDE_CODE_PATH", "claude")
    claude_available = shutil.which(claude_path) is not None

    # Check API key availability first (Gemini priority)
    if gemini_key:
        return generate_sql_with_gemini(request.query, schema_info)
    elif claude_available:
        return generate_sql_with_claude(request.query, schema_info)

    # Fall back to request preference if both available or neither available
    if request.llm_provider == "gemini":
        return generate_sql_with_gemini(request.query, schema_info)
    else:
        return generate_sql_with_claude(request.query, schema_info)