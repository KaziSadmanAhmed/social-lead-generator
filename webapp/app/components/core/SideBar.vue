<template lang="pug">
  v-navigation-drawer(v-model="open" app fixed)
    v-list
      v-list-group(prepend-icon="mdi-twitter" value="true")
        template(v-slot:activator)
          v-list-item-title Twitter
        v-list-item(:to="{name: 'dashboard-twitter-post-tweet'}" link nuxt)
          v-list-item-icon
            v-icon mdi-text-box-plus-outline
          v-list-item-content
            v-list-item-title Post Tweet
        v-list-item(:to="{name: 'dashboard-twitter-list-tweet'}" link nuxt)
          v-list-item-icon
            v-icon mdi-text-box-multiple-outline
          v-list-item-content
            v-list-item-title List Tweets
</template>

<script>
export default {
  data: () => ({}),
  computed: {
    open: {
      get() {
        return this.$store.getters['dashboard/getIsSidebarOpen']
      },
      set(value) {
        this.$store.commit('dashboard/setIsSidebarOpen', value)
      }
    }
  }
}
</script>
