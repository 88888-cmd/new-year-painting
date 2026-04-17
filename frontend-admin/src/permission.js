import router from './router'
import store from './store'
import { getToken } from '@/utils/auth'
import getPageTitle from '@/utils/get-page-title'

const whiteList = ['/login']

router.beforeEach(async (to, from, next) => {

  document.title = getPageTitle(to.meta.title)

  const hasToken = getToken()
  if (hasToken) {
    if (to.path === '/login') {
      next('/')
      return
    } else {
      const adminUser = store.getters.adminUser;
      if (adminUser.id == 0) {
        try {
          await store.dispatch('user/getInfo')
          next({ ...to, replace: true })
        } catch (error) {
          await store.dispatch('user/resetToken')
          next('/login')
        }
      } else {
        next()
      }
    }
  } else {
    if (whiteList.indexOf(to.path) !== -1) {
      next()
    } else {
      next('/login')
    }
  }
})