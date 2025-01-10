-- Set Journal Mode to WAL (Write-Ahead Logging) for better concurrency
PRAGMA journal_mode = WAL;

-- Set Synchronous to NORMAL for a good balance between performance and durability
PRAGMA synchronous = NORMAL;

-- Set the cache size to reduce disk access (negative value sets the number of pages, higher is better for performance)
PRAGMA cache_size = -100000;

-- Set the page size to 8KB (or 16KB, depending on your data) to optimize disk reads/writes
PRAGMA page_size = 8192;

-- Enable foreign key constraints (if needed)
PRAGMA foreign_keys = ON;

-- Set the default locking mode to NORMAL for better concurrency
PRAGMA locking_mode = NORMAL;

-- Set the default temp_store to MEMORY to store temporary data in memory for faster processing
PRAGMA temp_store = MEMORY;

-- Increase the mmap_size (Optional): Use memory-mapped I/O for certain large database
PRAGMA mmap_size = 536870912;

-- Turn on auto-vacuum to automatically reclaim space from deleted rows
PRAGMA auto_vacuum = FULL;

-- Set the number of threads SQLite should use to allow concurrent access
PRAGMA threads = 6;

-- Set the journal file size (increase this if you deal with larger transactions)
PRAGMA journal_size_limit = 134217728; -- Set to 128MB

PRAGMA max_page_count = 1000000;

PRAGMA busy_timeout = 10000;

PRAGMA cache_spill = OFF; -- Disable cache spill to avoid disk writes