<template lang="pug">
  v-container.align-self-start
    TwitterConnect

    v-row
      v-col(cols=12 sm=6 md=4 lg=6 xl=4 v-for="tweet in tweets" :key="tweet.id" align="center")

        v-card.fill-height(max-width=400 align="start")
          v-card-text.headline(style="min-height: 80px;") {{ tweet.text }}

          v-card-actions.pb-0
            v-list-item.grow(two-line)
              v-list-item-avatar(color="grey darken-3")
                v-img.elevation-6(:src="tweet.user.profile_image_url")

              v-list-item-content
                v-list-item-title {{ tweet.user.name }}
                v-list-item-subtitle.grey--text @{{ tweet.user.screen_name }}

          v-card-actions.pt-0
            v-list-item

              v-list-item-content
                v-list-item-subtitle.grey--text {{ tweet.created_at }}

              v-row.pr-4(align="center" justify="end")
                v-icon.mr-1 mdi-heart
                span.subheading.mr-2 {{ tweet.favorite_count }}
                v-icon.mr-1(style="font-size: 32px") mdi-twitter-retweet
                span.subheading {{ tweet.retweet_count }}
</template>

<script>
import TwitterConnect from '@/components/core/auth/twitter/TwitterConnect'

export default {
  components: {
    TwitterConnect
  },
  data: () => ({
    tweets: []
  }),
  created() {
    this.fetchTweets()
  },
  methods: {
    async fetchTweets() {
      try {
        this.tweets = await this.$axios
          .get('twitter/tweet/list')
          .then((res) => res.data.tweet_list)
      } catch (err) {}
    }
  }
}
</script>
