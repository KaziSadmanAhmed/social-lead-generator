<template lang="pug">
  v-container.fill-height
    v-alert(v-if="alert" :type="alertType" dismissible) {{ alertMsg }}
    v-row(justify="center")
      v-progress-circular(indeterminate color="grey lighten-1" size=50)
</template>

<script>
export default {
  data: () => ({
    alert: false,
    alertType: '',
    alertMsg: ''
  }),
  async created() {
    await this.callback()
    await this.$auth.fetchUser()
    setTimeout(() => {
      this.$router.push({ name: 'dashboard' })
    }, 1000)
  },
  methods: {
    async callback() {
      try {
        const res = await this.$axios
          .post('/auth/twitter/callback', {
            oauth_token: this.$route.query.oauth_token,
            oauth_verifier: this.$route.query.oauth_verifier
          })
          .then((res) => res.data)

        this.alert = true
        if (res.success) {
          this.alertType = 'success'
          this.alertMsg =
            'Successfully connected to Twitter. Redirecting to Dashboard...'
        } else {
          this.alertType = 'error'
          this.alertMsg =
            'Failed to connect to Twitter. Redirecting to Dashboard...'
        }
      } catch (err) {
        this.alertType = 'error'
        this.alertMsg =
          'Failed to connect to Twitter. Redirecting to Dashboard...'
      }
    }
  }
}
</script>
