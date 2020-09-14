<template lang="pug">
  v-card.mx-auto
    v-navigation-drawer(v-model="open" app fixed)
      v-list
        v-list-group(prepend-icon="mdi-twitter" value="true")
          template(v-slot:activator)
            v-list-item-title Twitter
          v-list-item(:to="{name: 'dashboard-twitter-list-tweets'}" link nuxt)
            v-list-item-content
              v-list-item-title Personal Tweets
            v-list-item-icon
              v-icon mdi-format-list-bulleted
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
