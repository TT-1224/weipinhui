import http from '@ohos.net.http'
import { StorageUtil } from './StorageUtil'
import { ToastUtil } from './ToastUtil'

export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE'

export interface ApiResp<T> {
  code: number
  msg: string
  data: T
}

export interface HttpOptions {
  method: HttpMethod
  path: string
  query?: Record<string, string | number | boolean>
  body?: object | string
  headers?: Record<string, string>
  showLoading?: boolean
  loadingText?: string
  hideToast?: boolean
  cache?: boolean
  cacheTime?: number
}

interface CacheItem<T> {
  data: T
  timestamp: number
}

interface CacheData {
  data: Object
  timestamp: number
}

const BASE_URL: string = 'http://10.219.33.47:8080'
const DEFAULT_CACHE_TIME: number = 5 * 60 * 1000

class CacheManager {
  private static cache: Map<string, CacheData> = new Map()

  static get<T>(key: string, cacheTime: number = DEFAULT_CACHE_TIME): T | null {
    const item = CacheManager.cache.get(key)
    if (!item) return null

    const now = Date.now()
    if (now - item.timestamp > cacheTime) {
      CacheManager.cache.delete(key)
      return null
    }

    return item.data as T
  }

  static set<T>(key: string, data: T): void {
    const cacheData: CacheData = {
      data: data as Object,
      timestamp: Date.now()
    }
    CacheManager.cache.set(key, cacheData)
  }

  static delete(key: string): void {
    CacheManager.cache.delete(key)
  }

  static clear(): void {
    CacheManager.cache.clear()
  }

  static size(): number {
    return CacheManager.cache.size
  }
}

function buildQuery(query?: Record<string, string | number | boolean>): string {
  if (!query) return ''
  const keys: string[] = Object.keys(query)
  if (keys.length === 0) return ''
  const parts: string[] = []
  keys.forEach((k: string) => {
    const v = query[k]
    const vs: string = encodeURIComponent(String(v))
    parts.push(`${encodeURIComponent(k)}=${vs}`)
  })
  return `?${parts.join('&')}`
}

export class HttpUtil {
  private static setLoading(show: boolean, text?: string): void {
    AppStorage.setOrCreate('global_loading', false)
    AppStorage.setOrCreate('global_loading_text', '')
    AppStorage.set('global_loading', show)
    AppStorage.set('global_loading_text', text ?? '')
  }

  private static handleError(e: Object, hideToast: boolean): Error {
    console.error('❌ 请求异常:', JSON.stringify(e))

    if (e instanceof Error) {
      const message: string = e.message

      if (message.startsWith('API_')) {
        if (!hideToast) {
          ToastUtil.error('服务端错误')
        }
        return e
      }

      if (message.startsWith('HTTP_')) {
        const statusCode = message.replace('HTTP_', '')
        if (!hideToast) {
          ToastUtil.error(`网络错误(${statusCode})`)
        }
        return e
      }

      if (message === 'PARSE_ERROR') {
        if (!hideToast) {
          ToastUtil.error('响应解析失败')
        }
        return e
      }

      if (message === 'EMPTY_RESPONSE') {
        if (!hideToast) {
          ToastUtil.warning('空响应')
        }
        return e
      }

      if (!hideToast) {
        ToastUtil.error('请求失败，请检查网络')
      }
      return e
    }

    if (!hideToast) {
      ToastUtil.error('未知错误')
    }
    return new Error('UNKNOWN_ERROR')
  }

