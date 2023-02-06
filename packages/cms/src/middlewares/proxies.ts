import type { Context, Next } from 'koa'

export default () => async (ctx: Context, next: Next) => {
  if (ctx.method.match(/get/i)) {
    try {
      ctx.url = '/index.html'
      ctx.body = strapi.middlewares['strapi::public'](ctx)
    } catch (e) {
      strapi.log.error(`[proxy] Failed to parse url: ${e?.message}`)
    }
  }
  return await next()
}
