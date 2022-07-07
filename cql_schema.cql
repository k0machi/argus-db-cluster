
CREATE KEYSPACE argus WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'}  AND durable_writes = true;

CREATE TYPE argus.cloudinstancedetails (
    provider text,
    region text,
    public_ip text,
    private_ip text,
    creation_time varint,
    termination_time varint,
    termination_reason text
);

CREATE TYPE argus.cloudinstancedetails_v2 (
    provider text,
    region text,
    public_ip text,
    private_ip text,
    creation_time varint,
    termination_time varint,
    termination_reason text,
    shards_amount varint
);

CREATE TYPE argus.cloudinstancedetails_v3 (
    provider text,
    region text,
    public_ip text,
    private_ip text,
    creation_time varint,
    termination_time varint,
    termination_reason text,
    shards_amount varint
);

CREATE TYPE argus.cloudnodesinfo (
    image_id text,
    instance_type text,
    node_amount varint,
    post_behaviour text
);

CREATE TYPE argus.cloudresource (
    name text,
    state text,
    instance_info frozen<cloudinstancedetails>
);

CREATE TYPE argus.cloudresource_v2 (
    name text,
    state text,
    instance_info frozen<cloudinstancedetails_v2>
);

CREATE TYPE argus.cloudresource_v3 (
    name text,
    state text,
    resource_type text,
    instance_info frozen<cloudinstancedetails_v3>
);

CREATE TYPE argus.cloudsetupdetails (
    db_node frozen<cloudnodesinfo>,
    loader_node frozen<cloudnodesinfo>,
    monitor_node frozen<cloudnodesinfo>,
    backend text
);

CREATE TYPE argus.eventsbyseverity (
    severity text,
    event_amount varint,
    last_events list<text>
);

CREATE TYPE argus.nodedescription (
    name text,
    ip text,
    shards varint
);

CREATE TYPE argus.nemesisruninfo (
    class_name text,
    name text,
    duration varint,
    target_node frozen<nodedescription>,
    status text,
    start_time varint,
    end_time varint,
    stack_trace text
);

CREATE TYPE argus.packageversion (
    name text,
    version text,
    date text,
    revision_id text
);

CREATE TYPE argus.packageversion_v2 (
    name text,
    version text,
    date text,
    revision_id text,
    build_id text
);

CREATE TYPE argus.web_run_comment (
    user_id uuid,
    timestamp int,
    message text,
    mentions list<uuid>
);

