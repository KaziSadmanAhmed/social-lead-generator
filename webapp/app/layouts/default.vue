<template lang="pug">
  v-app
    NavBar(@toggleSidebar="toggleSidebar")
    v-content
      nuxt

</template>

<script>
import NavBar from '@/components/core/NavBar'

export default {
  components: {
    NavBar
  },
  data() {
    return {}
  },
  methods: {
    toggleSidebar() {
      const isSidebarOpen = this.$store.getters['dashboard/getIsSidebarOpen']
      this.$store.commit('dashboard/setIsSidebarOpen', !isSidebarOpen)
    }
  }
}
</script>
