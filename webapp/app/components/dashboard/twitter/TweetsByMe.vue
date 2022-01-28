<template lang="pug">
  v-row
    v-col(cols=12 v-if="tweets.length")
      Chart(:chartData="chartData")
    v-col(cols=12 sm=6 lg=4 xl=3 v-for="tweet in tweets" :key="tweet.id")
      TweetCard(:tweet="tweet")
</template>

<script>
import TweetCard from '@/components/dashboard/twitter/partials/TweetCard'
import Chart from '@/components/Chart'

export default {
  components: {
    TweetCard,
    Chart
  },
  data: () => ({
    tweets: []
  }),
  computed: {
    chartData() {
      const retweetCountArr = []
      const favoriteCountArr = []
      const xTickLabelsArr = []

      this.tweets.forEach((tweet) => {
        retweetCountArr.push(tweet.retweet_count)
        favoriteCountArr.push(tweet.favorite_count)
        xTickLabelsArr.push(
          new Date(tweet.created_at).toLocaleString('en-US', {
            dateStyle: 'medium',
            timeStyle: 'medium'
          })
        )
      })

      return {
        series: [
          {
            name: 'Retweets',
            data: retweetCountArr
          },
          {
            name: 'Favorites',
            data: favoriteCountArr
          }
        ],
        xTickLabels: xTickLabelsArr,
        colors: ['#27bd68', '#f44336']
      }
    }
  },
  created() {
    this.fetchTweets()
  },
  methods: {
    async fetchTweets() {
      try {
        this.tweets = await this.$api
          .get('twitter/tweets')
          .then((res) => res.data.tweets)
      } catch (err) {}
    }
  }
}
</script>
