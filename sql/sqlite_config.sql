-- SQLite High-Performance Configuration File
-- Usage: sqlite3 your_database.db < sqlite_config.sql

/***********************[ ESSENTIAL FIRST SETTINGS ]***************************/
PRAGMA page_size = 4096; -- 16384 for HDDs, change to 4096 for SSDs
PRAGMA auto_vacuum = INCREMENTAL; -- Better for frequent modifications
PRAGMA journal_mode = WAL; -- Critical for concurrency
PRAGMA foreign_keys = ON;
-- Maintain data integrity

/***********************[ STORAGE-SPECIFIC SETTINGS ]**************************/
-- Uncomment section based on your storage type:

-- [[ HDD OPTIMIZATION ]]
-- PRAGMA synchronous = NORMAL; -- Safer for mechanical drives
-- PRAGMA journal_size_limit = 1073741824; -- 1GB WAL file limit
-- PRAGMA wal_autocheckpoint = 5000;
-- Less frequent checkpoints

-- [[ SSD OPTIMIZATION ]]
PRAGMA synchronous = OFF; -- Faster but riskier (SSDs only)
PRAGMA journal_size_limit = 268435456; -- 256MB WAL sufficient for SSDs
PRAGMA cell_size_check = OFF; -- Disable for modern SSDs
PRAGMA page_size = 4096;
-- Use 4KB page size for SSDs

/***********************[ MEMORY & PERFORMANCE ]*******************************/
PRAGMA cache_size = -250000; -- 4GB cache (250k pages * 16KB)
PRAGMA mmap_size = 2147483648; -- 2GB memory mapping
PRAGMA temp_store = MEMORY; -- Store temp data in RAM
PRAGMA busy_timeout = 60000;
-- 60s operation timeout

/***********************[ MAINTENANCE & LIMITS ]*******************************/
PRAGMA max_page_count = 1000000000; -- ~16TB max size (1B pages * 16KB)
PRAGMA secure_delete = ON; -- Faster deletes (security tradeoff)
PRAGMA automatic_index = ON; -- Manual index control
PRAGMA recursive_triggers = ON;
-- Enable complex triggers

/***********************[ INITIAL MAINTENANCE ]*********************************/
VACUUM; -- Initial database compaction
PRAGMA optimize; -- Query planner optimization
PRAGMA
analyze;
-- Statistics generation

--***********************[ CONNECTION SETTINGS ]*********************************
-- These should be set per-connection in application code:
PRAGMA cache_spill = OFF; -- Prevent spill to disk (requires ample RAM)
PRAGMA threads = 8; -- Manual thread control
PRAGMA read_uncommitted = 1;-- Reduce reader/writer contention
