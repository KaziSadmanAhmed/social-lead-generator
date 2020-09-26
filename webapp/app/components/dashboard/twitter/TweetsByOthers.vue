<template lang="pug">
  v-row

    v-col(cols=12)
      v-form(@submit.prevent="fetchTweets")
        v-row(align="end")
          v-col(cols=11 sm=8 md=6 lg=5)
            v-autocomplete(v-model="user" return-object :search-input.sync="q" :items="users" :item-text="searchUserText" item-value="id" label="Name" placeholder="Search by Twitter user's name" clearable :loading="loadingSearchUser" prepend-icon="mdi-account-search" hide-details hide-no-data)
              template(v-slot:item="data")
                v-list-item-avatar(left)
                  v-img(:src="data.item.profile_image_url")
                v-list-item-content
                  v-list-item-title {{ data.item.name }}
                  v-list-item-subtitle.caption @{{ data.item.screen_name }}

          v-col(cols=1)
            v-btn(type="submit" color="primary" :loading="loadingListTweets" :readonly="loadingListTweets" :disabled="!user") Get Tweets

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
    loadingSearchUser: false,
    loadingListTweets: false,
    q: null,
    awaitingSearch: false,
    user: null,
    users: [],
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
  watch: {
    q(val) {
      if (val) {
        if (!this.awaitingSearch) {
          setTimeout(() => {
            this.searchUsers()
            this.awaitingSearch = false
          }, 1000)
        }
        this.awaitingSearch = true
      }
    }
  },
  methods: {
    searchUserText(user) {
      return `${user.name} (@${user.screen_name})`
    },
    async searchUsers() {
      try {
        this.loadingSearchUser = true
        this.users = await this.$axios
          .get('twitter/users', {
            params: { q: this.q }
          })
          .then((res) => res.data.users)
      } catch (err) {
      } finally {
        this.loadingSearchUser = false
      }
    },
    async fetchTweets() {
      try {
        this.loadingListTweets = true
        this.tweets = await this.$axios
          .get(`twitter/users/${this.user.id}/tweets`)
          .then((res) => res.data.tweets)
      } catch (err) {
      } finally {
        this.loadingListTweets = false
      }
    }
  }
}
</script>
