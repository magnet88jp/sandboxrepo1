-- create new table
--
CREATE TABLE test_case (
        id          SERIAL PRIMARY KEY,
        name        TEXT,
        filename    TEXT,
        tags        TEXT,
        explanation TEXT
);
CREATE TABLE test_command (
        id          SERIAL PRIMARY KEY,
        command     TEXT,
        target      TEXT,
        value       TEXT
);
CREATE TABLE test_suite (
        id          SERIAL PRIMARY KEY,
        name        TEXT,
        filename    TEXT,
        tags        TEXT,
        explanation TEXT
);
CREATE TABLE suite_case_map (
        id          SERIAL PRIMARY KEY,
        test_suite_id   INTEGER REFERENCES test_suite (id),
        test_case_id    INTEGER REFERENCES test_case (id),
        map_order   INTEGER
);
CREATE TABLE case_command_map (
        id          SERIAL PRIMARY KEY,
        test_case_id    INTEGER REFERENCES test_case (id),
        test_command_id INTEGER REFERENCES test_command (id),
        map_order   INTEGER
);
---
--- read sample data
---
INSERT INTO test_case (name, filename, tags, explanation) VALUES ('Case A-1','aaa.txt','[セミナー][受講票]','セミナー受講票のテストケース');
INSERT INTO test_case (name, filename, tags, explanation ) VALUES ('Case A-2','aab.txt','[セミナー]','テストケース２');
INSERT INTO test_case (name, filename, tags, explanation ) VALUES ('Case A-3','aac.txt','[セミナー]','テストケース３');
INSERT INTO test_case (name, filename, tags, explanation ) VALUES ('Case A-4','aad.txt','','テストケース４');
INSERT INTO test_case (name, filename, tags, explanation ) VALUES ('Case A-5','aae.txt','[セミナー][管理者]','セミナー管理者のテストケース');

INSERT INTO test_command (command, target, value) VALUES ('open', '/home','');
INSERT INTO test_command (command, target, value) VALUES ('type', 'name','aaa');
INSERT INTO test_command (command, target, value) VALUES ('open', '/user','');

INSERT INTO test_case (name, filename, tags, explanation ) VALUES ('Case A-5','aae.txt','[セミナー][管理者]','セミナー管理者のテストケース');
INSERT INTO test_suite (name, filename, tags, explanation ) VALUES ('Mail Test','s1.html', '[normal]','メールスイート');
INSERT INTO test_suite (name, filename, tags, explanation ) VALUES ('Normal Test','s1.html', '[normal]','通常スイート');
INSERT INTO test_suite (name, filename, tags, explanation ) VALUES ('Common Test','s1.html', '[normal]','一般スイート');

INSERT INTO suite_case_map (test_suite_id, test_case_id, map_order) VALUES (1, 1, 1);
INSERT INTO suite_case_map (test_suite_id, test_case_id, map_order) VALUES (2, 1, 1);
INSERT INTO suite_case_map (test_suite_id, test_case_id, map_order) VALUES (2, 2, 2);

INSERT INTO case_command_map (test_case_id, test_command_id, map_order) VALUES (1, 1, 1);
INSERT INTO case_command_map (test_case_id, test_command_id, map_order) VALUES (1, 2, 2);
INSERT INTO case_command_map (test_case_id, test_command_id, map_order) VALUES (2, 2, 1);

