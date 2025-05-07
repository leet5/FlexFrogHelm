-- Users table: stores unique Telegram users
CREATE TABLE users
(
    id        BIGINT PRIMARY KEY,
    name      TEXT  NOT NULL UNIQUE CHECK (char_length(name) > 0),
    thumbnail BYTEA NOT NULL
);

-- Chats table: stores unique Telegram chat IDs and chat data
CREATE TABLE chats
(
    id         BIGINT PRIMARY KEY,
    title      TEXT  NOT NULL CHECK (char_length(title) > 0),
    username   TEXT,
    thumbnail  BYTEA NOT NULL,
    watched    BOOLEAN DEFAULT FALSE,
    is_private BOOLEAN DEFAULT FALSE
);

-- UsersChats table: many-to-many relationship between users and chats
CREATE TABLE users_chats
(
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    chat_id BIGINT NOT NULL REFERENCES chats (id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, chat_id)
);

-- Images table: stores image data, referencing messages
CREATE TABLE images
(
    id         BIGSERIAL PRIMARY KEY,
    data       BYTEA       NOT NULL,
    thumbnail  BYTEA       NOT NULL,
    message_id BIGINT      NOT NULL,
    user_id    BIGINT      NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    chat_id    BIGINT      NOT NULL REFERENCES chats (id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tags table: stores unique tags
CREATE TABLE tags
(
    id   BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE CHECK (char_length(name) > 0)
);

-- ImagesTags table: many-to-many relationship between images and tags
CREATE TABLE images_tags
(
    image_id BIGINT NOT NULL REFERENCES images (id) ON DELETE CASCADE,
    tag_id   BIGINT NOT NULL REFERENCES tags (id) ON DELETE CASCADE,
    PRIMARY KEY (image_id, tag_id)
);

-- Index for recent images: speeds up queries for images created in the last month
CREATE INDEX idx_images_recent_created_at
    ON images (created_at)
    WHERE created_at > now() - interval '1 month';

-- Already implied by PRIMARY KEY
CREATE INDEX idx_images_user_id ON images (user_id);
CREATE INDEX idx_images_chat_id ON images (chat_id);
CREATE INDEX idx_images_tags_image_id ON images_tags (image_id);
CREATE INDEX idx_images_tags_tag_id ON images_tags (tag_id);
CREATE INDEX idx_tags_name ON tags (name);