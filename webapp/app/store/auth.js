export const state = () => ({
  user: {},
  session: {}
})

export const getters = {
  getUser: (state) => state.user,
  getSession: (state) => state.session
}

export const mutations = {
  setUser: (state, user) => (state.user = user),
  setSession: (state, session) => (state.session = session)
}
