<template lang="pug">
  v-container.align-self-start
    TwitterConnect

    v-tabs(v-model="tab")
      v-tab Tweets by me
      v-tab Tweets by others

    v-tabs-items(v-model="tab")
      v-tab-item
        TweetsByMe
      v-tab-item
        TweetsByOthers
</template>

<script>
import TwitterConnect from '@/components/core/auth/twitter/TwitterConnect'
import TweetsByMe from '@/components/dashboard/twitter/TweetsByMe'
import TweetsByOthers from '@/components/dashboard/twitter/TweetsByOthers'

export default {
  components: {
    TwitterConnect,
    TweetsByMe,
    TweetsByOthers
  },
  data: () => ({
    tab: ''
  })
}
</script>
