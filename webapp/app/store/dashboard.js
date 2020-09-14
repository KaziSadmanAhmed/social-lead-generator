export const state = () => ({
  isSidebarOpen: false
})

export const getters = {
  getIsSidebarOpen: (state) => state.isSidebarOpen
}

export const mutations = {
  setIsSidebarOpen: (state, isSidebarOpen) =>
    (state.isSidebarOpen = isSidebarOpen)
}
