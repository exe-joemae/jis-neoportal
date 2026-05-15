'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@supabase/supabase-js'

export default function Home() {
  const [isLoggedIn, setIsLoggedIn] = useState(false)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    checkAuthStatus()
  }, [])

  const checkAuthStatus = async () => {
    try {
      const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
      const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

      if (!supabaseUrl || !supabaseAnonKey) {
        console.error('Supabase credentials not configured')
        setLoading(false)
        return
      }

      const supabase = createClient(supabaseUrl, supabaseAnonKey)
      const { data } = await supabase.auth.getSession()
      setIsLoggedIn(!!data?.session)
    } catch (error) {
      console.error('Error checking auth status:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p className="text-lg">読み込み中...</p>
      </div>
    )
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-16">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            JIS NeoPotal
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            学校連絡網・チャット・意見箱プラットフォーム
          </p>
          <p className="text-gray-500 mb-12">
            セットアップ中です。ログインページをご準備しています。
          </p>
          {isLoggedIn ? (
            <div>
              <p className="text-green-600 font-semibold">
                ✓ ログイン状態を検出しました
              </p>
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow-md p-8 max-w-md mx-auto">
              <p className="text-gray-600 mb-4">
                現在、ログインページを準備中です。
              </p>
              <p className="text-sm text-gray-500">
                README.md をご確認ください
              </p>
            </div>
          )}
        </div>
      </div>
    </main>
  )
}
