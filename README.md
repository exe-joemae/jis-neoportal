# JIS NeoPotal - 学校連絡網プラットフォーム

学校連絡網、先生とのチャット、意見箱をまとめたポータルアプリケーション

## 🚀 機能概要

### 主な機能
- **👥 ユーザー管理**: 生徒、先生、管理者の3つの役割
- **📢 連絡網**: 一斉通知機能
- **💬 チャット**: 先生とのダイレクトメッセージ
- **📰 お知らせ**: 先生からの連絡・アナウンスメント
- **💡 意見箱**: 匿名での提案・意見投稿
- **🔔 リアルタイム更新**: Supabase Realtime を使用

## 🛠 技術スタック

- **フロントエンド**: Next.js 14+ (React 18)
- **スタイリング**: Tailwind CSS
- **バックエンド/データベース**: Supabase (PostgreSQL)
- **認証**: Supabase Auth (ユーザー名 + パスワード)
- **リアルタイム**: Supabase Realtime
- **デプロイ**: Railway
- **言語**: TypeScript

## 📋 プロジェクト構成

```
jis-neoportal/
├── app/                        # Next.js App Router
│   ├── layout.tsx             # Root layout
│   ├── page.tsx               # Home page
│   ├── globals.css            # Global styles
│   ├── (auth)/                # Auth routes
│   │   ├── login/
│   │   └── signup/
│   ├── (dashboard)/           # Dashboard routes
│   │   ├── announcements/
│   │   ├── messages/
│   │   ├── suggestions/
│   │   └── contacts/
│   └── api/                   # API routes (optional)
├── lib/                       # Utility functions
│   ├── supabase.ts           # Supabase client
│   └── auth.ts               # Auth utilities
├── components/               # React components
│   ├── Navbar.tsx
│   ├── Sidebar.tsx
│   └── ...
├── supabase/                # Database
│   └── migrations/
│       └── 001_initial_schema.sql
├── public/                  # Static files
├── package.json
├── tsconfig.json
├── next.config.js
├── tailwind.config.ts
├── postcss.config.js
├── railway.json            # Railway deployment config
└── README.md
```

## ⚙️ セットアップ手順

### 前提条件
- Node.js 18+ (GitHub Codespaces に含まれる)
- Supabase アカウント (無料)
- Railway アカウント (デプロイ用)

### 1. リポジトリのクローン

```bash
git clone https://github.com/exe-joemae/jis-neoportal.git
cd jis-neoportal
```

### 2. 依存パッケージのインストール

```bash
npm install
```

### 3. Supabase セットアップ

#### 3.1 Supabase プロジェクト作成
1. [Supabase](https://supabase.com) にログイン
2. 新しいプロジェクトを作成
3. プロジェクト URL と Anon Key をメモ

#### 3.2 データベーススキーマ適用
1. Supabase ダッシュボードの SQL Editor を開く
2. `supabase/migrations/001_initial_schema.sql` の内容をコピー
3. 実行

#### 3.3 環境変数設定

`.env.local` ファイルを作成：

```bash
cp .env.example .env.local
```

以下の値を入力：

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

### 4. 開発サーバー起動

```bash
npm run dev
```

ブラウザで `http://localhost:3000` を開く

### 5. Railway へのデプロイ

#### 5.1 Railway CLI インストール（Codespaces の場合）

```bash
npm i -g @railway/cli
```

#### 5.2 Railway ログイン

```bash
railway login
```

#### 5.3 プロジェクト初期化

```bash
railway init
```

#### 5.4 環境変数設定

```bash
railway variables set NEXT_PUBLIC_SUPABASE_URL=your_url
railway variables set NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key
railway variables set SUPABASE_SERVICE_ROLE_KEY=your_key
```

#### 5.5 デプロイ

```bash
railway up
```

## 📚 ユーザー認証フロー

### ログイン方式: ユーザー名 + パスワード

```
ユーザー名: username
↓ (内部で username@jis-neoportal.local に変換)
↓
Supabase Auth でメール + パスワードで認証
↓
user_profiles テーブルからユーザー情報取得
```

### 新規登録フロー

1. ユーザーが以下を入力:
   - ユーザー名
   - パスワード
   - フルネーム
   - ユーザー役割 (学生/先生/管理者)

2. 内部処理:
   - Supabase Auth に登録
   - user_profiles テーブルに情報保存

## 🗄️ データベーススキーマ

### テーブル一覧

| テーブル名 | 説明 |
|-----------|------|
| `user_profiles` | ユーザープロフィール |
| `announcements` | 先生からの連絡 |
| `messages` | メッセージ（チャット） |
| `suggestions` | 意見箱 |
| `contact_list` | 連絡網 |
| `broadcast_messages` | 一斉通知 |
| `broadcast_recipients` | 一斉通知の受け取り状態 |

詳細は `supabase/migrations/001_initial_schema.sql` を参照

## 🔐 Row Level Security (RLS)

すべてのテーブルで RLS を有効化しており、ユーザーは自分のデータのみアクセス可能：

- ユーザーは自分のプロフィールを編集可能
- 先生が作成したお知らせは全員が閲覧可能
- メッセージは送受信者のみ閲覧可能
- 意見箱は投稿者と管理者のみ閲覧可能

## 🔄 リアルタイム更新

Supabase Realtime を使用し、以下をリアルタイムで更新：

- 新しいメッセージ受信時
- 新しいお知らせ配信時
- 意見箱の返信時

## 📱 GitHub Codespaces での開発

### 起動方法

1. このリポジトリを開く
2. `<> Code` → `Codespaces` → `Create codespace on main` をクリック
3. VS Code Web が起動
4. ターミナルで以下を実行：

```bash
npm install
npm run dev
```

5. ポップアップで「Open in Browser」をクリック

### 利点

- Linux は不要（Codespaces が提供）
- Node.js が事前インストール
- Chromebook で完全な開発環境が実現
- 無料で月 120 時間まで使用可能

## 🚀 次のステップ

以下の順で実装を進めるを推奨：

1. ✅ **プロジェクト初期化** (完了)
2. 📝 **ログイン・登録ページ実装**
3. 🏠 **ダッシュボードレイアウト**
4. 📢 **お知らせ機能**
5. 💬 **チャット機能**
6. 💡 **意見箱機能**
7. 👥 **連絡網機能**
8. 🔔 **リアルタイム更新実装**
9. 🚀 **Railway へのデプロイ**
10. 🎨 **UI/UX 改善**

## 🤝 貢献

プルリクエストを歓迎します！

## 📝 ライセンス

MIT License

## 💬 サポート

不明な点やバグがある場合は、GitHub Issues を作成してください。

---

**Happy Coding! 🎉**
