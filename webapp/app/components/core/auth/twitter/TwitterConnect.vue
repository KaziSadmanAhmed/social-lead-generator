<template lang="pug">
  v-overlay(v-if="!$auth.user.twitter_access_token" absolute)
    v-btn(color="#00acee" large @click="connect()" :loading="loading" :disabled="loading")
      v-icon(left) mdi-twitter
      | Connect twitter
</template>

<script>
export default {
  data: () => ({
    auth: {
      url: ''
    },
    loading: false
  }),
  methods: {
    async connect() {
      try {
        this.loading = true
        const res = await this.$axios
          .get('/auth/twitter/connect')
          .then((res) => res.data)

        window.location.href = res.authorization.url
      } catch (err) {
      } finally {
        this.loading = false
      }
    }
  }
}
</script>
