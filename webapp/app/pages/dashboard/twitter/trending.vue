<template lang="pug">
  v-row
    TwitterConnect

    v-col(cols=12)
      v-form(@submit.prevent="fetchTopics")
        v-row(align="end")

          v-col(cols=11 sm=8 md=6 lg=5)
            v-autocomplete(label="Location/Place" v-model="location" return-object :search-input.sync="q" :items="locations" :item-text="locationText" item-value="woeid" placeholder="Search by City, State or Country" clearable :loading="loadingLocations" prepend-icon="mdi-map-marker" hide-details hide-no-data)
              template(v-slot:item="{ parent, item }")
                v-list-item-content
                  v-list-item-title(v-html="parent.genFilteredText(locationText(item))")
                  v-list-item-subtitle.caption(v-html="item.location_type")

          v-col(cols=1)
            v-btn(type="submit" color="primary" :loading="loadingTopics" :readonly="loadingTopics" :disabled="!location") Get Topics

    v-col(cols=12)
      v-row(justify="center")
        v-badge.mr-8.my-2(v-for="topic in topics" :key="topic.name" :content="topic.tweets_count | kFormatter" :value="topic.tweets_count" overlap)
          v-chip(v-html="topic.name" color="primary" outlined :href="topic.url" target="_blank")


</template>

<script>
import TwitterConnect from '@/components/core/auth/twitter/TwitterConnect'

export default {
  components: {
    TwitterConnect
  },
  filters: {
    kFormatter(num) {
      const absNum = Math.abs(num)
      const signNum = Math.sign(num)

      if (absNum > 999 && absNum < 1000000)
        return signNum * (absNum / 1000).toFixed(0) + 'K'
      else if (absNum > 1000000)
        return signNum * (absNum / 1000000).toFixed(0) + 'M'
      else return Math.sign(num) * Math.abs(num)
    }
  },
  data: () => ({
    q: null,
    loadingLocations: false,
    loadingTopics: false,
    locations: [],
    location: null,
    topics: []
  }),
  created() {
    this.getLocations()
  },
  methods: {
    async getLocations() {
      try {
        this.loadingLocations = true
        this.locations = await this.$api
          .get('/twitter/trending/locations')
          .then((res) => res.data.locations)
      } catch (err) {
      } finally {
        this.loadingLocations = false
      }
    },
    locationText(location) {
      return [
        location.name,
        location.country &&
          location.country_code &&
          `${location.country} (${location.country_code})`
      ]
        .filter((x) => x)
        .join(', ')
    },
    async fetchTopics() {
      try {
        this.loadingTopics = true
        this.topics = await this.$api
          .post('/twitter/trending/topics', {
            woeid: this.location.woeid
          })
          .then((res) => res.data.topics)
      } catch (err) {
      } finally {
        this.loadingTopics = false
      }
    }
  }
}
</script>
