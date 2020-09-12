import createPersistedState from 'vuex-persistedstate'
import * as Cookies from 'js-cookie'

export default ({ store }) => {
  createPersistedState({
    key: 'social-lead-generator',
    paths: ['auth'],
    storage: {
      getItem: (key) => Cookies.get(key),
      setItem: (key, value) =>
        Cookies.set(key, value, {
          expires: 1,
          secure: process.env.ENV === 'prod',
          sameSite: 'strict'
        }),
      removeItem: (key) => Cookies.remove(key)
    }
  })(store)
}
