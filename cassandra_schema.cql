 // create the keyspace 
CREATE KEYSPACE IF NOT EXISTS oauth WITH REPLICATION = {'class':'SimpleStrategy', 'replication_factor':1};
// and the table
CREATE TABLE IF NOT EXISTS oauth.access_tokens(access_token varchar PRIMARY KEY, user_id bigint, client_id bigint, expires bigint);