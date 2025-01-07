import pandas as pd
import sqlite3

# Step 1: Count the total number of lines in the CSV file
with open("/travail/yelp_academic_dataset_tip.csv") as f:
    total_lines = sum(1 for line in f)  # Count each line

# Step 2: Read the CSV file into the DataFrame and skip bad lines
df = pd.read_csv("/travail/yelp_academic_dataset_tip.csv", on_bad_lines='skip')

# Step 3: Print the total number of lines and the number of rows in the DataFrame
print(f"Total number of lines in the file: {total_lines}")
print(f"Number of rows in the DataFrame: {df.shape[0]}")

# Optionally print the DataFrame information (to check other aspects like columns)
print(df.info())

# Step 4: Create or connect to an SQLite database
conn = sqlite3.connect('yelp_data.db')  # Replace with your desired path or filename for the SQLite database

# Step 5: Save the DataFrame to the SQLite database
df.to_sql('tips_data', conn, if_exists='replace', index=False)  # 'tips_data' is the table name, replace as needed

# Step 6: Confirm the data has been saved
print("Data has been successfully saved to the SQLite database.")

# Step 7: Optionally, you can check if the data was stored by querying the database
query_result = pd.read_sql('SELECT * FROM tips_data LIMIT 5;', conn)
print(query_result)

# Close the connection to the database
conn.close()
