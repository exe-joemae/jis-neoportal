-- Users Profile Table
CREATE TABLE user_profiles (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  username VARCHAR(50) NOT NULL UNIQUE,
  full_name VARCHAR(255) NOT NULL,
  user_role VARCHAR(20) NOT NULL CHECK (user_role IN ('student', 'teacher', 'admin')),
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Announcements Table (先生からの連絡)
CREATE TABLE announcements (
  id BIGSERIAL PRIMARY KEY,
  teacher_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  is_pinned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Messages Table (先生とのチャット)
CREATE TABLE messages (
  id BIGSERIAL PRIMARY KEY,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Suggestion Box Table (意見箱)
CREATE TABLE suggestions (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  category VARCHAR(50),
  is_anonymous BOOLEAN DEFAULT FALSE,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
  response TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Contact List Table (連絡網)
CREATE TABLE contact_list (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  phone_number VARCHAR(20),
  email VARCHAR(255),
  is_public BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Broadcast Messages Table (一斉通知)
CREATE TABLE broadcast_messages (
  id BIGSERIAL PRIMARY KEY,
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  recipient_role VARCHAR(20) CHECK (recipient_role IN ('student', 'teacher', 'admin', 'all')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Broadcast Message Recipients Table
CREATE TABLE broadcast_recipients (
  id BIGSERIAL PRIMARY KEY,
  broadcast_id BIGINT NOT NULL REFERENCES broadcast_messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  UNIQUE(broadcast_id, user_id)
);

-- Create Indexes for Performance
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_username ON user_profiles(username);
CREATE INDEX idx_announcements_teacher_id ON announcements(teacher_id);
CREATE INDEX idx_announcements_created_at ON announcements(created_at);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_suggestions_user_id ON suggestions(user_id);
CREATE INDEX idx_suggestions_status ON suggestions(status);
CREATE INDEX idx_contact_list_user_id ON contact_list(user_id);
CREATE INDEX idx_broadcast_messages_sender_id ON broadcast_messages(sender_id);
CREATE INDEX idx_broadcast_recipients_broadcast_id ON broadcast_recipients(broadcast_id);
CREATE INDEX idx_broadcast_recipients_user_id ON broadcast_recipients(user_id);

-- Enable RLS (Row Level Security)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_list ENABLE ROW LEVEL SECURITY;
ALTER TABLE broadcast_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE broadcast_recipients ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_profiles
CREATE POLICY "Users can read their own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can read public profiles"
  ON user_profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- RLS Policies for announcements
CREATE POLICY "Anyone can read announcements"
  ON announcements FOR SELECT
  USING (true);

CREATE POLICY "Teachers can create announcements"
  ON announcements FOR INSERT
  WITH CHECK (auth.uid() = teacher_id);

CREATE POLICY "Teachers can update their announcements"
  ON announcements FOR UPDATE
  USING (auth.uid() = teacher_id);

-- RLS Policies for messages
CREATE POLICY "Users can read their messages"
  ON messages FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update their messages"
  ON messages FOR UPDATE
  USING (auth.uid() = sender_id);

-- RLS Policies for suggestions
CREATE POLICY "Users can read their suggestions"
  ON suggestions FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() IN (SELECT user_id FROM user_profiles WHERE user_role = 'admin'));

CREATE POLICY "Users can create suggestions"
  ON suggestions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for contact_list
CREATE POLICY "Users can read their contact list"
  ON contact_list FOR SELECT
  USING (auth.uid() = user_id OR is_public = true);

CREATE POLICY "Users can update their contact list"
  ON contact_list FOR UPDATE
  USING (auth.uid() = user_id);

-- RLS Policies for broadcast_messages
CREATE POLICY "Teachers and admins can create broadcast"
  ON broadcast_messages FOR INSERT
  WITH CHECK (auth.uid() IN (SELECT user_id FROM user_profiles WHERE user_role IN ('teacher', 'admin')));

CREATE POLICY "Anyone can read broadcast messages"
  ON broadcast_messages FOR SELECT
  USING (true);

-- RLS Policies for broadcast_recipients
CREATE POLICY "Users can read their broadcast status"
  ON broadcast_recipients FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their broadcast read status"
  ON broadcast_recipients FOR UPDATE
  USING (auth.uid() = user_id);
