<template lang="pug">
  v-container
    TwitterConnect
    v-alert(:type="alert.type" v-model="alert.open" dismissible) {{ alert.message }}
    v-card
      v-card-title.headline.grey.lighten-2 Post a Tweet
      v-card-text
        v-container
          v-form(v-model="postTweetFormValid" ref="postTweetForm" @submit.prevent="postTweet")
            v-textarea(
              label="Message"
              v-model="tweet.text",
              placeholder="Enter a message",
              :loading="loading"
              :readonly="loading"
              :rules="[validations.required('Message')]"
              required
            )
            v-btn(type="submit" color="primary" :loading="loading" :disabled="!postTweetFormValid") Post
</template>

<script>
import validations from '@/utils/validations'
import TwitterConnect from '@/components/core/auth/twitter/TwitterConnect'

export default {
  components: {
    TwitterConnect
  },
  data: () => ({
    loading: false,
    postTweetFormValid: false,
    tweet: {
      text: ''
    },
    alert: {
      open: false,
      type: 'success',
      message: ''
    },
    validations
  }),
  methods: {
    async postTweet() {
      if (this.$refs.postTweetForm.validate()) {
        try {
          this.loading = true
          this.alert.open = false
          this.alert.type = 'success'
          this.alert.message = ''

          await this.$api
            .post('/twitter/tweets', {
              text: this.tweet.text
            })
            .then((res) => {
              if (!res.data.success) throw Error
            })

          this.alert.message = 'Successfully posted the tweet'
          this.alert.open = true
        } catch (err) {
          this.alert.message = 'Failed to post the tweet'
          this.alert.type = 'error'
          this.alert.open = true
        } finally {
          this.loading = false
        }
      }
    }
  }
}
</script>