  static async request<T>(opt: HttpOptions): Promise<T> {
    const showLoading: boolean = opt.showLoading !== false
    const hideToast: boolean = opt.hideToast === true
    const useCache: boolean = opt.cache === true
    const cacheTime: number = opt.cacheTime || DEFAULT_CACHE_TIME

    if (showLoading) {
      HttpUtil.setLoading(true, opt.loadingText ?? '加载中…')
    }

    const token: string = await StorageUtil.getToken()
    const url: string = `${BASE_URL}${opt.path}${buildQuery(opt.query)}`
    const cacheKey: string = `${opt.method}:${url}`

    if (useCache && opt.method === 'GET') {
      const cachedData = CacheManager.get<T>(cacheKey, cacheTime)
      if (cachedData !== null) {
        if (showLoading) {
          HttpUtil.setLoading(false)
        }
        console.info('✅ 使用缓存:', cacheKey)
        return cachedData
      }
    }

    const header: Record<string, string> = {
      'Content-Type': 'application/json'
    }
    if (token) {
      header['Authorization'] = `Bearer ${token}`
    }
    if (opt.headers) {
      Object.keys(opt.headers).forEach((k: string) => {
        header[k] = opt.headers![k]
      })
    }

    const client = http.createHttp()
    try {
      console.info('✅ 请求URL:', url)
      console.info('✅ 请求头:', JSON.stringify(header))
      console.info('✅ 请求体:', JSON.stringify(opt.body))

      const res = await client.request(url, {
        method: HttpUtil.convertMethod(opt.method),
        header: header,
        extraData: opt.body ? (typeof opt.body === 'string' ? opt.body : JSON.stringify(opt.body)) : undefined,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 15000,
        readTimeout: 15000
      })

      const status: number = res.responseCode
      const raw: string = res.result as string

      console.info('✅ 响应状态:', status)
      console.info('✅ 响应内容:', raw)

      if (status < 200 || status >= 300) {
        throw new Error(`HTTP_${status}`)
      }

      let parsed: ApiResp<T> | undefined = undefined
      try {
        parsed = JSON.parse(raw) as ApiResp<T>
      } catch (e) {
        throw new Error('PARSE_ERROR')
      }

      if (!parsed) {
        throw new Error('EMPTY_RESPONSE')
      }

      if (parsed.code !== 0) {
        if (parsed.code === 401) {
          if (!hideToast) {
            ToastUtil.warning('登录已过期，请重新登录')
          }
          StorageUtil.clearAuth()
        } else {
          if (!hideToast) {
            ToastUtil.error(parsed.msg || '请求失败')
          }
        }
        throw new Error(`API_${parsed.code}`)
      }

      if (useCache && opt.method === 'GET') {
        CacheManager.set(cacheKey, parsed.data)
        console.info('✅ 缓存数据:', cacheKey)
      }

      return parsed.data
    } catch (e) {
      const error = HttpUtil.handleError(e as Object, hideToast)
      throw error
    } finally {
      client.destroy()
      if (showLoading) {
        HttpUtil.setLoading(false)
      }
    }
  }

  private static convertMethod(method: HttpMethod): http.RequestMethod {
    switch (method) {
      case 'GET': return http.RequestMethod.GET
      case 'POST': return http.RequestMethod.POST
      case 'PUT': return http.RequestMethod.PUT
      case 'DELETE': return http.RequestMethod.DELETE
      default: return http.RequestMethod.GET
    }
  }

  static get<T>(path: string, query?: Record<string, string | number | boolean>, showLoading: boolean = true, cache: boolean = false): Promise<T> {
    const o: HttpOptions = {
      method: 'GET',
      path: path,
      query: query,
      showLoading: showLoading,
      cache: cache
    }
    return HttpUtil.request<T>(o)
  }

  static post<T>(path: string, body?: object | string, showLoading: boolean = true): Promise<T> {
    const o: HttpOptions = {
      method: 'POST',
      path: path,
      body: body,
      showLoading: showLoading
    }
    return HttpUtil.request<T>(o)
  }

  static put<T>(path: string, body?: object | string, showLoading: boolean = true): Promise<T> {
    const o: HttpOptions = {
      method: 'PUT',
      path: path,
      body: body,
      showLoading: showLoading
    }
    return HttpUtil.request<T>(o)
  }

  static delete<T>(path: string, body?: object | string, showLoading: boolean = true): Promise<T> {
    const o: HttpOptions = {
      method: 'DELETE',
      path: path,
      body: body,
      showLoading: showLoading
    }
    return HttpUtil.request<T>(o)
  }

  static clearCache(): void {
    CacheManager.clear()
  }

  static getCacheSize(): number {
    return CacheManager.size()
  }

  static async saveToken(token: string): Promise<void> {
    await StorageUtil.setToken(token)
  }

  static async isLoggedIn(): Promise<boolean> {
    const token: string = await StorageUtil.getToken()
    return token !== null && token.length > 0
  }
}

export default HttpUtil