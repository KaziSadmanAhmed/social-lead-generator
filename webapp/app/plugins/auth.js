import Auth from '@/utils/auth'

export default ({ store }, inject) => {
  const auth = new Auth({
    store
  })
  inject('auth', auth)
}