CREATE TABLE argus.web_category_group (
    id uuid PRIMARY KEY,
    description text,
    name text,
    pretty_name text
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs (
    id uuid,
    release_name text,
    name text,
    group text,
    assignee text,
    start_time varint,
    allocated_resources list<frozen<cloudresource>>,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    heartbeat varint,
    leftover_resources list<frozen<cloudresource>>,
    logs list<frozen<tuple<text, text>>>,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion>>,
    region_name list<text>,
    scm_revision_id text,
    sct_runner_host frozen<cloudinstancedetails>,
    started_by text,
    status text,
    terminated_resources list<frozen<cloudresource>>,
    yaml_test_duration varint,
    PRIMARY KEY (id, release_name, name, group, assignee, start_time)
) WITH CLUSTERING ORDER BY (release_name ASC, name ASC, group ASC, assignee ASC, start_time ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_release_name_idx ON argus.test_runs (release_name);
CREATE INDEX test_runs_group_idx ON argus.test_runs (group);
CREATE INDEX test_runs_name_idx ON argus.test_runs (name);
CREATE INDEX test_runs_status_idx ON argus.test_runs (status);
CREATE INDEX test_runs_assignee_idx ON argus.test_runs (assignee);

CREATE MATERIALIZED VIEW argus.test_runs_name_idx_index AS
    SELECT name, idx_token, id, release_name, group, assignee, start_time
    FROM argus.test_runs
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id, release_name, group, assignee, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC, release_name ASC, group ASC, assignee ASC, start_time ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_group_idx_index AS
    SELECT group, idx_token, id, release_name, name, assignee, start_time
    FROM argus.test_runs
    WHERE group IS NOT NULL
    PRIMARY KEY (group, idx_token, id, release_name, name, assignee, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC, release_name ASC, name ASC, assignee ASC, start_time ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_release_name_idx_index AS
    SELECT release_name, idx_token, id, name, group, assignee, start_time
    FROM argus.test_runs
    WHERE release_name IS NOT NULL
    PRIMARY KEY (release_name, idx_token, id, name, group, assignee, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC, name ASC, group ASC, assignee ASC, start_time ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_assignee_idx_index AS
    SELECT assignee, idx_token, id, release_name, name, group, start_time
    FROM argus.test_runs
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, id, release_name, name, group, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC, release_name ASC, name ASC, group ASC, start_time ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_status_idx_index AS
    SELECT status, idx_token, id, release_name, name, group, assignee, start_time
    FROM argus.test_runs
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, id, release_name, name, group, assignee, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC, release_name ASC, name ASC, group ASC, assignee ASC, start_time ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_test_v2 (
    test_id uuid,
    release_id uuid,
    id timeuuid,
    schedule_id timeuuid,
    PRIMARY KEY ((test_id, release_id), id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_schedule_test_v2_schedule_id_idx ON argus.argus_schedule_test_v2 (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_schedule_test_v2_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, test_id, release_id, id
    FROM argus.argus_schedule_test_v2
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, test_id, release_id, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, test_id ASC, release_id ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_test_v3 (
    test_id uuid,
    release_id uuid,
    id timeuuid,
    schedule_id timeuuid,
    PRIMARY KEY ((test_id, release_id), id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_schedule_test_v3_schedule_id_idx ON argus.argus_schedule_test_v3 (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_schedule_test_v3_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, test_id, release_id, id
    FROM argus.argus_schedule_test_v3
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, test_id, release_id, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, test_id ASC, release_id ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_group_v2 (
    group_id text,
    release_id uuid,
    id timeuuid,
    schedule_id timeuuid,
    PRIMARY KEY ((group_id, release_id), id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_schedule_group_v2_schedule_id_idx ON argus.argus_schedule_group_v2 (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_schedule_group_v2_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, group_id, release_id, id
    FROM argus.argus_schedule_group_v2
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, group_id, release_id, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, group_id ASC, release_id ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_release_schedule_group (
    name text,
    release text,
    id timeuuid,
    schedule_id timeuuid,
    PRIMARY KEY ((name, release), id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_release_schedule_group_schedule_id_idx ON argus.argus_release_schedule_group (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_release_schedule_group_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, name, release, id
    FROM argus.argus_release_schedule_group
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, name, release, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, name ASC, release ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_test_v4 (
    test_id uuid,
    release_id uuid,
    id timeuuid,
    schedule_id timeuuid,
    PRIMARY KEY ((test_id, release_id), id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_schedule_test_v4_schedule_id_idx ON argus.argus_schedule_test_v4 (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_schedule_test_v4_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, test_id, release_id, id
    FROM argus.argus_schedule_test_v4
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, test_id, release_id, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, test_id ASC, release_id ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_test_v5 (
    release_id uuid,
    test_id uuid,
    id timeuuid,
    schedule_id timeuuid,
    PRIMARY KEY (release_id, test_id, id)
) WITH CLUSTERING ORDER BY (test_id ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_schedule_test_v5_schedule_id_idx ON argus.argus_schedule_test_v5 (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_schedule_test_v5_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, release_id, test_id, id
    FROM argus.argus_schedule_test_v5
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, release_id, test_id, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, release_id ASC, test_id ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.web_file_storage (
    id uuid PRIMARY KEY,
    filename text,
    filepath text
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_event (
    id uuid PRIMARY KEY,
    body text,
    created_at timestamp,
    group_id uuid,
    kind text,
    release_id uuid,
    run_id uuid,
    test_id uuid,
    user_id uuid
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_event_user_id_idx ON argus.argus_event (user_id);
CREATE INDEX argus_event_release_id_idx ON argus.argus_event (release_id);
CREATE INDEX argus_event_kind_idx ON argus.argus_event (kind);
CREATE INDEX argus_event_run_id_idx ON argus.argus_event (run_id);
CREATE INDEX argus_event_test_id_idx ON argus.argus_event (test_id);
CREATE INDEX argus_event_group_id_idx ON argus.argus_event (group_id);

CREATE MATERIALIZED VIEW argus.argus_event_kind_idx_index AS
    SELECT kind, idx_token, id
    FROM argus.argus_event
    WHERE kind IS NOT NULL
    PRIMARY KEY (kind, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_event_user_id_idx_index AS
    SELECT user_id, idx_token, id
    FROM argus.argus_event
    WHERE user_id IS NOT NULL
    PRIMARY KEY (user_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_event_test_id_idx_index AS
    SELECT test_id, idx_token, id
    FROM argus.argus_event
    WHERE test_id IS NOT NULL
    PRIMARY KEY (test_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_event_release_id_idx_index AS
    SELECT release_id, idx_token, id
    FROM argus.argus_event
    WHERE release_id IS NOT NULL
    PRIMARY KEY (release_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_event_group_id_idx_index AS
    SELECT group_id, idx_token, id
    FROM argus.argus_event
    WHERE group_id IS NOT NULL
    PRIMARY KEY (group_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_event_run_id_idx_index AS
    SELECT run_id, idx_token, id
    FROM argus.argus_event
    WHERE run_id IS NOT NULL
    PRIMARY KEY (run_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v6 (
    id uuid PRIMARY KEY,
    allocated_resources list<frozen<cloudresource_v3>>,
    assignee text,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    group text,
    heartbeat varint,
    investigation_status text,
    logs list<frozen<tuple<text, text>>>,
    name text,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion_v2>>,
    region_name list<text>,
    release_name text,
    scm_revision_id text,
    screenshots list<text>,
    sct_runner_host frozen<cloudinstancedetails_v3>,
    start_time varint,
    started_by text,
    status text,
    yaml_test_duration varint
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_v6_assignee_idx ON argus.test_runs_v6 (assignee);
CREATE INDEX test_runs_v6_build_job_name_idx ON argus.test_runs_v6 (build_job_name);
CREATE INDEX test_runs_v6_release_name_idx ON argus.test_runs_v6 (release_name);
CREATE INDEX test_runs_v6_status_idx ON argus.test_runs_v6 (status);
CREATE INDEX test_runs_v6_group_idx ON argus.test_runs_v6 (group);
CREATE INDEX test_runs_v6_name_idx ON argus.test_runs_v6 (name);

CREATE MATERIALIZED VIEW argus.test_runs_v6_build_job_name_idx_index AS
    SELECT build_job_name, idx_token, id
    FROM argus.test_runs_v6
    WHERE build_job_name IS NOT NULL
    PRIMARY KEY (build_job_name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v6_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.test_runs_v6
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v6_release_name_idx_index AS
    SELECT release_name, idx_token, id
    FROM argus.test_runs_v6
    WHERE release_name IS NOT NULL
    PRIMARY KEY (release_name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v6_group_idx_index AS
    SELECT group, idx_token, id
    FROM argus.test_runs_v6
    WHERE group IS NOT NULL
    PRIMARY KEY (group, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v6_assignee_idx_index AS
    SELECT assignee, idx_token, id
    FROM argus.test_runs_v6
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v6_status_idx_index AS
    SELECT status, idx_token, id
    FROM argus.test_runs_v6
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v7 (
    build_id text,
    start_time timestamp,
    allocated_resources list<frozen<cloudresource_v3>>,
    assignee uuid,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time timestamp,
    events list<frozen<eventsbyseverity>>,
    group_id uuid,
    heartbeat varint,
    id uuid,
    investigation_status text,
    logs list<frozen<tuple<text, text>>>,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion_v2>>,
    region_name list<text>,
    release_id uuid,
    scm_revision_id text,
    screenshots list<text>,
    sct_runner_host frozen<cloudinstancedetails_v3>,
    started_by text,
    status text,
    test_id uuid,
    yaml_test_duration varint,
    PRIMARY KEY (build_id, start_time)
) WITH CLUSTERING ORDER BY (start_time DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_v7_group_id_idx ON argus.test_runs_v7 (group_id);
CREATE INDEX test_runs_v7_assignee_idx ON argus.test_runs_v7 (assignee);
CREATE INDEX test_runs_v7_release_id_idx ON argus.test_runs_v7 (release_id);
CREATE INDEX test_runs_v7_status_idx ON argus.test_runs_v7 (status);
CREATE INDEX test_runs_v7_id_idx ON argus.test_runs_v7 (id);
CREATE INDEX test_runs_v7_test_id_idx ON argus.test_runs_v7 (test_id);

CREATE MATERIALIZED VIEW argus.test_runs_v7_group_id_idx_index AS
    SELECT group_id, idx_token, build_id, start_time
    FROM argus.test_runs_v7
    WHERE group_id IS NOT NULL
    PRIMARY KEY (group_id, idx_token, build_id, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, build_id ASC, start_time DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v7_id_idx_index AS
    SELECT id, idx_token, build_id, start_time
    FROM argus.test_runs_v7
    WHERE id IS NOT NULL
    PRIMARY KEY (id, idx_token, build_id, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, build_id ASC, start_time DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v7_assignee_idx_index AS
    SELECT assignee, idx_token, build_id, start_time
    FROM argus.test_runs_v7
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, build_id, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, build_id ASC, start_time DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v7_release_id_idx_index AS
    SELECT release_id, idx_token, build_id, start_time
    FROM argus.test_runs_v7
    WHERE release_id IS NOT NULL
    PRIMARY KEY (release_id, idx_token, build_id, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, build_id ASC, start_time DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v7_test_id_idx_index AS
    SELECT test_id, idx_token, build_id, start_time
    FROM argus.test_runs_v7
    WHERE test_id IS NOT NULL
    PRIMARY KEY (test_id, idx_token, build_id, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, build_id ASC, start_time DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v7_status_idx_index AS
    SELECT status, idx_token, build_id, start_time
    FROM argus.test_runs_v7
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, build_id, start_time)
    WITH CLUSTERING ORDER BY (idx_token ASC, build_id ASC, start_time DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v4 (
    id uuid PRIMARY KEY,
    allocated_resources list<frozen<cloudresource_v2>>,
    assignee text,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    group text,
    heartbeat varint,
    investigation_status text,
    leftover_resources list<frozen<cloudresource_v2>>,
    logs list<frozen<tuple<text, text>>>,
    name text,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion_v2>>,
    region_name list<text>,
    release_name text,
    scm_revision_id text,
    screenshots list<text>,
    sct_runner_host frozen<cloudinstancedetails_v2>,
    start_time varint,
    started_by text,
    status text,
    terminated_resources list<frozen<cloudresource_v2>>,
    yaml_test_duration varint
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_v4_group_idx ON argus.test_runs_v4 (group);
CREATE INDEX test_runs_v4_name_idx ON argus.test_runs_v4 (name);
CREATE INDEX test_runs_v4_status_idx ON argus.test_runs_v4 (status);
CREATE INDEX test_runs_v4_assignee_idx ON argus.test_runs_v4 (assignee);
CREATE INDEX test_runs_v4_release_name_idx ON argus.test_runs_v4 (release_name);

CREATE MATERIALIZED VIEW argus.test_runs_v4_release_name_idx_index AS
    SELECT release_name, idx_token, id
    FROM argus.test_runs_v4
    WHERE release_name IS NOT NULL
    PRIMARY KEY (release_name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v4_status_idx_index AS
    SELECT status, idx_token, id
    FROM argus.test_runs_v4
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v4_assignee_idx_index AS
    SELECT assignee, idx_token, id
    FROM argus.test_runs_v4
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v4_group_idx_index AS
    SELECT group, idx_token, id
    FROM argus.test_runs_v4
    WHERE group IS NOT NULL
    PRIMARY KEY (group, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v4_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.test_runs_v4
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v3_screenshots_support (
    id uuid PRIMARY KEY,
    allocated_resources list<frozen<cloudresource>>,
    assignee text,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    group text,
    heartbeat varint,
    leftover_resources list<frozen<cloudresource>>,
    logs list<frozen<tuple<text, text>>>,
    name text,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion_v2>>,
    region_name list<text>,
    release_name text,
    scm_revision_id text,
    screenshots list<text>,
    sct_runner_host frozen<cloudinstancedetails>,
    start_time varint,
    started_by text,
    status text,
    terminated_resources list<frozen<cloudresource>>,
    yaml_test_duration varint
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_v3_screenshots_support_group_idx ON argus.test_runs_v3_screenshots_support (group);
CREATE INDEX test_runs_v3_screenshots_support_release_name_idx ON argus.test_runs_v3_screenshots_support (release_name);
CREATE INDEX test_runs_v3_screenshots_support_name_idx ON argus.test_runs_v3_screenshots_support (name);
CREATE INDEX test_runs_v3_screenshots_support_assignee_idx ON argus.test_runs_v3_screenshots_support (assignee);
CREATE INDEX test_runs_v3_screenshots_support_status_idx ON argus.test_runs_v3_screenshots_support (status);

CREATE MATERIALIZED VIEW argus.test_runs_v3_screenshots_support_assignee_idx_index AS
    SELECT assignee, idx_token, id
    FROM argus.test_runs_v3_screenshots_support
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_screenshots_support_group_idx_index AS
    SELECT group, idx_token, id
    FROM argus.test_runs_v3_screenshots_support
    WHERE group IS NOT NULL
    PRIMARY KEY (group, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_screenshots_support_release_name_idx_index AS
    SELECT release_name, idx_token, id
    FROM argus.test_runs_v3_screenshots_support
    WHERE release_name IS NOT NULL
    PRIMARY KEY (release_name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_screenshots_support_status_idx_index AS
    SELECT status, idx_token, id
    FROM argus.test_runs_v3_screenshots_support
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_screenshots_support_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.test_runs_v3_screenshots_support
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v2 (
    id uuid PRIMARY KEY,
    allocated_resources list<frozen<cloudresource>>,
    assignee text,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    group text,
    heartbeat varint,
    leftover_resources list<frozen<cloudresource>>,
    logs list<frozen<tuple<text, text>>>,
    name text,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion>>,
    region_name list<text>,
    release_name text,
    scm_revision_id text,
    sct_runner_host frozen<cloudinstancedetails>,
    start_time varint,
    started_by text,
    status text,
    terminated_resources list<frozen<cloudresource>>,
    yaml_test_duration varint
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_v2_group_idx ON argus.test_runs_v2 (group);
CREATE INDEX test_runs_v2_assignee_idx ON argus.test_runs_v2 (assignee);
CREATE INDEX test_runs_v2_name_idx ON argus.test_runs_v2 (name);
CREATE INDEX test_runs_v2_release_name_idx ON argus.test_runs_v2 (release_name);
CREATE INDEX test_runs_v2_status_idx ON argus.test_runs_v2 (status);

CREATE MATERIALIZED VIEW argus.test_runs_v2_group_idx_index AS
    SELECT group, idx_token, id
    FROM argus.test_runs_v2
    WHERE group IS NOT NULL
    PRIMARY KEY (group, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v2_release_name_idx_index AS
    SELECT release_name, idx_token, id
    FROM argus.test_runs_v2
    WHERE release_name IS NOT NULL
    PRIMARY KEY (release_name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v2_assignee_idx_index AS
    SELECT assignee, idx_token, id
    FROM argus.test_runs_v2
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v2_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.test_runs_v2
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v2_status_idx_index AS
    SELECT status, idx_token, id
    FROM argus.test_runs_v2
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v3 (
    id uuid PRIMARY KEY,
    allocated_resources list<frozen<cloudresource>>,
    assignee text,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    group text,
    heartbeat varint,
    leftover_resources list<frozen<cloudresource>>,
    logs list<frozen<tuple<text, text>>>,
    name text,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion_v2>>,
    region_name list<text>,
    release_name text,
    scm_revision_id text,
    sct_runner_host frozen<cloudinstancedetails>,
    start_time varint,
    started_by text,
    status text,
    terminated_resources list<frozen<cloudresource>>,
    yaml_test_duration varint
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_v3_name_idx ON argus.test_runs_v3 (name);
CREATE INDEX test_runs_v3_status_idx ON argus.test_runs_v3 (status);
CREATE INDEX test_runs_v3_release_name_idx ON argus.test_runs_v3 (release_name);
CREATE INDEX test_runs_v3_group_idx ON argus.test_runs_v3 (group);
CREATE INDEX test_runs_v3_assignee_idx ON argus.test_runs_v3 (assignee);

CREATE MATERIALIZED VIEW argus.test_runs_v3_group_idx_index AS
    SELECT group, idx_token, id
    FROM argus.test_runs_v3
    WHERE group IS NOT NULL
    PRIMARY KEY (group, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_status_idx_index AS
    SELECT status, idx_token, id
    FROM argus.test_runs_v3
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_assignee_idx_index AS
    SELECT assignee, idx_token, id
    FROM argus.test_runs_v3
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_release_name_idx_index AS
    SELECT release_name, idx_token, id
    FROM argus.test_runs_v3
    WHERE release_name IS NOT NULL
    PRIMARY KEY (release_name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.test_runs_v3
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.web_run_comments (
    test_id uuid PRIMARY KEY,
    comments list<frozen<web_run_comment>>
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v3_shards_amount (
    id uuid PRIMARY KEY,
    allocated_resources list<frozen<cloudresource_v2>>,
    assignee text,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    group text,
    heartbeat varint,
    leftover_resources list<frozen<cloudresource_v2>>,
    logs list<frozen<tuple<text, text>>>,
    name text,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion_v2>>,
    region_name list<text>,
    release_name text,
    scm_revision_id text,
    sct_runner_host frozen<cloudinstancedetails_v2>,
    start_time varint,
    started_by text,
    status text,
    terminated_resources list<frozen<cloudresource_v2>>,
    yaml_test_duration varint
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_v3_shards_amount_release_name_idx ON argus.test_runs_v3_shards_amount (release_name);
CREATE INDEX test_runs_v3_shards_amount_group_idx ON argus.test_runs_v3_shards_amount (group);
CREATE INDEX test_runs_v3_shards_amount_assignee_idx ON argus.test_runs_v3_shards_amount (assignee);
CREATE INDEX test_runs_v3_shards_amount_status_idx ON argus.test_runs_v3_shards_amount (status);
CREATE INDEX test_runs_v3_shards_amount_name_idx ON argus.test_runs_v3_shards_amount (name);

CREATE MATERIALIZED VIEW argus.test_runs_v3_shards_amount_assignee_idx_index AS
    SELECT assignee, idx_token, id
    FROM argus.test_runs_v3_shards_amount
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_shards_amount_release_name_idx_index AS
    SELECT release_name, idx_token, id
    FROM argus.test_runs_v3_shards_amount
    WHERE release_name IS NOT NULL
    PRIMARY KEY (release_name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_shards_amount_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.test_runs_v3_shards_amount
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_shards_amount_group_idx_index AS
    SELECT group, idx_token, id
    FROM argus.test_runs_v3_shards_amount
    WHERE group IS NOT NULL
    PRIMARY KEY (group, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_shards_amount_status_idx_index AS
    SELECT status, idx_token, id
    FROM argus.test_runs_v3_shards_amount
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_planner_comment_v2 (
    release uuid,
    group uuid,
    test uuid,
    comment text,
    PRIMARY KEY (release, group, test)
) WITH CLUSTERING ORDER BY (group ASC, test ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_group_v2 (
    id uuid PRIMARY KEY,
    assignee list<uuid>,
    build_system_id text,
    description text,
    enabled boolean,
    name text,
    pretty_name text,
    release_id uuid
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_group_v2_name_idx ON argus.argus_group_v2 (name);
CREATE INDEX argus_group_v2_release_id_idx ON argus.argus_group_v2 (release_id);

CREATE MATERIALIZED VIEW argus.argus_group_v2_release_id_idx_index AS
    SELECT release_id, idx_token, id
    FROM argus.argus_group_v2
    WHERE release_id IS NOT NULL
    PRIMARY KEY (release_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_group_v2_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.argus_group_v2
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_user_v3 (
    assignee uuid,
    id timeuuid,
    release_id uuid,
    schedule_id timeuuid,
    PRIMARY KEY (assignee, id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_schedule_user_v3_schedule_id_idx ON argus.argus_schedule_user_v3 (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_schedule_user_v3_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, assignee, id
    FROM argus.argus_schedule_user_v3
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, assignee, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, assignee ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_user_v2 (
    assignee uuid,
    id timeuuid,
    release_id uuid,
    schedule_id timeuuid,
    PRIMARY KEY (assignee, id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_schedule_user_v2_schedule_id_idx ON argus.argus_schedule_user_v2 (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_schedule_user_v2_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, assignee, id
    FROM argus.argus_schedule_user_v2
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, assignee, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, assignee ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_test_v2 (
    id uuid PRIMARY KEY,
    assignee list<uuid>,
    build_system_id text,
    build_system_url text,
    description text,
    enabled boolean,
    group_id uuid,
    name text,
    pretty_name text,
    "primary" boolean,
    release_id uuid
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_test_v2_group_id_idx ON argus.argus_test_v2 (group_id);
CREATE INDEX argus_test_v2_release_id_idx ON argus.argus_test_v2 (release_id);
CREATE INDEX argus_test_v2_name_idx ON argus.argus_test_v2 (name);
CREATE INDEX argus_test_v2_build_system_id_idx ON argus.argus_test_v2 (build_system_id);

CREATE MATERIALIZED VIEW argus.argus_test_v2_release_id_idx_index AS
    SELECT release_id, idx_token, id
    FROM argus.argus_test_v2
    WHERE release_id IS NOT NULL
    PRIMARY KEY (release_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_test_v2_build_system_id_idx_index AS
    SELECT build_system_id, idx_token, id
    FROM argus.argus_test_v2
    WHERE build_system_id IS NOT NULL
    PRIMARY KEY (build_system_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_test_v2_group_id_idx_index AS
    SELECT group_id, idx_token, id
    FROM argus.argus_test_v2
    WHERE group_id IS NOT NULL
    PRIMARY KEY (group_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_test_v2_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.argus_test_v2
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v4_resource_tracking (
    id uuid PRIMARY KEY,
    allocated_resources list<frozen<cloudresource_v3>>,
    assignee text,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    group text,
    heartbeat varint,
    investigation_status text,
    logs list<frozen<tuple<text, text>>>,
    name text,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion_v2>>,
    region_name list<text>,
    release_name text,
    scm_revision_id text,
    screenshots list<text>,
    sct_runner_host frozen<cloudinstancedetails_v3>,
    start_time varint,
    started_by text,
    status text,
    yaml_test_duration varint
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_planned_tests_for_release (
    id uuid PRIMARY KEY,
    group_id uuid,
    release_id uuid,
    test_id uuid
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_planned_tests_for_release_group_id_idx ON argus.argus_planned_tests_for_release (group_id);
CREATE INDEX argus_planned_tests_for_release_release_id_idx ON argus.argus_planned_tests_for_release (release_id);
CREATE INDEX argus_planned_tests_for_release_test_id_idx ON argus.argus_planned_tests_for_release (test_id);

CREATE MATERIALIZED VIEW argus.argus_planned_tests_for_release_test_id_idx_index AS
    SELECT test_id, idx_token, id
    FROM argus.argus_planned_tests_for_release
    WHERE test_id IS NOT NULL
    PRIMARY KEY (test_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_planned_tests_for_release_release_id_idx_index AS
    SELECT release_id, idx_token, id
    FROM argus.argus_planned_tests_for_release
    WHERE release_id IS NOT NULL
    PRIMARY KEY (release_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_planned_tests_for_release_group_id_idx_index AS
    SELECT group_id, idx_token, id
    FROM argus.argus_planned_tests_for_release
    WHERE group_id IS NOT NULL
    PRIMARY KEY (group_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_release_schedule_assignee (
    assignee uuid,
    id timeuuid,
    release text,
    schedule_id timeuuid,
    PRIMARY KEY (assignee, id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_release_schedule_assignee_schedule_id_idx ON argus.argus_release_schedule_assignee (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_release_schedule_assignee_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, assignee, id
    FROM argus.argus_release_schedule_assignee
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, assignee, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, assignee ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v3_investigation_status (
    id uuid PRIMARY KEY,
    allocated_resources list<frozen<cloudresource>>,
    assignee text,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    group text,
    heartbeat varint,
    investigation_status text,
    leftover_resources list<frozen<cloudresource>>,
    logs list<frozen<tuple<text, text>>>,
    name text,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion_v2>>,
    region_name list<text>,
    release_name text,
    scm_revision_id text,
    sct_runner_host frozen<cloudinstancedetails>,
    start_time varint,
    started_by text,
    status text,
    terminated_resources list<frozen<cloudresource>>,
    yaml_test_duration varint
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_v3_investigation_status_assignee_idx ON argus.test_runs_v3_investigation_status (assignee);
CREATE INDEX test_runs_v3_investigation_status_status_idx ON argus.test_runs_v3_investigation_status (status);
CREATE INDEX test_runs_v3_investigation_status_release_name_idx ON argus.test_runs_v3_investigation_status (release_name);
CREATE INDEX test_runs_v3_investigation_status_group_idx ON argus.test_runs_v3_investigation_status (group);
CREATE INDEX test_runs_v3_investigation_status_name_idx ON argus.test_runs_v3_investigation_status (name);

CREATE MATERIALIZED VIEW argus.test_runs_v3_investigation_status_release_name_idx_index AS
    SELECT release_name, idx_token, id
    FROM argus.test_runs_v3_investigation_status
    WHERE release_name IS NOT NULL
    PRIMARY KEY (release_name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_investigation_status_assignee_idx_index AS
    SELECT assignee, idx_token, id
    FROM argus.test_runs_v3_investigation_status
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_investigation_status_status_idx_index AS
    SELECT status, idx_token, id
    FROM argus.test_runs_v3_investigation_status
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_investigation_status_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.test_runs_v3_investigation_status
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v3_investigation_status_group_idx_index AS
    SELECT group, idx_token, id
    FROM argus.test_runs_v3_investigation_status
    WHERE group IS NOT NULL
    PRIMARY KEY (group, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.release_planner_comment (
    release text,
    group text,
    test text,
    comment text,
    PRIMARY KEY (release, group, test)
) WITH CLUSTERING ORDER BY (group ASC, test ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_release_group_test (
    id uuid PRIMARY KEY,
    assignee list<uuid>,
    description text,
    group_id uuid,
    kind text,
    name text,
    pretty_name text,
    release_id uuid
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_release_group_test_release_id_idx ON argus.argus_release_group_test (release_id);
CREATE INDEX argus_release_group_test_name_idx ON argus.argus_release_group_test (name);
CREATE INDEX argus_release_group_test_group_id_idx ON argus.argus_release_group_test (group_id);
CREATE INDEX argus_release_group_test_kind_idx ON argus.argus_release_group_test (kind);

CREATE MATERIALIZED VIEW argus.argus_release_group_test_kind_idx_index AS
    SELECT kind, idx_token, id
    FROM argus.argus_release_group_test
    WHERE kind IS NOT NULL
    PRIMARY KEY (kind, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_release_group_test_group_id_idx_index AS
    SELECT group_id, idx_token, id
    FROM argus.argus_release_group_test
    WHERE group_id IS NOT NULL
    PRIMARY KEY (group_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_release_group_test_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.argus_release_group_test
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_release_group_test_release_id_idx_index AS
    SELECT release_id, idx_token, id
    FROM argus.argus_release_group_test
    WHERE release_id IS NOT NULL
    PRIMARY KEY (release_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.test_runs_v5 (
    id uuid PRIMARY KEY,
    allocated_resources list<frozen<cloudresource_v3>>,
    assignee text,
    build_job_name text,
    build_job_url text,
    cloud_setup frozen<cloudsetupdetails>,
    config_files list<text>,
    end_time varint,
    events list<frozen<eventsbyseverity>>,
    group text,
    heartbeat varint,
    investigation_status text,
    logs list<frozen<tuple<text, text>>>,
    name text,
    nemesis_data list<frozen<nemesisruninfo>>,
    packages list<frozen<packageversion_v2>>,
    region_name list<text>,
    release_name text,
    scm_revision_id text,
    screenshots list<text>,
    sct_runner_host frozen<cloudinstancedetails_v3>,
    start_time varint,
    started_by text,
    status text,
    yaml_test_duration varint
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX test_runs_v5_group_idx ON argus.test_runs_v5 (group);
CREATE INDEX test_runs_v5_release_name_idx ON argus.test_runs_v5 (release_name);
CREATE INDEX test_runs_v5_name_idx ON argus.test_runs_v5 (name);
CREATE INDEX test_runs_v5_assignee_idx ON argus.test_runs_v5 (assignee);
CREATE INDEX test_runs_v5_status_idx ON argus.test_runs_v5 (status);

CREATE MATERIALIZED VIEW argus.test_runs_v5_assignee_idx_index AS
    SELECT assignee, idx_token, id
    FROM argus.test_runs_v5
    WHERE assignee IS NOT NULL
    PRIMARY KEY (assignee, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v5_group_idx_index AS
    SELECT group, idx_token, id
    FROM argus.test_runs_v5
    WHERE group IS NOT NULL
    PRIMARY KEY (group, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v5_release_name_idx_index AS
    SELECT release_name, idx_token, id
    FROM argus.test_runs_v5
    WHERE release_name IS NOT NULL
    PRIMARY KEY (release_name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v5_status_idx_index AS
    SELECT status, idx_token, id
    FROM argus.test_runs_v5
    WHERE status IS NOT NULL
    PRIMARY KEY (status, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.test_runs_v5_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.test_runs_v5
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.user (
    id uuid PRIMARY KEY,
    email text,
    full_name text,
    password text,
    picture_id uuid,
    registration_date timestamp,
    roles list<text>,
    username text
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX user_email_idx ON argus.user (email);
CREATE INDEX user_username_idx ON argus.user (username);

CREATE MATERIALIZED VIEW argus.user_email_idx_index AS
    SELECT email, idx_token, id
    FROM argus.user
    WHERE email IS NOT NULL
    PRIMARY KEY (email, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.user_username_idx_index AS
    SELECT username, idx_token, id
    FROM argus.user
    WHERE username IS NOT NULL
    PRIMARY KEY (username, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_test_run_comment (
    id uuid,
    posted_at int,
    mentions list<uuid>,
    message text,
    reactions map<text, int>,
    release_id uuid,
    test_run_id uuid,
    user_id uuid,
    PRIMARY KEY (id, posted_at)
) WITH CLUSTERING ORDER BY (posted_at DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_test_run_comment_test_run_id_idx ON argus.argus_test_run_comment (test_run_id);
CREATE INDEX argus_test_run_comment_release_id_idx ON argus.argus_test_run_comment (release_id);
CREATE INDEX argus_test_run_comment_user_id_idx ON argus.argus_test_run_comment (user_id);

CREATE MATERIALIZED VIEW argus.argus_test_run_comment_release_id_idx_index AS
    SELECT release_id, idx_token, id, posted_at
    FROM argus.argus_test_run_comment
    WHERE release_id IS NOT NULL
    PRIMARY KEY (release_id, idx_token, id, posted_at)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC, posted_at DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_test_run_comment_user_id_idx_index AS
    SELECT user_id, idx_token, id, posted_at
    FROM argus.argus_test_run_comment
    WHERE user_id IS NOT NULL
    PRIMARY KEY (user_id, idx_token, id, posted_at)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC, posted_at DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_test_run_comment_test_run_id_idx_index AS
    SELECT test_run_id, idx_token, id, posted_at
    FROM argus.argus_test_run_comment
    WHERE test_run_id IS NOT NULL
    PRIMARY KEY (test_run_id, idx_token, id, posted_at)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC, posted_at DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_release_schedule (
    release text,
    schedule_id timeuuid,
    period_end timestamp,
    period_start timestamp,
    tag text,
    PRIMARY KEY (release, schedule_id)
) WITH CLUSTERING ORDER BY (schedule_id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.web_release (
    id uuid PRIMARY KEY,
    description text,
    name text,
    picture_id uuid,
    pretty_name text
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_release_v2 (
    id uuid PRIMARY KEY,
    assignee list<uuid>,
    description text,
    dormant boolean,
    enabled boolean,
    github_repo_url text,
    name text,
    perpetual boolean,
    picture_id uuid,
    pretty_name text
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_release_v2_name_idx ON argus.argus_release_v2 (name);

CREATE MATERIALIZED VIEW argus.argus_release_v2_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.argus_release_v2
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_v2 (
    release_id uuid,
    id timeuuid,
    period_end timestamp,
    period_start timestamp,
    tag text,
    PRIMARY KEY (release_id, id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_v3 (
    release_id uuid,
    id timeuuid,
    period_end timestamp,
    period_start timestamp,
    tag text,
    PRIMARY KEY (release_id, id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_github_issue (
    id uuid PRIMARY KEY,
    added_on timestamp,
    group_id uuid,
    issue_number int,
    last_status text,
    owner text,
    release_id uuid,
    repo text,
    run_id uuid,
    test_id uuid,
    title text,
    type text,
    url text,
    user_id uuid
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_github_issue_release_id_idx ON argus.argus_github_issue (release_id);
CREATE INDEX argus_github_issue_test_id_idx ON argus.argus_github_issue (test_id);
CREATE INDEX argus_github_issue_group_id_idx ON argus.argus_github_issue (group_id);
CREATE INDEX argus_github_issue_user_id_idx ON argus.argus_github_issue (user_id);
CREATE INDEX argus_github_issue_run_id_idx ON argus.argus_github_issue (run_id);

CREATE MATERIALIZED VIEW argus.argus_github_issue_test_id_idx_index AS
    SELECT test_id, idx_token, id
    FROM argus.argus_github_issue
    WHERE test_id IS NOT NULL
    PRIMARY KEY (test_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_github_issue_run_id_idx_index AS
    SELECT run_id, idx_token, id
    FROM argus.argus_github_issue
    WHERE run_id IS NOT NULL
    PRIMARY KEY (run_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_github_issue_release_id_idx_index AS
    SELECT release_id, idx_token, id
    FROM argus.argus_github_issue
    WHERE release_id IS NOT NULL
    PRIMARY KEY (release_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_github_issue_group_id_idx_index AS
    SELECT group_id, idx_token, id
    FROM argus.argus_github_issue
    WHERE group_id IS NOT NULL
    PRIMARY KEY (group_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_github_issue_user_id_idx_index AS
    SELECT user_id, idx_token, id
    FROM argus.argus_github_issue
    WHERE user_id IS NOT NULL
    PRIMARY KEY (user_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_notification (
    receiver uuid,
    id timeuuid,
    content text,
    sender uuid,
    source_id uuid,
    source_type text,
    state smallint,
    title text,
    type text,
    PRIMARY KEY (receiver, id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.user_oauth_token (
    id uuid PRIMARY KEY,
    kind text,
    "token" text,
    user_id uuid
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX user_oauth_token_kind_idx ON argus.user_oauth_token (kind);
CREATE INDEX user_oauth_token_user_id_idx ON argus.user_oauth_token (user_id);

CREATE MATERIALIZED VIEW argus.user_oauth_token_kind_idx_index AS
    SELECT kind, idx_token, id
    FROM argus.user_oauth_token
    WHERE kind IS NOT NULL
    PRIMARY KEY (kind, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.user_oauth_token_user_id_idx_index AS
    SELECT user_id, idx_token, id
    FROM argus.user_oauth_token
    WHERE user_id IS NOT NULL
    PRIMARY KEY (user_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_release (
    id uuid PRIMARY KEY,
    assignee list<uuid>,
    description text,
    enabled boolean,
    github_repo_url text,
    name text,
    picture_id uuid,
    pretty_name text
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_release_name_idx ON argus.argus_release (name);

CREATE MATERIALIZED VIEW argus.argus_release_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.argus_release
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.web_nemesis (
    id uuid PRIMARY KEY,
    description text,
    name text,
    pretty_name text
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_release_schedule_test (
    name text,
    release text,
    id timeuuid,
    schedule_id timeuuid,
    PRIMARY KEY ((name, release), id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_release_schedule_test_schedule_id_idx ON argus.argus_release_schedule_test (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_release_schedule_test_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, name, release, id
    FROM argus.argus_release_schedule_test
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, name, release, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, name ASC, release ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_v4 (
    release_id uuid,
    id timeuuid,
    period_end timestamp,
    period_start timestamp,
    tag text,
    PRIMARY KEY (release_id, id, period_end)
) WITH CLUSTERING ORDER BY (id DESC, period_end DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_release_group (
    id uuid PRIMARY KEY,
    assignee list<uuid>,
    description text,
    kind text,
    name text,
    pretty_name text,
    release_id uuid
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_release_group_name_idx ON argus.argus_release_group (name);
CREATE INDEX argus_release_group_release_id_idx ON argus.argus_release_group (release_id);
CREATE INDEX argus_release_group_kind_idx ON argus.argus_release_group (kind);

CREATE MATERIALIZED VIEW argus.argus_release_group_kind_idx_index AS
    SELECT kind, idx_token, id
    FROM argus.argus_release_group
    WHERE kind IS NOT NULL
    PRIMARY KEY (kind, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_release_group_release_id_idx_index AS
    SELECT release_id, idx_token, id
    FROM argus.argus_release_group
    WHERE release_id IS NOT NULL
    PRIMARY KEY (release_id, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE MATERIALIZED VIEW argus.argus_release_group_name_idx_index AS
    SELECT name, idx_token, id
    FROM argus.argus_release_group
    WHERE name IS NOT NULL
    PRIMARY KEY (name, idx_token, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, id ASC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

CREATE TABLE argus.argus_schedule_group_v3 (
    group_id uuid,
    release_id uuid,
    id timeuuid,
    schedule_id timeuuid,
    PRIMARY KEY ((group_id, release_id), id)
) WITH CLUSTERING ORDER BY (id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';
CREATE INDEX argus_schedule_group_v3_schedule_id_idx ON argus.argus_schedule_group_v3 (schedule_id);

CREATE MATERIALIZED VIEW argus.argus_schedule_group_v3_schedule_id_idx_index AS
    SELECT schedule_id, idx_token, group_id, release_id, id
    FROM argus.argus_schedule_group_v3
    WHERE schedule_id IS NOT NULL
    PRIMARY KEY (schedule_id, idx_token, group_id, release_id, id)
    WITH CLUSTERING ORDER BY (idx_token ASC, group_id ASC, release_id ASC, id DESC)
    AND bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'}
    AND comment = ''
    AND compaction = {'class': 'SizeTieredCompactionStrategy'}
    AND compression = {'sstable_compression': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND dclocal_read_repair_chance = 0.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND read_repair_chance = 0.0
    AND speculative_retry = '99.0PERCENTILE';

