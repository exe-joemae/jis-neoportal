import { supabase } from './supabase'

export interface LoginCredentials {
  username: string
  password: string
}

export interface SignUpData extends LoginCredentials {
  userRole: 'student' | 'teacher' | 'admin'
  fullName: string
}

/**
 * ユーザー名でログイン
 */
export async function loginWithUsername(credentials: LoginCredentials) {
  try {
    // ユーザー名をメールアドレスのように扱う（Supabase Auth対応）
    const email = `${credentials.username}@jis-neoportal.local`
    
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password: credentials.password,
    })

    if (error) throw error
    return { data, error: null }
  } catch (error) {
    return { data: null, error }
  }
}

/**
 * 新規ユーザー登録
 */
export async function signUpWithUsername(signUpData: SignUpData) {
  try {
    const email = `${signUpData.username}@jis-neoportal.local`

    // Supabase Authにユーザーを登録
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password: signUpData.password,
    })

    if (authError) throw authError

    if (authData.user) {
      // ユーザープロフィールテーブルにデータを挿入
      const { error: profileError } = await supabase
        .from('user_profiles')
        .insert([
          {
            user_id: authData.user.id,
            username: signUpData.username,
            full_name: signUpData.fullName,
            user_role: signUpData.userRole,
          },
        ])

      if (profileError) throw profileError
    }

    return { data: authData, error: null }
  } catch (error) {
    return { data: null, error }
  }
}

/**
 * ログアウト
 */
export async function logout() {
  const { error } = await supabase.auth.signOut()
  return { error }
}

/**
 * 現在のセッション取得
 */
export async function getSession() {
  const { data } = await supabase.auth.getSession()
  return data.session
}

/**
 * ユーザープロフィール取得
 */
export async function getUserProfile(userId: string) {
  const { data, error } = await supabase
    .from('user_profiles')
    .select('*')
    .eq('user_id', userId)
    .single()

  return { data, error }
}
