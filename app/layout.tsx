import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'JIS NeoPotal - 学校連絡網プラットフォーム',
  description: '学校連絡網、先生とのチャット、意見箱をまとめたプラットフォーム',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  )
}
